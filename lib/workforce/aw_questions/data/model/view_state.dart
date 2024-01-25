import 'package:awign/workforce/file_storage_remote/data/model/upload.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ViewState {
  late String error;
  late bool isSynced;
  late int? waitingForResultId;
  late List<Upload>? uploads;
  late bool isEntryInProgress;
  late int? entryProgress;
  late ViewResult result;
  late List<ViewResult> arrayResults;

  ViewState(
      {error,
      this.isSynced = false,
      this.waitingForResultId,
      this.uploads,
      this.isEntryInProgress = false,
      this.entryProgress,
      result,
      arrayResults}) {
    if (error != null) {
      this.error = error;
    } else {
      this.error = 'invalid_value'.tr;
    }
    if (result != null) {
      this.result = result;
    } else {
      this.result = ViewResult();
    }
    if (arrayResults != null) {
      this.arrayResults = arrayResults;
    } else {
      this.arrayResults = [];
    }
  }
}

class ViewResult {
  late int? resultCode;
  late bool cameraCaptureResultComplete;
  late Uri? cameraCaptureUri;
  late Map<String, dynamic>? data;

  ViewResult(
      {this.resultCode,
      this.cameraCaptureResultComplete = false,
      this.cameraCaptureUri,
      this.data});
}
