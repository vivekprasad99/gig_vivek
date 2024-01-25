import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/app_config_response.dart';
import 'package:awign/workforce/core/data/model/notification_response.dart';
import 'package:awign/workforce/core/data/network/data_source/core_remote_data_source.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';

abstract class CoreRemoteRepository {
  Future<AppConfigResponse> getLaunchConfig();

  Future<List<Notifications>?> fetchNotificationList(NotificationPageRequest universityRequest, int pageIndex);

  Future updateNotificationsStatus(int userID,String createdAT);

  Future updateSingleNotificationStatus(int notificationId);
}

class CoreRemoteRepositoryImpl implements CoreRemoteRepository {
  final CoreRemoteDataSource _dataSource;

  CoreRemoteRepositoryImpl(this._dataSource);

  @override
  Future<AppConfigResponse> getLaunchConfig() async {
    try {
      final apiResponse = await _dataSource.getLaunchConfig();
      return AppConfigResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getLaunchConfig : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Notifications>?> fetchNotificationList(NotificationPageRequest pageRequest, int pageIndex) async {
    try {
      var builder = AdvanceSearchRequestBuilder();
      builder.putPropertyToCondition("user_id", Operator.equal, pageRequest.userID!.toInt()).setPage(pageIndex);
      ApiResponse data =  await _dataSource.fetchNotificationList(builder.build());
      NotificationData? notificationData = NotificationData.fromJson(data.data);
      return notificationData.notifications;
    } catch (e, st) {
      AppLog.e('fetchNotificationList : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future updateNotificationsStatus(int userID,String createdAT) async {
    try {
      var builder = AdvanceSearchRequestBuilder();
      builder.putPropertyToCondition("user_id", Operator.equal, userID);
      builder.putPropertyToCondition("created_at", Operator.lessThen, createdAT);
      Map<String, String> map = {"status" : "acked"};
      builder.setNotification(map);
      ApiResponse data =  await _dataSource.updateNotificationsStatus(builder.build());
      return data;
    } catch (e, st) {
      AppLog.e('updateNotificationsStatus : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future updateSingleNotificationStatus(int notificationId) async {
    try {
      ApiResponse data =  await _dataSource.updateSingleNotificationStatus(notificationId);
      return data;
    } catch (e, st) {
      AppLog.e('updateSingleNotificationStatus : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
