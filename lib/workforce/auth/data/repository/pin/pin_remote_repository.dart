import 'package:awign/workforce/auth/data/model/user_request_payload.dart';
import 'package:awign/workforce/auth/data/network/data_source/pin/pin_remote_data_source.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';

abstract class PINRemoteRepository {
  Future<ApiResponse> verifyPIN(int userID, String pin);

  Future<ApiResponse> generatePINOTP(
      int userID, String email, String mobileNumber, String dob);

  Future<ApiResponse> updatePIN(int userID, String pin);

  Future<ApiResponse> verifyPINOTP(int userID, String otp);
}

class PINRemoteRepositoryImpl implements PINRemoteRepository {
  final PINRemoteDataSource _dataSource;

  PINRemoteRepositoryImpl(this._dataSource);

  @override
  Future<ApiResponse> verifyPIN(int userID, String pin) async {
    try {
      UserRequestPayload userRequestPayload = UserRequestPayload(pin: pin);
      UserRequestDataPayload userRequestDataPayload =
          UserRequestDataPayload(userRequestPayload: userRequestPayload);
      final apiResponse =
          await _dataSource.verifyPIN(userID, userRequestDataPayload);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('verifyPIN : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> generatePINOTP(
      int userID, String email, String mobileNumber, String dob) async {
    try {
      UserRequestPayload userRequestPayload = UserRequestPayload(
          email: email, mobileNumber: mobileNumber, dob: dob);
      UserRequestDataPayload userRequestDataPayload =
          UserRequestDataPayload(userRequestPayload: userRequestPayload);
      final apiResponse =
          await _dataSource.generatePINOTP(userID, userRequestDataPayload);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('generatePINOTP : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updatePIN(int userID, String pin) async {
    try {
      UserRequestPayload userRequestPayload = UserRequestPayload(pin: pin);
      UserRequestDataPayload userRequestDataPayload =
          UserRequestDataPayload(userRequestPayload: userRequestPayload);
      final apiResponse =
          await _dataSource.updatePIN(userID, userRequestDataPayload);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('updatePIN : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> verifyPINOTP(int userID, String otp) async {
    try {
      UserRequestPayload userRequestPayload = UserRequestPayload(otp: otp);
      UserRequestDataPayload userRequestDataPayload =
          UserRequestDataPayload(userRequestPayload: userRequestPayload);
      final apiResponse =
          await _dataSource.verifyPINOTP(userID, userRequestDataPayload);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('verifyPINOTP : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
