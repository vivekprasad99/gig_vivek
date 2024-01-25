import '../../../data/model/upload_or_sync/upload_status.dart';

enum ImageSyncState {
  unAnswered('unAnswered'),
  answered('answered'),
  uploading('uploading'),
  paused('paused'),
  uploaded('uploaded'),
  syncing('syncing'),
  queued('queued'),
  failed('failed');

  const ImageSyncState(this.value);

  final String value;

  static ImageSyncState get(status) {
    switch (status) {
      case UploadStatus.inProgress:
        return ImageSyncState.uploading;
      case UploadStatus.uploadNotStarted:
        return ImageSyncState.paused;
      case UploadStatus.uploadedNotSynced:
        return ImageSyncState.uploaded;
      case UploadStatus.uploadFailed:
        return ImageSyncState.failed;
      case UploadStatus.synced:
        return ImageSyncState.answered;
      case UploadStatus.syncFailed:
        return ImageSyncState.failed;
      case UploadStatus.syncing:
        return ImageSyncState.syncing;
      case UploadStatus.queued:
        return ImageSyncState.queued;
      default:
        return ImageSyncState.paused;
    }
  }
}

class ImageSyncStatus {
  ImageSyncState imageSyncState;
  dynamic data;

  ImageSyncStatus({this.imageSyncState = ImageSyncState.unAnswered, this.data});
}
