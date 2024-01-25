import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/bottom_sheet/cubit/transfer_details_bottom_sheet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../tile/widget/transfer_history_tile.dart';

void showTransferDetailsBottomSheet(
    BuildContext context, String transferId) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return TransferDetailsBottomSheetWidget(transferId);
    },
  );
}

class TransferDetailsBottomSheetWidget extends StatefulWidget {
  final String transferId;

  const TransferDetailsBottomSheetWidget(this.transferId, {Key? key})
      : super(key: key);

  @override
  State<TransferDetailsBottomSheetWidget> createState() =>
      TransferDetailsBottomSheetWidgetState();
}

class TransferDetailsBottomSheetWidgetState
    extends State<TransferDetailsBottomSheetWidget> {
  final TransferDetailsBottomSheetCubit _transferDetailsBottomSheetCubit =
      sl<TransferDetailsBottomSheetCubit>();
  UserData? _currentUser;
  KycDetails? _kycDetails;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _transferDetailsBottomSheetCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _transferDetailsBottomSheetCubit.getTransfer(_currentUser?.id ?? -1, widget.transferId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<TransferHistoryResponse>(
                  stream:
                      _transferDetailsBottomSheetCubit.transferDetailsResponse,
                  builder: (context, transferHistoryResponse) {
                    if (transferHistoryResponse.hasData) {
                      switch (transferHistoryResponse.data?.transfer?.status) {
                        case TransferHistoryTile.failed:
                        case TransferHistoryTile.reversed:
                          return buildCardContainer(buildTransferWidgets(
                              'assets/images/ic_error.svg',
                              'failed'.tr,
                              _transferDetailsBottomSheetCubit.buildTransferDetails(
                                  date: transferHistoryResponse.data?.transfer?.updatedAt,
                                  refId: transferHistoryResponse.data?.transfer?.referenceId),
                              transferHistoryResponse.data?.transfer?.amount ?? 0.0,
                          ));
                        case TransferHistoryTile.created:
                        case TransferHistoryTile.retrying:
                        case TransferHistoryTile.processing:
                          return buildCardContainer(buildTransferWidgets(
                              'assets/images/ic_processing.svg',
                              'payment_under_process'.tr,
                              _transferDetailsBottomSheetCubit.buildTransferDetails(
                                  requestedDate: transferHistoryResponse.data?.transfer?.createdAt,
                                  expectedDisbursal: transferHistoryResponse.data?.transfer?.expectedTransferTime),
                              transferHistoryResponse.data?.transfer?.amount ?? 0.0));
                        case TransferHistoryTile.credited:
                        case TransferHistoryTile.disbursed:
                          return buildCardContainer(buildTransferWidgets(
                              'assets/images/ic_check_circle.svg',
                              'successful'.tr,
                              _transferDetailsBottomSheetCubit.buildTransferDetails(
                                  date: transferHistoryResponse.data?.transfer?.updatedAt,
                                  refId: transferHistoryResponse.data?.transfer?.referenceId),
                              transferHistoryResponse.data?.transfer?.amount ?? 0.0));
                        default:
                          return const SizedBox();
                      }
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          ),
        );
      },
    );
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
      String icons, String heading, String description, double amount) {
    return Column(children: [
      Row(
        children: [
          SvgPicture.asset(icons),
          const SizedBox(
            width: Dimens.margin_8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Text(
            StringUtils.getIndianFormatNumber(amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
      const SizedBox(
        height: Dimens.margin_16,
      ),
    ]);
  }
}
