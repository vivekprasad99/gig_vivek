import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/EarningsWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showNonWithdrawalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return const NonWithdrawalBottomSheetWidget();
    },
  );
}

class NonWithdrawalBottomSheetWidget extends StatefulWidget {
  const NonWithdrawalBottomSheetWidget({Key? key}) : super(key: key);

  @override
  State<NonWithdrawalBottomSheetWidget> createState() =>
      NonWithdrawalBottomSheetWidgetState();
}

class NonWithdrawalBottomSheetWidgetState
    extends State<NonWithdrawalBottomSheetWidget> {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_alert.svg',
                            color: AppColors.error400,
                          ),
                          const SizedBox(width: Dimens.padding_16),
                          Flexible(
                            child: Text(
                              'minimum_amount_that_can_be_withdrawn'.tr,
                              style: Get.textTheme.headline7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildCloseIcon(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_56 - 2, Dimens.padding_16, Dimens.padding_16, 0),
                child: Text(
                  '${Constants.rs} ${EarningsWidget.nonWithdrawalAmount}',
                  style: Get.textTheme.headline6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Icon(Icons.close),
      ),
    );
  }
}
