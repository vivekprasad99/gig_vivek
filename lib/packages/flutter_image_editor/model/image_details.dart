import 'dart:io';

import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';

import '../../../workforce/aw_questions/data/model/answer/trackable_data.dart';
import '../../../workforce/aw_questions/data/model/data_type.dart';
import '../../../workforce/aw_questions/data/model/question.dart';
import '../../../workforce/aw_questions/data/model/upload_or_sync/upload_status.dart';

class FileQuality<String> extends Enum1<String> {
  const FileQuality(String val) : super(val);

  static const FileQuality low = FileQuality('low');
  static const FileQuality medium = FileQuality('medium');
  static const FileQuality high = FileQuality('high');

  static FileQuality get(dynamic value) {
    switch (value) {
      case 'low':
        return FileQuality.low;
      case 'medium':
        return FileQuality.medium;
      case 'high':
        return FileQuality.high;
      default:
        return FileQuality.low;
    }
  }
}

class FilePathType<String> extends Enum1<String> {
  const FilePathType(String val) : super(val);

  static const FilePathType filePath = FilePathType('file_Path');
  static const FilePathType uri = FilePathType('uri');
}

class ImageDetails {
  ImageDetails({
    this.uploadEntityHOKey,
    this.originalFileName,
    this.originalFilePath,
    this.lowQualityFileName,
    this.lowQualityFilePath,
    this.mediumQualityFileName,
    this.mediumQualityFilePath,
    this.url,
    this.uploadLater = false,
    this.isMetaDataType = false,
    this.isTrackableType = false,
    this.fileQuality = FileQuality.low,
    this.isUploadLaterSelected = false,
    this.rotationAngle = 0,
    this.subFolderName = '',
    this.question,
    this.uploadStatus = UploadStatus.uploadNotStarted,
    this.isOpenImageEditor = true,
    this.isAsync = false,
    this.dataType = DataType.single,
    this.fromRoute,
    this.trackableData,
    this.isFrontCamera = false,
  }) {
    if (subFolderName.isEmpty) {
      subFolderName = 'Image_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  late int? uploadEntityHOKey;
  late String? originalFileName;
  late String? originalFilePath;
  late String? lowQualityFileName;
  late String? lowQualityFilePath;
  late String? mediumQualityFileName;
  late String? mediumQualityFilePath;
  late String? url;
  late bool uploadLater;
  late bool isMetaDataType;
  late bool isTrackableType;
  late FileQuality fileQuality;
  late bool isUploadLaterSelected;
  late int rotationAngle;
  late String subFolderName;
  List<ImageDetails>? imageDetailsList;
  Question? question;
  late UploadStatus uploadStatus;
  late bool isOpenImageEditor;
  late bool isAsync;
  late DataType dataType;
  late String? fromRoute;
  late TrackableData? trackableData;
  late bool isFrontCamera;

  ImageDetails.fromImageDetails(ImageDetails imageDetails) {
    originalFileName = imageDetails.originalFileName;
    originalFilePath = imageDetails.originalFilePath;
    lowQualityFileName = imageDetails.lowQualityFileName;
    lowQualityFilePath = imageDetails.lowQualityFilePath;
    mediumQualityFileName = imageDetails.mediumQualityFileName;
    mediumQualityFilePath = imageDetails.mediumQualityFilePath;
    url = imageDetails.url;
    uploadLater = imageDetails.uploadLater;
    isMetaDataType = imageDetails.isMetaDataType;
    isTrackableType = imageDetails.isTrackableType;
    fileQuality = imageDetails.fileQuality;
    isUploadLaterSelected = imageDetails.isUploadLaterSelected;
    rotationAngle = imageDetails.rotationAngle;
    subFolderName = imageDetails.subFolderName;
    imageDetailsList = imageDetails.imageDetailsList;
    question = imageDetails.question;
    uploadStatus = imageDetails.uploadStatus;
    uploadEntityHOKey = imageDetails.uploadEntityHOKey;
    isOpenImageEditor = imageDetails.isOpenImageEditor;
    isAsync = imageDetails.isAsync;
    dataType = imageDetails.dataType;
    fromRoute = imageDetails.fromRoute;
    trackableData = imageDetails.trackableData;
  }

  File? getFile() {
    if (fileQuality == FileQuality.low && lowQualityFilePath != null) {
      return File(lowQualityFilePath!);
    } else if (fileQuality == FileQuality.high && originalFilePath != null) {
      return File(originalFilePath!);
    } else if (lowQualityFilePath != null) {
      return File(lowQualityFilePath!);
    } else if (originalFilePath != null) {
      return File(originalFilePath!);
    } else {
      return null;
    }
  }

  Future<void> deleteFile() async {
    if (lowQualityFilePath != null) {
      File file = File(lowQualityFilePath!);
      await file.delete();
    }
    if (originalFilePath != null) {
      File file = File(originalFilePath!);
      await file.delete();
    }
  }

  String? getFileName() {
    File? file = getFile();
    if (file != null) {
      return file.name ?? '';
    } else if (url != null) {
      return FileUtils.getFileNameFromFilePath(url!);
    } else {
      return null;
    }
  }
}
