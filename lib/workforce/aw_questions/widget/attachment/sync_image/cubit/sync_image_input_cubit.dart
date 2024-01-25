import 'dart:io';

import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/file_storage_remote/data/model/aws_upload_result.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../../core/di/app_injection_container.dart';
import '../../../../../core/utils/file_utils.dart';
import '../../../../../file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import '../../../../data/model/data_type.dart';
import '../../../../data/model/question.dart';
import '../../data/image_sync_state.dart';

part 'sync_image_input_state.dart';

class SyncImageInputCubit extends Cubit<SyncImageInputState> {
  final _imageSyncStatus =
      BehaviorSubject<ImageSyncStatus>.seeded(ImageSyncStatus());

  Stream<ImageSyncStatus> get imageSyncStatus => _imageSyncStatus.stream;

  Function(ImageSyncStatus) get changeImageSyncStatus =>
      _imageSyncStatus.sink.add;

  final _isOptionsExpanded = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isOptionsExpanded => _isOptionsExpanded.stream;

  Function(bool) get changeIsOptionsExpanded => _isOptionsExpanded.sink.add;

  int totalFileSize = 0;

  SyncImageInputCubit() : super(SyncImageInputInitial());

  @override
  Future<void> close() {
    _imageSyncStatus.close();
    _isOptionsExpanded.close();
    return super.close();
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
    FileUtils.getFileSizeInBytes(file.path, 2).then((fileSize) {
      totalFileSize = fileSize;
    });
    String? updatedFileName, s3FolderPath;
    updatedFileName = file.name?.cleanForUrl();
    s3FolderPath = question.parentReference?.getUploadPath(file.name!);
    if (updatedFileName != null && s3FolderPath != null) {
      AWSUploadResult? awsUploadResult = await sl<RemoteStorageRepository>()
          .uploadFile(file, updatedFileName, s3FolderPath);
      question.answerUnit?.stringValue = awsUploadResult?.url;
      imageDetails.url = awsUploadResult?.url;
      question.answerUnit?.imageDetails = imageDetails;
      onAnswerUpdate(question);
      changeImageSyncStatus(ImageSyncStatus(
          imageSyncState: ImageSyncState.uploaded, data: imageDetails));
    }
  }

  void deleteImage(
      Question question, Function(Question question) onAnswerUpdate) {
    question.answerUnit?.stringValue = null;
    question.answerUnit?.imageDetails = null;
    question.isDeleted = true;
    onAnswerUpdate(question);
    if (question.dataType == DataType.single) {
      changeImageSyncStatus(
          ImageSyncStatus(imageSyncState: ImageSyncState.unAnswered));
    }
  }
}
