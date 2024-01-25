import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/payment/data/model/payment_withdraw_request.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/data/network/data_source/pds_remote_data_source.dart';

import '../model/update_beneficiary_request.dart';

abstract class PDSRemoteRepository {
  Future<TransferHistoryResponse> getTransferHistory(int userID, int pageIndex);

  Future<TransferDetailsResponse> getTransfer(String paymentTransferID);

  Future<ApiResponse> updateBeneficiary(Transfer transfer);
}

class PDSRemoteRepositoryImpl implements PDSRemoteRepository {
  final PDSRemoteDataSource _dataSource;

  PDSRemoteRepositoryImpl(this._dataSource);

  @override
  Future<TransferHistoryResponse> getTransferHistory(
      int userID, int pageIndex) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(Constants.requesterID, Operator.equal, userID)
          .setPage(pageIndex)
          .build();
      ApiResponse apiResponse =
          await _dataSource.getTransferHistory(advancedSearchRequest);
      return TransferHistoryResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getTransferHistory : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<TransferDetailsResponse> getTransfer(String paymentTransferID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getTransfer(paymentTransferID);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return TransferDetailsResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getTransfer : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateBeneficiary(Transfer transfer) async {
    try {
      UpdateBeneficiaryRequest updateBeneficiaryRequest = UpdateBeneficiaryRequest(
          beneficiaryID: (transfer.beneficiaryId ?? -1).toString()
      );
      ApiResponse apiResponse = await _dataSource.retryWithdrawal(
          (transfer.id != null) ? int.parse(transfer.id.toString()) : -1, updateBeneficiaryRequest);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('retryWithdrawal : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
