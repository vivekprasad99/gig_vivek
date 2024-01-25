import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../theme/theme_manager.dart';

void showImproveBottomSheet(
    BuildContext context,String selectedNavItem) {
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
        return  ShowImproveBottomSheet(selectedNavItem: selectedNavItem,);
      });
}

class ShowImproveBottomSheet extends StatelessWidget {
  final String selectedNavItem;
  const ShowImproveBottomSheet({Key? key,required this.selectedNavItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_32, Dimens.margin_48,
              Dimens.padding_16, 0),
          decoration: const BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/images/icons_8_light_on.svg',
                  ),
                  MyInkWell(
                    onTap: () {
                      MRouter.pop(null);
                    },
                    child: const CircleAvatar(
                      backgroundColor: AppColors.backgroundGrey700,
                      radius: Dimens.radius_12,
                      child: Icon(
                        Icons.close,
                        color: AppColors.backgroundWhite,
                        size: Dimens.margin_16,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getSelectedText(selectedNavItem)['selectedNavItemText'],
                    style: Get.context?.textTheme.titleLarge
                        ?.copyWith(color: AppColors.backgroundBlack,fontSize: Dimens.padding_20,fontWeight: FontWeight.w700),
                  ),
                  SvgPicture.asset(
                    'assets/images/improve_tip.svg',
                    height: Dimens.padding_88,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimens.padding_24,),
        if(selectedNavItem == "EARNING") ...[
          buildImproveTipText('increase_your_performance_score'.tr),
          buildImproveTipText('request_more_task_from_your_manager'.tr),
          buildImproveTipText('complete_your_task_in_stipulated_time'.tr),
          buildImproveTipText('work_on_parallel_job'.tr)
    ]
        else if(selectedNavItem == "JOB_ONBOARDED") ...[
        buildImproveTipText('attend_all_webinar'.tr),
        buildImproveTipText('go_through_all_the_material'.tr),
        buildImproveTipText('apply_for_similar_jobs'.tr),
        ]
        else ...[
        buildImproveTipText('request_more_task'.tr),
        buildImproveTipText('complete_your_task_in_stipulated_time'.tr),
        buildImproveTipText('increase_your_quality'.tr),
        ],
        const SizedBox(height: Dimens.padding_24,),
      ],
    );
  }

  Widget buildImproveTipText(String name)
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_32, 0,
          Dimens.padding_16, Dimens.margin_16),
      child: Row(
        children: [
          const CircleAvatar(radius: 2,backgroundColor: AppColors.backgroundBlack,),
          const SizedBox(width: Dimens.padding_8,),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.start,
              style: Get.context?.textTheme.titleLarge
                  ?.copyWith(color: AppColors.backgroundGrey900,fontSize: Dimens.padding_16,fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getSelectedText(String selectedNavItem) {
    switch (selectedNavItem) {
      case "EARNING":
        return {"selectedNavItemText": 'how_to_earn_more'.tr};
      case "JOB_ONBOARDED":
        return {"selectedNavItemText": 'improve_your_job_onboarding'.tr,};
      case "TASK_COMPLETED":
        return {"selectedNavItemText": 'how to get more task'.tr,};
      default:
        return {"selectedNavItemText": "fifth"};
    }
  }
}
