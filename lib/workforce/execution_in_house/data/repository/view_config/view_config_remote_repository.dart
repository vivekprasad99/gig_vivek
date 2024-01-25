import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/view_config/view_config_remote_data_source.dart';

abstract class ViewConfigRemoteRepository {
  Future<ListViewConfigData> fetchListView(String executionID, String projectRoleUID);
}

class ViewConfigRemoteRepositoryImpl implements ViewConfigRemoteRepository {
  final ViewConfigRemoteDataSource _dataSource;

  ViewConfigRemoteRepositoryImpl(this._dataSource);

  @override
  Future<ListViewConfigData> fetchListView(
      String executionID, String projectRoleUID) async {
    try {
      ListViewsRequest listViewsRequest = ListViewsRequest(
          limit: Constants.maxIntValue,
          sortColumn: Constants.createdAt,
          sortOrder: Constants.asc);
      ApiResponse apiResponse = await _dataSource.fetchListView(
          executionID, projectRoleUID, listViewsRequest);
      if (apiResponse.status == ApiResponse.success) {
        return ListViewConfigData.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('fetchListView : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
