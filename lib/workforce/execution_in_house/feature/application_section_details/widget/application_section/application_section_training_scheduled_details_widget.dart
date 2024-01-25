import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationSectionTrainingScheduledDetailsWidget extends StatelessWidget {
  final ScheduledBatchSection scheduledBatchSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const ApplicationSectionTrainingScheduledDetailsWidget(
      this.scheduledBatchSection,
      this.workApplicationEntity,
      this.onActionTapped,
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
      child: Container(
        // margin: const EdgeInsets.all(Dimens.margin_16),
        decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            border: Border.all(color: AppColors.backgroundWhite),
            borderRadius:
                const BorderRadius.all(Radius.circular(Dimens.radius_8))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: buildTitleWidget()),
            Center(child: buildDateTimeWidget()),
            // const SizedBox(height: Dimens.margin_16),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     buildDateTimeWidget(),
            //     buildRescheduleWidget(),
            //   ],
            // ),
            const SizedBox(height: Dimens.margin_16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.margin_16),
              child: HDivider(),
            ),
            Center(child: buildRescheduleWidget()),
            // const SizedBox(height: Dimens.padding_4),
            // buildUnableToJoinTextWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: Text('Your Webinar Training is scheduled :',
          style: Get.textTheme.bodyText2),
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
          style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildRescheduleWidget() {
    if ((scheduledBatchSection.enableReschedule ?? false)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, Dimens.margin_16),
        child: MyInkWell(
          onTap: () {
            onActionTapped(
                workApplicationEntity,
                ActionData(
                    actionKey: ApplicationAction.reScheduleWebinarTraining));
          },
          child: Text(
            'reschedule'.tr,
            style: Get.textTheme.bodyText2?.copyWith(
                fontWeight: FontWeight.w500, color: AppColors.primaryMain),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildUnableToJoinTextWidget() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.padding_8,
            Dimens.margin_16, Dimens.margin_16),
        child: MyInkWell(
          onTap: () async {
            SPUtil? spUtil = await SPUtil.getInstance();
            UserData? currentUser = spUtil?.getUserData();
            ClevertapData clevertapData = ClevertapData(
                isApplicationActionEvent: true,
                clevertapActionType: ClevertapHelper.unableToJoinTraining,
                workApplicationEntity: workApplicationEntity,
                currentUser: currentUser);
            CaptureEventHelper.captureEvent(clevertapData: clevertapData);
          },
          child: Text(
            'unable_to_join_training'.tr,
            style: Get.textTheme.bodyText2?.copyWith(
                color: AppColors.primaryMain,
                decoration: TextDecoration.underline,
                fontSize: Dimens.font_12),
          ),
        ),
      ),
    );
  }
}
