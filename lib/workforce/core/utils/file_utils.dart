import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

class FileUtils {
  static void downloadFile(BuildContext context, String url) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!FlutterDownloader.initialized) {
      await FlutterDownloader.initialize(
          debug: true // optional: set false to disable printing logs to console
          );
    }
    TargetPlatform? platform = Theme.of(context).platform;
    final hasGranted = await checkStoragePermission(platform);
    if (hasGranted) {
      Tuple2<String, Directory>? localPath = await _prepareSaveDir();
      if (localPath != null) {
        requestDownload(url, localPath.item1);
      }
    }
  }

  static Future<bool> download(BuildContext context, String url) async {
    TargetPlatform? platform = Theme.of(context).platform;
    bool hasPermission = await checkStoragePermission(platform);
    if (!hasPermission) return false;

    Dio dio = Dio();
    Tuple2<String, Directory>? localPath = await _prepareSaveDir();
    // You should put the name you want for the file here.
    // Take in account the extension.
    String fileName = url;
    if (localPath != null) {
      await dio.download(url, "${localPath.item1}/$fileName");
    }
    return true;
  }

  static Future<String?> getAudioFilePath(BuildContext context) async {
    TargetPlatform? platform = Theme.of(context).platform;
    final hasGranted = await checkStoragePermission(platform);
    if (hasGranted) {
      Tuple2<String, Directory>? filePath = await _prepareSaveDir();
      if (filePath != null) {
        return '${filePath.item1}/Audio${DateTime.now().millisecondsSinceEpoch}.mp4';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<String?> getImageFilePath(BuildContext context) async {
    TargetPlatform? platform = Theme.of(context).platform;
    final hasGranted = await checkStoragePermission(platform);
    if (hasGranted) {
      Tuple2<String, Directory>? filePath = await _prepareSaveDir();
      if (filePath != null) {
        return '${filePath.item1}/Image${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<Tuple2<String, Directory>?> getSubFolderPath(
      BuildContext context, String subFolderName) async {
    TargetPlatform? platform = Theme.of(context).platform;
    final hasGranted = await checkStoragePermission(platform);
    if (hasGranted) {
      Tuple2<String, Directory>? folderPath =
          await _prepareSaveDir(subFolderName: subFolderName);
      if (folderPath != null) {
        return folderPath;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<bool> checkStoragePermission(TargetPlatform? platform) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) return true;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (platform == TargetPlatform.android &&
        androidInfo.version.sdkInt! <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  static Future<Tuple2<String, Directory>?> _prepareSaveDir(
      {String? subFolderName}) async {
    String? localPath = (await _findLocalPath(subFolderName: subFolderName));
    if (localPath != null) {
      final savedDir = Directory(localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        if (subFolderName != null) {
          await savedDir.create(recursive: true);
        } else {
          await savedDir.create();
        }
      }
      return Tuple2(localPath, savedDir);
    } else {
      return null;
    }
  }

  static Future<String?> _findLocalPath({String? subFolderName}) async {
    try {
      var externalStorageDirPath;
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          externalStorageDirPath = await AndroidPathProvider.downloadsPath;
        } catch (e) {
          final directory = await getExternalStorageDirectory();
          externalStorageDirPath = directory?.path;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        externalStorageDirPath =
            (await getApplicationDocumentsDirectory()).absolute.path;
      }
      if (subFolderName != null) {
        return '$externalStorageDirPath/Awign/$subFolderName';
      } else {
        return '$externalStorageDirPath/Awign';
      }
    } catch (e, stacktrace) {
      AppLog.e('_findLocalPath : ${e.toString()} \n${stacktrace.toString()}');
    }
    return null;
  }

  static void requestDownload(String url, String localPath) async {
    try {
      String? result = await FlutterDownloader.enqueue(
        url: url,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: localPath,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
      AppLog.i('result : $result');

      FlutterDownloader.registerCallback((id, status, progress) {
        // Handle callbacks here
        if (result == id && status == DownloadTaskStatus.complete) {
          Fluttertoast.showToast(
              msg: "Download completed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      });
    } catch (e, stacktrace) {
      AppLog.e('requestDownload : ${e.toString()} \n${stacktrace.toString()}');
    }
  }

  static Future<String?> downloadAndSaveImage(String url) async {
    try {
      Response response = await Dio().get(
        url,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              if (status != null) {
                return status < 500;
              } else {
                return false;
              }
            }),
      );
      AppLog.i('downloadImage: ${response.headers}');
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      File file = File(filePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return filePath;
    } catch (e, st) {
      AppLog.e('downloadImage : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  static String getFileNameFromFilePath(String filePath) {
    return filePath.split("/").last;
  }

  static Future<int> getFileSizeInBytes(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return 0;
    return bytes;
  }

  static Tuple2<String, String> getFileUploadedSizeAndTotalSize(
      String filePath, int totalSizeInBytes, int percentage) {
    double uploadedSizeInBytes = (percentage / 100) * totalSizeInBytes;
    return Tuple2(getReadableFileSize(uploadedSizeInBytes.toInt()),
        getReadableFileSize(totalSizeInBytes.toInt()));
  }

  /// A method returns a human readable string representing a file _size
  static String getReadableFileSize(int size, [int round = 2]) {
    /**
     * [size] can be passed as number or as string
     *
     * the optional parameter [round] specifies the number
     * of digits after comma/point (default is 2)
     */
    var divider = 1024;
    int _size;
    try {
      _size = int.parse(size.toString());
    } catch (e) {
      throw ArgumentError('Can not parse the size parameter: $e');
    }

    if (_size < divider) {
      return '$_size B';
    }

    if (_size < divider * divider && _size % divider == 0) {
      return '${(_size / divider).toStringAsFixed(0)} KB';
    }

    if (_size < divider * divider) {
      return '${(_size / divider).toStringAsFixed(round)} KB';
    }

    if (_size < divider * divider * divider && _size % divider == 0) {
      return '${(_size / (divider * divider)).toStringAsFixed(0)} MB';
    }

    if (_size < divider * divider * divider) {
      return '${(_size / divider / divider).toStringAsFixed(round)} MB';
    }

    if (_size < divider * divider * divider * divider && _size % divider == 0) {
      return '${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB';
    }

    if (_size < divider * divider * divider * divider) {
      return '${(_size / divider / divider / divider).toStringAsFixed(round)} GB';
    }

    if (_size < divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider;
      return '${r.toStringAsFixed(0)} TB';
    }

    if (_size < divider * divider * divider * divider * divider) {
      num r = _size / divider / divider / divider / divider;
      return '${r.toStringAsFixed(round)} TB';
    }

    if (_size < divider * divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider / divider;
      return '${r.toStringAsFixed(0)} PB';
    } else {
      num r = _size / divider / divider / divider / divider / divider;
      return '${r.toStringAsFixed(round)} PB';
    }
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      return {
        "device_name": '',
        "operating_system": 'Web',
        "os_version": '',
        "model": ''
      };
    } else if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return {
        "device_name": androidInfo.device ?? '',
        "operating_system": 'Android',
        "os_version": Platform.operatingSystemVersion,
        "model": androidInfo.model ?? ''
      };
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return {
        "device_name": iosInfo.name ?? "",
        "operating_system": 'iOS',
        "os_version": Platform.operatingSystemVersion,
        "model": iosInfo.model ?? ''
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<String?> shareImages(String url) async {
    try {
      Response response = await Dio().get(
        url,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              if (status != null) {
                return status < 500;
              } else {
                return false;
              }
            }),
      );
      AppLog.i('shareImages: ${response.headers}');
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      File file = File(filePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      Share.shareFiles([filePath!]);
      return filePath;
    } catch (e, st) {
      AppLog.e('shareImages : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }
}
