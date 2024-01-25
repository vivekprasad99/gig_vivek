import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_screen_response.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/lead_screen/screen_remote_data_source.dart';

abstract class ScreenRemoteRepository {
  Future<LeadScreenResponse> getStartScreen(int userID, LeadDataSourceParams leadDataSourceParams);

  Future<LeadScreenResponse> getNextScreen(
      int userID, String executionID, String leadID, String screenID);
}

class ScreenRemoteRepositoryImpl implements ScreenRemoteRepository {
  final ScreenRemoteDataSource _dataSource;

  ScreenRemoteRepositoryImpl(this._dataSource);

  @override
  Future<LeadScreenResponse> getStartScreen(int userID,
      LeadDataSourceParams leadDataSourceParams) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder().setLimit(1);
      if (leadDataSourceParams.currentStatus != null &&
          (leadDataSourceParams.screenViewType == ScreenViewType.updateLead ||
              leadDataSourceParams.screenViewType ==
                  ScreenViewType.sampleLead)) {
        advancedSearchRequest.putPropertyToCondition(Constants.workFlowStatus,
            Operator.equal, leadDataSourceParams.currentStatus!);
      }
      String viewTypeValue = '';
      switch (leadDataSourceParams.screenViewType) {
        case ScreenViewType.addLead:
          viewTypeValue = 'add_lead_view';
          break;
        case ScreenViewType.sampleLead:
          viewTypeValue = 'status_view';
          break;
        case ScreenViewType.updateLead:
          viewTypeValue = 'status_view';
          break;
      }
      advancedSearchRequest.putPropertyToCondition(
          Constants.viewType, Operator.equal, viewTypeValue);
      ApiResponse apiResponse = await _dataSource.getStartScreen(
          leadDataSourceParams.executionID ?? '',
          leadDataSourceParams.projectRoleUID ?? '',
          advancedSearchRequest.build());
      if (apiResponse.status == ApiResponse.success) {
        return LeadScreenResponse.fromJson(apiResponse.data, userID, -1);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getStartScreen : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<LeadScreenResponse> getNextScreen(int userID, String executionID, String leadID, String screenID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getNextScreen(
          executionID,
          leadID,
          screenID);
      if (apiResponse.status == ApiResponse.success) {
        return LeadScreenResponse.fromJson(apiResponse.data, userID, -1);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getStartScreen : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
