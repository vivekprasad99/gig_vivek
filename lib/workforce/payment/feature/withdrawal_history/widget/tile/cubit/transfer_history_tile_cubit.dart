import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../core/utils/string_utils.dart';
import '../../../../../data/model/transfer_history_response.dart';

part 'transfer_history_tile_state.dart';

class TransferHistoryTileCubit extends Cubit<TransferHistoryTileState> {
  final _isShowDetail = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isShowDetailStream => _isShowDetail.stream;

  bool get isShowDetail => _isShowDetail.value;

  Function(bool) get changeIsShowDetail => _isShowDetail.sink.add;

  TransferHistoryTileCubit() : super(TransferHistoryTileInitial());

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
      transferDetails += "Date: ${StringUtils.getDateInLocalFromUtc(date!)}\n\n";
    }

    if (!refId.isNullOrEmpty) {
      transferDetails += "Ref ID: $refId";
    }

    return transferDetails;
  }

  String getRemarkText(Transfer transfer) {
    if (transfer.statusReason == "INVALID_BENEFICIARY_DETAILS") {
      return 'Please update your bank details now!';
    }
    if (transfer.statusReason == "NOT_ENOUGH_BALANCE") {
      return 'Relax, your payment is secure! Automatic retry is scheduled for ${StringUtils.getDateInLocalFromUtc(transfer.expectedTransferTime ?? '')} by 9 PM.';
    }
    if (transfer.statusReason == "BANK_SIDE_ISSUE") {
      return 'There was an issue with your bank. Automatic retry is scheduled for ${StringUtils.getDateInLocalFromUtc(transfer.expectedTransferTime ?? '')} by 9 PM.';
    }

    return 'Relax, your payment is secure! Automatic retry is scheduled for ${StringUtils.getDateInLocalFromUtc(transfer.expectedTransferTime ?? '')} by 9 PM';
  }
}
