import 'dart:io';

import 'package:awign/workforce/auth/data/model/device_info.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_udid/flutter_udid.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoUtils {
  static Future<DeviceInfo?> getDeviceInfoData() async {
    try {
      DeviceInfo deviceInfoData = DeviceInfo();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      deviceInfoData.osVersion = packageInfo.version;

      deviceInfoData.deviceUUID = await FlutterUdid.udid;

      final deviceInfoPlugin = DeviceInfoPlugin();
      // final allInfo = deviceInfo.data;
      if (kIsWeb) {
      } else if (Platform.isAndroid) {
        final deviceInfo =
            await deviceInfoPlugin.deviceInfo as AndroidDeviceInfo;
        deviceInfoData.board = deviceInfo.board;
        deviceInfoData.bootloader = deviceInfo.bootloader;
        deviceInfoData.brand = deviceInfo.brand;
        deviceInfoData.device = deviceInfo.device;
        deviceInfoData.display = deviceInfo.display;
        deviceInfoData.fingerprint = deviceInfo.fingerprint;
        // deviceInfoData.radioversion = deviceInfo.rad;
        deviceInfoData.hardware = deviceInfo.hardware;
        deviceInfoData.host = deviceInfo.host;
        deviceInfoData.buildID = deviceInfo.id;
        deviceInfoData.manufacturer = deviceInfo.manufacturer;
        deviceInfoData.model = deviceInfo.model;
        deviceInfoData.product = deviceInfo.product;
        deviceInfoData.osVersion = deviceInfo.version.release;
        if (deviceInfo.supported32BitAbis.isNotEmpty) {
          deviceInfoData.supported32BitsAbis = deviceInfo.supported32BitAbis;
        } else if (deviceInfo.supported64BitAbis.isNotEmpty) {
          deviceInfoData.supported64BitsAbis = deviceInfo.supported64BitAbis;
        }
        deviceInfoData.supportedAbis = deviceInfo.supportedAbis;
        deviceInfoData.tags = deviceInfo.tags;
        // deviceInfoData.time = deviceInfo.time;
        deviceInfoData.buildType = deviceInfo.type;
        // deviceInfoData.unknown = deviceInfo.unknown;
        // deviceInfoData.user = deviceInfo.user;
        // deviceInfoData.cpuAbi = deviceInfo.cpuApi;
        // deviceInfoData.cpuAbi2 = deviceInfo.cpuAbi2;
        // deviceInfoData.serial = deviceInfo.serial;
        // deviceInfoData.versionSdkInt = deviceInfo.versionSdkInt;
        // deviceInfoData.sdk = deviceInfo.sdk;
        // deviceInfoData.versionBaseOS = deviceInfo.versionBaseOS;
        // deviceInfoData.versionCodename = deviceInfo.versionCodeName;
        deviceInfoData.primaryAppVersion = packageInfo.version;
      } else if (Platform.isIOS) {
        final deviceInfo = await deviceInfoPlugin.deviceInfo as IosDeviceInfo;
        deviceInfoData.board = deviceInfo.systemName;
        deviceInfoData.bootloader = deviceInfo.systemVersion;
        deviceInfoData.brand = deviceInfo.model;
        deviceInfoData.device = deviceInfo.localizedModel;
        // deviceInfoData.display = '';
        // deviceInfoData.fingerprint = deviceInfo.fingerprint;
        // deviceInfoData.hardware = deviceInfo.hardware;
        // deviceInfoData.host = deviceInfo.host;
        // deviceInfoData.buildID = deviceInfo.id;
        // deviceInfoData.manufacturer = deviceInfo.manufacturer;
        deviceInfoData.model = deviceInfo.model;
        // deviceInfoData.product = deviceInfo.product;
        // if(deviceInfo.supported32BitAbis.isNotEmpty) {
        //   deviceInfoData.supported32BitsAbis = deviceInfo.supported32BitAbis;
        // } else if(deviceInfo.supported64BitAbis.isNotEmpty) {
        //   deviceInfoData.supported64BitsAbis = deviceInfo.supported64BitAbis;
        // }
        // deviceInfoData.supportedAbis = deviceInfo.supportedAbis;
        // deviceInfoData.tags = deviceInfo.tags;
        // deviceInfoData.time = deviceInfo.time;
        // deviceInfoData.buildType = deviceInfo.type;
        // deviceInfoData.unknown = deviceInfo.unknown;
        // deviceInfoData.user = deviceInfo.user;
        // deviceInfoData.cpuAbi = deviceInfo.cpuApi;
        // deviceInfoData.cpuAbi2 = deviceInfo.cpuAbi2;
        // deviceInfoData.serial = deviceInfo.serial;
        // deviceInfoData.versionSdkInt = deviceInfo.versionSdkInt;
        // deviceInfoData.sdk = deviceInfo.sdk;
        // deviceInfoData.versionBaseOS = deviceInfo.versionBaseOS;
        // deviceInfoData.versionCodename = deviceInfo.versionCodeName;
      }
      deviceInfoData.primaryAppVersion = packageInfo.version;
      return deviceInfoData;
    } catch (e, st) {
      AppLog.e('getDeviceInfoData : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }
}
