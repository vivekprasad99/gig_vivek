class ButtonStatus {
  bool isEnable;
  bool isLoading;
  bool isSuccess;
  String? message;

  ButtonStatus(
      {this.isEnable = false, this.isLoading = false, this.isSuccess = false, this.message});
}
