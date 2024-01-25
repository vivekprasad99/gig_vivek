import 'dart:io';

import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:simple_s3/simple_s3.dart';

import '../../model/aws_upload_result.dart';

class RemoteStorageRepository {
  static const bucketName = 'awign-mobile-app';
  static const poolID = 'ap-south-1:eb638975-1875-4e9c-8c6c-3980c8864da7';
  late SimpleS3 _simpleS3;
  bool isUploading = false;

  RemoteStorageRepository() {
    _simpleS3 = SimpleS3();
  }

  Stream getUploadPercentageStream() {
    return _simpleS3.getUploadPercentage;
  }

  void close() {}

  Future<AWSUploadResult?> uploadFile(
      File file, String fileName, String s3FolderPath) async {
    try {
      if (isUploading) {
        return null;
      }
      // _simpleS3 = SimpleS3();
      isUploading = true;
      String url = await _simpleS3.uploadFile(
          file, bucketName, poolID, AWSRegions.apSouth1,
          fileName: fileName, s3FolderPath: s3FolderPath);
      AppLog.i('Upload success URL::::: $url');
      isUploading = false;
      return AWSUploadResult(url: url);
    } catch (e, st) {
      AppLog.e('uploadFile : ${e.toString()} \n${st.toString()}');
      isUploading = false;
      rethrow;
    }
  }
}
