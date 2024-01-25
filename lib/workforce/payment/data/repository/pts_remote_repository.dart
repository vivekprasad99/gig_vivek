import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/payment_withdraw_request.dart';
import 'package:awign/workforce/payment/data/model/workforce_payout_response.dart';
import 'package:awign/workforce/payment/data/network/data_source/pts_remote_data_source.dart';

abstract class PTSRemoteRepository {
  static const String userID = 'user_id';
  static const String advanceAnalyze = 'advance_analyze';

  Future<WorkforcePayoutResponse> getWorkForcePayouts(int userID);

  Future<ApiResponse> initWithdraw(
      double requestedAmount,
      String beneficiaryId,
      String beneficiaryUserId,
      String requestedId,
      String paymentChannelType,
      String requestAt);
}

class PTSRemoteRepositoryImpl implements PTSRemoteRepository {
  final PTSRemoteDataSource _dataSource;

  PTSRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkforcePayoutResponse> getWorkForcePayouts(int userID) async {
    try {
      Map<String, dynamic> body = {
        PTSRemoteRepository.userID: userID.toString(),
        PTSRemoteRepository.advanceAnalyze: true,
      };
      ApiResponse apiResponse =
          await _dataSource.getWorkForcePayouts(userID, body);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return WorkforcePayoutResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getWorkForcePayouts : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> initWithdraw(
      double requestedAmount,
      String beneficiaryId,
      String beneficiaryUserId,
      String requestedId,
      String paymentChannelType,
      String requestAt) async {
    try {
      PaymentWithdrawRequest paymentWithdrawRequest = PaymentWithdrawRequest(
          requestedAmount: requestedAmount,
          beneficiaryUserID: beneficiaryUserId,
          beneficiaryID: beneficiaryId,
          requesterID: requestedId,
          requestedAT: requestAt,
          remark: '',
          paymentDisbursalService: paymentChannelType);
      ApiResponse apiResponse =
          await _dataSource.initWithdraw(paymentWithdrawRequest);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('initWithdraw : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
