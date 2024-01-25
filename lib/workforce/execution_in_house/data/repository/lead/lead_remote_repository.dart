import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/execution_in_house/data/model/call_bridge_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/lead/lead_remote_data_source.dart';

abstract class LeadRemoteRepository {
  Future<LeadsAnalysis> fetchLeadAnalyze(
      String executionID, String projectRoleUID);

  Future<LeadSearchResponse> searchLeads(
      LeadRemoteRequest leadRemoteRequest, int page);

  Future<Lead> getLead(String executionID, String projectRoleID, String leadID);

  Future<Lead> addLead(
      LeadDataSourceParams? leadDataSourceParams, String listViewID);

  Future<Lead> updateLead(String executionID, String screenID, String leadID,
      List<ScreenRow>? screenRowList,
      {Map<String, dynamic>? answerMap});

  Future<ApiResponse> updateLeadStatus(
      LeadDataSourceParams? leadDataSourceParams,
      String screenID,
      String leadID,
      String status);

  Future<ApiResponse> callBridge(
      String leadId, String executionId, CallBridgeRequest callBridgeRequest);

  Future<Lead> cloneLead(String leadId,LeadDataSourceParams? leadDataSourceParams,String listViewId);

  Future<ApiResponse> deleteLead(String leadId,LeadDataSourceParams? leadDataSourceParams,String listViewId);
}

class LeadRemoteRepositoryImpl implements LeadRemoteRepository {
  final LeadRemoteDataSource _dataSource;

  LeadRemoteRepositoryImpl(this._dataSource);

  @override
  Future<LeadsAnalysis> fetchLeadAnalyze(
      String executionID, String projectRoleUID) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder().build();
      ApiResponse apiResponse = await _dataSource.fetchLeadAnalyze(
          executionID, projectRoleUID, advancedSearchRequest);
      if (apiResponse.status == ApiResponse.success) {
        return LeadsAnalysis.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('fetchLeadAnalyze : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<LeadSearchResponse> searchLeads(
      LeadRemoteRequest leadRemoteRequest, int page) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder();
      advancedSearchRequest.setConditions(leadRemoteRequest.filters);
      advancedSearchRequest.setSortOrder(Constants.desc);
      advancedSearchRequest.setSortColumn(Constants.updatedAt);
      advancedSearchRequest.setPage(page);
      if (leadRemoteRequest.searchTerm != null) {
        advancedSearchRequest.setSearchTerm(leadRemoteRequest.searchTerm!);
      }
      ApiResponse apiResponse = await _dataSource.searchLeads(
          leadRemoteRequest, advancedSearchRequest.build());
      if (apiResponse.status == ApiResponse.success) {
        return LeadSearchResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('searchLeads : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Lead> getLead(
      String executionID, String projectRoleID, String leadID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getLead(executionID, projectRoleID, leadID);
      if (apiResponse.status == ApiResponse.success) {
        return Lead.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getLead : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Lead> addLead(
      LeadDataSourceParams? leadDataSourceParams, String listViewID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.addLead(leadDataSourceParams, listViewID);
      if (apiResponse.status == ApiResponse.success) {
        return Lead.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('addLead : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Lead> updateLead(String executionID, String screenID, String leadID,
      List<ScreenRow>? screenRowList,
      {Map<String, dynamic>? answerMap}) async {
    try {
      Map<String, dynamic> leadAnswerMap = {};
      if (screenRowList != null) {
        leadAnswerMap =
            AnswerUnitMapper.transformScreenRowForUpdateLead(screenRowList);
      } else if (answerMap != null) {
        leadAnswerMap = answerMap;
      }
      LeadUpdateRequest leadUpdateRequest =
          LeadUpdateRequest(leadAnswerMap, null);
      ApiResponse apiResponse = await _dataSource.updateLead(
          executionID, screenID, leadID, leadUpdateRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Lead.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateLead : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateLeadStatus(
      LeadDataSourceParams? leadDataSourceParams,
      String screenID,
      String leadID,
      String status) async {
    try {
      Map<String, String> leadStatusMap = {Lead.sstatus: status};
      LeadUpdateRequest leadUpdateRequest =
          LeadUpdateRequest(leadStatusMap, null);
      ApiResponse apiResponse = await _dataSource.updateLeadStatus(
          leadDataSourceParams, screenID, leadID, leadUpdateRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateLeadStatus : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> callBridge(String leadId, String executionId,
      CallBridgeRequest callBridgeRequest) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.callBridge(leadId, executionId, callBridgeRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('callBridge : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Lead> cloneLead(String leadId,LeadDataSourceParams? leadDataSourceParams,String listViewId) async {
    try {
      ApiResponse apiResponse =
      await _dataSource.cloneLead(leadId, leadDataSourceParams?.executionID ?? "",leadDataSourceParams?.projectRoleUID ?? "",listViewId);
      if (apiResponse.status == ApiResponse.success) {
        return Lead.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('cloneLead : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> deleteLead(String leadId,LeadDataSourceParams? leadDataSourceParams,String listViewId) async {
    try {
      ApiResponse apiResponse =
      await _dataSource.deleteLead(leadId, leadDataSourceParams?.executionID ?? "",leadDataSourceParams?.projectRoleUID ?? "",listViewId);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('cloneLead : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
