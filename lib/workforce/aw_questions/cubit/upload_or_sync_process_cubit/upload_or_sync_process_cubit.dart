import 'dart:convert';
import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/answer/trackable_data.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/upload_or_sync/upload_status.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/data/local/database/upload_entity_ho/trackable_entity_ho.dart';
import '../../../core/data/local/repository/upload_entry/upload_entry_local_repository.dart';
import '../../../core/di/app_injection_container.dart';
import '../../../core/exception/exception.dart';
import '../../../core/utils/app_log.dart';
import '../../../execution_in_house/data/model/lead_entity.dart';
import '../../../execution_in_house/data/repository/lead/lead_remote_repository.dart';
import '../../../file_storage_remote/data/model/aws_upload_result.dart';
import '../../../file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import '../../data/mapper/answer_unit_mapper.dart';
import '../../data/model/answer/answer_unit.dart';
import '../../data/model/answer/trackable_data_holder.dart';
import '../../data/model/input_type.dart';
import '../../data/model/upload_or_sync/priority_operation.dart';
import '../../data/model/upload_or_sync/upload_operation.dart';
import '../../helper/upload_prioritization_helper.dart';

part 'upload_or_sync_process_state.dart';

class UploadOrSyncProcessCubit extends Cubit<UploadOrSyncProcessState> {
  final UploadEntryLocalRepository _uploadEntryLocalRepository;
  final LeadRemoteRepository _leadRemoteRepository;

  bool isRunning = false;

  static const String trackingData = "_tracking_data";
  static const String metaData = "_metadata";

  UploadOrSyncProcessCubit(this._uploadEntryLocalRepository,
      this._leadRemoteRepository)
      : super(UploadOrSyncProcessInitial());

  @override
  Future<void> close() {
    return super.close();
  }

  void start() {
    if (isRunning) {
      return;
    }
    isRunning = true;
    executePriorityOperation();
  }

  void executePriorityOperation() {
    UploadPrioritizationHelper uploadPrioritizationHelper =
    UploadPrioritizationHelper(_uploadEntryLocalRepository);
    PriorityOperation? priorityOperation =
    uploadPrioritizationHelper.getPriorityOperation();
    if (priorityOperation == null) {
      isRunning = false;
      return;
    }

    switch (priorityOperation.uploadOperation) {
      case UploadOperation.upload:
        upload(priorityOperation.uploadEntityHO);
        break;
      case UploadOperation.sync:
        getLeadAndUpdateLead(priorityOperation.uploadEntityHO);
        break;
    }
  }

  Future<void> upload(UploadEntityHO uploadEntityHO) async {
    File? file = uploadEntityHO.getImageDetails().getFile();
    if (file == null) {
      isRunning = false;
      return;
    }
    // changeImageSyncStatus(ImageSyncStatus(
    //     imageSyncState: ImageSyncState.uploading, data: imageDetails));
    // File file = imageDetails.getFile()!;
    // FileUtils.getFileSizeInBytes(file.path, 2).then((fileSize) {
    //   totalFileSize = fileSize;
    // });
    // String? updatedFileName, s3FolderPath;
    // updatedFileName =
    //     question.parentReference?.getUploadPath(file.name!).split('/').last;
    // s3FolderPath = question.parentReference?.getUploadPath(file.name!);
    if (uploadEntityHO.uploadFileName != null &&
        uploadEntityHO.s3FolderPath != null) {
      try {
        /// update loading status on db
        uploadEntityHO.uploadStatus = UploadStatus.inProgress.value;
        uploadEntityHO.save();

        AWSUploadResult? awsUploadResult = await sl<RemoteStorageRepository>()
            .uploadFile(file, uploadEntityHO.uploadFileName!,
            uploadEntityHO.s3FolderPath!);
        // question.answerUnit?.stringValue = awsUploadResult.url;
        // imageDetails.url = awsUploadResult.url;
        // question.answerUnit?.imageDetails = imageDetails;
        if (awsUploadResult != null) {
          AppLog.i('URL..............${awsUploadResult.url}');
          // onAnswerUpdate(question);
          // changeImageSyncStatus(ImageSyncStatus(
          //     imageSyncState: ImageSyncState.uploaded, data: imageDetails));
          /// update loading status on db
          uploadEntityHO.uploadStatus = UploadStatus.uploadedNotSynced.value;
          uploadEntityHO.uploadedFileUrl = awsUploadResult.url;
          uploadEntityHO.save();
        }
        isRunning = false;
        start();
      } catch (e, st) {
        AppLog.e('upload : ${e.toString()} \n${st.toString()}');
        uploadEntityHO.uploadStatus = UploadStatus.uploadFailed.value;
        uploadEntityHO.uploadFailedCount =
            (uploadEntityHO.uploadFailedCount ?? 0) + 1;
        uploadEntityHO.save();
        isRunning = false;
        start();
        rethrow;
      }
    } else {
      isRunning = false;
      start();
    }
  }

  void getLeadAndUpdateLead(UploadEntityHO uploadEntityHO) {
    DataType? dataType = DataType.get(uploadEntityHO.syncDataType);
    switch (dataType) {
      case DataType.single:
        updateLead(uploadEntityHO, null);
        break;
      case DataType.array:
        getLead(uploadEntityHO);
        break;
    }
  }

  void getLead(UploadEntityHO uploadEntityHO) async {
    try {
      Lead lead = await _leadRemoteRepository.getLead(
          uploadEntityHO.executionID ?? '',
          uploadEntityHO.projectRoleID ?? '',
          uploadEntityHO.leadID ?? '');
      updateLead(uploadEntityHO, lead);
    } on ServerException catch (e) {
      AppLog.e('getLead : ${e.toString()}');
      _syncFailed(uploadEntityHO);
      isRunning = false;
      start();
    } on FailureException catch (e) {
      AppLog.e('getLead : ${e.toString()}');
      _syncFailed(uploadEntityHO);
      isRunning = false;
      start();
    } catch (e, st) {
      AppLog.e('getLead : ${e.toString()} \n${st.toString()}');
      _syncFailed(uploadEntityHO);
      isRunning = false;
      start();
    }
  }

  _syncFailed(UploadEntityHO uploadEntityHO) {
    uploadEntityHO.uploadStatus = UploadStatus.syncFailed.value;
    uploadEntityHO.syncFailedCount = (uploadEntityHO.syncFailedCount ?? 0) + 1;
    uploadEntityHO.save();
  }

  void updateLead(UploadEntityHO uploadEntityHO, Lead? lead) async {
    try {
      Map<String, dynamic> answerMap = {};
      if (uploadEntityHO.questionUID != null &&
          uploadEntityHO.uploadedFileUrl != null &&
          lead != null) {
        dynamic value = lead.getLeadAnswerValue(uploadEntityHO.questionUID);
        if (value == null) {
          answerMap[uploadEntityHO.questionUID!] = [
            uploadEntityHO.uploadedFileUrl
          ];
        } else if (value is List<dynamic>) {
          value.add(uploadEntityHO.uploadedFileUrl!);
          answerMap[uploadEntityHO.questionUID!] = value;
        }
      } else if (uploadEntityHO.questionUID != null &&
          uploadEntityHO.uploadedFileUrl != null) {
        answerMap[uploadEntityHO.questionUID!] = [
          uploadEntityHO.uploadedFileUrl
        ];
      }

      Map<String, AnswerUnit> updateMap = {};
      if (uploadEntityHO.isArray() && lead != null) {
        updateMap = getUpdateMapArray(uploadEntityHO, lead);

      } else {
        updateMap = getUpdateMapSingle(uploadEntityHO);
      }
      answerMap.addAll(AnswerUnitMapper.transform(updateMap));

      if (answerMap.isNotEmpty) {
        Lead updatedLead = await _leadRemoteRepository.updateLead(
            uploadEntityHO.executionID ?? '',
            uploadEntityHO.screenID ?? '',
            uploadEntityHO.leadID ?? '',
            null,
            answerMap: answerMap); //TODO check this map
        uploadEntityHO.uploadStatus = UploadStatus.synced.value;
        uploadEntityHO.save();
      }
      isRunning = false;
      start();
    } on ServerException catch (e) {
      AppLog.e('updateLead : ${e.toString()}');
      _syncFailed(uploadEntityHO);
      isRunning = false;
      start();
    } on FailureException catch (e) {
      AppLog.e('updateLead : ${e.toString()}');
      _syncFailed(uploadEntityHO);
      isRunning = false;
      start();
    } catch (e, st) {
      AppLog.e('updateLead : ${e.toString()} \n${st.toString()}');
      _syncFailed(uploadEntityHO);
      isRunning = false;
      start();
    }
  }

  TrackableData transform(TrackableDataHO trackableDataHO) {
    return TrackableData(
      accuracy: trackableDataHO.accuracy,
      address: trackableDataHO.address,
      area: trackableDataHO.area,
      city: trackableDataHO.city,
      countryName: trackableDataHO.countryName,
      latLong: trackableDataHO.latLong,
      pinCode: trackableDataHO.pinCode,
      timeStamp: trackableDataHO.timeStamp,
    );
  }

  void setTrackableData(UploadEntityHO upload, AnswerUnit answerUnit) {
    if (upload.trackableData != null) {
      final TrackableData trackableData = transform(upload.trackableData!);
      final trackableDataHolder =
      answerUnit.trackableDataHolder != null
          ? answerUnit.trackableDataHolder!
          : TrackableDataHolder();
      if (upload.isMetaDataType == true) {
        trackableDataHolder.metadataData = trackableData;
      }
      if (upload.isTrackableType == true) {
        trackableDataHolder.trackableData = trackableData;
      }
      answerUnit.trackableDataHolder = trackableDataHolder;
    } else {
      final trackableData = TrackableDataHolder();
      if (upload.isMetaDataType == true) {
        trackableData.metaDataList = [];
      }
      if (upload.isTrackableType == true) {
        trackableData.trackableList = [];
      }
      answerUnit.trackableDataHolder = trackableData;
    }
  }

  AnswerUnit getSingleAnswer(UploadEntityHO upload) {
    AnswerUnit answerUnit = AnswerUnit(
        inputType: InputType.file, dateType: DataType.single);
    answerUnit.stringValue = upload.uploadedFileUrl;
    setTrackableData(upload, answerUnit);
    return answerUnit;
  }

  Map<String, AnswerUnit> getUpdateMapArray(
      UploadEntityHO uploadEntityHO, Lead lead) {
    Map<String, AnswerUnit> updateMap = {};
    AnswerUnit answerUnit = AnswerUnitMapper.getAnswerUnit(
        InputType.file,
        DataType.array,
        lead.leadMap[uploadEntityHO.questionUID],
        []
    );

    if (uploadEntityHO.isMetaDataType == true) {
      String trackableKey = (uploadEntityHO.questionUID ?? '') + metaData;
      AnswerUnitMapper.setMetaDataInAnswerUnit(
          lead.leadMap[trackableKey],
          answerUnit
      );
    }

    bool alreadyExists = false;
    for (AnswerUnit answer in answerUnit.arrayValue ?? []) {
      if (answer.stringValue == uploadEntityHO.uploadedFileUrl) {
        alreadyExists = true;
        break;
      }
    }

    if (!alreadyExists) {
      answerUnit.arrayValue?.add(getSingleAnswer(uploadEntityHO));
      setTrackableData(uploadEntityHO, answerUnit);
    }

    updateMap[uploadEntityHO.questionUID ?? ''] = answerUnit;

    return updateMap;
  }

  Map<String, AnswerUnit> getUpdateMapSingle(
      UploadEntityHO uploadEntityHO) {
    Map<String, AnswerUnit> updateMap = {};
    updateMap[uploadEntityHO.questionUID ?? ''] = getSingleAnswer(uploadEntityHO);
    return updateMap;
  }

}
