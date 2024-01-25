import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_amount.dart';
import 'package:awign/workforce/execution_in_house/data/model/project.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/dashboard_remote_data_source.dart';
import 'package:tuple/tuple.dart';

abstract class DashboardRemoteRepository {
  Future<Tuple2<ExecutionsResponse, String>> getExecutions(
      int page, ExecutionPageParameters executionPageParameters);

  Future<ApiResponse> getTabs(String executionID, String projectRole);

  Future<Project> getProject(String projectID);

  Future<LeadPayoutAmount> getLeadPayoutAmount(String executionID);

  Future<ApiResponse> certificateStatusUpdate(
      String projectID, String executionID, String status);

  Future<ExecutionsResponse> requestWork(String executionID);

  Future<Execution> getExecution(String executionID, String projectID);
}

class DashboardRemoteRepositoryImpl implements DashboardRemoteRepository {
  final DashboardRemoteDataSource _dataSource;

  DashboardRemoteRepositoryImpl(this._dataSource);

  @override
  Future<Tuple2<ExecutionsResponse, String>> getExecutions(
      int page, ExecutionPageParameters executionPageParameters) async {
    try {
      String uIDS = 'category_uids';
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(
              uIDS, Operator.IN, executionPageParameters.uIDs)
          .setSkipSaasOrgId(executionPageParameters.skipSaasOrgId)
          .setLimit(50)
          .setPage(page)
          .build();
      ApiResponse apiResponse = await _dataSource.getExecutions(
          executionPageParameters.memberID, advancedSearchRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            ExecutionsResponse.fromJson(
                apiResponse.data, executionPageParameters.uIDs),
            apiResponse.message ?? '');
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getExecutions : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getTabs(String executionID, String projectRole) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getTabs(executionID, projectRole);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getTabs : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Project> getProject(String projectID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getProject(projectID);
      if (apiResponse.status == ApiResponse.success) {
        return Project.fromJson(apiResponse.data['project']);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getProject : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<LeadPayoutAmount> getLeadPayoutAmount(String executionID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getLeadPayoutAmount(executionID);
      if (apiResponse.status == ApiResponse.success) {
        return LeadPayoutAmount.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getLeadPayoutAmount : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> certificateStatusUpdate(
      String projectID, String executionID, String status) async {
    try {
      Map<String, String> statusMap = {};
      statusMap['_status'] = status;
      Map<String, dynamic> statusUpdateMap = {};
      statusUpdateMap['execution'] = statusMap;
      ApiResponse apiResponse = await _dataSource.certificateStatusUpdate(
          projectID, executionID, statusUpdateMap);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('certificateStatusUpdate : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ExecutionsResponse> requestWork(String executionID) async {
    try {
      ApiResponse apiResponse = await _dataSource.requestWork(executionID);
      if (apiResponse.status == ApiResponse.success) {
        return ExecutionsResponse.fromJson(apiResponse.data, '');
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('requestWork : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Execution> getExecution(String executionID, String projectID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getExecution(executionID, projectID);
      if (apiResponse.status == ApiResponse.success) {
        Map<String, dynamic> data = apiResponse.data as Map<String, dynamic>;
        return Execution.fromJson(data['execution'], '');
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getExecution : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
