import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/widget/provider/application_tile_section_widget_provider.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationTile extends StatelessWidget {
  final int index;
  final WorkApplicationEntity workApplicationEntity;
  final UserData? currentUser;
  final Function(WorkApplicationEntity application, ActionData actionData)
      onApplicationAction;
  final Function(WorkApplicationEntity application) onViewDetailsTap;
  final Function(
          int? categoryApplicationId, int? workListingId, int? categoryId)
      onCheckEligibilityTap;

  const ApplicationTile(
      {Key? key,
      required this.index,
      required this.workApplicationEntity,
      required this.currentUser,
      required this.onViewDetailsTap,
      required this.onApplicationAction,
      required this.onCheckEligibilityTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_16),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildIcon(),
                  const Spacer(),
                  // build3dots(),
                  Visibility(
                      visible: !workApplicationEntity.isEligible!,
                      child: buildInEligibleText()),
                  const SizedBox(width: Dimens.padding_16),
                ],
              ),
              buildApplicationName(),
              buildViewDetails(),
              buildEarningText(),
              buildLocationText(),
              if (workApplicationEntity.isEligible!) ...[
                buildSection(),
              ] else ...[
                buildCheckEligiblityWidget(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIcon() {
    if (workApplicationEntity.icon != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
        child: CustomCircleAvatar(
            url: workApplicationEntity.icon, radius: Dimens.radius_20),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildInEligibleText() {
    return Padding(
      padding: const EdgeInsets.only(right: Dimens.padding_16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_16)),
          border: Border.all(
            color: AppColors.backgroundGrey400,
            width: Dimens.border_1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: Dimens.margin_4),
                height: Dimens.margin_8,
                width: Dimens.margin_8,
                decoration: const BoxDecoration(
                    color: AppColors.googleRed,
                    borderRadius:
                        BorderRadius.all(Radius.circular(Dimens.radius_12))),
              ),
              Text('ineligible'.tr, style: Get.textTheme.bodyText2),
            ],
          ),
        ),
      ),
    );
  }

  Widget build3dots() {
    return const Icon(
      Icons.more_horiz,
      color: AppColors.backgroundGrey500,
      size: Dimens.radius_32,
    );
  }

  Widget buildApplicationName() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text(
        workApplicationEntity.workListingTitle ?? '',
        style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildViewDetails() {
    if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideApplicationDetails) ??
        false)) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            onViewDetailsTap(workApplicationEntity);
          },
          child: Text(
            'application_details'.tr,
            style: Get.textTheme.bodyText2?.copyWith(color: AppColors.link400),
          ),
        ),
      );
    }
  }

  Widget buildEarningText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_balance_wallet,
              color: AppColors.backgroundGrey800),
          const SizedBox(width: Dimens.margin_8),
          Expanded(
            child: Text(
                '${workApplicationEntity.potentialEarning?.getEarningText()}',
                style: Get.context?.textTheme.bodyText1),
          ),
          const Icon(Icons.info, color: AppColors.backgroundGrey500),
        ],
      ),
    );
  }

  Widget buildLocationText() {
    String? locationType = "";
    if (workApplicationEntity.worklisting?.locationType?.getValue2() != null) {
      locationType =
          workApplicationEntity.worklisting?.locationType?.getValue2();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: AppColors.backgroundGrey800,
          ),
          const SizedBox(
            width: Dimens.margin_8,
          ),
          Text(
            locationType ?? '',
            style: Get.textTheme.bodyText2?.copyWith(color: AppColors.link400),
          ),
        ],
      ),
    );
  }

  Widget buildCheckEligiblityWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_8,
          Dimens.padding_16, Dimens.padding_16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
            Dimens.padding_16, Dimens.padding_16),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey400,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8)),
          border: Border.all(
            color: AppColors.backgroundGrey400,
            width: Dimens.border_1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dont_full_eligibility_text'.tr,
              style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.backgroundGrey800),
            ),
            const SizedBox(
              height: Dimens.margin_8,
            ),
            MyInkWell(
              onTap: () {
                onCheckEligibilityTap(
                    workApplicationEntity.categoryApplicationId,
                    workApplicationEntity.workListingId,
                    workApplicationEntity.categoryId);
              },
              child: Text(
                'check_eligibility'.tr,
                style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500, color: AppColors.primaryMain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection() {
    ClevertapData clevertapData = ClevertapData(
        isApplicationStatusEvent: true,
        workApplicationEntity: workApplicationEntity,
        applicationStatus: workApplicationEntity.applicationStatus,
        currentUser: currentUser);
    CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    if (workApplicationEntity.applicationStatus ==
            ApplicationStatus.inAppInterviewRejected ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.telephonicInterviewRejected ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.inAppTrainingRejected ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.webinarTrainingRejected ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.pitchTestRejected ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.inAppInterviewCompleted ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.telephonicInterviewCompleted ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.inAppTrainingCompleted ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.webinarTrainingCompleted ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.manualPitchDemoCompleted ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.automatedPitchDemoCompleted ||
        workApplicationEntity.applicationStatus ==
            ApplicationStatus.pitchTestCompleted) {
      LoggingData loggingData =
          LoggingData(event: workApplicationEntity.applicationStatus?.value);
      CaptureEventHelper.captureEvent(loggingData: loggingData);
    }
    return ApplicationTileSectionWidgetProvider.getActionSection(
        workApplicationEntity.tileActionSection,
        workApplicationEntity,
        onApplicationAction);
  }
}
