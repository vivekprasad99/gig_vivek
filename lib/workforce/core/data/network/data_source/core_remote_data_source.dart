import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/network/api/core_api.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:dio/dio.dart';

abstract class CoreRemoteDataSource {
  Future<ApiResponse> getLaunchConfig();

  Future<ApiResponse> fetchNotificationList(AdvancedSearchRequest builder);

  Future<ApiResponse> updateNotificationsStatus(AdvancedSearchRequest builder);

  Future<ApiResponse> updateSingleNotificationStatus(int notificationId);
}

class CoreRemoteDataSourceImpl extends CoreAPI implements CoreRemoteDataSource {
  @override
  Future<ApiResponse> getLaunchConfig() async {
    try {
      Response response = await coreRestClient.get(launchConfigAPI);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> fetchNotificationList(AdvancedSearchRequest builder) async {
    try {
      Response response = await coreRestClient.post(fetchNotificationListAPI,
          body: builder.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateNotificationsStatus(AdvancedSearchRequest builder) async {
    try {
      Response response = await coreRestClient.patch(updateNotificationsStatusAPI,
          body: builder.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateSingleNotificationStatus(int notificationId) async {
    try {
      Map<String,String> map = {"status": "acked"};
      Map<String,Map<String,String>> hashmap = {"notification" : map};
      Response response = await coreRestClient.patch(updateSingleNotificationStatusAPI.replaceAll('notification_id', '$notificationId'),
          body: hashmap);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
