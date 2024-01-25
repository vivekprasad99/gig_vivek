import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showOnboardingBottomSheet(
    BuildContext context, Function() onLoginTap, onExploreTap) {
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
        return OnboardingBottomSheet(onLoginTap, onExploreTap);
      }).whenComplete(() {
    MRouter.exitApp();
  });
}

class OnboardingBottomSheet extends StatelessWidget {
  final Function() onLoginTap;
  final Function() onExploreTap;
  const OnboardingBottomSheet(this.onLoginTap, this.onExploreTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.margin_48,
          Dimens.padding_16, Dimens.margin_32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('welcome_text'.tr,
              style: Get.context?.textTheme.bodyText1Bold?.copyWith(
                  color: AppColors.black,
                  fontSize: Dimens.font_28,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: Dimens.margin_16),
          Text(
            'india_largst_gig_work_platform_Want_to_earn_and_grow_Youre_at_the_right_place'
                .tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.backgroundGrey900,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: Dimens.margin_24),
          RaisedRectButton(
            height: Dimens.margin_40,
            text: 'login_or_signup'.tr,
            onPressed: () {
              onLoginTap();
            },
            backgroundColor: AppColors.primaryMain,
          ),
          const SizedBox(height: Dimens.margin_16),
          RaisedRectButton(
            height: Dimens.margin_40,
            text: 'explore_job'.tr,
            onPressed: () {
              onExploreTap();
            },
            backgroundColor: AppColors.backgroundWhite,
            textColor: AppColors.primaryMain,
            borderColor: AppColors.primaryMain,
          ),
        ],
      ),
    );
  }
}
