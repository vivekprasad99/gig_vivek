import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/application_clevertap_event.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';

class CaptureEventHelper {
  static captureEvent(
      {ClevertapData? clevertapData, LoggingData? loggingData}) {
    if (clevertapData != null) {
      if (clevertapData.isApplicationEvent) {
        ApplicationClevertapEvent.addApplicationClevertapEvents(
            clevertapData.applicationAction,
            clevertapData.workApplicationEntity,
            clevertapData.currentUser);
      } else if (clevertapData.isApplicationActionEvent) {
        ApplicationClevertapEvent.addClevertapActionEvents(
            clevertapData.clevertapActionType,
            clevertapData.workApplicationEntity,
            clevertapData.currentUser);
      } else if (clevertapData.isApplicationActionEvent) {
        ApplicationClevertapEvent.addApplicationStatusClevertapEvents(
            clevertapData.applicationStatus,
            clevertapData.workApplicationEntity,
            clevertapData.currentUser);
      } else if (clevertapData.eventName != null &&
          clevertapData.properties != null) {
        ClevertapHelper.instance().addCleverTapEvent(
            clevertapData.eventName!, clevertapData.properties!);
      }
    }

    if (loggingData != null) {
      LoggingEventHelper.saveLoggingEvent(
          loggingData.event ?? '',
          loggingData.action ?? '',
          loggingData.pageName ?? '',
          loggingData.sectionName ?? '',
          loggingData.otherProperty);
    }
  }
}
