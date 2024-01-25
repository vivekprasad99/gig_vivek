import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/divider/v_divider.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing_response.dart';
import 'package:flutter/material.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:get/get.dart';
import '../../../../../../core/widget/theme/theme_manager.dart';

class WorkListTile extends StatelessWidget {
  final Worklistings workListings;
  final int index;
  final Function(int index, Worklistings workListings) onCardTap;
  final Function(int index, Worklistings workListings) onSalaryDetailTap;
  final Function(WorkApplicationEntity application, ActionData actionData)
      onApplicationAction;
  final Function(
      int? categoryApplicationId, int? workListingId, int? categoryId)
  onCheckEligibilityTap;

  const WorkListTile(this.workListings, this.index, this.onCardTap,
      this.onSalaryDetailTap, this.onApplicationAction,this.onCheckEligibilityTap,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundGold,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Stack(
        children: [
          if (workListings.highlightTag?.name != null) buildFeaturedTag(),
          Container(
            padding:  EdgeInsets.fromLTRB(Dimens.padding_16, workListings.highlightTag?.name != null? Dimens.padding_32 : Dimens.padding_16,
                Dimens.padding_16, Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyInkWell(
                  onTap: () {
                    onCardTap(index, workListings);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          buildCategoryIcon(workListings),
                          const SizedBox(width: Dimens.margin_16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  workListings.name ?? '',
                                  style: context.textTheme.bodyText1Bold
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: Dimens.margin_8),
                                Row(
                                  children: [
                                    Text(
                                      '${workListings.listingType?.replaceAll("_", " ").toCapitalized()}',
                                      style: context.textTheme.caption?.copyWith(
                                          color: AppColors.backgroundBlack),
                                    ),
                                    SizedBox(
                                      height: Dimens.padding_12,
                                      child: VDivider(),
                                    ),
                                    buildLocationText(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimens.margin_8),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: '${'basic_req'.tr}: ',
                                style: context.textTheme.labelMedium?.copyWith(
                                    color: AppColors.backgroundGrey800,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: workListings.requirements ?? '',
                                style: context.textTheme.bodyText2
                                    ?.copyWith(color: AppColors.backgroundGrey800)),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
                        child: Text(
                          '${workListings.potentialEarning?.getEarningText()}',
                          style: context.textTheme.bodyText1Medium
                              ?.copyWith(color: AppColors.backgroundGrey900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimens.margin_8),
                buildSalaryDetailText(context),
                const SizedBox(height: Dimens.margin_8),
                Visibility(
                  visible: workListings
                      .workApplicationEntity?.supplyPendingAction?.value !=
                      null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HDivider(),
                      const SizedBox(height: Dimens.margin_8),
                        buildSupplyPendingActionText(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget buildFeaturedTag() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: workListings.getTagColor(),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(Dimens.radius_40),
            topRight: Radius.circular(Dimens.radius_8)
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 24,top: 8,right: 16,bottom: 8),
          child: Text(workListings.highlightTag?.name ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  Widget buildCategoryIcon(Worklistings worklistings) {
    String url = worklistings.icon ?? '';
    return NetworkImageLoader(
      url: url,
      width: Dimens.imageWidth_48,
      height: Dimens.imageHeight_48,
      filterQuality: FilterQuality.high,
      fit: BoxFit.cover,
    );
  }

  Widget buildLocationText() {
    String? locationType = "";
    if (workListings.locationType?.getValue2() != null) {
      locationType = workListings.locationType?.getValue2();
    }
    return Text(
      '$locationType',
      style: Get.context?.textTheme.caption
          ?.copyWith(color: AppColors.backgroundBlack),
    );
  }

  Widget buildSalaryDetailText(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onSalaryDetailTap(index, workListings);
      },
      child: Text(
        'salary_detail'.tr,
        style: Get.context?.textTheme.caption
            ?.copyWith(color: AppColors.primaryMain),
      ),
    );
  }

  Widget buildSupplyPendingActionText(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onApplicationAction(workListings.workApplicationEntity!,
            workListings.workApplicationEntity!.pendingAction ?? ActionData());
      },
      child: Text(
        workListings.workApplicationEntity?.supplyPendingAction?.value
                .toString()
                .toCapitalized()
                .replaceAll("_", " ") ??
            "",
        style: Get.context?.textTheme.bodyText2Bold
            ?.copyWith(color: AppColors.primaryMain),
      ),
    );
  }
}
