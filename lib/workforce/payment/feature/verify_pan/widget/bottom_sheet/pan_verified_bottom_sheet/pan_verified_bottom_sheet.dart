import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showPANVerifiedBottomSheet(BuildContext context, VoidCallback onTap) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return PANVerifiedBottomSheet(onTap);
      }).whenComplete(() {
        onTap();
  });
}

class PANVerifiedBottomSheet extends StatelessWidget {
  final VoidCallback? onTap;
  const PANVerifiedBottomSheet(this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Dimens.padding_24),
          SvgPicture.asset('assets/images/done_step.svg', width: Dimens.iconSize_48, height: Dimens.iconSize_48),
          const SizedBox(height: Dimens.padding_32),
          buildTitle(context),
          const SizedBox(height: Dimens.padding_48),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    String title = 'pan_verified_successfully'.tr;
    return Text(title,
        style: context.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundGrey800,
            fontWeight: FontWeight.w700,
            fontSize: Dimens.font_18));
  }
}
