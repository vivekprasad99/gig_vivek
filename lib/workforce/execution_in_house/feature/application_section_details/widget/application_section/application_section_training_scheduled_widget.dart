import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/webinar_training_joining_bottom_sheet/widget/webinar_training_joining_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationSectionTrainingScheduledWidget extends StatelessWidget {
  final ScheduledBatchSection scheduledBatchSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const ApplicationSectionTrainingScheduledWidget(this.scheduledBatchSection,
      this.workApplicationEntity, this.onActionTapped,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimens.margin_16),
      decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border.all(color: AppColors.backgroundLight),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitleWidget(),
          buildCountdownAndCommunicationWidgets(),
          Align(
            alignment: Alignment.centerRight,
            child: buildRescheduleWidget(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.margin_16),
            child: HDivider(dividerColor: AppColors.backgroundGrey400,),
          ),
          // buildApplicationActionWidget(),
          buildShowActionButton(),
        ],
      ),
    );
  }

  Widget buildShowActionButton() {
    switch (workApplicationEntity.supplyPendingAction?.value) {
      case "prepare_training_no_resources":
        return buildJoinTrainingButton(false);
      case "prepare_training":
        return Row(
          children: [
            Expanded(child: buildPrepareForTrainingButton(true)),
            Expanded(child: buildJoinTrainingButton(false)),
          ],
        );
      case "join_training":
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: buildPrepareForTrainingButton(true)),
                Expanded(child: buildJoinTrainingButton(true)),
              ],
            ),
            buildUnableToJoinMeetingButton(),
          ],
        );
      case "join_training_no_resources":
        return Column(
          children: [
            buildJoinTrainingButton(true),
            buildUnableToJoinMeetingButton(),
          ],
        );
      default:
        return const SizedBox();
    }
  }


  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: Text('Your Webinar Training is scheduled : ${scheduledBatchSection.scheduledBatch?.startTime != null ? scheduledBatchSection.scheduledBatch!.startTime!.getFormattedDateTime(StringUtils.dateTimeFormatDMHMA) : ''}',
          style: Get.textTheme.bodyText2),
    );
  }

  Widget buildSubTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: Text('Please come back after', style: Get.textTheme.bodyText2),
    );
  }

  Widget buildDateTimeWidget() {
    if (scheduledBatchSection.scheduledBatch?.startTime != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
        child: Text(
          scheduledBatchSection.scheduledBatch!.startTime!
              .getFormattedDateTime(StringUtils.dateTimeFormatDMHMA),
          style: Get.textTheme.bodyText2SemiBold,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildRemainingTime() {
    Duration? duration = StringUtils.getRemainingTime(
        scheduledBatchSection.scheduledBatch?.startTime!);
    String time = "";
    Color? color;
    if (duration!.inDays > 0) {
      time = "${duration.inDays} Days";
      color = AppColors.success300;
    } else if (duration.inHours > 0) {
      time =
      "${duration.inHours} hours ${duration.inMinutes.remainder(60)} minutes";
      color = AppColors.success300;
    } else if (duration.inMinutes > 0) {
      time = "${duration.inMinutes} minutes";
      color = AppColors.error300;
    }
    if(duration.inDays == 0 && duration.inHours == 0 && duration.inMinutes == 0)
    {
      return Text(
        'your_webinar_has_started_please_join_the_meeting'.tr,
        style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500, fontSize: Dimens.font_16),
      );
    }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.alarm,
            color: AppColors.backgroundGrey700,
            size: Dimens.font_28,
          ),
          const SizedBox(width: Dimens.margin_8),
          Text(
            time,
            style: Get.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500, color: color, fontSize: Dimens.font_16),
          ),
        ],
      );
    }
  }

  Widget buildCountdownAndCommunicationWidgets() {
    String strCommunicationText = 'please_come_back_after'.tr;
    String? strRemainingTime;
    DateTime? startDateTime = scheduledBatchSection.scheduledBatch!.startTime!
        .getDateTimeObjectFromStrDateTime(StringUtils.dateTimeFormatYMDTHMSS,
            isUTC: false);
    if (startDateTime != null) {
      strRemainingTime = StringUtils.calculateTimeDifferenceBetween(
          DateTime.now(), startDateTime);
    }
    if (strRemainingTime != null) {
      Color color = AppColors.success400;
      if (strRemainingTime.contains('days') ||
          strRemainingTime.contains('hours')) {
        color = AppColors.success400;
      } else {
        color = AppColors.error300;
        strCommunicationText =
            'you_can_start_joining_in_and_wait_for_trainer_to_come'.tr;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
            child: Text(strCommunicationText,
                textAlign: TextAlign.center, style: Get.textTheme.bodyText2),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alarm, color: AppColors.backgroundGrey800),
                const SizedBox(width: Dimens.padding_8),
                Text(strRemainingTime,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headline7.copyWith(color: color)),
              ],
            ),
          ),
        ],
      );
    } else {
      strCommunicationText =
          'your_webinar_has_started_please_join_the_meeting'.tr;
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
          child: Text(strCommunicationText,
              textAlign: TextAlign.start, style: Get.textTheme.bodyText2),
        ),
      );
    }
  }

  Widget buildRescheduleWidget() {
    if ((scheduledBatchSection.enableReschedule ?? false)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
        child: MyInkWell(
          onTap: () {
            onActionTapped(
                workApplicationEntity,
                ActionData(
                    actionKey: ApplicationAction.reScheduleWebinarTraining));
          },
          child: Text(
            'reschedule'.tr,
            style: Get.textTheme.caption?.copyWith(color: AppColors.link400),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildApplicationActionWidget() {
    switch (scheduledBatchSection.actionData?.actionKey) {
      case ApplicationAction.prepareTrainingNoResource:
        return buildJoinTrainingButton(false);
      case ApplicationAction.joinTraining:
      case ApplicationAction.joinTrainingNoResource:
        return Column(
          children: [
            buildJoinTrainingButton(true),
            // buildUnableToJoinTrainingButton(),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget buildJoinTrainingButton(bool isEnable) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_8, Dimens.margin_16,
          Dimens.margin_8, Dimens.margin_16),
      child: CustomTextButton(
        text: 'join_training'.tr,
        textColor: AppColors.backgroundWhite,
        backgroundColor:
            isEnable ? AppColors.primaryMain : AppColors.backgroundGrey500,
        borderColor:
            isEnable ? AppColors.primaryMain : AppColors.backgroundGrey500,
        onPressed: () {
          // if (isEnable) {
          onActionTapped(
              workApplicationEntity,
              ActionData(
                actionKey: ApplicationAction.joinTraining,
                data: TrainingData(
                    meetingID: scheduledBatchSection.meetingId,
                    meetingPassword: scheduledBatchSection.meetingPassword),
              ));
          // }
        },
      ),
    );
  }

  Widget buildPrepareForTrainingButton(bool isEnable) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_4, Dimens.margin_16, Dimens.margin_4, Dimens.margin_16),
      child: RaisedRectButton(
        backgroundColor:
        isEnable ? AppColors.primaryMain : AppColors.backgroundGrey600,
        text: 'prepare_for_training'.tr,
        fontSize: Dimens.font_12,
        textColor: AppColors.backgroundWhite,
        onPressed: () {
          onActionTapped(
              workApplicationEntity,
              ActionData(
                actionKey: ApplicationAction.prepareTraining,
                data: workApplicationEntity.id));
        },
      ),
    );
  }

  Widget buildUnableToJoinMeetingButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_4, Dimens.margin_16, Dimens.margin_4, Dimens.margin_16),
      child: RaisedRectButton(
        backgroundColor: AppColors.backgroundWhite,
        text: 'unable_to_join_training'.tr,
        textColor: AppColors.black,
        onPressed: () {
          webinarTrainingJoiningBottomSheet(
              Get.context!, workApplicationEntity.webinarTraining);
        },
      ),
    );
  }

}
