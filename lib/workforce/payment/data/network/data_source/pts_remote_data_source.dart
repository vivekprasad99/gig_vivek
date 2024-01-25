import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/payment/data/model/payment_withdraw_request.dart';
import 'package:awign/workforce/payment/data/network/api/pts_api.dart';
import 'package:dio/dio.dart';

abstract class PTSRemoteDataSource {
  Future<ApiResponse> getWorkForcePayouts(
      int userID, Map<String, dynamic> body);

  Future<ApiResponse> initWithdraw(
      PaymentWithdrawRequest paymentWithdrawRequest);
}

class PTSRemoteDataSourceImpl extends PtsAPI implements PTSRemoteDataSource {
  @override
  Future<ApiResponse> getWorkForcePayouts(
      int userID, Map<String, dynamic> body) async {
    try {
      Response response =
          await ptsRestClient.post(getWorkForcePayoutsAPI, body: body);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> initWithdraw(
      PaymentWithdrawRequest paymentWithdrawRequest) async {
    try {
      Response response = await ptsRestClient.post(initWithdrawAPI,
          body: paymentWithdrawRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
