import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/data/repository/payment_bff_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../core/utils/string_utils.dart';

part 'transfer_details_bottom_sheet_state.dart';

class TransferDetailsBottomSheetCubit extends Cubit<TransferDetailsState> {
  PaymentBffRemoteRepository _paymentBffRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _transferDetailsResponse = BehaviorSubject<TransferHistoryResponse>();

  Stream<TransferHistoryResponse> get transferDetailsResponse =>
      _transferDetailsResponse.stream;

  Function(TransferHistoryResponse) get changeTransferDetailsResponse =>
      _transferDetailsResponse.sink.add;

  TransferDetailsBottomSheetCubit(this._paymentBffRemoteRepository)
      : super(TransferDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _transferDetailsResponse.close();
    return super.close();
  }

  void getTransfer(int userId, String transferID) async {
    try {
      TransferHistoryResponse transferHistoryResponse =
          await _paymentBffRemoteRepository.getTransfer(userId.toString(), transferID);
      if (!_transferDetailsResponse.isClosed) {
        changeTransferDetailsResponse(transferHistoryResponse);
      } else {
        _transferDetailsResponse.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getTransfer : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  String buildTransferDetails(
      {String? requestedDate,
        String? expectedDisbursal,
        String? date,
        String? refId}) {
    String transferDetails = "";
    if (!requestedDate.isNullOrEmpty) {
      transferDetails +=
      "Requested Date: ${StringUtils.getDateInLocalFromUtc(requestedDate!)}\n";
    }

    if (!expectedDisbursal.isNullOrEmpty) {
      transferDetails +=
      "Expected Disbursal: ${StringUtils.getDateInLocalFromUtc(expectedDisbursal!)}\n";
    }

    if (!date.isNullOrEmpty) {
      transferDetails += "Date: ${StringUtils.getDateInLocalFromUtc(date!)}\n";
    }

    if (!refId.isNullOrEmpty) {
      transferDetails += "Ref ID: $refId\n";
    }

    return transferDetails;
  }
}
