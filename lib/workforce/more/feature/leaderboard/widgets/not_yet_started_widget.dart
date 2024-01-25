import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';
import '../../../../core/utils/constants.dart';

class NotYetStartedWidget extends StatelessWidget {
  String navItemSelectedValue;
  NotYetStartedWidget(this.navItemSelectedValue, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        color: AppColors.backgroundGrey400,
        padding: const EdgeInsets.all(Dimens.padding_16),
        width: double.infinity,
        child: Column(
          children: [
            buildNotYetStartedImage(),
            const SizedBox(height: Dimens.margin_16),
            buildNotYetStarted(),
            const SizedBox(height: Dimens.margin_16),
            buildExploreCategoriesText(),
            const SizedBox(height: Dimens.margin_16),
            buildExploreJobButton(),
            const SizedBox(height: Dimens.margin_16),
          ],
        ),
      ),
    );
  }

  Widget buildNotYetStartedImage() {
    return SvgPicture.asset(
      'assets/images/not_yet_started.svg',
    );
  }

  Widget buildNotYetStarted() {
    return Text(
      "not_yet_started".tr,
      style: Get.context?.textTheme.titleMedium?.copyWith(
          color: AppColors.backgroundBlack,
          fontWeight: FontWeight.w600,
          fontSize: Dimens.margin_16),
    );
  }

  Widget buildExploreJobButton() {
    return RaisedRectButton(
      width: Dimens.etWidth_150,
      text: 'explore_jobs'.tr,
      onPressed: () async {
        switch (navItemSelectedValue) {
          case Constants.earning:
            CaptureEventHelper.captureEvent(
                loggingData: LoggingData(
                    event: LoggingEvents.viewExploreJobsFromEarnings,
                    action: LoggingActions.click,
                    pageName: "Leaderboard",
                    sectionName: "Profile")
            );
            break;
          case Constants.taskCompleted:
            CaptureEventHelper.captureEvent(
                loggingData: LoggingData(
                    event: LoggingEvents.viewExploreJobsFromTasks,
                    action: LoggingActions.click,
                    pageName: "Leaderboard",
                    sectionName: "Profile")
            );
            break;
        }
        MRouter.pushNamed(MRouter.categoryListingWidget);
      },
    );
  }

  Widget buildExploreCategoriesText() {
    return Text(
      "explore_categories".tr,
      textAlign: TextAlign.center,
      style: Get.context?.textTheme.titleMedium?.copyWith(
          color: AppColors.backgroundGrey800,
          fontWeight: FontWeight.w400,
          fontSize: Dimens.font_14),
    );
  }
}
