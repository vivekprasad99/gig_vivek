import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/data/image_sync_state.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/data/local/database/upload_entity_ho/upload_entity_ho.dart';
import '../../../../../core/data/local/repository/upload_entry/upload_entry_local_repository.dart';
import '../../../../../core/di/app_injection_container.dart';
import '../../../../../core/exception/exception.dart';
import '../../../../../core/utils/app_log.dart';
import '../../../../../core/utils/file_utils.dart';
import '../../../../../execution_in_house/data/model/lead_entity.dart';
import '../../../../../execution_in_house/data/repository/lead/lead_remote_repository.dart';
import '../../../../../file_storage_remote/data/model/aws_upload_result.dart';
import '../../../../cubit/aw_questions_cubit.dart';
import '../../../../cubit/upload_or_sync_process_cubit/upload_or_sync_process_cubit.dart';
import '../../../../data/model/row/screen_row.dart';
import '../../../../data/model/upload_or_sync/upload_status.dart';

part 'async_image_input_state.dart';

class AsyncImageInputCubit extends Cubit<AsyncImageInputState> {
  final UploadEntryLocalRepository _uploadEntryLocalRepository;
  final LeadRemoteRepository _leadRemoteRepository;

  final _imageSyncStatus =
      BehaviorSubject<ImageSyncStatus>.seeded(ImageSyncStatus());

  Stream<ImageSyncStatus> get imageSyncStatus => _imageSyncStatus.stream;

  Function(ImageSyncStatus) get changeImageSyncStatus =>
      _imageSyncStatus.sink.add;

  final _isOptionsExpanded = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isOptionsExpanded => _isOptionsExpanded.stream;

  Function(bool) get changeIsOptionsExpanded => _isOptionsExpanded.sink.add;

  int totalFileSize = 0;

  AsyncImageInputCubit(
      this._uploadEntryLocalRepository,
      this._leadRemoteRepository
      ) : super(AsyncImageInputInitial());

  @override
  Future<void> close() {
    _imageSyncStatus.close();
    _isOptionsExpanded.close();
    return super.close();
  }

  Future<void> calculateTotalFileSized(ImageDetails imageDetails) async {
    File file = imageDetails.getFile()!;
    totalFileSize = await FileUtils.getFileSizeInBytes(file.path, 2);
  }

  checkDBAndUpdateQuestionList(Question question) {
    if (question.hasAnswered(isCheckImageDetails: true)) {
      UploadEntityHO? uploadEntityHO =
          _uploadEntryLocalRepository.getUploadEntityHO(
              uploadEntityHOKey:
                  question.answerUnit?.imageDetails?.uploadEntityHOKey);
      question.answerUnit?.imageDetails = uploadEntityHO?.getImageDetails();

      if (uploadEntityHO != null) {
        if (uploadEntityHO.isUploading ?? false) {
          changeImageSyncStatus(ImageSyncStatus(
              imageSyncState: ImageSyncState.uploading,
              data: question.answerUnit!.imageDetails!));
        } else {
          if (uploadEntityHO.isPaused ?? false) {
            changeImageSyncStatus(ImageSyncStatus(
                imageSyncState: ImageSyncState.paused,
                data: question.answerUnit!.imageDetails!));
            return;
          }
          switch (UploadStatus.get(uploadEntityHO.uploadStatus)) {
            case UploadStatus.syncFailed:
            case UploadStatus.uploadFailed:
            changeImageSyncStatus(ImageSyncStatus(
                imageSyncState: ImageSyncState.failed,
                data: question.answerUnit!.imageDetails!));
              break;
            case UploadStatus.synced:
              changeImageSyncStatus(ImageSyncStatus(
                  imageSyncState: ImageSyncState.uploaded,
                  data: question.answerUnit!.imageDetails!));
              break;
            case UploadStatus.uploadedNotSynced:
              changeImageSyncStatus(ImageSyncStatus(
                  imageSyncState: ImageSyncState.syncing,
                  data: question.answerUnit!.imageDetails!));
              break;
            case UploadStatus.uploadNotStarted:
              changeImageSyncStatus(ImageSyncStatus(
                  imageSyncState: ImageSyncState.queued,
                  data: question.answerUnit!.imageDetails!));
              break;
            default:
              break;
          }
        }
      }
    }
  }

  void resumeUploading(Question question) {
    UploadEntityHO? uploadEntityHO =
        _uploadEntryLocalRepository.getUploadEntityHO(
            uploadEntityHOKey:
                question.answerUnit?.imageDetails?.uploadEntityHOKey);
    if (uploadEntityHO != null) {
      uploadEntityHO.isPaused = false;
      uploadEntityHO.save();

      /// Start image uploading
      sl<UploadOrSyncProcessCubit>().start();
    }
  }

  Future<void> insertImageAndStartUploading(ImageDetails imageDetails) async {
    await calculateTotalFileSized(imageDetails);
    await _uploadEntryLocalRepository.upsertEntity(imageDetails);

    /// Start image uploading
    sl<UploadOrSyncProcessCubit>().start();
  }

  Future upload(Question question, ImageDetails imageDetails,
      Function(Question question) onAnswerUpdate) async {
    if (imageDetails.uploadLater && imageDetails.isUploadLaterSelected) {
      changeImageSyncStatus(ImageSyncStatus(
          imageSyncState: ImageSyncState.paused, data: imageDetails));
      return;
    }
    if (imageDetails.getFile() == null) {
      return;
    }
    changeImageSyncStatus(ImageSyncStatus(
        imageSyncState: ImageSyncState.uploading, data: imageDetails));
    File file = imageDetails.getFile()!;
    await calculateTotalFileSized(imageDetails);
    String? updatedFileName, s3FolderPath;
    updatedFileName = file.name?.cleanForUrl();
    s3FolderPath = question.parentReference?.getUploadPath(file.name!);
    if (updatedFileName != null && s3FolderPath != null) {
      try {
        AWSUploadResult? awsUploadResult = await sl<RemoteStorageRepository>()
            .uploadFile(file, updatedFileName, s3FolderPath);
        if (awsUploadResult != null) {
          question.answerUnit?.stringValue = awsUploadResult.url;
          imageDetails.url = awsUploadResult.url;
          question.answerUnit?.imageDetails = imageDetails;
          AppLog.i('URL..............${awsUploadResult.url}');
        }
        onAnswerUpdate(question);
        changeImageSyncStatus(ImageSyncStatus(
            imageSyncState: ImageSyncState.uploaded, data: imageDetails));
      } catch (e, st) {
        AppLog.e('upload : ${e.toString()} \n${st.toString()}');
        rethrow;
      }
    }
  }

  void deleteImage(
      Question question, Function(Question question) onAnswerUpdate) {
    _uploadEntryLocalRepository.deleteUploadEntityHO(
        question.answerUnit?.imageDetails?.uploadEntityHOKey ?? -1);
    question.isDeleted = true;
    question.answerUnit?.stringValue = "";
    updateLead(question);
    onAnswerUpdate(question);
    changeImageSyncStatus(
        ImageSyncStatus(imageSyncState: ImageSyncState.unAnswered));
  }

  void updateLead(Question question) async {
    try {
      List<ScreenRow>? screenRowList =
      sl<AwQuestionsCubit>().getScreenRowListByQuestionID(question);
      if (screenRowList != null && screenRowList.length == 1) {
        ScreenRow screenRow = screenRowList[0];
        screenRow.question = question;
        screenRowList[0] = screenRow;
      }
      Lead lead = await _leadRemoteRepository.updateLead(
          question.executionID ?? '',
          question.screenID ?? '',
          question.leadID ?? '',
          screenRowList);
    } on ServerException catch (e) {
      AppLog.e('updateLead : ${e.toString()} \n${e.message!}');
    } on FailureException catch (e) {
      AppLog.e('updateLead : ${e.toString()} \n${e.message!}');
    } catch (e, st) {
      AppLog.e('updateLead : ${e.toString()} \n${st.toString()}');
    }
  }
}
