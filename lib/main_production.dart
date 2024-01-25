import 'dart:io';

import 'package:awign/main_common.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const BASE_URL = 'https://....com/';
const authBaseURL = 'https://auth-api.awign.com/';
const authV2BaseURL = 'https://auth-api-v2.awign.com/';
const wosEndpoint = 'https://wos-api.awign.com/';
const inHouseOMSEndpoint = 'https://ih-oms-api.awign.com/';
const coreEndpoint = 'https://core-api.awign.com/';
const ptsEndpoint = 'https://pts-api.awign.com/';
const pdsEndpoint = 'https://pds-api.awign.com/';
const loggingEndpoint = 'https://data-api.awign.com/';
const documentesEndpoint = 'https://documents-api.awign.com/';
const learningEndpoint = 'https://learnings-api.awign.com/';
const zohoAppKey = "UYjkbgQ%2BNZcmMwbg4m%2FwX%2FZE3DOER6zT";
const androidZohoAccessKey =
    "WC7cqZTiVEPJ7XKJUAS0l2HQQOQeA1jcg7rsIOUYp268TN0pJ%2BPGlhFnQAkJ5wH47%2B2P0zbo1%2FuHvI%2BpZ1A3Da9rSiaAJIAwYya476Hnf7k4abb393jmKGRApZi%2FM3OoAT2GHadLgk9eYOROf2s10iPwVNbg7ejK";
const iOSZohoAccessKey =
    "WC7cqZTiVEPJ7XKJUAS0l5cIejdBKTVuFAV4JYsWC8O5OkJQIkdWpmOd%2B7sfbJ%2Bq6kdIxS4N53UT7Lf1mSVwHG5iGtpgADk7VqbnM%2FyqQst%2BgU6feJArrGRApZi%2FM3OoAT2GHadLgk9eYOROf2s10iPwVNbg7ejK";
const clevertapAccountID = 'R9Z-8W6-Z95Z';
const clevertapToken = '60b-1c2';
const otpLessEndpoint = 'https://api.otpless.app/';
const whatsappSigninEndpoint = 'https://bff-api.awign.com/';
const bffEndpoint = 'https://bff-api.awign.com/';
const moEngageAppId = '1KR2IE6HRPJ2FOZ5ONSIJGRW';

void main() {
  String zohoAccessKey = "";
  if (kIsWeb) {
  } else if (Platform.isAndroid) {
    zohoAccessKey = androidZohoAccessKey;
  } else if (Platform.isIOS) {
    zohoAccessKey = iOSZohoAccessKey;
  }
  FlavorConfig flavorConfig = FlavorConfig(
      appName: Constants.appName,
      appFlavor: AppFlavor.production,
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
      documentsEndPoint: documentesEndpoint,
      learningEndpoint: learningEndpoint,
      clevertapAccountID: clevertapAccountID,
      clevertapToken: clevertapToken,
      otpLessEndpoint: otpLessEndpoint,
      whatsappSigninEndpoint: whatsappSigninEndpoint,
      bffEndpoint: bffEndpoint,
      moEngageAppId: moEngageAppId);
  mainCommon(flavorConfig);
}
