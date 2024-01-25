
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

void showSalaryBottomSheet(BuildContext context,Worklistings worklistings,Function() onViewJobTap) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return  ShowSalaryBottomSheet(worklistings,onViewJobTap);
      });
}

class ShowSalaryBottomSheet extends StatelessWidget {
  final Worklistings worklistings;
  final Function() onViewJobTap;
  const ShowSalaryBottomSheet(this.worklistings,this.onViewJobTap,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_48,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSalaryDetailText(),
          const SizedBox(height: Dimens.margin_8),
          HDivider(),
          Html(
            data: worklistings.informationText ?? '',
          ),
          const SizedBox(height: Dimens.margin_16),
          buildViewJobText(),
        ],
      ),
    );
  }

  Widget buildSalaryDetailText() {
    return Text(
      'salary_detail'.tr,
      style: Get.context?.textTheme.bodyLarge
          ?.copyWith(
          color: AppColors
              .backgroundBlack,fontWeight: FontWeight.w600),
    );
  }

  Widget buildViewJobText() {
    return MyInkWell(
      onTap: (){
        MRouter.pop(null);
        onViewJobTap();
      },
      child: Row(
        children: [
          Text(
            'view_jobs_desc'.tr,
            style: Get.context?.textTheme.bodyMedium
                ?.copyWith(
                color: AppColors
                    .primaryMain,fontWeight: FontWeight.w600),
          ),
          const Icon(
              Icons.arrow_forward_ios,
            color: AppColors.primaryMain,
            size: Dimens.font_12,
          ),
        ],
      ),
    );
  }
}
