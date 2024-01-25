class DeviceInfoRequest {
  DeviceInfoRequest({required this.deviceInfo, required this.userID});

  late final DeviceInfo? deviceInfo;
  late final int? userID;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['device_info'] = deviceInfo?.toJson();
    _data['user_id'] = userID;
    return _data;
  }
}

class DeviceInfo {
  String? loggedInRole;
  String? fcmToken;
  String? osVersion;
  String? imeiNumber;
  String? serialNo;
  String? manufacturer;
  String? model;
  String? deviceUUID;
  String? board;
  String? bootloader;
  String? brand;
  String? device;
  String? display;
  String? fingerprint;
  String? radioversion;
  String? serial;
  String? hardware;
  String? host;
  String? product;
  List<String?>? supported32BitsAbis;
  List<String?>? supported64BitsAbis;
  List<String?>? supportedAbis;
  String? tags;
  String? time;
  String? buildType;
  String? unknown;
  String? buildID;
  String? user;
  String? cpuAbi;
  String? cpuAbi2;
  String? radio;
  String? sdk;
  int? versionSdkInt;
  String? versionBaseOS;
  String? versionCodename;
  String? versionIncremental;
  int? versionPreviewSdkInt;
  String? versionRelease;
  String? versionSecurityPatch;
  String? primaryAppVersion;

  DeviceInfo(
      {this.loggedInRole,
      this.fcmToken,
      this.osVersion,
      this.imeiNumber,
      this.serialNo,
      this.manufacturer,
      this.model,
      this.deviceUUID,
      this.board,
      this.bootloader,
      this.brand,
      this.device,
      this.display,
      this.fingerprint,
      this.radioversion,
      this.serial,
      this.hardware,
      this.host,
      this.product,
      this.supported32BitsAbis,
      this.supported64BitsAbis,
      this.supportedAbis,
      this.tags,
      this.time,
      this.buildType,
      this.unknown,
      this.buildID,
      this.user,
      this.cpuAbi,
      this.cpuAbi2,
      this.radio,
      this.sdk,
      this.versionSdkInt,
      this.versionBaseOS,
      this.versionCodename,
      this.versionIncremental,
      this.versionPreviewSdkInt,
      this.versionRelease,
      this.versionSecurityPatch,
      this.primaryAppVersion});

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    loggedInRole = json['logged_in_role'];
    fcmToken = json['fcm_token'];
    osVersion = json['os_version'];
    imeiNumber = json['imei_number'];
    serialNo = json['serial_no'];
    manufacturer = json['manufacturer'];
    model = json['model'];
    deviceUUID = json['device_uuid'];
    board = json['board'];
    bootloader = json['bootloader'];
    brand = json['brand'];
    device = json['device'];
    display = json['display'];
    fingerprint = json['fingerprint'];
    radioversion = json['radioversion'];
    serial = json['serial'];
    hardware = json['hardware'];
    host = json['host'];
    product = json['product'];
    supported32BitsAbis = json['supported_32_bits_abis'] != null
        ? List.castFrom<dynamic, String>(json['supported_32_bits_abis'])
        : null;
    supported64BitsAbis = json['supported_64_bits_abis'] != null
        ? List.castFrom<dynamic, String>(json['supported_64_bits_abis'])
        : null;
    supportedAbis = json['supported_abis'] != null
        ? List.castFrom<dynamic, String>(json['supported_abis'])
        : null;
    tags = json['tags'];
    time = json['time'];
    buildType = json['build_type'];
    unknown = json['unknown'];
    buildID = json['build_id'];
    user = json['user'];
    cpuAbi = json['cpu_abi'];
    cpuAbi2 = json['cpu_abi2'];
    radio = json['radio'];
    sdk = json['sdk'];
    versionSdkInt = json['version_sdk_int'];
    versionBaseOS = json['version_base_os'];
    versionCodename = json['version_codename'];
    versionIncremental = json['version_incremental'];
    versionPreviewSdkInt = json['version_preview_sdk_int'];
    versionRelease = json['version_release'];
    versionSecurityPatch = json['version_security_patch'];
    primaryAppVersion = json['primary_app_version'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['logged_in_role'] = loggedInRole;
    _data['fcm_token'] = fcmToken;
    _data['os_version'] = osVersion;
    _data['imei_number'] = imeiNumber;
    _data['serial_no'] = serialNo;
    _data['manufacturer'] = manufacturer;
    _data['model'] = model;
    _data['device_uuid'] = deviceUUID;
    _data['board'] = board;
    _data['bootloader'] = bootloader;
    _data['brand'] = brand;
    _data['device'] = device;
    _data['display'] = display;
    _data['fingerprint'] = fingerprint;
    _data['radioversion'] = radioversion;
    _data['serial'] = serial;
    _data['hardware'] = hardware;
    _data['host'] = host;
    _data['supported_32_bits_abis'] = supported32BitsAbis;
    _data['supported_64_bits_abis'] = supported64BitsAbis;
    _data['supported_abis'] = supportedAbis;
    _data['tags'] = tags;
    _data['time'] = time;
    _data['build_type'] = buildType;
    _data['unknown'] = unknown;
    _data['build_id'] = buildID;
    _data['user'] = user;
    _data['cpu_abi'] = cpuAbi;
    _data['cpu_abi2'] = cpuAbi2;
    _data['radio'] = radio;
    _data['sdk'] = sdk;
    _data['version_sdk_int'] = versionSdkInt;
    _data['version_base_os'] = versionBaseOS;
    _data['version_codename'] = versionCodename;
    _data['version_incremental'] = versionIncremental;
    _data['version_preview_sdk_int'] = versionPreviewSdkInt;
    _data['version_release'] = versionRelease;
    _data['version_security_patch'] = versionSecurityPatch;
    _data['primary_app_version'] = primaryAppVersion;
    return _data;
  }
}
