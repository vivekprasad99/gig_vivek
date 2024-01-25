import 'dart:async';
import 'dart:convert';

import 'package:awign/workforce/core/data/local/shared_preference_keys.dart';
import 'package:awign/workforce/core/data/model/app_config_response.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  static SPUtil? _instance;

  static Future<SPUtil?> get instance async {
    return await getInstance();
  }

  static SharedPreferences? _spf;

  SPUtil._();

  Future _init() async {
    _spf = await SharedPreferences.getInstance();
  }

  static Future<SPUtil?>? getInstance() async {
    if (_instance == null) {
      _instance = SPUtil._();
      await _instance?._init();
    }
    return _instance;
  }

  static bool _beforeCheck() {
    if (_spf == null) {
      return true;
    }
    return false;
  }

  bool? hasKey(String key) {
    Set? keys = getKeys();
    return keys?.contains(key);
  }

  Set<String>? getKeys() {
    if (_beforeCheck()) return null;
    return _spf?.getKeys();
  }

  get(String key) {
    if (_beforeCheck()) return null;
    return _spf?.get(key);
  }

  String? getString(String key) {
    if (_beforeCheck()) return null;
    return _spf?.getString(key);
  }

  Future<bool>? putString(String key, String value) {
    if (_beforeCheck()) return null;
    return _spf?.setString(key, value);
  }

  bool? getBool(String key) {
    if (_beforeCheck()) return null;
    return _spf?.getBool(key);
  }

  Future<bool>? putBool(String key, bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(key, value);
  }

  int? getInt(String key) {
    if (_beforeCheck()) return null;
    return _spf?.getInt(key);
  }

  Future<bool>? putInt(String key, int value) {
    if (_beforeCheck()) return null;
    return _spf?.setInt(key, value);
  }

  double? getDouble(String key) {
    if (_beforeCheck()) return null;
    return _spf?.getDouble(key);
  }

  Future<bool>? putDouble(String key, double value) {
    if (_beforeCheck()) return null;
    return _spf?.setDouble(key, value);
  }

  List<String>? getStringList(String key) {
    return _spf?.getStringList(key);
  }

  Future<bool>? putStringList(String key, List<String> value) {
    if (_beforeCheck()) return null;
    return _spf?.setStringList(key, value);
  }

  dynamic getDynamic(String key) {
    if (_beforeCheck()) return null;
    return _spf?.get(key);
  }

  Future<bool>? remove(String key) {
    if (_beforeCheck()) return null;
    return _spf?.remove(key);
  }

  Future<bool>? clear()  async{
    if (_beforeCheck()) return false;
    for(String key in  _spf!.getKeys()) {
      if(key != SPKeys.profileCompletionBottomSheetCount) {
        _spf!.remove(key);
      }
    }
    return true;
  }

  // Saving user sign in data
  Future<bool>? putUserData(UserData? userData) {
    if (_beforeCheck()) return null;
    String encodedBusiness = json.encode(userData?.toJson());
    return _spf?.setString(SPKeys.userData, encodedBusiness);
  }

  // Retrieve user sign in data
  UserData? getUserData() {
    if (_beforeCheck()) return null;
    String? strUserData = getString(SPKeys.userData);
    if (strUserData == null) {
      return null;
    }
    UserData userData = UserData.fromJson(json.decode(strUserData));
    return userData;
  }

  String? getAccessToken() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.accessToken);
  }

  Future<bool>? putAccessToken(String value) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.accessToken, value);
  }

  String? getClient() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.client);
  }

  Future<bool>? putClient(String value) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.client, value);
  }

  String? getUID() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.uid);
  }

  Future<bool>? putUID(String value) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.uid, value);
  }

  String? getSaasOrgID() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.saasOrgID);
  }

  Future<bool>? putSaasOrgID(String value) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.saasOrgID, value);
  }

  bool? getIsDarkModeEnabled() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.isDarkModeEnabled);
  }

  Future<bool>? putIsDarkModeEnabled(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.isDarkModeEnabled, value);
  }

  Future<bool>? putAppLanguage(String langCode) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.appLanguage, langCode);
  }

  String? getAppLanguage() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.appLanguage);
  }

  Future<bool>? putLaunchConfigData(AppConfigResponse? appConfigResponse) {
    if (_beforeCheck()) return null;
    String encodedBusiness = json.encode(appConfigResponse?.toJson());
    return _spf?.setString(SPKeys.appConfigData, encodedBusiness);
  }

  AppConfigResponse? getLaunchConfigData() {
    if (_beforeCheck()) return null;
    String? strAppConfData = getString(SPKeys.appConfigData);
    if (strAppConfData == null) {
      return null;
    }
    AppConfigResponse appConfigResponse =
        AppConfigResponse.fromJson(json.decode(strAppConfData));
    return appConfigResponse;
  }

  Future<bool>? putLastEarningSectionAccessTime(int time) {
    if (_beforeCheck()) return null;
    return _spf?.setInt(SPKeys.lastEarningSectionAccessTime, time);
  }

  int? getLastEarningSectionAccessTime() {
    if (_beforeCheck()) return null;
    return _spf?.getInt(SPKeys.lastEarningSectionAccessTime);
  }

  Future<bool>? putFCMToken(String fcmToken) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.fcmToken, fcmToken);
  }

  String? getFCMToken() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.fcmToken);
  }

  Future<bool>? previousWhatsappBottomSheetOpenTime(int time) {
    if (_beforeCheck()) return null;
    return _spf?.setInt(SPKeys.previousWhatsappBottomSheetOpenTime, time);
  }

  int? getPreviousWhatsappBottomSheetOpenTime() {
    if (_beforeCheck()) return null;
    return _spf?.getInt(SPKeys.previousWhatsappBottomSheetOpenTime);
  }

  Future<bool>? shouldShowBottomSheet(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.shouldShowBottomSheet, value);
  }

  bool? getShouldShowBottomSheet() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.shouldShowBottomSheet);
  }

  Future<bool>? shouldShowEarningWithdrawnBottomSheet(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.shouldShowEarningWithdrawBottomSheet, value);
  }

  bool? getShouldShowEarningWithdrawnBottomSheet() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.shouldShowEarningWithdrawBottomSheet);
  }

  bool? getIsTrustBuildingWidgetShown() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.isTrustBuildingWidgetShown);
  }

  Future<bool>? putIsTrustBuildingWidgetShown(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.isTrustBuildingWidgetShown, value);
  }

  bool? getIsDreamApplicationMaybeLater() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.isDreamApplicationMaybeLater);
  }

  Future<bool>? putIsDreamApplicationMaybeLater(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.isDreamApplicationMaybeLater, value);
  }

  Future<bool>? shouldShowNewInLeaderboard(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.shouldShowNewInLeaderboard, value);
  }

  bool? getShouldShowNewInLeaderboard() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.shouldShowNewInLeaderboard);
  }

  Future<bool>? setLeaderBoardFlagShownLastMonth(int value){
    if (_beforeCheck()) return null;
    return _spf?.setInt(SPKeys.leaderBoardFlagShownLastMonth, value);
  }

  int? leaderBoardFlagShownLastMonth() {
    if (_beforeCheck()) return null;
    return _spf?.getInt(SPKeys.leaderBoardFlagShownLastMonth);
  }

  String? getXRoute() {
    if (_beforeCheck()) return null;
    return _spf?.getString(SPKeys.xRoute);
  }

  Future<bool>? putXRoute(String value) {
    if (_beforeCheck()) return null;
    return _spf?.setString(SPKeys.xRoute, value);
  }

  Future<bool>? shouldShowProfileCompletionBottomSheet(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.profileCompletionBottomSheet, value);
  }

  bool? getShouldShowProfileCompletionBottomSheet() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.profileCompletionBottomSheet);
  }

  Future<bool>? putProfileCompletionBottomSheetCount(int count) {
    if (_beforeCheck()) return null;
    return _spf?.setInt(SPKeys.profileCompletionBottomSheetCount, count);
  }

  int? getProfileCompletionBottomSheetCount() {
    if (_beforeCheck()) return null;
    return _spf?.getInt(SPKeys.profileCompletionBottomSheetCount);
  }

  Future<bool>? putOtpListner(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.otpListner, value);
  }

  bool? isOtpListned() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.otpListner);
  }

  Future<bool>? putOtpListnerForOtpVerification(bool value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.otpListnerForOtpVerification, value);
  }

  bool? isOtpListnedForOtpVerification() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.otpListnerForOtpVerification);
  }

  Future<bool>? putWhatsappSubscribe(bool? value) {
    if (_beforeCheck()) return null;
    return _spf?.setBool(SPKeys.isWhatsAppSubscribe, value!);
  }

  bool? isWhatsAppSubscribe() {
    if (_beforeCheck()) return null;
    return _spf?.getBool(SPKeys.isWhatsAppSubscribe);
  }

  Future<bool>? putNotifyCategoryId(int? categoryId) {
    if (_beforeCheck()) return null;
    return categoryId != null
        ? _spf?.setInt(SPKeys.notifyCategoryId, categoryId)
        : _spf?.setInt(SPKeys.notifyCategoryId, -1);
  }

  int? getNotifyCategoryId() {
    if (_beforeCheck()) return null;
    return _spf?.getInt(SPKeys.notifyCategoryId) != -1
        ? _spf?.getInt(SPKeys.notifyCategoryId)
        : null;
  }
}
