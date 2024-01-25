import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationSectionScheduledInterviewWidget extends StatelessWidget {
  final ScheduledSlotSection scheduleSlotSection;
  final WorkApplicationEntity workApplicationEntity;
  final String? fromRoute;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const ApplicationSectionScheduledInterviewWidget(
      this.scheduleSlotSection, this.workApplicationEntity, this.fromRoute, this.onActionTapped,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(fromRoute == MRouter.applicationSectionDetailsWidget) {
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: buildBody(),
      );
    } else {
      return buildBody();
    }
  }

  Widget buildBody() {
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
          const SizedBox(height: Dimens.padding_8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildDateTimeWidget(),
              buildRescheduleWidget(),
            ],
          ),
          const SizedBox(height: Dimens.padding_4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
            child: HDivider(),
          ),
          const SizedBox(height: Dimens.padding_4),
          buildMobileNumberTileWidget(),
          const SizedBox(height: Dimens.padding_8),
          buildMobileNumberWidget(),
          buildButton(),
        ],
      ),
    );
  }

  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: Text('Your Telephonic Interview is scheduled :',
          style: Get.textTheme.bodyText2),
    );
  }

  Widget buildDateTimeWidget() {
    if (scheduleSlotSection.scheduledSlot.startTime != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: Text(
            scheduleSlotSection.scheduledSlot.startTime!
                .getFormattedDateTime(StringUtils.dateTimeFormatDMHMA),
            style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildRescheduleWidget() {
    if (scheduleSlotSection.enableReschedule) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: MyInkWell(
          onTap: () {
            onActionTapped(
                workApplicationEntity,
                ActionData(
                    actionKey:
                        ApplicationAction.reScheduleTelephonicInterview));
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

  Widget buildMobileNumberTileWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: Text('Your manager will be calling you on :',
          style: Get.textTheme.bodyText2),
    );
  }

  Widget buildMobileNumberWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, Dimens.padding_8),
      child: Text(scheduleSlotSection.scheduledSlot.mobileNumber ?? '',
          style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),),
    );
  }

  Widget buildButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_8, Dimens.margin_16, Dimens.margin_8, Dimens.margin_16),
      child: RaisedRectButton(
        height: Dimens.btnHeight_40,
        text: 'prepare_for_interview'.tr,
        onPressed: () {
          Helper.showInfoToast('Coming soon...');
        },
      ),
    );
  }
}
