import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/work_application/work_application_remote_data_source.dart';

import '../../../../execution_in_house/data/model/resource.dart';

abstract class WorkApplicationRemoteRepository {
  Future<WorkApplicationEntity> fetchWorkApplication(
      int userID, int applicationID);

  Future<TimelineSectionEntity> fetchTimeline(int userID, int applicationID);

  Future<ResourceResponse> fetchResource(int userID, int applicationID);

  Future<Map<String, dynamic>> applicationCreate(
      String categoryID, String supplyID, String workListingId);
}

class WorkApplicationRemoteRepositoryImpl
    implements WorkApplicationRemoteRepository {
  final WorkApplicationRemoteDataSource _dataSource;

  WorkApplicationRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkApplicationEntity> fetchWorkApplication(
      int userID, int applicationID) async {
    try {
      final workApplicationEntity =
          await _dataSource.fetchWorkApplication(userID, applicationID);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('fetchWorkApplication : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<TimelineSectionEntity> fetchTimeline(
      int userID, int applicationID) async {
    try {
      final timelineSectionEntity =
          await _dataSource.fetchTimeline(userID, applicationID);
      return timelineSectionEntity;
    } catch (e) {
      AppLog.e('fetchTimeline : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<ResourceResponse> fetchResource(int userID, int applicationID) async {
    try {
      final fetchResource =
          await _dataSource.fetchResource(userID, applicationID);
      return fetchResource;
    } catch (e) {
      AppLog.e('fetchTimeline : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> applicationCreate(
      String categoryID, String supplyID, String workListingId) async {
    try {
      CreateRequestData createRequestData =
          CreateRequestData(workListingID: workListingId);
      WorkApplicationCreateRequest workApplicationCreateRequest =
          WorkApplicationCreateRequest(createRequestData);
      Map<String, dynamic> apiResponse = await _dataSource.applicationCreate(
          categoryID, supplyID, workApplicationCreateRequest);
      if (apiResponse.containsKey('message')) {
        throw FailureException(0, apiResponse['message']);
      } else {
        return apiResponse;
      }
    } catch (e, st) {
      AppLog.e('applicationCreate : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
