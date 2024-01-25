import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showUpcomingEarningBottomSheet(BuildContext context) {
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
        return const UpcomingEarningBottomSheet();
      });
}

class UpcomingEarningBottomSheet extends StatelessWidget {
  const UpcomingEarningBottomSheet({Key? key}) : super(key: key);

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
          SvgPicture.asset('assets/images/Treasure.svg',height: Dimens.etWidth_100,),
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Text('what_are_upcoming_earnings'.tr,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontWeight: FontWeight.w700,
                  fontSize: Dimens.font_18)),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          Text('what_are_upcoming_earnings_desc'.tr,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.font_14)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
            child: MyInkWell(
              onTap: () {
                BrowserHelper.customTab(
                    context, "https://www.awign.com/terms_and_conditions");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('terms_and_condition_applied'.tr,
                      style: Get.context!.textTheme.bodyText2?.copyWith(
                          color: AppColors.primaryMain,
                          fontWeight: FontWeight.w400,
                          fontSize: Dimens.font_10)),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: Dimens.padding_8,
                    color: AppColors.primaryMain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
