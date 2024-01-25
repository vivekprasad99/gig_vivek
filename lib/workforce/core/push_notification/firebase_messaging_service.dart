import 'dart:convert';
import 'dart:io';

import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/fcm/fcm_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/push_notification/notification_service.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:moengage_flutter/moengage_flutter.dart';

import '../data/local/repository/logging_event/helper/logging_actions.dart';
import '../data/local/repository/logging_event/helper/logging_events.dart';

// For handling the background notifications
Future _firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) async {
  AppLog.i(
      "Handling a background message: ${remoteMessage.notification?.title}");
  FirebaseMessagingService().handleRemoteNotification(remoteMessage);
}

class FirebaseMessagingService {
  static const viewBody = 'view_body';
  static const actionFromFCM = 'action_from_fcm';
  static const backgroundBody = 'background_body';
  static const cleverTapNotificationTitle = 'nt';
  static const cleverTapNotificationMessage = 'nm';
  static const cleverTapNotificationImage = 'wzrk_bp';
  static const cleverTapNotificationDeepLink = 'wzrk_dl';
  static const cleverTapNotificationSummary = 'wzrk_nms';
  static const cleverTapNotificationLargeIcon = 'ico';

  static final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _firebaseMessagingService;
  }

  FirebaseMessagingService._internal();

  Future<void> requestAndRegisterNotification() async {
    // Instantiate Firebase Messaging
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    SPUtil? spUtil = await SPUtil.getInstance();

    if (kIsWeb) {
    } else if (Platform.isAndroid) {
      String? token = await messaging.getToken();
      AppLog.i('FCM token is $token');
      if (token != null) {
        spUtil?.putFCMToken(token);
      }
    } else if (Platform.isIOS) {
      // On iOS, this helps to take the user permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLog.i('User granted permission');
        String? token = await messaging.getToken();
        AppLog.i('FCM token is $token');
        if (token != null) {
          spUtil?.putFCMToken(token);
        }
      } else {
        AppLog.i('User declined or has not accepted permission');
      }
    }

    // For handling the foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      AppLog.i(
          'onMessage - ${remoteMessage.notification?.title} ${remoteMessage.data['subtitle']}');
      handleRemoteNotification(remoteMessage);
    });

    // For handling the notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      AppLog.i(
          'onMessageOpenedApp - ${remoteMessage.notification?.title} ${remoteMessage.data['subtitle']}');
      NotificationService().handleBackgroundNotificationAction(remoteMessage);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await NotificationService().init();
    NotificationService().requestPermissions();
  }

  Future<void> handleRemoteNotification(RemoteMessage remoteMessage) async {
    FCMData fcmData = getFDCMData(remoteMessage);
    if (fcmData.viewBody != null) {
      SPUtil? spUtil = await SPUtil.getInstance();
      Map<String, dynamic> properties =
          await UserProperty.getUserProperty(spUtil?.getUserData());
      if (fcmData.viewBody!.deepLinkingUrl.isNullOrEmpty) {
        ClevertapData clevertapData = ClevertapData(
            eventName: ClevertapHelper.appNotificationReceivedWithoutUrl,
            properties: properties);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
      } else {
        ClevertapData clevertapData = ClevertapData(
            eventName: ClevertapHelper.appNotificationReceivedWithUrl,
            properties: properties);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
      }
      NotificationService().showNotification(fcmData);
    }
  }

  FCMData getFDCMData(RemoteMessage remoteMessage) {
    FCMData fcmData = FCMData();
    if (remoteMessage.data[viewBody] != null) {
      FCMViewBody fcmViewBody =
          FCMViewBody.fromJson(json.decode(remoteMessage.data[viewBody]));
      fcmData.viewBody = fcmViewBody;
    } else if (remoteMessage.data[backgroundBody] != null) {
      FCMViewBody fcmViewBody = FCMViewBody();
      fcmViewBody.title = remoteMessage.data[cleverTapNotificationTitle];
      fcmViewBody.message = remoteMessage.data[cleverTapNotificationMessage];
      fcmViewBody.notificationImage =
          remoteMessage.data[cleverTapNotificationImage];
      fcmViewBody.deepLinkingUrl =
          remoteMessage.data[cleverTapNotificationDeepLink];
      fcmViewBody.summary = remoteMessage.data[cleverTapNotificationSummary];
      fcmViewBody.largeIconUrl =
          remoteMessage.data[cleverTapNotificationLargeIcon];
      fcmViewBody.isCleverTapNotification = true;
      fcmData.viewBody = fcmViewBody;

      LoggingData loggingData = LoggingData(
          event: LoggingEvents.notification, action: LoggingActions.received);
      CaptureEventHelper.captureEvent(loggingData: loggingData);
    }
    return fcmData;
  }
}
