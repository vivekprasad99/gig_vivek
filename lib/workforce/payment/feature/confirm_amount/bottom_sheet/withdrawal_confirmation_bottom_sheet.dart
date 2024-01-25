import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showWithdrawalConfirmationBottomSheet(
    BuildContext context, String expectedDate, Function() onYesTap) {
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
        return WithdrawalConfirmationBottomSheet(expectedDate, onYesTap);
      });
}

class WithdrawalConfirmationBottomSheet extends StatelessWidget {
  final String expectedTransferTime;
  final Function() onYesTap;

  const WithdrawalConfirmationBottomSheet(
      this.expectedTransferTime, this.onYesTap,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'withdrawal_confirmation'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: Dimens.font_18),
          ),
          const SizedBox(
            height: Dimens.margin_16,
          ),
          RichText(
              textAlign: TextAlign.center,
              text:
                  TextSpan(style: const TextStyle(color: AppColors.black), children: [
                const TextSpan(
                    text:
                        'By clicking \'Yes,\' you initiate the withdrawal process. '
                        'The payment will be credited to your bank account on '),
                TextSpan(
                    text:
                        '${StringUtils.getDateInLocalFromUtc(expectedTransferTime)}, ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(
                  text:
                      ' between 5pm and 9pm. You will receive an SMS and an app notification '
                      'once the payment is credited.',
                )
              ])),
          const SizedBox(
            height: Dimens.margin_16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    MRouter.pop(null);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimens.margin_8,
                          horizontal: Dimens.margin_48),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(Dimens.radius_8)),
                          border: Border.all(
                              color: AppColors.primaryMain,
                              width: Dimens.border_2)),
                      child: Text(
                        'no'.tr,
                        style: const TextStyle(color: AppColors.primaryMain),
                      ))),
              TextButton(
                  onPressed: () {
                    MRouter.pop(null);
                    onYesTap();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimens.margin_8,
                          horizontal: Dimens.margin_48),
                      decoration: BoxDecoration(
                          color: AppColors.primaryMain,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(Dimens.radius_8)),
                          border: Border.all(
                              color: AppColors.primaryMain,
                              width: Dimens.border_2)),
                      child: Text(
                        'yes'.tr,
                        style:
                            const TextStyle(color: AppColors.backgroundWhite),
                      )))
            ],
          )
        ],
      ),
    );
  }
}
