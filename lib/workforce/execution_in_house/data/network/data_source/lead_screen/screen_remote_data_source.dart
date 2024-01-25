import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class ScreenRemoteDataSource {
  Future<ApiResponse> getStartScreen(String executionID, String projectRoleUID,
      AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> getNextScreen(
      String executionID, String leadID, String screenID);
}

class ScreenRemoteDataSourceImpl extends InHouseOMSAPI
    implements ScreenRemoteDataSource {
  @override
  Future<ApiResponse> getStartScreen(String executionID, String projectRoleUID,
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          getScreensAPI
              .replaceAll('executionID', executionID)
              .replaceAll('projectRoleUID', projectRoleUID),
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getNextScreen(
      String executionID, String leadID, String screenID) async {
    try {
      Response response = await inHouseOMSRestClient.get(getNextScreenAPI
          .replaceAll('executionID', executionID)
          .replaceAll('leadID', leadID)
          .replaceAll('screenID', screenID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
