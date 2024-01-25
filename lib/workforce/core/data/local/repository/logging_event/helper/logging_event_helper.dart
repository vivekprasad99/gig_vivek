import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/remote/moengage/moengage_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';

import '../logging_local_repository.dart';

export 'logging_actions.dart';
export 'logging_events.dart';
export 'logging_page_names.dart';
export 'logging_section_names.dart';

class LoggingEventHelper {
  static void saveLoggingEvent(String event, String action, String pageName,
      String sectionName, Map<String, String>? otherProperty) async {
    try {
      MoEngage.trackEvent(event.isNullOrEmpty ? action : event, otherProperty);
      SPUtil? spUtil = await SPUtil.getInstance();
      if (spUtil != null) {
        await sl<LoggingLocalRepository>().saveLoggingEventLocally(
            spUtil.getUserData(),
            event,
            action,
            pageName,
            sectionName,
            otherProperty);
      }
    } catch (e, st) {
      AppLog.e('saveLoggingEvent : ${e.toString()} \n${st.toString()}');
    }
  }
}
