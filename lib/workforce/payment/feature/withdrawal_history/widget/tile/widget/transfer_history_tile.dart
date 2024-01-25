import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/tile/cubit/transfer_history_tile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../../../core/data/remote/capture_event/logging_data.dart';
import '../../../../../../core/di/app_injection_container.dart';

class TransferHistoryTile extends StatefulWidget {
  final int index;
  final Transfer transfer;
  static const String failed = 'failed';
  static const String created = 'created';
  static const String retrying = 'retrying';
  static const String processing = 'processing';
  static const String credited = 'credited';
  static const String disbursed = 'disbursed';
  static const String reversed = 'reversed';
  static const String success = 'success';
  static const String notEnoughMoneyReason =
      'Not enough available balance in the account';

  final Function(int index, Transfer transfer) onContactSupportTap;
  final Function(int index, Transfer transfer) onRetryTap;

  const TransferHistoryTile(
      {Key? key,
      required this.index,
      required this.transfer,
      required this.onContactSupportTap,
      required this.onRetryTap})
      : super(key: key);

  @override
  State<TransferHistoryTile> createState() => _TransferHistoryTileState();
}

class _TransferHistoryTileState extends State<TransferHistoryTile> {
  final TransferHistoryTileCubit _transferHistoryTileCubit =
      sl<TransferHistoryTileCubit>();

  final panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    switch (widget.transfer.status) {
      case TransferHistoryTile.failed:
      case TransferHistoryTile.reversed:
        return buildCardContainer(buildTransferWidgets(
            'assets/images/ic_error.svg',
            'failed'.tr,
            _transferHistoryTileCubit.buildTransferDetails(
                date: widget.transfer.updatedAt,
                refId: widget.transfer.referenceId),
            widget.transfer.amount ?? 0.0,
            isFailed: true));
      case TransferHistoryTile.created:
      case TransferHistoryTile.retrying:
      case TransferHistoryTile.processing:
        return buildCardContainer(buildTransferWidgets(
            'assets/images/ic_processing.svg',
            'payment_under_process'.tr,
            _transferHistoryTileCubit.buildTransferDetails(
                requestedDate: widget.transfer.createdAt,
                expectedDisbursal: widget.transfer.expectedTransferTime,
                refId: widget.transfer.referenceId),
            widget.transfer.amount ?? 0.0));
      case TransferHistoryTile.credited:
      case TransferHistoryTile.disbursed:
      case TransferHistoryTile.success:
        return buildCardContainer(buildTransferWidgets(
            'assets/images/ic_check_circle.svg',
            'successful'.tr,
            _transferHistoryTileCubit.buildTransferDetails(
                date: widget.transfer.updatedAt,
                refId: widget.transfer.referenceId),
            widget.transfer.amount ?? 0.0));
      default:
        return const SizedBox();
    }
  }

  Widget buildCardContainer(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_8, Dimens.padding_16,
          Dimens.padding_8, Dimens.padding_16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_8,
              Dimens.padding_16, Dimens.padding_8, Dimens.padding_16),
          child: widget,
        ),
      ),
    );
  }

  Widget buildTransferWidgets(
      String icons, String heading, String description, double amount,
      {bool isFailed = false}) {
    return Column(
        mainAxisSize: MainAxisSize.max, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(icons),
          const SizedBox(width: Dimens.padding_8,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      heading,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        StringUtils.getIndianFormatNumber(amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, top: 10.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.start,
                  ),
                ),
                if (isFailed) ...[
                  Visibility(
                    visible: widget.transfer.statusReasonRemarkExternal != null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Reason : ${widget.transfer.statusReasonRemarkExternal ?? ''}',
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
                if (isFailed) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text(
                      'Remark : ${_transferHistoryTileCubit.getRemarkText(widget.transfer)}',
                      textAlign: TextAlign.start,
                    ),
                  )
                ]
              ],
                ),
              ),
            ],
      ),
      if (isFailed) ...[
        Visibility(
          visible: widget.transfer.statusReason == "INVALID_BENEFICIARY_DETAILS",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildUpdateBankDetialsWidget(),
            ],
          ),
        ),
      ]
    ]);
  }

  Widget buildUpdateBankDetialsWidget() {
    return TextButton(
      onPressed: () async {
        LoggingData loggingData =
            LoggingData(action: LoggingEvents.contactSupport);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        widget.onRetryTap(widget.index, widget.transfer);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: Dimens.margin_8),
          decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.all(Radius.circular(Dimens.radius_8)),
              border: Border.all(
                  color: AppColors.primaryMain, width: Dimens.border_2)),
          child: Padding(
            padding: const EdgeInsets.only(left: 30,right: 30),
            child: Center(
              child: Text(
                'Update bank details'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.primaryMain, fontSize: Dimens.font_12),
              ),
            ),
          )),
    );
  }
}
