import 'dart:io';

import 'package:awign/main_common.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const authBaseURL = 'https://auth-api.awigndev.com/';
const authV2BaseURL = 'https://auth-api-v2.awigndev.com/';
const wosEndpoint = 'https://wos-api.awigndev.com/';
const inHouseOMSEndpoint = 'https://ih-oms-api.awigndev.com/';
const zohoAppKey = "UYjkbgQ%2BNZcmMwbg4m%2FwX%2FZE3DOER6zT";
const coreEndpoint = 'https://core-api.awigndev.com/';
const ptsEndpoint = 'https://pts-api.awigndev.com/';
const pdsEndpoint = 'https://pds-api.awigndev.com/';
const loggingEndpoint = 'https://data-api.awigndev.com/';
const documentsEndpoint = 'https://documents-api.awigndev.com/';
const learningEndpoint = 'https://learnings-api.awigndev.com/';
const androidZohoAccessKey =
    "WC7cqZTiVEPJ7XKJUAS0l2HQQOQeA1jcg7rsIOUYp268TN0pJ%2BPGlhFnQAkJ5wH47%2B2P0zbo1%2FuHvI%2BpZ1A3Da9rSiaAJIAwYya476Hnf7k4abb393jmKGRApZi%2FM3OoAT2GHadLgk9eYOROf2s10iPwVNbg7ejK";
const iOSZohoAccessKey =
    "WC7cqZTiVEPJ7XKJUAS0l5cIejdBKTVuFAV4JYsWC8O5OkJQIkdWpmOd%2B7sfbJ%2Bq6kdIxS4N53UT7Lf1mSVwHG5iGtpgADk7VqbnM%2FyqQst%2BgU6feJArrGRApZi%2FM3OoAT2GHadLgk9eYOROf2s10iPwVNbg7ejK";
const clevertapAccountID = 'TEST-WR5-994-595Z';
const clevertapToken = 'TEST-4cc-520';
const otpLessEndpoint = 'https://api.otpless.app/';
const whatsappSigninEndpoint = 'https://bff-api.awigntest.com/';
const bffEndpoint = 'https://bff-api.awigndev.com/';
const moEngageAppId = 'JF1EZI4GYP8PXZICEYSJI6NT';

void main() {
  String zohoAccessKey = "";
  if (kIsWeb) {
  } else if (Platform.isAndroid) {
    zohoAccessKey = androidZohoAccessKey;
  } else if (Platform.isIOS) {
    zohoAccessKey = iOSZohoAccessKey;
  }
  FlavorConfig flavorConfig = FlavorConfig(
      appName: '${Constants.appName} Dev',
      appFlavor: AppFlavor.development,
      authEndPoint: authBaseURL,
      authV2EndPoint: authV2BaseURL,
      wosEndPoint: wosEndpoint,
      inHouseOMSEndPoint: inHouseOMSEndpoint,
      coreEndPoint: coreEndpoint,
      ptsEndPoint: ptsEndpoint,
      pdsEndPoint: pdsEndpoint,
      zohoAppKey: zohoAppKey,
      zohoAccessKey: zohoAccessKey,
      loggingEndPoint: loggingEndpoint,
      documentsEndPoint: documentsEndpoint,
      learningEndpoint: learningEndpoint,
      clevertapAccountID: clevertapAccountID,
      clevertapToken: clevertapToken,
      otpLessEndpoint: otpLessEndpoint,
      whatsappSigninEndpoint: whatsappSigninEndpoint,
      bffEndpoint: bffEndpoint,
      moEngageAppId: moEngageAppId);
  mainCommon(flavorConfig);
}
