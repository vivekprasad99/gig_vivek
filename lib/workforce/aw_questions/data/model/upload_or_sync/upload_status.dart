enum UploadStatus {
  inProgress('in_progress'),
  uploadNotStarted('not_started'),
  uploadedNotSynced('not_synced'),
  uploadFailed('upload_failed'),
  synced('synced'),
  syncFailed('sync_failed'),
  syncing('syncing'),
  queued('queued');

  const UploadStatus(this.value);

  final String value;

  static UploadStatus get(status) {
    switch (status) {
      case 'in_progress':
        return UploadStatus.inProgress;
      case 'not_started':
        return UploadStatus.uploadNotStarted;
      case 'not_synced':
        return UploadStatus.uploadedNotSynced;
      case 'upload_failed':
        return UploadStatus.uploadFailed;
      case 'synced':
        return UploadStatus.synced;
      case 'sync_failed':
        return UploadStatus.syncFailed;
      default:
        return UploadStatus.uploadNotStarted;
    }
  }
}
