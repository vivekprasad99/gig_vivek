import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

import '../../../../../execution_in_house/data/model/resource.dart';

abstract class WorkApplicationRemoteDataSource {
  Future<WorkApplicationEntity> fetchWorkApplication(
      int userID, int applicationID);

  Future<TimelineSectionEntity> fetchTimeline(int userID, int applicationID);

  Future<ResourceResponse> fetchResource(int userID, int applicationID);

  Future<Map<String, dynamic>> applicationCreate(
      String categoryID,
      String supplyID,
      WorkApplicationCreateRequest workApplicationCreateRequest);
}

class WorkApplicationRemoteDataSourceImpl extends WosAPI
    implements WorkApplicationRemoteDataSource {
  @override
  Future<WorkApplicationEntity> fetchWorkApplication(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchWorkApplicationAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TimelineSectionEntity> fetchTimeline(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchTimelineAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return TimelineSectionEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ResourceResponse> fetchResource(int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchResourcesAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return ResourceResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> applicationCreate(
      String categoryID,
      String supplyID,
      WorkApplicationCreateRequest workApplicationCreateRequest) async {
    try {
      Response response = await wosRestClient.post(
          applicationCreateAPI
              .replaceAll('categoryID', categoryID)
              .replaceAll('supplyID', supplyID),
          body: workApplicationCreateRequest.toJson());
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
