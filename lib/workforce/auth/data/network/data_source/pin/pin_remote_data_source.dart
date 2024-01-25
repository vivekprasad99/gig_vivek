import 'package:awign/workforce/auth/data/model/user_request_payload.dart';
import 'package:awign/workforce/auth/data/network/api/auth_api.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:dio/dio.dart';

abstract class PINRemoteDataSource {
  Future<ApiResponse> verifyPIN(
      int userID, UserRequestDataPayload userRequestDataPayload);

  Future<ApiResponse> generatePINOTP(
      int userID, UserRequestDataPayload userRequestDataPayload);

  Future<ApiResponse> updatePIN(
      int userID, UserRequestDataPayload userRequestDataPayload);

  Future<ApiResponse> verifyPINOTP(
      int userID, UserRequestDataPayload userRequestDataPayload);
}

class PINRemoteDataSourceImpl extends AuthAPI implements PINRemoteDataSource {
  @override
  Future<ApiResponse> verifyPIN(
      int userID, UserRequestDataPayload userRequestDataPayload) async {
    try {
      Response response = await authRestClient.post(
          verifyPINApi.replaceAll('userID', '$userID'),
          body: userRequestDataPayload.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> generatePINOTP(
      int userID, UserRequestDataPayload userRequestDataPayload) async {
    try {
      Response response = await authRestClient.post(
          generatePINOTPApi.replaceAll('userID', '$userID'),
          body: userRequestDataPayload.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updatePIN(
      int userID, UserRequestDataPayload userRequestDataPayload) async {
    try {
      Response response = await authRestClient.patch(
          updatePINApi.replaceAll('userID', '$userID'),
          body: userRequestDataPayload.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> verifyPINOTP(
      int userID, UserRequestDataPayload userRequestDataPayload) async {
    try {
      Response response = await authRestClient.post(
          verifyPINOTPApi.replaceAll('userID', '$userID'),
          body: userRequestDataPayload.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
