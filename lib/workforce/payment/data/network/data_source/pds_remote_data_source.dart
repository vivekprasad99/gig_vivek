import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/payment/data/model/payment_withdraw_request.dart';
import 'package:awign/workforce/payment/data/network/api/pds_api.dart';
import 'package:dio/dio.dart';

import '../../model/update_beneficiary_request.dart';
import '../api/payments_bff_api.dart';

abstract class PDSRemoteDataSource {
  Future<ApiResponse> getTransferHistory(
      AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> getTransfer(String paymentTransferID);

  Future<ApiResponse> retryWithdrawal(
      int transferID, UpdateBeneficiaryRequest paymentWithdrawRequest);
}

class PDSRemoteDataSourceImpl extends PdsAPI implements PDSRemoteDataSource {
  @override
  Future<ApiResponse> getTransferHistory(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await pdsRestClient.post(getTransferHistoryAPI,
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getTransfer(String transferID) async {
    try {
      Response response = await pdsRestClient
          .get(getTransferAPI.replaceAll('transferID', transferID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> retryWithdrawal(
      int transferID, UpdateBeneficiaryRequest paymentWithdrawRequest) async {
    try {
      Response response = await bffRestClient.patch(
          PaymentsBffAPI().retryWithdrawalAPI(transferID),
          body: paymentWithdrawRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
