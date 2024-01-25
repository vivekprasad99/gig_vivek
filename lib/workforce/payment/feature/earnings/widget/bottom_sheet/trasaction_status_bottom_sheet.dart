import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:flutter/material.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

enum TransferStatus {
  success,
  failure,
  processing,
}

void showTransactionStatusBottomSheet(BuildContext context,
    Stream<TransferStatus> transferStatus, Function() onGreatTap,{bool isFromUpdate = false} ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return TransactionStatusBottomSheet(transferStatus, onGreatTap, isFromUpdate);
    },
  );
}

class TransactionStatusBottomSheet extends StatefulWidget {
  final Stream<TransferStatus> transferStatus;
  final Function() onGreatTap;
  final bool isFromUpdate;

  const TransactionStatusBottomSheet(this.transferStatus, this.onGreatTap, this.isFromUpdate,
      {Key? key})
      : super(key: key);

  @override
  State<TransactionStatusBottomSheet> createState() =>
      _TransactionStatusBottomSheetState();
}

class _TransactionStatusBottomSheetState
    extends State<TransactionStatusBottomSheet> {
  bool isLoadingSet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransferStatus>(
        stream: widget.transferStatus,
        builder: (context, response) {
          if (response.hasData) {
            //show success
            switch (response.data!) {
              case TransferStatus.success:
                return buildSuccessView();
              case TransferStatus.failure:
                return buildErrorView();
              case TransferStatus.processing:
                return buildLoadingView();
            }
          } else {
            return buildLoadingView();
          }
        });
  }

  Widget buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_24),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/images/ic_transaction_success_animation.json'),
          const SizedBox(
            height: Dimens.margin_20,
          ),
          Text(
            widget.isFromUpdate ? 'Bank Details Updated!' :
            'yay_your_payment_is_under_process'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: Dimens.font_18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: Dimens.margin_56,
          ),
          RaisedRectButton(
            width: Dimens.margin_120,
            text: 'great'.tr,
            onPressed: () {
              // widget.onGreatTap();
              MRouter.pop(null);
            },
            height: Dimens.btnHeight_40,
          ),
        ],
      ),
    );
  }

  Widget buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_24),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/images/ic_transaction_failed_animation.json'),
          const SizedBox(
            height: Dimens.margin_20,
          ),
          Text(
            'something_went_wrong'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: Dimens.font_18),
          ),
          const SizedBox(
            height: Dimens.margin_56,
          ),
          TextButton(
              onPressed: () {
                MRouter.pop(null);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimens.margin_8, horizontal: Dimens.margin_20),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Dimens.radius_8)),
                    border: Border.all(
                        color: AppColors.primaryMain, width: Dimens.border_2)),
                child: Text(
                  'go_back'.tr,
                  style: const TextStyle(color: AppColors.primaryMain),
                ),
              )),
        ],
      ),
    );
  }

  Widget buildLoadingView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/images/ic_transaction_processing_animation.json'),
      ],
    );
  }
}
