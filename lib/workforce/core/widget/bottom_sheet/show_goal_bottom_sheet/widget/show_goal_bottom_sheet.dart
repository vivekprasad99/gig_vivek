import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/user_earning_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';

void showGoalBottomSheet(
    BuildContext context, UserEarningResponse userEarning,String selectedNavItem) {
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
        return ShowGoalBottomSheet(
          userEarning: userEarning,
          selectedNavItem: selectedNavItem,
        );
      });
}

class ShowGoalBottomSheet extends StatefulWidget {
  UserEarningResponse userEarning;
  String selectedNavItem;
  ShowGoalBottomSheet({Key? key, required this.userEarning,required this.selectedNavItem}) : super(key: key);

  @override
  State<ShowGoalBottomSheet> createState() => _ShowGoalBottomSheetState();
}

class _ShowGoalBottomSheetState extends State<ShowGoalBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.margin_48,
          Dimens.padding_16, Dimens.margin_32),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'my_goals'.tr,
                  style: Get.context?.textTheme.titleLarge?.copyWith(
                      color: AppColors.backgroundBlack,
                      fontSize: Dimens.padding_20,
                      fontWeight: FontWeight.w700),
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
            const SizedBox(
              height: Dimens.padding_24,
            ),
            Text(
              'track_your_progress'.tr,
              style: Get.context?.textTheme.titleLarge?.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontSize: Dimens.padding_14,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: Dimens.padding_16,
            ),
            Stack(
              children: [
                Container(
                  height: Dimens.btnWidth_250,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Dimens.padding_48, top: Dimens.padding_32),
                      child: SvgPicture.asset(
                        'assets/images/milestone_person.svg',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Dimens.btnWidth_90),
                      child: SvgPicture.asset(
                        'assets/images/flag_2.svg',
                        height: Dimens.padding_24,
                      ),
                    ),
                  ],
                ),
                Positioned(
                    top: 0,
                    child: Visibility(
                      visible: showPerformanceCard(
                          widget.userEarning.performance!)[1],
                      child: buildGoodContainer(
                          0.55,
                          BubblePosition.Bottom,
                          0.4,
                          AppColors.success100,
                          AppColors.success300,
                          'good'.tr,
                          getSelectedText(widget.selectedNavItem)['good'],
                    ),),),
                Padding(
                  padding: const EdgeInsets.only(top: Dimens.btnWidth_110),
                  child: Stack(
                    children: [
                      LinearPercentIndicator(
                        animation: true,
                        lineHeight: Dimens.padding_16,
                        animationDuration: 500,
                        percent: 0.3,
                        barRadius: const Radius.circular(Dimens.padding_12),
                        progressColor: AppColors.primary300,
                        backgroundColor: AppColors.primary100,
                      ),
                      buildMilestone(0.33),
                      buildMilestone(0.66),
                      buildMilestone(0.93),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 10,
                    right: Dimens.padding_200,
                    child: Visibility(
                      visible: showPerformanceCard(
                          widget.userEarning.performance!)[0],
                      child: buildGoodContainer(
                          0.33,
                          BubblePosition.Top,
                          0.5,
                          AppColors.warning100,
                          AppColors.warning300,
                          'average'.tr,
                        getSelectedText(widget.selectedNavItem)['average'],),
                    )),
                Positioned(
                    bottom: 10,
                    right: Dimens.padding_16,
                    child: Visibility(
                      visible: showPerformanceCard(
                          widget.userEarning.performance!)[2],
                      child: buildGoodContainer(
                          0.93,
                          BubblePosition.Top,
                          0.9,
                          AppColors.link100,
                          AppColors.link300,
                          'excellent'.tr,
                        getSelectedText(widget.selectedNavItem)['excellent'],)
                    )),
              ],
            ),
          ]),
    );
  }

  Widget buildMilestone(double value) {
    return Container(
      margin: EdgeInsets.only(left: marginForMileStone(value)),
      child: const CircleAvatar(
        radius: Dimens.radius_8,
        backgroundColor: AppColors.primary200,
      ),
    );
  }

  Widget buildGoodContainer(
      double value,
      BubblePosition position,
      double percentPosition,
      Color backgroundColor,
      Color borderColor,
      String performance,
      String performanceText) {
    return Container(
      margin: EdgeInsets.only(left: marginForMileStone(value)),
      width: Dimens.btnWidth_150,
      height: Dimens.btnWidth_110,
      child: ShapeOfView(
        shape: BubbleShape(
            position: position,
            arrowPositionPercent: percentPosition,
            borderRadius: Dimens.avatarHeight_20,
            arrowHeight: 10,
            arrowWidth: 10),
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: 1,
              )),
          padding: EdgeInsets.only(
              left: Dimens.padding_8,
              right: Dimens.padding_8,
              bottom: 0,
              top: position == BubblePosition.Top
                  ? Dimens.avatarHeight_20
                  : Dimens.padding_8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: Dimens.padding_4,
                        backgroundColor: borderColor,
                      ),
                      const SizedBox(
                        width: Dimens.padding_4,
                      ),
                      Text(
                        performance,
                        style: Get.context?.textTheme.titleLarge?.copyWith(
                            color: AppColors.backgroundBlack,
                            fontSize: Dimens.padding_12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: performance != 'Average',
                    child: SvgPicture.asset(
                      'assets/images/good_icon.svg',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: Dimens.padding_4,
              ),
              Text(
                performanceText,
                textAlign: TextAlign.start,
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.backgroundBlack,
                    fontSize: Dimens.padding_12,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double marginForMileStone(double value) {
    double i = MediaQuery.of(context).size.width - 32;
    return i * value;
  }

  List<bool> showPerformanceCard(String performance) {
    switch (performance) {
      case "poor":
        return [true, true, true];
      case "average":
        return [false, true, true];
      case "good":
        return [
          false,
          false,
          true,
        ];
      case "excellent":
        return [
          false,
          false,
          false,
        ];
      default:
        return [true, true, true];
    }
  }

  Map<String, dynamic> getSelectedText(String selectedNavItem) {
    switch (selectedNavItem) {
      case "EARNING":
        return {"average": "Earn ${NumberFormat.currency(locale: 'HI', name: "", decimalDigits: 0, symbol: '₹ ').format(widget.userEarning.goals?.average)} more to reach here","good" : "Earn ${NumberFormat.currency(locale: 'HI', name: "", decimalDigits: 0, symbol: '₹ ').format(widget.userEarning.goals?.good)} more to reach here & get a certificate","excellent" : "Earn ${NumberFormat.currency(locale: 'HI', name: "", decimalDigits: 0, symbol: '₹ ').format(widget.userEarning.goals?.excellent)} more to reach here & get a certificate"};
      case "TASK_COMPLETED":
        return {"average": "Onboard to ${NumberFormat.currency(locale: 'HI', name: "", decimalDigits: 0, symbol: '').format(widget.userEarning.goals?.average)} more jobs to reach here.","good" : "Onboard to ${NumberFormat.currency(locale: 'HI', name: "", decimalDigits: 0, symbol: '').format(widget.userEarning.goals?.good)} more jobs to reach here and get a certificate.","excellent" : "Onboard to ${NumberFormat.currency(locale: 'HI', name: "", decimalDigits: 0, symbol: '').format(widget.userEarning.goals?.excellent)} more jobs to reach here be in the top 5 category."};
      default:
        return {"selectedNavItemText": "fifth"};
    }
  }
}
