import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

void dreamApplicationBottomSheet(BuildContext context, Function() onCompleteTap,
    Function() onLaterTap, Widget bottomWidget) {
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
        return DreamApplicationBottomSheet(
            onCompleteTap, onLaterTap, bottomWidget);
      });
}

class DreamApplicationBottomSheet extends StatelessWidget {
  final Function() onCompleteTap;
  final Function() onLaterTap;
  final Widget bottomWidget;
  const DreamApplicationBottomSheet(
      this.onCompleteTap, this.onLaterTap, this.bottomWidget,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDreamApplicationWidget(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_32,
            Dimens.padding_16,
            Dimens.padding_16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bottomWidget,
              const SizedBox(height: Dimens.margin_16),
              buildDreamApplicationDescText(),
              const SizedBox(height: Dimens.margin_16),
              buildCompleteNowButton(),
              const SizedBox(height: Dimens.margin_16),
              buildMayBeLetterButton(),
            ],
          ),
        ),
        const SizedBox(height: Dimens.margin_16),
      ],
    );
  }

  Widget buildDreamApplicationWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildIntroducingText(),
              const SizedBox(height: Dimens.margin_8),
              buildDreamText(),
              const SizedBox(height: Dimens.margin_4),
              buildApplicationText(),
            ],
          ),
          buildDreamApplicationImage(),
        ],
      ),
    );
  }

  Widget buildIntroducingText() {
    return Text(
      'introducing'.tr,
      style: Get.textTheme.bodyText1Bold
          ?.copyWith(color: AppColors.primary200, letterSpacing: 2),
    );
  }

  Widget buildDreamText() {
    return Row(
      children: [
        Text(
          'dream'.tr,
          style: Get.textTheme.headlineSmall
              ?.copyWith(color: AppColors.primary600),
        ),
        const SizedBox(width: Dimens.margin_4),
        SvgPicture.asset('assets/images/ic_stars.svg'),
      ],
    );
  }

  Widget buildApplicationText() {
    return Text(
      'application'.tr,
      style: Get.textTheme.headlineSmall?.copyWith(color: AppColors.primary600),
    );
  }

  Widget buildDreamApplicationImage() {
    return Padding(
      padding: const EdgeInsets.only(right: Dimens.padding_28),
      child: SvgPicture.asset(
        'assets/images/ic_dream_application_nudge.svg',
        height: Dimens.margin_80,
      ),
    );
  }

  Widget buildDreamApplicationDescText() {
    return Text(
      'be_the_first_to_reached_out'.tr,
      style: Get.textTheme.bodyMedium
          ?.copyWith(color: AppColors.backgroundGrey800),
    );
  }

  Widget buildCompleteNowButton() {
    return RaisedRectButton(
      text: 'complete_now'.tr,
      height: Dimens.btnHeight_40,
      elevation: 0,
      textStyle: Get.textTheme.bodyText2SemiBold
          ?.copyWith(color: AppColors.backgroundWhite),
      onPressed: () {
        onCompleteTap();
      },
    );
  }

  Widget buildMayBeLetterButton() {
    return CustomTextButton(
      height: Dimens.btnHeight_40,
      text: 'maybe_later'.tr,
      backgroundColor: AppColors.transparent,
      borderColor: AppColors.transparent,
      textStyle: Get.textTheme.bodyText2SemiBold
          ?.copyWith(color: AppColors.backgroundGrey800),
      onPressed: () {
        onLaterTap();
      },
    );
  }
}
