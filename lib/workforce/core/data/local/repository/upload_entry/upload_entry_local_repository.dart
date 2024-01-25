import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/core/data/local/data_srouce/upload_entry/upload_entry_local_data_source.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';

import '../../../../utils/app_log.dart';
import '../../database/helper/upload_entity_ho_mapper.dart';

abstract class UploadEntryLocalRepository {
  Future<int> upsertEntity(ImageDetails imageDetails);
  List<UploadEntityHO> getUploadEntityHOList(
      {String? questionID, String? leadID, String? status, bool? isPaused});
  UploadEntityHO? getUploadEntityHO({int? uploadEntityHOKey});
  void deleteUploadEntityHO(int? uploadEntityHOKey);
}

class UploadEntryLocalRepositoryImpl implements UploadEntryLocalRepository {
  final UploadEntryLocalDataSource _dataSource;

  UploadEntryLocalRepositoryImpl(this._dataSource);

  @override
  Future<int> upsertEntity(ImageDetails imageDetails) {
    try {
      UploadEntityHO uploadEntityHO =
          UploadEntityHOMapper.uploadEntityHOFromImageDetails(imageDetails);
      if (imageDetails.uploadEntityHOKey != null) {
        deleteUploadEntityHO(imageDetails.uploadEntityHOKey);
      }
      return _dataSource.upsertEntity(uploadEntityHO);
    } catch (e, stacktrace) {
      AppLog.e('upsertEntity : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  List<UploadEntityHO> getUploadEntityHOList(
      {String? questionID, String? leadID, String? status, bool? isPaused}) {
    try {
      return _dataSource.getUploadEntityHOList(
          questionID: questionID,
          leadID: leadID,
          status: status,
          isPaused: isPaused);
    } catch (e, stacktrace) {
      AppLog.e('getEntries : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  UploadEntityHO? getUploadEntityHO({int? uploadEntityHOKey}) {
    try {
      return _dataSource.getUploadEntityHO(
          uploadEntityHOKey: uploadEntityHOKey);
    } catch (e, stacktrace) {
      AppLog.e('getEntries : ${e.toString()} \n${stacktrace.toString()}');
      return null;
    }
  }

  @override
  void deleteUploadEntityHO(int? uploadEntityHOKey) {
    try {
      return _dataSource.deleteUploadEntityHO(uploadEntityHOKey);
    } catch (e, stacktrace) {
      AppLog.e(
          'deleteUploadEntityHO : ${e.toString()} \n${stacktrace.toString()}');
    }
  }
}
