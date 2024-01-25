class Result<D, E> {
  late bool success;
  late D data;
  late E error;

  Result(this.success, this.data, this.error);

  Result.success() {
    success = true;
  }

  Result.error(this.error) {
    success = false;
  }
}
