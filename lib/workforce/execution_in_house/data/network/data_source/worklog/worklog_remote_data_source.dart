import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/model/worklog_response.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class WorklogRemoteDataSource {
  Future<ApiResponse> getWorkLog(String projectId, String projectRoleUid);

  Future<ApiResponse> createWorkLog(
      String executionId, String projectRoleUid, WorklogRequest answerUnit);
}

class WorklogRemoteDataSourceImpl extends InHouseOMSAPI
    implements WorklogRemoteDataSource {
  @override
  Future<ApiResponse> getWorkLog(
      String projectId, String projectRoleUid) async {
    try {
      Response response = await inHouseOMSRestClient.post(getWorkLogAPI
          .replaceAll('project_id', projectId)
          .replaceAll('project_role_uid', projectRoleUid));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createWorkLog(String executionId, String projectRoleUid,
      WorklogRequest answerUnit) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          createWorklogAPI
              .replaceAll('execution_id', executionId)
              .replaceAll('project_role_id', projectRoleUid),
          body: answerUnit);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
