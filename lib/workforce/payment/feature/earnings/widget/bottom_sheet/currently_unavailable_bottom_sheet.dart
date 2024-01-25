import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void showCurrentlyUnavailableBottomSheet(BuildContext context) {
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
        return const ShowCurrentlyUnavailableBottomSheet();
      });
}

class ShowCurrentlyUnavailableBottomSheet extends StatelessWidget {
  const ShowCurrentlyUnavailableBottomSheet({Key? key}) : super(key: key);

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
          MyInkWell(
            onTap: () {
              MRouter.pop(null);
            },
            child: const Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                backgroundColor: AppColors.backgroundGrey700,
                radius: Dimens.padding_12,
                child: Icon(
                  Icons.close,
                  color: AppColors.backgroundWhite,
                  size: Dimens.padding_16,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Image.asset(
            "assets/images/unavailable.png",
          ),
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Text('currently_unavailable'.tr,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontWeight: FontWeight.w700,
                  fontSize: Dimens.font_18)),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          Text('currently_unavailable_desc'.tr,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.font_14)),
        ],
      ),
    );
  }
}
