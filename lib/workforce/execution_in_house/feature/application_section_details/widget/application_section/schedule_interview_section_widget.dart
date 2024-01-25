import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleInterviewSectionWidget extends StatelessWidget {
  final ScheduleSlotSection scheduleSlotSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const ScheduleInterviewSectionWidget(
      this.scheduleSlotSection, this.workApplicationEntity, this.onActionTapped,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitleWidget(),
          const SizedBox(height: Dimens.padding_8),
          HDivider(),
          buildDateWidget(),
          buildTimeWidget(),
          buildConfirmSlotButton(),
          buildChangeSlotButton(),
        ],
      ),
    );
  }

  Widget buildTitleWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        child: Text('Telephonic Interview',
            style:
                Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildDateWidget() {
    if (scheduleSlotSection.autoScheduleSlot.startTime != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
          child: Text(
              scheduleSlotSection.autoScheduleSlot.startTime!
                  .getFormattedDateTime(StringUtils.dateTimeFormatEDMY),
              style: Get.textTheme.bodyText2),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildTimeWidget() {
    if (scheduleSlotSection.autoScheduleSlot.startTime != null &&
        scheduleSlotSection.autoScheduleSlot.endTime != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: Text(
              '${scheduleSlotSection.autoScheduleSlot.startTime!.getFormattedDateTime(StringUtils.timeFormatHMA)} - ${scheduleSlotSection.autoScheduleSlot.endTime!.getFormattedDateTime(StringUtils.timeFormatHMA)}',
              style: Get.textTheme.subtitle2),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildConfirmSlotButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: RaisedRectButton(
        text: 'confirm_slot'.tr,
        height: Dimens.btnHeight_40,
        onPressed: () async {
          SPUtil? spUtil = await SPUtil.getInstance();
          UserData? currentUser = spUtil?.getUserData();
          switch (scheduleSlotSection.actionData?.actionKey) {
            case ApplicationAction.scheduleTelephonicInterview:
              ClevertapData clevertapData = ClevertapData(
                  isApplicationActionEvent: true,
                  clevertapActionType:
                      ClevertapHelper.confirmSlotTelephonicInterview,
                  workApplicationEntity: workApplicationEntity,
                  currentUser: currentUser);
              CaptureEventHelper.captureEvent(clevertapData: clevertapData);
              break;
            case ApplicationAction.schedulePitchDemo:
              ClevertapData clevertapData = ClevertapData(
                  isApplicationActionEvent: true,
                  clevertapActionType: ClevertapHelper.confirmSlotPitchDemo,
                  workApplicationEntity: workApplicationEntity,
                  currentUser: currentUser);
              CaptureEventHelper.captureEvent(clevertapData: clevertapData);
              break;
          }
          onActionTapped(
              workApplicationEntity,
              ActionData(
                  actionKey: scheduleSlotSection.actionData?.actionKey,
                  data: scheduleSlotSection.autoScheduleSlot));
        },
      ),
    );
  }

  Widget buildChangeSlotButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
          Dimens.margin_16, Dimens.margin_16),
      child: CustomTextButton(
        text: 'change_slot'.tr,
        textColor: AppColors.primaryMain,
        backgroundColor: AppColors.backgroundWhite,
        borderColor: AppColors.backgroundWhite,
        onPressed: () async {
          SPUtil? spUtil = await SPUtil.getInstance();
          UserData? currentUser = spUtil?.getUserData();
          switch (scheduleSlotSection.actionData?.actionKey) {
            case ApplicationAction.scheduleTelephonicInterview:
              ClevertapData clevertapData = ClevertapData(
                  isApplicationActionEvent: true,
                  clevertapActionType:
                      ClevertapHelper.changeSlotTelephonicInterview,
                  workApplicationEntity: workApplicationEntity,
                  currentUser: currentUser);
              CaptureEventHelper.captureEvent(clevertapData: clevertapData);
              break;
            case ApplicationAction.schedulePitchDemo:
              ClevertapData clevertapData = ClevertapData(
                  isApplicationActionEvent: true,
                  clevertapActionType: ClevertapHelper.changeBatchPitchDemo,
                  workApplicationEntity: workApplicationEntity,
                  currentUser: currentUser);
              CaptureEventHelper.captureEvent(clevertapData: clevertapData);
              break;
          }
          onActionTapped(
              workApplicationEntity,
              ActionData(
                  actionKey: ApplicationAction.reScheduleTelephonicInterview));
        },
      ),
    );
  }
}
