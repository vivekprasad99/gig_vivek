import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/tile/early_withdrawl_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/utils/constants.dart';

class AllDeductionWidget extends StatelessWidget {
  final CalculateDeductionResponse? calculateDeductionResponse;
  const AllDeductionWidget(this.calculateDeductionResponse,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return RouteWidget(
      bottomNavigation: true,
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        bottomPadding: 0,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              DefaultAppBar(isCollapsable: true, title: 'all_deduction'.tr),
            ];
          },
          body: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.context?.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16,
          Dimens.padding_16,
          Dimens.padding_16,
          Dimens.padding_56,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWithdrawlChargesLabel(),
            const SizedBox(
              height: Dimens.padding_16,
            ),
            buildEarlyWithdrawlList(),
            HDivider(dividerColor: AppColors.backgroundGrey400),
            buildTotalDeductionWidget()
          ],
        ),
      ),
    );
  }

  Widget buildCloseIcon() {
    return MyInkWell(
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
    );
  }

  Widget buildEarlyWithdrawlText()
  {
    return Text('early_withdrawal_charges'.tr,
        style: Get.context!.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundBlack,
            fontWeight: FontWeight.w600,
            fontSize: Dimens.font_18));
  }

  Widget buildWithdrawlChargesDescCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                const Icon(
                  Icons.info,
                  color: AppColors.black,
                  size: Dimens.padding_20,
                ),
                const SizedBox(
                  width: Dimens.padding_16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                          'charges_depend_on_desc'
                              .tr,
                          style: Get.context!
                              .textTheme
                              .bodyText2
                              ?.copyWith(color: AppColors.backgroundBlack, fontWeight: FontWeight.w500,fontSize: Dimens.font_10)),
                      const SizedBox(
                        height: Dimens.padding_8,
                      ),
                      MyInkWell(
                        onTap:
                            () {
                        },
                        child: Text(
                            'terms_and_condition_applied'.tr,
                            style: Get.context!.textTheme.bodyText2?.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w400, fontSize: Dimens.font_10)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  Widget buildWithdrawlChargesLabel()
  {
    return Row(
      children: [
        Expanded(
          child: Text("approval_date".tr,
            textAlign: TextAlign.start,
            style: Get.textTheme.bodySmall!.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text("upcoming_account".tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodySmall!.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text("early_redemption_deduction".tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodySmall!.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget buildTotalDeductionWidget()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("total_deduction".tr,
          textAlign: TextAlign.start,
          style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.backgroundBlack,
              fontWeight: FontWeight.w700),
        ),
        Text('${calculateDeductionResponse?.deductions![1].amount}',
          textAlign: TextAlign.start,
          style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.error400,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildEarlyWithdrawlList() {
    return Expanded(
      child: MediaQuery.removePadding(
        context: Get.context!,
        removeTop: true,
        child: ListView.builder(
          itemCount: calculateDeductionResponse?.approvedPayouts?.length,
          itemBuilder: (_, i) {
            return EarlyWithdrawlTile(approvedPayouts: calculateDeductionResponse!.approvedPayouts![i],);
          },
        ),
      ),
    );
  }
}
