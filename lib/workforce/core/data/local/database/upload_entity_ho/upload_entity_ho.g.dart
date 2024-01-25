// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_entity_ho.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadEntityHOAdapter extends TypeAdapter<UploadEntityHO> {
  @override
  final int typeId = 1;

  @override
  UploadEntityHO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadEntityHO()
      ..uploadStatus = fields[0] as String?
      ..downloadStatus = fields[1] as String?
      ..uploadedFileUrl = fields[2] as String?
      ..uploadedBytes = fields[3] == null ? 0 : fields[3] as int?
      ..totalBytes = fields[4] == null ? 1 : fields[4] as int?
      ..isUploading = fields[5] as bool?
      ..uploadFileQuality = fields[6] as String?
      ..originalFileName = fields[7] as String?
      ..originalFilePath = fields[8] as String?
      ..lowQualityFileName = fields[9] as String?
      ..lowQualityFilePath = fields[10] as String?
      ..mediumQualityFileName = fields[11] as String?
      ..mediumQualityFilePath = fields[12] as String?
      ..nestedArrayIndex = fields[13] as int?
      ..fileStorage = fields[14] as String?
      ..syncType = fields[15] as String?
      ..syncDataType = fields[16] as String?
      ..urlPath = fields[17] as String?
      ..filePathType = fields[18] as String?
      ..questionOrLeadAttributeID = fields[19] as String?
      ..leadID = fields[20] as String?
      ..screenID = fields[21] as String?
      ..executionID = fields[22] as String?
      ..projectID = fields[23] as String?
      ..projectRoleID = fields[24] as String?
      ..nestedQuestionUID = fields[25] as String?
      ..nestedQuestionIndex = fields[26] as String?
      ..uploadFailedCount = fields[27] == null ? 0 : fields[27] as int?
      ..syncFailedCount = fields[28] == null ? 0 : fields[28] as int?
      ..isDeleted = fields[29] == null ? false : fields[29] as bool?
      ..isPaused = fields[30] == null ? false : fields[30] as bool?
      ..trackableData = fields[31] as TrackableDataHO?
      ..isMetaDataType = fields[32] == null ? false : fields[32] as bool?
      ..isTrackableType = fields[33] == null ? false : fields[33] as bool?
      ..createdAt = fields[34] as int?
      ..updatedAt = fields[35] as int?
      ..uploadLater = fields[36] as bool?
      ..questionID = fields[37] as String?
      ..uploadFileName = fields[38] as String?
      ..s3FolderPath = fields[39] as String?
      ..totalFileSize = fields[40] as int?
      ..isAsync = fields[41] as bool?
      ..questionUID = fields[42] as String?;
  }

  @override
  void write(BinaryWriter writer, UploadEntityHO obj) {
    writer
      ..writeByte(43)
      ..writeByte(0)
      ..write(obj.uploadStatus)
      ..writeByte(1)
      ..write(obj.downloadStatus)
      ..writeByte(2)
      ..write(obj.uploadedFileUrl)
      ..writeByte(3)
      ..write(obj.uploadedBytes)
      ..writeByte(4)
      ..write(obj.totalBytes)
      ..writeByte(5)
      ..write(obj.isUploading)
      ..writeByte(6)
      ..write(obj.uploadFileQuality)
      ..writeByte(7)
      ..write(obj.originalFileName)
      ..writeByte(8)
      ..write(obj.originalFilePath)
      ..writeByte(9)
      ..write(obj.lowQualityFileName)
      ..writeByte(10)
      ..write(obj.lowQualityFilePath)
      ..writeByte(11)
      ..write(obj.mediumQualityFileName)
      ..writeByte(12)
      ..write(obj.mediumQualityFilePath)
      ..writeByte(13)
      ..write(obj.nestedArrayIndex)
      ..writeByte(14)
      ..write(obj.fileStorage)
      ..writeByte(15)
      ..write(obj.syncType)
      ..writeByte(16)
      ..write(obj.syncDataType)
      ..writeByte(17)
      ..write(obj.urlPath)
      ..writeByte(18)
      ..write(obj.filePathType)
      ..writeByte(19)
      ..write(obj.questionOrLeadAttributeID)
      ..writeByte(20)
      ..write(obj.leadID)
      ..writeByte(21)
      ..write(obj.screenID)
      ..writeByte(22)
      ..write(obj.executionID)
      ..writeByte(23)
      ..write(obj.projectID)
      ..writeByte(24)
      ..write(obj.projectRoleID)
      ..writeByte(25)
      ..write(obj.nestedQuestionUID)
      ..writeByte(26)
      ..write(obj.nestedQuestionIndex)
      ..writeByte(27)
      ..write(obj.uploadFailedCount)
      ..writeByte(28)
      ..write(obj.syncFailedCount)
      ..writeByte(29)
      ..write(obj.isDeleted)
      ..writeByte(30)
      ..write(obj.isPaused)
      ..writeByte(31)
      ..write(obj.trackableData)
      ..writeByte(32)
      ..write(obj.isMetaDataType)
      ..writeByte(33)
      ..write(obj.isTrackableType)
      ..writeByte(34)
      ..write(obj.createdAt)
      ..writeByte(35)
      ..write(obj.updatedAt)
      ..writeByte(36)
      ..write(obj.uploadLater)
      ..writeByte(37)
      ..write(obj.questionID)
      ..writeByte(38)
      ..write(obj.uploadFileName)
      ..writeByte(39)
      ..write(obj.s3FolderPath)
      ..writeByte(40)
      ..write(obj.totalFileSize)
      ..writeByte(41)
      ..write(obj.isAsync)
      ..writeByte(42)
      ..write(obj.questionUID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadEntityHOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
