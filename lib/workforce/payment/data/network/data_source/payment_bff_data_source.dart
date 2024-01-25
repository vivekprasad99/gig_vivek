import 'package:awign/workforce/auth/data/network/api/bff_api.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/payment/data/model/withdrawl_data.dart';
import 'package:dio/dio.dart';

abstract class PaymentBffDataSource {
  Future<ApiResponse> getWorkForcePayout(int userID);

  Future<ApiResponse> calculateDeduction(Map<String, dynamic> body);

  Future<ApiResponse> withdrawRequest(WithdrawlData withdrawlData);

  Future<ApiResponse> getWithdrawlHistory(int userID, int pageIndex, int limit);

  Future<ApiResponse> getTransferInFailed(int userID);

  Future<ApiResponse> getTransferInProcessing(int userID);

  Future<Map<String, dynamic>> getExpectedTransferTime();

  Future<ApiResponse> getTransfer(String userId, String transferId, );

  Future<ApiResponse> npsRating(String userId,int rating);

  Future<ApiResponse> getNpsAction(String userId);
}

class PaymentBffDataSourceImpl extends BffAPI implements PaymentBffDataSource {
  @override
  Future<ApiResponse> getWorkForcePayout(int userID) async {
    try {
      Response response = await bffRestClient
          .get(getWorkForcePayoutAPI.replaceAll('userID', '$userID'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> calculateDeduction(Map<String, dynamic> body) async {
    try {
      Response response =
          await bffRestClient.post(calculateDeductionAPI, body: body);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> withdrawRequest(WithdrawlData withdrawlData) async {
    try {
      Response response = await bffRestClient.post(withdrawRequestAPI,
          body: withdrawlData.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getWithdrawlHistory(
      int userID, int pageIndex, int limit) async {
    try {
      Response response = await bffRestClient.post(getWithdrawlHistoryAPI
          .replaceAll('userID', '$userID')
          .replaceAll('num', '$pageIndex')
          .replaceAll('record', '$limit'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getTransferInFailed(int userID) async {
    try {
      Response response = await bffRestClient
          .post(getTransferInStatusAPI(userID, 1, 10, "FAILED"));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getTransferInProcessing(int userID) async {
    try {
      Response response = await bffRestClient
          .post(getTransferInStatusAPI(userID, 1, 10, "PROCESSING"));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getExpectedTransferTime() async{
    try {
      Response response = await bffRestClient.get(getExpectedTransferApi());
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getTransfer(String userId, String transferId) async {
    try {
      Response response = await bffRestClient.get(getSingleTransferApi(userId, transferId));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> npsRating(String userId,int rating) async {
    try {
      Response response = await bffRestClient.post(npsRatingApi(userId),body: {'rating' : rating});
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getNpsAction(String userId) async {
    try {
      Response response = await bffRestClient.get(getNpsRatingApi(userId));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
