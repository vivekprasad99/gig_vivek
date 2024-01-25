import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/show_improve_bottom_sheet/widget/show_improve_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/user_earning_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TipsToImproveWidget extends StatelessWidget {
  final UserEarningResponse userEarning;
  final String selectedNavItem;

  const TipsToImproveWidget(
      {Key? key, required this.userEarning, required this.selectedNavItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: ListTile(
          leading: SvgPicture.asset(
            'assets/images/icons_8_light_on.svg',
          ),
          title: Text(
            getTipsToImproveText(userEarning.performance!),
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.backgroundBlack,
                fontSize: Dimens.padding_14,
                fontWeight: FontWeight.w400),
          ),
          subtitle: MyInkWell(
            onTap: () {
              showImproveBottomSheet(context, selectedNavItem);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: Dimens.margin_8),
              child: Row(
                children: [
                  Text(
                    'view'.tr,
                    style: Get.context?.textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryMain,
                        fontSize: Dimens.padding_12,
                        fontWeight: FontWeight.w600),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryMain,
                    size: Dimens.padding_12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getTipsToImproveText(String performance) {
    switch (performance) {
      case Constants.poor:
        return selectedNavItem == Constants.earning
            ? 'you_are_capable_of_even_more_learn_the_secrets'.tr
            : (selectedNavItem == Constants.jobOnboarded
                ? 'job_onboarding_improve_desc'.tr
                : 'your_effort_show_promise'.tr);
      case Constants.average:
        return selectedNavItem == Constants.earning
            ? 'average_work_desc'.tr
            : (selectedNavItem == Constants.jobOnboarded
                ? ''
                : 'want_to_climb_the_ladder'.tr);
      default:
        return "";
    }
  }
}
