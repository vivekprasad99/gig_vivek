enum RecorderState {
  noneInitialized,
  initialized,
  recording,
  recorded,
  playing,
  paused,
  uploading,
  uploaded,
  failedUploading,
}

class RecorderStatus {
  RecorderState recorderState;
  dynamic data;

  RecorderStatus(
      {this.recorderState = RecorderState.noneInitialized,
        this.data});
}
