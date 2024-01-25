import 'dart:io';

import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

import '../../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../../aw_questions/data/model/answer/trackable_data.dart';
import '../upload_entity_ho/trackable_entity_ho.dart';

class UploadEntityHOMapper {
  static UploadEntityHO uploadEntityHOFromImageDetails(
      ImageDetails imageDetails) {
    File file = imageDetails.getFile()!;
    String? uploadFileName, s3FolderPath;
    uploadFileName = file.name?.cleanForUrl();
    s3FolderPath =
        imageDetails.question?.parentReference?.getUploadPath(file.name!);

    UploadEntityHO uploadEntityHO = UploadEntityHO() //
      ..uploadStatus = imageDetails.uploadStatus.value
      ..originalFileName = imageDetails.originalFileName
      ..originalFilePath = imageDetails.originalFilePath
      ..lowQualityFileName = imageDetails.lowQualityFileName
      ..lowQualityFilePath = imageDetails.lowQualityFilePath
      // nestedArrayIndex
      ..syncDataType = imageDetails.question?.dataType?.value
      ..isTrackableType =
          (imageDetails.question?.configuration?.isLocationTrackable == true ||
              imageDetails.question?.configuration?.isTimeTrackable == true)
      ..isMetaDataType =
          imageDetails.question?.configuration?.imageMetaData != null
      ..trackableData = transformTrackableData(imageDetails.trackableData)
      ..uploadLater = imageDetails.uploadLater
      ..isPaused = imageDetails.isUploadLaterSelected
      ..uploadFileQuality = imageDetails.fileQuality.value
      ..uploadFileName = uploadFileName
      ..s3FolderPath = s3FolderPath
      // ..totalFileSize = totalFileSize
      ..questionID = imageDetails.question?.questionID
      ..isAsync = imageDetails.isAsync
      ..questionUID = imageDetails.question?.configuration?.uid
      ..leadID = imageDetails.question?.leadID
      ..screenID = imageDetails.question?.screenID
      ..executionID = imageDetails.question?.executionID
      ..projectID = imageDetails.question?.projectID
      ..projectRoleID = imageDetails.question?.selectedProjectRole
          ?.toLowerCase()
          .replaceAll(' ', '_');
    // nestedQuestionUID = imageDetails.question?.configuration?.uid ?? '';
    // nestedQuestionIndex = imageDetails.question?.configuration?.uid ?? '';
    return uploadEntityHO;
  }

  static TrackableDataHO? transformTrackableData(TrackableData? trackableData) {
    if (trackableData == null) return null;
    return TrackableDataHO(
      accuracy: trackableData.accuracy,
      address: trackableData.address,
      area: trackableData.area,
      city: trackableData.city,
      countryName: trackableData.countryName,
      latLong: trackableData.latLong,
      pinCode: trackableData.pinCode,
      timeStamp: trackableData.timeStamp,
    );
  }
}
