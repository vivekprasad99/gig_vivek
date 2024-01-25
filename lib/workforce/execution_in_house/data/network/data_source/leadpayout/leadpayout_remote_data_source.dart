import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class LeadPayoutRemoteDataSource {
  Future<ApiResponse> getLeadPayoutAmount(String executionID);

  Future getLeadPayoutDetails(AdvancedSearchRequest advancedSearchRequest);

  Future getEarningsBreakup(AdvancedSearchRequest advancedSearchRequest,String executionID);
}

class LeadPayoutRemoteDataSourceImpl extends InHouseOMSAPI
    implements LeadPayoutRemoteDataSource {
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
  Future getLeadPayoutDetails(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(getLeadPayoutsAPI,
          body: advancedSearchRequest.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future getEarningsBreakup(
      AdvancedSearchRequest advancedSearchRequest,String executionID) async {
    try {
      Response response = await inHouseOMSRestClient.post(getEarningsBreakupAPI.replaceAll('execution_id', executionID),
          body: advancedSearchRequest.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
