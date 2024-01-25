import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/payment/data/model/amount_deduction_response.dart';
import 'package:awign/workforce/payment/data/model/earning_statement_entity.dart';
import 'package:awign/workforce/payment/data/model/payment_withdraw_request.dart';
import 'package:awign/workforce/payment/data/network/data_source/earning_remote_data_source.dart';

abstract class EarningRemoteRepository {
  Future<WithdrawalStatementResponse> getEarningStatement(
      int userID, String month);

  Future<AmountDeductionResponse> calculateTDS(double requestedAmount,
      String beneficiaryUserId, String requestedId, String requestAt);
}

class EarningRemoteRepositoryImpl implements EarningRemoteRepository {
  final EarningRemoteDataSource _dataSource;

  EarningRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WithdrawalStatementResponse> getEarningStatement(
      int userID, String month) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(Constants.month, Operator.equal,
              month.toLowerCase().replaceAll(' ', '-'))
          .putPropertyToCondition(Constants.user_Id, Operator.equal, userID)
          .setLimit(1)
          .build();
      ApiResponse apiResponse =
          await _dataSource.getEarningStatement(advancedSearchRequest);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return WithdrawalStatementResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getEarningStatement : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<AmountDeductionResponse> calculateTDS(double requestedAmount,
      String beneficiaryUserId, String requestedId, String requestAt) async {
    try {
      PaymentWithdrawRequest paymentWithdrawRequest = PaymentWithdrawRequest(
          requestedAmount: requestedAmount,
          beneficiaryUserID: beneficiaryUserId,
          requesterID: requestedId,
          requestedAT: requestAt);
      ApiResponse apiResponse =
          await _dataSource.calculateTDS(paymentWithdrawRequest);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return AmountDeductionResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('calculateTDS : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
