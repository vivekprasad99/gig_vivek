import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class DashboardRemoteDataSource {
  Future<ApiResponse> getExecutions(
      String memberID, AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> getTabs(String executionID, String projectRole);

  Future<ApiResponse> getProject(String projectID);

  Future<ApiResponse> getLeadPayoutAmount(String executionID);

  Future<ApiResponse> certificateStatusUpdate(String projectID,
      String executionID, Map<String, dynamic> statusUpdateMap);

  Future<ApiResponse> requestWork(String executionID);

  Future<ApiResponse> getExecution(String executionID, String projectID);
}

class DashboardRemoteDataSourceImpl extends InHouseOMSAPI
    implements DashboardRemoteDataSource {
  @override
  Future<ApiResponse> getExecutions(
      String memberID, AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          executionsAPI.replaceAll('memberID', memberID),
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getTabs(String executionID, String projectRole) async {
    try {
      Response response = await inHouseOMSRestClient.post(getTabsAPI
          .replaceAll('executionID', executionID)
          .replaceAll('projectRole', projectRole));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getProject(String projectID) async {
    try {
      Response response = await inHouseOMSRestClient
          .get(getProjectAPI.replaceAll('projectID', projectID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getLeadPayoutAmount(String executionID) async {
    try {
      Response response = await inHouseOMSRestClient
          .post(getLeadPayoutAmountAPI.replaceAll('executionID', executionID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> certificateStatusUpdate(String projectID,
      String executionID, Map<String, dynamic> statusUpdateMap) async {
    try {
      Response response = await inHouseOMSRestClient.patch(
          certificateStatusUpdateAPI
              .replaceAll('projectID', projectID)
              .replaceAll('executionID', executionID),
          body: statusUpdateMap);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> requestWork(String executionID) async {
    try {
      Response response = await inHouseOMSRestClient
          .patch(requestWorkAPI.replaceAll('executionID', executionID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getExecution(String executionID, String projectID) async {
    try {
      Response response = await inHouseOMSRestClient
          .get(getExecutionAPI.replaceAll('executionID', executionID)
          .replaceAll('projectID', projectID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
