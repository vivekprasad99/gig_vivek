import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/earning_breakup_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_amount.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/leadpayout/leadpayout_remote_data_source.dart';

abstract class LeadPayoutRemoteRepository {
  Future<LeadPayoutAmount> getLeadPayoutAmount(String executionID);

  Future<List<LeadPayoutEntity>?> getLeadPayoutDetails(
      String leadPayoutId, String executionID);

  Future<List<EarningBreakupEntity>?> getEarningsBreakup(
    EarningBreakupParams pageRequest,
    int page,
  );
}

class LeadPayoutRemoteRepositoryImpl implements LeadPayoutRemoteRepository {
  final LeadPayoutRemoteDataSource _dataSource;

  LeadPayoutRemoteRepositoryImpl(this._dataSource);

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
  Future<List<LeadPayoutEntity>?> getLeadPayoutDetails(
      String leadPayoutId, String executionID) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder();
      advancedSearchRequest
          .setPage(1)
          .setLimit(100)
          .putPropertyToCondition("lead_id", Operator.equal, leadPayoutId)
          .putPropertyToCondition(
              "executive_task_id", Operator.equal, executionID);

      var apiResponse =
          await _dataSource.getLeadPayoutDetails(advancedSearchRequest.build());
      return LeadPayoutResponse.fromJson(apiResponse.data).leadPayoutData!.leadPayouts;
    } catch (e, st) {
      AppLog.e('getLeadPayoutDetails : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<EarningBreakupEntity>?> getEarningsBreakup(
    EarningBreakupParams pageRequest,
    int page,
  ) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder();
      advancedSearchRequest.setPage(page);
      var apiResponse = await _dataSource.getEarningsBreakup(
          advancedSearchRequest.build(), pageRequest.execution!.id!);
      return EarningBreakupResponse.fromJson(apiResponse.data)
          .earningBreakupDataEntity!
          .earningBreakups;
    } catch (e, st) {
      AppLog.e('getEarningsBreakup : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
