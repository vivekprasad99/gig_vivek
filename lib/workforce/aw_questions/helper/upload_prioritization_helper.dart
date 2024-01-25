import 'package:awign/workforce/aw_questions/data/model/upload_or_sync/priority_operation.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';

import '../../core/data/local/repository/upload_entry/upload_entry_local_repository.dart';
import '../../core/exception/exception.dart';
import '../../core/utils/app_log.dart';
import '../data/model/upload_or_sync/upload_operation.dart';
import '../data/model/upload_or_sync/upload_status.dart';

class UploadPrioritizationHelper {
  static const maxRetryCount = 2;
  final UploadEntryLocalRepository _uploadEntryLocalRepository;

  UploadPrioritizationHelper(this._uploadEntryLocalRepository);

  PriorityOperation? getPriorityOperation() {
    try {
      List<UploadEntityHO> interruptedEntries = _uploadEntryLocalRepository
          .getUploadEntityHOList(status: UploadStatus.inProgress.value);
      if (interruptedEntries.isNotEmpty) {
        return PriorityOperation(
            interruptedEntries.first, UploadOperation.upload);
      }

      List<UploadEntityHO> syncFailedEntries = _uploadEntryLocalRepository
          .getUploadEntityHOList(status: UploadStatus.syncFailed.value);
      if (syncFailedEntries.isNotEmpty &&
          !retryLimitExceeded(syncFailedEntries.first.syncFailedCount ?? 0)) {
        return PriorityOperation(syncFailedEntries.first, UploadOperation.sync);
      }

      List<UploadEntityHO> notSyncedEntries = _uploadEntryLocalRepository
          .getUploadEntityHOList(status: UploadStatus.uploadedNotSynced.value);
      if (notSyncedEntries.isNotEmpty &&
          !retryLimitExceeded(notSyncedEntries.first.uploadFailedCount ?? 0)) {
        return PriorityOperation(notSyncedEntries.first, UploadOperation.sync);
      }

      List<UploadEntityHO> uploadFailedEntries = _uploadEntryLocalRepository
          .getUploadEntityHOList(status: UploadStatus.uploadFailed.value);
      if (uploadFailedEntries.isNotEmpty) {
        return PriorityOperation(
            uploadFailedEntries.first, UploadOperation.upload);
      }

      List<UploadEntityHO> uploadNotStartedEntries =
          _uploadEntryLocalRepository.getUploadEntityHOList(
              status: UploadStatus.uploadNotStarted.value, isPaused: false);
      if (uploadNotStartedEntries.isNotEmpty) {
        return PriorityOperation(
            uploadNotStartedEntries.first, UploadOperation.upload);
      }
    } on FailureException catch (e) {
      AppLog.e('getPriorityOperation : ${e.toString()}');
    } catch (e, st) {
      AppLog.e('getPriorityOperation : ${e.toString()} \n${st.toString()}');
    }
    return null;
  }

  bool retryLimitExceeded(int retryCount) {
    return retryCount > maxRetryCount;
  }
}
