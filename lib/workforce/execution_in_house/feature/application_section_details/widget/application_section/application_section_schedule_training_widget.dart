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

class ApplicationSectionScheduleTrainingWidget extends StatelessWidget {
  final ScheduleBatchSection scheduleBatchSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const ApplicationSectionScheduleTrainingWidget(this.scheduleBatchSection,
      this.workApplicationEntity, this.onActionTapped,
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
        child: Text('Training on Zoom App',
            style:
                Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildDateWidget() {
    if (scheduleBatchSection.autoScheduleBatch?.startTime != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
          child: Text(
              scheduleBatchSection.autoScheduleBatch!.startTime!
                  .getFormattedDateTime(StringUtils.dateTimeFormatEDMY),
              style: Get.textTheme.bodyText2),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildTimeWidget() {
    if (scheduleBatchSection.autoScheduleBatch?.startTime != null &&
        scheduleBatchSection.autoScheduleBatch?.endTime != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: Text(
              '${scheduleBatchSection.autoScheduleBatch?.startTime!.getFormattedDateTime(StringUtils.timeFormatHMA)} - ${scheduleBatchSection.autoScheduleBatch?.endTime!.getFormattedDateTime(StringUtils.timeFormatHMA)}',
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
          ClevertapData clevertapData = ClevertapData(
              isApplicationActionEvent: true,
              clevertapActionType: ClevertapHelper.confirmBatchWebinarTraining,
              workApplicationEntity: workApplicationEntity,
              currentUser: currentUser);
          CaptureEventHelper.captureEvent(clevertapData: clevertapData);
          onActionTapped(
              workApplicationEntity,
              ActionData(
                  actionKey: ApplicationAction.scheduleWebinarTraining,
                  data: scheduleBatchSection.autoScheduleBatch));
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
          ClevertapData clevertapData = ClevertapData(
              isApplicationActionEvent: true,
              clevertapActionType: ClevertapHelper.changeBatchWebinarRraining,
              workApplicationEntity: workApplicationEntity,
              currentUser: currentUser);
          CaptureEventHelper.captureEvent(clevertapData: clevertapData);
          onActionTapped(
              workApplicationEntity,
              ActionData(
                  actionKey: ApplicationAction.reScheduleWebinarTraining));
        },
      ),
    );
  }
}
