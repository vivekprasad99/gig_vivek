import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:awign/workforce/auth/data/model/device_info.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/moengage/moengage_constant.dart';
import 'package:awign/workforce/core/utils/device_info_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:moengage_flutter/model/app_status.dart';
import 'package:moengage_flutter/model/gender.dart';
import 'package:moengage_flutter/model/moe_init_config.dart';
import 'package:moengage_flutter/model/permission_result.dart';
import 'package:moengage_flutter/model/push/push_campaign_data.dart';
import 'package:moengage_flutter/model/push/push_config.dart';
import 'package:moengage_flutter/model/push/push_token_data.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:moengage_flutter/properties.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/app_log.dart';

class MoEngage {
  static const openApp = "open_app";
  static const universityClicked = "university_clicked";

  static late MoEngageFlutter moEngageFlutter;

  static Future<void> init(String appId) async {
    try {
      moEngageFlutter = MoEngageFlutter(appId,
        moEInitConfig: MoEInitConfig(
          pushConfig: PushConfig(shouldDeliverCallbackOnForegroundClick: true)
        )
      );
      DeviceInfo? deviceInfo = await DeviceInfoUtils.getDeviceInfoData();
      if (Platform.isAndroid &&
          deviceInfo != null &&
          deviceInfo.osVersion != null &&
          int.parse(deviceInfo.osVersion!) > 12) {
        PermissionStatus status = await Permission.notification.status;
            moEngageFlutter.pushPermissionResponseAndroid(status.isGranted);
      } else if(Platform.isAndroid)
        {
          moEngageFlutter.pushPermissionResponseAndroid(true);
        }
      moEngageFlutter.setupNotificationChannelsAndroid();
      moEngageFlutter.setAppStatus(MoEAppStatus.install);
      moEngageFlutter.setAppStatus(MoEAppStatus.update);
      SPUtil? spUtil = await SPUtil.getInstance();
      String? fcmToken = spUtil?.getFCMToken();
      moEngageFlutter.passFCMPushToken(fcmToken!);
      moEngageFlutter.setPushTokenCallbackHandler(_onPushTokenGenerated);
      moEngageFlutter.setPermissionCallbackHandler(_permissionCallbackHandler);
      moEngageFlutter.initialise();
    } catch (e) {
      AppLog.e('moEngage init: ${e.toString()}');
    }
  }

  static void _onPushTokenGenerated(PushTokenData pushToken) {}

  static void _permissionCallbackHandler(PermissionResultData data) {}

  static Future<void> setUniqueId(String userId) async {
    moEngageFlutter.setUniqueId(userId);
    MoEngage.setUserAttribute();
  }

  static Future<void> logout() async {
    moEngageFlutter.logout();
  }

  static Future<void> setUserAttribute() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? currentUser = spUtil?.getUserData();
    moEngageFlutter.setUserName(currentUser?.name ?? "");
    moEngageFlutter.setEmail(currentUser?.email ?? "");
    moEngageFlutter.setPhoneNumber(currentUser?.mobileNumber ?? "");
    moEngageFlutter.setGender(currentUser?.userProfile?.gender == Gender.male
        ? MoEGender.male
        : currentUser?.userProfile?.gender == Gender.female
            ? MoEGender.female
            : MoEGender.other);
    moEngageFlutter.setBirthDate(currentUser?.userProfile?.dob ?? "");
  }

  static Future<MoEProperties> getMoEngageUserProperty(
      MoEProperties properties) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? currentUser = spUtil?.getUserData();
    properties.addAttribute(MoEngageConstant.userName, currentUser?.name ?? "");
    properties.addAttribute(
        MoEngageConstant.userEmail, currentUser?.email ?? "");
    properties.addAttribute(
        MoEngageConstant.userPhone, currentUser?.mobileNumber ?? "");
    properties.addAttribute(MoEngageConstant.userGender,
        currentUser?.userProfile?.gender?.name() ?? "");
    properties.addAttribute(
        MoEngageConstant.userDOB, currentUser?.userProfile?.dob ?? "");
    properties.addAttribute(MoEngageConstant.userState,
        currentUser?.userProfile?.addresses?.first.state ?? "");
    properties.addAttribute(MoEngageConstant.userCity,
        currentUser?.userProfile?.addresses?.first.city ?? "");
    properties.addAttribute(MoEngageConstant.userPincode,
        currentUser?.userProfile?.addresses?.first.pincode ?? "");
    properties.addAttribute(MoEngageConstant.id, currentUser?.id ?? "");
    properties.addAttribute(MoEngageConstant.language,
        currentUser?.userProfile?.languages?.toString() ?? "");
    properties.addAttribute(MoEngageConstant.educationLevel,
        currentUser?.userProfile?.professionalExperiences?.toString() ?? "");
    properties.addAttribute(
        MoEngageConstant.panStatus,
        currentUser?.userProfile?.kycDetails?.panVerificationStatus?.value ??
            "");
    properties.addAttribute(
        MoEngageConstant.platformName, Platform.isAndroid ? 'Android' : 'Ios');
    DeviceInfo? deviceInfo = await DeviceInfoUtils.getDeviceInfoData();
    properties.addAttribute(
        MoEngageConstant.appVersion, deviceInfo?.versionRelease ?? "");
    return properties;
  }

  static trackEvent(
      String eventName, Map<String, dynamic>? propertiesMap) async {
    var properties = MoEProperties();
    if (propertiesMap != null) {
      propertiesMap.forEach((k, v) {
        properties.addAttribute(k, v);
      });
    }
    moEngageFlutter.trackEvent(
        eventName, await getMoEngageUserProperty(properties));
  }
}
