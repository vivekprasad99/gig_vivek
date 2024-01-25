import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/model/signature_response.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class ExecutionRemoteDataSource {
  Future<ApiResponse> getExecutions(
      String memberID, AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> getSignatures(String memberID);

  Future<ApiResponse> createSignature(
      String memberID, CreateSignatureRequest createSignatureRequest);

  Future<ApiResponse> acceptOfferLetter(
      String projectID, String executionID, String signatureID);

  Future<ApiResponse> fetchSummaryView(String executionID, String projectRoleUID);

  Future<ApiResponse> fetchLeadBlock(String executionID, String projectRoleUID, String listViewID, String summaryViewID);
}

class ExecutionRemoteDataSourceImpl extends InHouseOMSAPI
    implements ExecutionRemoteDataSource {
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
  Future<ApiResponse> getSignatures(String memberID) async {
    try {
      Response response = await inHouseOMSRestClient
          .post(signaturesAPI.replaceAll('memberID', memberID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createSignature(
      String memberID, CreateSignatureRequest createSignatureRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          createSignatureAPI.replaceAll('memberID', memberID),
          body: createSignatureRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> acceptOfferLetter(
      String projectID, String executionID, String signatureID) async {
    try {
      Response response = await inHouseOMSRestClient.patch(acceptOfferLetterAPI
          .replaceAll('projectID', projectID)
          .replaceAll('executionID', executionID)
          .replaceAll('signatureID', signatureID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> fetchSummaryView(String executionID, String projectRoleUID) async {
    try {
      Response response = await inHouseOMSRestClient.post(fetchSummaryViewAPI
          .replaceAll('executionID', executionID)
          .replaceAll('projectRoleUID', projectRoleUID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> fetchLeadBlock(String executionID, String projectRoleUID, String listViewID, String summaryViewID) async {
    try {
      Response response = await inHouseOMSRestClient.post(fetchLeadBlockAPI
          .replaceAll('executionID', executionID)
          .replaceAll('projectRoleUID', projectRoleUID)
          .replaceAll('listViewID', listViewID)
          .replaceAll('summaryViewID', summaryViewID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
