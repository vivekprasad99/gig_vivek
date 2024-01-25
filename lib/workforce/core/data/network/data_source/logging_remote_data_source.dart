import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/network/api/logging_api.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:dio/dio.dart';

abstract class LoggingRemoteDataSource {
  Future<ApiResponse> sentLoggingEvents(
      List<Map<String, Object?>> loggingEventList);
}

class LoggingRemoteDataSourceImpl extends LoggingAPI
    implements LoggingRemoteDataSource {
  @override
  Future<ApiResponse> sentLoggingEvents(
      List<Map<String, Object?>> loggingEventList) async {
    try {
      Response response = await loggingRestClient.post(sentLoggingEventAPI,
          body: loggingEventList);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
