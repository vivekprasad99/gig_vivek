import 'dart:convert';
import 'dart:io';

import 'package:awign/workforce/core/data/model/fcm/fcm_data.dart';
import 'package:awign/workforce/core/deep_link/cubit/deep_link_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/push_notification/firebase_messaging_service.dart';
import 'package:awign/workforce/core/push_notification/helper/fcm_notification_action_helper.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

// handle background notification action
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  AppLog.i("notificationTapBackground: ${notificationResponse.payload}");
  NotificationService()._handleNotificationAction(notificationResponse);
}

class NotificationService {
  static const channelID = "view_body_notification";
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    //Initialization Settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    //Initialization Settings for iOS
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        AppLog.i("notificationTapForeground: ${notificationResponse.payload}");
        _handleNotificationAction(notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void requestPermissions() {
    if (kIsWeb) {
    } else if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } else if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<NotificationDetails> _notificationDetails(FCMData fcmData) async {
    var largeIcon;
    var bigPicture;
    if (fcmData.viewBody?.largeIconUrl != null) {
      largeIcon = await FileUtils.downloadAndSaveImage(
          fcmData.viewBody?.largeIconUrl ?? '');
    }
    fcmData.viewBody?.notificationImage =
        "https://images.unsplash.com/photo-1624948465027-6f9b51067557?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80";
    if (fcmData.viewBody?.notificationImage != null) {
      bigPicture = await FileUtils.downloadAndSaveImage(
          fcmData.viewBody?.notificationImage ?? '');
    }

    DefaultStyleInformation styleInformation =
        const DefaultStyleInformation(true, true);
    if (fcmData.message.isNotEmpty) {
      styleInformation = const DefaultStyleInformation(true, true);
    } else if (fcmData.viewBody?.summary != null) {
      styleInformation = BigTextStyleInformation(fcmData.viewBody!.summary!,
          contentTitle: fcmData.title, summaryText: fcmData.viewBody!.summary!);
    } else if (bigPicture != null) {
      styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicture),
          hideExpandedLargeIcon: false);
    }
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelID, 'notification_channel_title'.tr,
            channelDescription: '',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            ticker: 'notification_title'.tr,
            styleInformation: styleInformation,
            largeIcon: largeIcon);

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            attachments: bigPicture != null
                ? <DarwinNotificationAttachment>[
                    DarwinNotificationAttachment(bigPicture)
                  ]
                : null);

    return NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    FCMData fcmData;
    if (payload != null) {
      fcmData = FCMData.fromJson(json.decode(payload));
    } else {
      fcmData = FCMData(title: title ?? Constants.appName, message: body ?? '');
    }
    showNotification(fcmData);
  }

  Future<void> showNotification(FCMData fcmData) async {
    final details = await _notificationDetails(fcmData);
    await flutterLocalNotificationsPlugin.show(
        fcmData.id, fcmData.title, fcmData.message, details,
        payload: json.encode(fcmData.toJson()));
  }

  _handleNotificationAction(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      FCMData fcmData =
          FCMData.fromJson(json.decode(notificationResponse.payload!));
      if (fcmData.viewBody?.deepLinkingUrl != null) {
        sl<DeepLinkCubit>()
            .launchWidgetFromDeepLink(fcmData.viewBody!.deepLinkingUrl!);
      } else {
        FCMNotificationHelper.launchWidgetFromFCMAction(
            fcmData.viewBody?.action, fcmData.viewBody);
      }
    }
  }

  handleBackgroundNotificationAction(RemoteMessage remoteMessage) {
    FCMData fcmData = FirebaseMessagingService().getFDCMData(remoteMessage);
    if (fcmData.viewBody?.deepLinkingUrl != null) {
      sl<DeepLinkCubit>()
          .launchWidgetFromDeepLink(fcmData.viewBody!.deepLinkingUrl!);
    } else {
      FCMNotificationHelper.launchWidgetFromFCMAction(
          fcmData.viewBody?.action, fcmData.viewBody);
    }
  }
}
