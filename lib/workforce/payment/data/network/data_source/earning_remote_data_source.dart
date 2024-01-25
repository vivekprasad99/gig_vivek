import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/payment/data/model/payment_withdraw_request.dart';
import 'package:awign/workforce/payment/data/network/api/payments_bff_api.dart';
import 'package:awign/workforce/payment/data/network/api/pds_api.dart';
import 'package:dio/dio.dart';

abstract class EarningRemoteDataSource {
  Future<ApiResponse> getEarningStatement(
      AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> calculateTDS(
      PaymentWithdrawRequest paymentWithdrawRequest);
}

class EarningRemoteDataSourceImpl extends PdsAPI
    implements EarningRemoteDataSource {
  @override
  Future<ApiResponse> getEarningStatement(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await bffRestClient.post(PaymentsBffAPI().getEarningStatement(),
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> calculateTDS(
      PaymentWithdrawRequest paymentWithdrawRequest) async {
    try {
      Response response = await pdsRestClient.post(calculateTDSAPI,
          body: paymentWithdrawRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
