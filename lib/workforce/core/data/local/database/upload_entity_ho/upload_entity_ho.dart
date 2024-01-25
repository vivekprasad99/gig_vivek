import 'package:awign/workforce/aw_questions/data/model/upload_or_sync/upload_status.dart';
import 'package:awign/workforce/core/data/local/database/boxes.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/trackable_entity_ho.dart';
import 'package:hive/hive.dart';

import '../../../../../../packages/flutter_image_editor/model/image_details.dart';

part 'upload_entity_ho.g.dart';

@HiveType(typeId: Boxes.uploadEntityHoTypeID)
class UploadEntityHO extends HiveObject {
  @HiveField(0)
  String? uploadStatus;
  @HiveField(1)
  String? downloadStatus;
  @HiveField(2)
  String? uploadedFileUrl;
  @HiveField(3, defaultValue: 0)
  int? uploadedBytes;
  @HiveField(4, defaultValue: 1)
  int? totalBytes;
  @HiveField(5)
  bool? isUploading;
  @HiveField(6)
  String? uploadFileQuality;
  @HiveField(7)
  String? originalFileName;
  @HiveField(8)
  String? originalFilePath;
  @HiveField(9)
  String? lowQualityFileName;
  @HiveField(10)
  String? lowQualityFilePath;
  @HiveField(11)
  String? mediumQualityFileName;
  @HiveField(12)
  String? mediumQualityFilePath;
  @HiveField(13)
  int? nestedArrayIndex;
  @HiveField(14)
  String? fileStorage;
  @HiveField(15)
  String? syncType;
  @HiveField(16)
  String? syncDataType;
  @HiveField(17)
  String? urlPath;
  @HiveField(18)
  String? filePathType;
  @HiveField(19)
  String? questionOrLeadAttributeID;
  @HiveField(20)
  String? leadID;
  @HiveField(21)
  String? screenID;
  @HiveField(22)
  String? executionID;
  @HiveField(23)
  String? projectID;
  @HiveField(24)
  String? projectRoleID;
  @HiveField(25)
  String? nestedQuestionUID;
  @HiveField(26)
  String? nestedQuestionIndex;
  @HiveField(27, defaultValue: 0)
  int? uploadFailedCount;
  @HiveField(28, defaultValue: 0)
  int? syncFailedCount;
  @HiveField(29, defaultValue: false)
  bool? isDeleted;
  @HiveField(30, defaultValue: false)
  bool? isPaused;
  @HiveField(31)
  TrackableDataHO? trackableData;
  @HiveField(32, defaultValue: false)
  bool? isMetaDataType;
  @HiveField(33, defaultValue: false)
  bool? isTrackableType;
  @HiveField(34)
  int? createdAt;
  @HiveField(35)
  int? updatedAt;
  @HiveField(36)
  bool? uploadLater;
  @HiveField(37)
  String? questionID;
  @HiveField(38)
  String? uploadFileName;
  @HiveField(39)
  String? s3FolderPath;
  @HiveField(40)
  int? totalFileSize;
  @HiveField(41)
  bool? isAsync;
  @HiveField(42)
  String? questionUID;

  ImageDetails getImageDetails() {
    return ImageDetails(
        uploadEntityHOKey: key,
        originalFileName: originalFileName,
        originalFilePath: originalFilePath,
        lowQualityFileName: lowQualityFileName,
        lowQualityFilePath: lowQualityFilePath,
        uploadLater: uploadLater ?? false,
        isUploadLaterSelected: isPaused ?? false,
        fileQuality: FileQuality.get(uploadFileQuality),
        uploadStatus: UploadStatus.get(uploadStatus),
        url: uploadedFileUrl,
        isAsync: isAsync ?? false);
  }

  bool isArray() {
    return syncDataType == "array";
  }
}
