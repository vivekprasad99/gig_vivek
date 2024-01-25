import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class ViewConfigRemoteDataSource {
  Future<ApiResponse> fetchListView(String executionID, String projectRoleUID,
      ListViewsRequest listViewsRequest);
}

class ViewConfigRemoteDataSourceImpl extends InHouseOMSAPI
    implements ViewConfigRemoteDataSource {
  @override
  Future<ApiResponse> fetchListView(String executionID, String projectRoleUID,
      ListViewsRequest listViewsRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          fetchListViewAPI
              .replaceAll('executionID', executionID)
              .replaceAll('projectRoleUID', projectRoleUID),
          body: listViewsRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
