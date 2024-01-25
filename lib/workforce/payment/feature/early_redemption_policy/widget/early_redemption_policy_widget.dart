import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/widget/network_sensitive/internet_sensitive.dart';
import '../../../../core/widget/route_widget/route_widget.dart';

class EarlyRedemptionPolicyWidget extends StatelessWidget {
  final CalculateDeductionResponse? calculateDeductionResponse;
  const EarlyRedemptionPolicyWidget(this.calculateDeductionResponse,{Key? key}) : super(key: key);

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
              DefaultAppBar(isCollapsable: true, title: 'early_redemption_policy'.tr),
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
      child: InternetSensitive(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_36, Dimens.padding_16, Dimens.padding_36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('please_not_the_following_points'.tr,
                    textAlign: TextAlign.center,
                    style: Get.context?.textTheme.bodyText1?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,)),
                const SizedBox(height: Dimens.padding_24),
                Text('value_payout_desc'.tr,
                    style: Get.context?.textTheme.bodyText1?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,)),
                const SizedBox(height: Dimens.padding_24),
                Text('example_redemption_desc'.tr,
                    style: Get.context?.textTheme.bodyText1?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,)),
                const SizedBox(height: Dimens.padding_16),
                Image.asset(
                  "assets/images/redemption_table.png",
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
                const SizedBox(height: Dimens.padding_16),
                Text('values_amount_desc'.tr,
                    style: Get.context?.textTheme.labelMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,)),
                const SizedBox(height: Dimens.padding_16),
                Text('refundable_desc'.tr,
                    style: Get.context?.textTheme.labelMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,)),
                const SizedBox(height: Dimens.padding_40),
                Center(
                  child: RaisedRectButton(
                    width: Dimens.btnWidth_180,
                    text: 'view_all_dedc'.tr,
                    onPressed: () {
                      MRouter.pushNamed(MRouter.allDeductionWidget,arguments: calculateDeductionResponse);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
