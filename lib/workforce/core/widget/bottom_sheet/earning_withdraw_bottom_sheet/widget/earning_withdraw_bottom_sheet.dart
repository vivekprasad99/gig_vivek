import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../buttons/my_ink_well.dart';

void showEarningWithDrawBottomSheet(BuildContext context, VoidCallback onTap) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return EarningWithdrawBottomSheet(onTap);
      });
}

class EarningWithdrawBottomSheet extends StatelessWidget {
  final VoidCallback onTap;
  const EarningWithdrawBottomSheet(this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_20,
        Dimens.padding_32,
        Dimens.padding_20,
        Dimens.padding_32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Image.asset(
            'assets/images/earning_withdraw.png',
          ),
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Text('why_wait_to_withdraw'.tr,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontWeight: FontWeight.w700,
                  fontSize: Dimens.font_18)),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          Text('why_wait_to_withdraw_desc'.tr,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.font_14)),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          RaisedRectButton(
            text: 'okay'.tr,
            height: Dimens.btnHeight_40,
            backgroundColor: AppColors.primaryMain,
            onPressed: () {
              onTap();
            },
          )
        ],
      ),
    );
  }
}
