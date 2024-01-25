import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/show_goal_bottom_sheet/widget/show_goal_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/user_earning_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PerformanceWidget extends StatelessWidget {
  final UserEarningResponse userEarning;
  final String date;
  final String selectedNavItem;

  const PerformanceWidget(
      {Key? key,
      required this.userEarning,
      required this.date,
      required this.selectedNavItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPerformanceAttributeLabel(),
                buildViewGoalWidget(context),
              ],
            ),
            const SizedBox(height: Dimens.margin_8),
            buildPerformanceAttributeValue(),
            const SizedBox(height: Dimens.margin_8),
            HDivider(
              dividerColor: AppColors.backgroundGrey300,
            ),
            const SizedBox(height: Dimens.margin_8),
            buildPerformanceRemark(),
            const SizedBox(height: Dimens.margin_8),
            buildPerformancePercentageWidget(),
            const SizedBox(height: Dimens.margin_8),
            buildPerformanceAttributeDesc(),
          ],
        ),
      ),
    );
  }

  Widget buildViewGoalWidget(BuildContext context) {
    return Visibility(
      visible: date == StringUtils.getMonthAndYear(),
      child: MyInkWell(
        onTap: () {
          showGoalBottomSheet(context, userEarning, selectedNavItem);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/flag.svg',
            ),
            Text(
              'view_goals'.tr,
              style: Get.context?.textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryMain,
                  fontSize: Dimens.padding_14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPerformanceRemark() {
    return Text(
      '${getPerformanceDetail(userEarning.performance!)["performance_remark"]}',
      style: Get.context?.textTheme.titleLarge?.copyWith(
          color: getPerformanceDetail(userEarning.performance!)["bg_color"],
          fontSize: Dimens.padding_14,
          fontWeight: FontWeight.w500),
    );
  }

  Widget buildPerformancePercentageWidget() {
    return Row(
      children: [
        buildPercentIndicator(
            "poor".tr, getPerformanceColor(userEarning.performance!)[0]),
        const SizedBox(
          width: 10,
        ),
        buildPercentIndicator(
            "average".tr, getPerformanceColor(userEarning.performance!)[1]),
        const SizedBox(
          width: 10,
        ),
        buildPercentIndicator(
            "good".tr, getPerformanceColor(userEarning.performance!)[2]),
        const SizedBox(
          width: 10,
        ),
        buildPercentIndicator(
            "excellent".tr, getPerformanceColor(userEarning.performance!)[3]),
      ],
    );
  }

  Widget buildPerformanceAttributeLabel() {
    return Text(
      getSelectedText(selectedNavItem)['selectedNavItemText'],
      style: Get.context?.textTheme.titleLarge?.copyWith(
          color: AppColors.backgroundGrey800,
          fontSize: Dimens.padding_14,
          fontWeight: FontWeight.w500),
    );
  }

  Widget buildPerformanceAttributeValue() {
    return Text(
      getSelectedText(selectedNavItem)['data'],
      style: Get.context?.textTheme.titleLarge?.copyWith(
          color: AppColors.backgroundBlack,
          fontSize: Dimens.padding_24,
          fontWeight: FontWeight.w700),
    );
  }

  Widget buildPercentIndicator(String name, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: Dimens.padding_16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: Dimens.margin_12),
          Text(
            name,
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.backgroundGrey800,
                fontSize: Dimens.padding_14,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget buildPerformanceAttributeDesc() {
    return Visibility(
      visible: userEarning.message!.isNotEmpty,
      child: Column(
        children: [
          HDivider(
            dividerColor: AppColors.backgroundGrey300,
          ),
          const SizedBox(height: Dimens.margin_8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/info_red.svg',
                color:
                    getPerformanceDetail(userEarning.performance!)["bg_color"],
              ),
              const SizedBox(width: Dimens.margin_4),
              Text(
                '${userEarning.message}',
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.backgroundBlack,
                    fontSize: Dimens.padding_14,
                    fontWeight: FontWeight.w400),
              ),
            ],
          )
        ],
      ),
    );
  }

  Map<String, dynamic> getPerformanceDetail(String performance) {
    switch (performance) {
      case Constants.poor:
        return {
          Constants.bgColor: AppColors.error400,
          "performance_remark": "poor_performance".tr
        };
      case Constants.average:
        return {
          Constants.bgColor: AppColors.warning300,
          "performance_remark": "average_performance".tr
        };
      case Constants.good:
        return {
          Constants.bgColor: AppColors.success300,
          "performance_remark": "good_performance".tr
        };
      case Constants.excellent:
        return {
          Constants.bgColor: AppColors.link300,
          "performance_remark": "excellent_performance".tr
        };
      default:
        return {
          Constants.bgColor: AppColors.warning200,
          "performance_remark": "poor_performance".tr
        };
    }
  }

  List<Color> getPerformanceColor(String performance) {
    switch (performance) {
      case Constants.poor:
        return [
          AppColors.error400,
          AppColors.backgroundGrey300,
          AppColors.backgroundGrey300,
          AppColors.backgroundGrey300,
        ];
      case Constants.average:
        return [
          AppColors.warning300,
          AppColors.warning300,
          AppColors.backgroundGrey300,
          AppColors.backgroundGrey300,
        ];
      case Constants.good:
        return [
          AppColors.success300,
          AppColors.success300,
          AppColors.success300,
          AppColors.backgroundGrey300,
        ];
      case Constants.excellent:
        return [
          AppColors.link300,
          AppColors.link300,
          AppColors.link300,
          AppColors.link300,
        ];
      default:
        return [
          AppColors.error400,
          AppColors.backgroundGrey300,
          AppColors.backgroundGrey300,
          AppColors.backgroundGrey300,
        ];
    }
  }

  Map<String, dynamic> getSelectedText(String selectedNavItem) {
    switch (selectedNavItem) {
      case Constants.earning:
        return {
          Constants.selectedNavItemText: 'your_earnings'.tr,
          "data": NumberFormat.currency(
                  locale: 'HI', name: "", decimalDigits: 0, symbol: '₹ ')
              .format(userEarning.data)
        };
      case Constants.jobOnboarded:
        return {
          Constants.selectedNavItemText: 'your_job'.tr,
          "data": "${userEarning.data} Jobs"
        };
      case Constants.taskCompleted:
        return {
          Constants.selectedNavItemText: 'your_tasks'.tr,
          "data": "${userEarning.data} Tasks"
        };
      default:
        return {"": ""};
    }
  }
}
