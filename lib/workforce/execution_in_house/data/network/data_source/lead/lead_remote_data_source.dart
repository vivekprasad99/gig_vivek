import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/model/call_bridge_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class LeadRemoteDataSource {
  Future<ApiResponse> fetchLeadAnalyze(String executionID,
      String projectRoleUID, AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> searchLeads(LeadRemoteRequest leadRemoteRequest,
      AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> getLead(
      String executionID, String projectRoleID, String leadID);

  Future<ApiResponse> addLead(LeadDataSourceParams? leadDataSourceParams,
      String listViewID);

  Future<ApiResponse> updateLead(String executionID, String screenID,
      String leadID, LeadUpdateRequest leadUpdateRequest);

  Future<ApiResponse> updateLeadStatus(
      LeadDataSourceParams? leadDataSourceParams,
      String screenID,
      String leadID,
      LeadUpdateRequest leadUpdateRequest);

  Future<ApiResponse> callBridge(String leadId, String executionId, CallBridgeRequest callBridgeRequest);

  Future<ApiResponse> cloneLead(String leadId,String executionId,String projectRoleId,String listViewId);

  Future<ApiResponse> deleteLead(String leadId,String executionId,String projectRoleId,String listViewId);
}

class LeadRemoteDataSourceImpl extends InHouseOMSAPI
    implements LeadRemoteDataSource {
  @override
  Future<ApiResponse> fetchLeadAnalyze(String executionID,
      String projectRoleUID,
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          fetchLeadAnalyzeAPI
              .replaceAll('executionID', executionID)
              .replaceAll('projectRoleUID', projectRoleUID),
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> searchLeads(LeadRemoteRequest leadRemoteRequest,
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          searchLeadsAPI
              .replaceAll('executionID',
              leadRemoteRequest.leadDataSourceParams.executionID ?? '')
              .replaceAll('projectRoleUID',
              leadRemoteRequest.leadDataSourceParams.projectRoleUID ?? '')
              .replaceAll('listViewID', leadRemoteRequest.listViewID ?? '')
              .replaceAll('blockID', leadRemoteRequest.blockID ?? ''),
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getLead(
      String executionID, String projectRoleID, String leadID) async {
    try {
      Response response = await inHouseOMSRestClient.get(getLeadAPI
          .replaceAll('executionID', executionID)
          .replaceAll('projectRoleUID', projectRoleID)
          .replaceAll('leadID', leadID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> addLead(LeadDataSourceParams? leadDataSourceParams,
      String listViewID) async {
    try {
      Response response = await inHouseOMSRestClient.post(addLeadAPI
          .replaceAll('executionID', leadDataSourceParams?.executionID ?? '')
          .replaceAll(
          'projectRoleUID', leadDataSourceParams?.projectRoleUID ?? '')
          .replaceAll('listViewID', listViewID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateLead(String executionID, String screenID,
      String leadID, LeadUpdateRequest leadUpdateRequest) async {
    try {
      Response response = await inHouseOMSRestClient.patch(
          updateLeadAPI
              .replaceAll('executionID', executionID)
              .replaceAll('screenID', screenID)
              .replaceAll('leadID', leadID),
          body: leadUpdateRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateLeadStatus(
      LeadDataSourceParams? leadDataSourceParams,
      String screenID,
      String leadID,
      LeadUpdateRequest leadUpdateRequest) async {
    try {
      Response response = await inHouseOMSRestClient.patch(
          updateLeadStatusAPI
              .replaceAll(
              'executionID', leadDataSourceParams?.executionID ?? '')
              .replaceAll(
              'projectRoleUID', leadDataSourceParams?.projectRoleUID ?? '')
              .replaceAll('screenID', screenID)
              .replaceAll('leadID', leadID),
          body: leadUpdateRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> callBridge(String leadId,
      String executionId, CallBridgeRequest callBridgeRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(callBridgeAPI
          .replaceAll("executionID", executionId)
          .replaceAll("leadID", leadId),
          body: callBridgeRequest);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> cloneLead(String leadId,String executionId,String projectRoleId,String listViewId) async {
    try {
      Response response = await inHouseOMSRestClient.post(cloneLeadApi
          .replaceAll("execution_id", executionId)
          .replaceAll("project_role_id", projectRoleId)
          .replaceAll("list_view_id", listViewId)
          .replaceAll("lead_id", leadId));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> deleteLead(String leadId,String executionId,String projectRoleId,String listViewId) async {
    try {
      Response response = await inHouseOMSRestClient.delete(deleteLeadApi
          .replaceAll("execution_id", executionId)
          .replaceAll("project_role_uid", projectRoleId)
          .replaceAll("list_view_id", listViewId)
          .replaceAll("lead_id", leadId));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
