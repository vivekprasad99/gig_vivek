import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/nps_bottom_sheet/data/nps_entity.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/data/model/withdrawal_response.dart';
import 'package:awign/workforce/payment/data/model/workforce_payout_response.dart';
import 'package:awign/workforce/payment/data/network/data_source/payment_bff_data_source.dart';

import '../model/withdrawl_data.dart';

abstract class PaymentBffRemoteRepository {
  static const String requestedAmount = 'requested_amount';

  Future<WorkforcePayoutResponse> getWorkForcePayout(int userID);

  Future<CalculateDeductionResponse> calculateDeduction(double approvedAmount);

  Future<WithdrawalResponse> withdrawRequest(WithdrawlData withdrawlData);

  Future<TransferHistoryResponse> getWithdrawlHistory(
      int userID, int pageIndex);

  Future<TransferHistoryResponse> getTransferInFailed(int userID);

  Future<TransferHistoryResponse> getTransferInProcessing(int userID);

  Future<Map<String, dynamic>> getExpectedTransferTime();

  Future<TransferHistoryResponse> getTransfer(String userId, String transferId);

  Future<ApiResponse> npsRating(String userId,int rating);

  Future<Nps> getNpsAction(String userId);
}

class PaymentBffRemoteRepositoryImpl implements PaymentBffRemoteRepository {
  final PaymentBffDataSource _dataSource;

  PaymentBffRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkforcePayoutResponse> getWorkForcePayout(int userID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getWorkForcePayout(userID);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return WorkforcePayoutResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getWorkForcePayout : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CalculateDeductionResponse> calculateDeduction(
      double approvedAmount) async {
    try {
      Map<String, dynamic> body = {
        PaymentBffRemoteRepository.requestedAmount: approvedAmount,
      };
      ApiResponse apiResponse = await _dataSource.calculateDeduction(body);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return CalculateDeductionResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('calculateDeduction : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<WithdrawalResponse> withdrawRequest(
      WithdrawlData withdrawlData) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.withdrawRequest(withdrawlData);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return WithdrawalResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('withdrawRequest : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<TransferHistoryResponse> getWithdrawlHistory(
      int userID, int pageIndex) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getWithdrawlHistory(userID, pageIndex, 20);
      return TransferHistoryResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getWithdrawlHistory : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<TransferHistoryResponse> getTransferInFailed(int userID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getTransferInFailed(userID);
      return TransferHistoryResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getTransferInFailed : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<TransferHistoryResponse> getTransferInProcessing(int userID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getTransferInProcessing(userID);
      return TransferHistoryResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getTransferInProcessing : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getExpectedTransferTime() async {
    try {
      Map<String, dynamic> apiResponse = await _dataSource.getExpectedTransferTime();
      return apiResponse;
    } catch (e, st) {
      AppLog.e('getExpectedTransferTime : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<TransferHistoryResponse> getTransfer(String userId, String transferId) async {
    try {
      ApiResponse apiResponse = await _dataSource.getTransfer(userId, transferId);
      return TransferHistoryResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getTransfer: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> npsRating(String userId,int rating) async {
    try {
      ApiResponse apiResponse = await _dataSource.npsRating(userId,rating);
      return apiResponse;
    } catch (e, st) {
      AppLog.e('npsRating: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Nps> getNpsAction(String userId) async {
    try {
      ApiResponse apiResponse = await _dataSource.getNpsAction(userId);
      return Nps.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getNpsAction: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
