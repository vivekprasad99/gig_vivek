import 'dart:io' as io;

import 'package:awign/workforce/core/data/local/database/boxes.dart';
import 'package:awign/workforce/core/data/local/database/logging_event_ho/logging_event_hive_object.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class LoggingLocalRepository {
  Future saveLoggingEventLocally(
      UserData? userData,
      String event,
      String action,
      String pageName,
      String sectionName,
      Map<String, String>? otherProperty);
}

class LoggingLocalRepositoryImpl implements LoggingLocalRepository {
  @override
  Future saveLoggingEventLocally(
      UserData? userData,
      String pageName,
      String sectionName,
      String event,
      String action,
      Map<String, String>? otherProperty) async {
    try {
      final Map<String, String> device = await FileUtils.getDeviceInfo();
      device.addAll({"fcm_token": ""});
      DateTime? eventAt =
          DateTime.now().toString().getDateObjectFromYYYYMMDDHHMMSS();
      String strPlatform = '';
      if (kIsWeb) {
        strPlatform = 'Web';
      } else if (io.Platform.isAndroid) {
        strPlatform = 'Android';
      } else if (io.Platform.isIOS) {
        strPlatform = 'Ios';
      }
      final loggingEventHO = LoggingEventHO()
        ..id = null
        ..userId = userData!.id ?? -1
        ..userRole =
            userData.roles.toString().replaceAll("[", "").replaceAll("]", "")
        ..pageName = pageName
        ..sectionName = sectionName
        ..event = event
        ..action = action
        ..origin = strPlatform
        ..applicationName = 'intern-app'
        ..device = device
        ..eventAt = eventAt.toString()
        ..otherProperty = otherProperty;

      final loggingBox = Boxes.getLoggingBox();
      loggingBox.add(loggingEventHO);
    } catch (e, stacktrace) {
      AppLog.e(
          'saveLoggingEventLocally : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
