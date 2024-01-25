enum AppFlavor {
  development,
  staging,
  production,
}

class FlavorConfig {
  final String appName;
  final AppFlavor appFlavor;
  final String authEndPoint;
  final String authV2EndPoint;
  final String wosEndPoint;
  final String inHouseOMSEndPoint;
  final String coreEndPoint;
  final String ptsEndPoint;
  final String pdsEndPoint;
  final String zohoAppKey;
  final String zohoAccessKey;
  final String loggingEndPoint;
  final String documentsEndPoint;
  final String learningEndpoint;
  final String clevertapAccountID;
  final String clevertapToken;
  final String otpLessEndpoint;
  final String whatsappSigninEndpoint;
  final String bffEndpoint;
  final String moEngageAppId;

  FlavorConfig({
    required this.appName,
    required this.appFlavor,
    required this.authEndPoint,
    required this.authV2EndPoint,
    required this.wosEndPoint,
    required this.inHouseOMSEndPoint,
    required this.coreEndPoint,
    required this.ptsEndPoint,
    required this.pdsEndPoint,
    required this.zohoAppKey,
    required this.zohoAccessKey,
    required this.loggingEndPoint,
    required this.documentsEndPoint,
    required this.learningEndpoint,
    required this.clevertapAccountID,
    required this.clevertapToken,
    required this.otpLessEndpoint,
    required this.whatsappSigninEndpoint,
    required this.bffEndpoint,
    required this.moEngageAppId,
  });
}
