import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';

import '../../database/boxes.dart';

abstract class UploadEntryLocalDataSource {
  Future<int> upsertEntity(UploadEntityHO uploadEntityHO);
  List<UploadEntityHO> getUploadEntityHOList(
      {String? questionID, String? leadID, String? status, bool? isPaused});
  UploadEntityHO? getUploadEntityHO({int? uploadEntityHOKey});
  void deleteUploadEntityHO(int? uploadEntityHOKey);
}

class UploadEntryLocalDataSourceImpl implements UploadEntryLocalDataSource {
  @override
  Future<int> upsertEntity(UploadEntityHO uploadEntityHO) {
    try {
      return Boxes.getUploadEntityBox().add(uploadEntityHO);
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<UploadEntityHO> getUploadEntityHOList(
      {String? questionID, String? leadID, String? status, bool? isPaused}) {
    try {
      Iterable<UploadEntityHO> uploadEntityHOList =
          Boxes.getUploadEntityBox().values;
      if (status != null) {
        uploadEntityHOList = uploadEntityHOList
            .where((element) => element.uploadStatus == status);
      }
      if (isPaused != null) {
        uploadEntityHOList =
            uploadEntityHOList.where((element) => element.isPaused == isPaused);
      }
      if (questionID != null && leadID != null) {
        uploadEntityHOList = uploadEntityHOList.where((element) =>
            element.questionID == questionID && element.leadID == leadID);
      }
      if (uploadEntityHOList.isNotEmpty) {
        return uploadEntityHOList.toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  UploadEntityHO? getUploadEntityHO({int? uploadEntityHOKey}) {
    try {
      if (uploadEntityHOKey != null) {
        return Boxes.getUploadEntityBox().get(uploadEntityHOKey);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  void deleteUploadEntityHO(int? uploadEntityHOKey) {
    Boxes.getUploadEntityBox().delete(uploadEntityHOKey);
  }
}
