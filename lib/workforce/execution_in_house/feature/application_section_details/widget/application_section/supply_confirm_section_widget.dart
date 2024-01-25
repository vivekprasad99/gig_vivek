import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplyConfirmSectionWidget extends StatelessWidget {
  final SupplyConfirmSection supplyConfirmSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const SupplyConfirmSectionWidget(this.supplyConfirmSection,
      this.workApplicationEntity, this.onActionTapped,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimens.margin_16),
      decoration: const BoxDecoration(
          color: AppColors.backgroundGrey400,
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildQuestionWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildYesButton(),
              buildNoButton(),
            ],
          ),
          // buildYesButton(),
          // buildNoButton(),
        ],
      ),
    );
  }

  Widget buildQuestionWidget() {
    String question = '';
    switch (supplyConfirmSection.actionData?.actionKey) {
      case ApplicationAction.telephonicInterviewAskConfirmation:
        question = 'did_your_interview_happen'.tr;
        break;
      case ApplicationAction.webinarTrainingAskConfirmation:
        question = 'did_your_training_happen'.tr;
        break;
      default:
        question = '';
      // case ApplicationAction.pi:
      //   question = 'did_your_pitch_demo_happen'.tr;
      //   break;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text(question,
          textAlign: TextAlign.center, style: Get.textTheme.bodyText1),
    );
  }

  Widget buildYesButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
            Dimens.margin_8, Dimens.margin_16),
        child: CustomTextButton(
          height: Dimens.btnHeight_40,
          text: 'yes'.tr,
          fontSize: Dimens.font_14,
          backgroundColor: AppColors.success300,
          borderColor: AppColors.success300,
          onPressed: () {
            switch (supplyConfirmSection.actionData?.actionKey) {
              case ApplicationAction.webinarTrainingAskConfirmation:
                onActionTapped(
                    workApplicationEntity,
                    ActionData(
                        actionKey: supplyConfirmSection.actionData?.actionKey,
                        data: ApplicationAction
                            .webinarTrainingSupplyConfirmWithNavigation));
                break;
              case ApplicationAction.telephonicInterviewAskConfirmation:
                onActionTapped(
                    workApplicationEntity,
                    ActionData(
                        actionKey: supplyConfirmSection.actionData?.actionKey,
                        data: ApplicationAction
                            .telephonicInterviewSupplyConfirmWithNavigation));
                break;
            }
          },
        ),
      ),
    );
  }

  Widget buildNoButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.margin_8, Dimens.margin_16,
            Dimens.margin_16, Dimens.margin_16),
        child: CustomTextButton(
          height: Dimens.btnHeight_40,
          text: 'no'.tr,
          fontSize: Dimens.font_14,
          textColor: AppColors.error400,
          backgroundColor: AppColors.transparent,
          borderColor: AppColors.error400,
          onPressed: () {
            switch (supplyConfirmSection.actionData?.actionKey) {
              case ApplicationAction.webinarTrainingAskConfirmation:
                onActionTapped(
                    workApplicationEntity,
                    ActionData(
                        actionKey: supplyConfirmSection.actionData?.actionKey,
                        data: ApplicationAction
                            .webinarTrainingSupplyUnConfirmWithNavigation));
                break;
              case ApplicationAction.telephonicInterviewAskConfirmation:
                onActionTapped(
                    workApplicationEntity,
                    ActionData(
                        actionKey: supplyConfirmSection.actionData?.actionKey,
                        data: ApplicationAction
                            .telephonicInterviewSupplyUnConfirmWithNavigation));
                break;
            }
          },
        ),
      ),
    );
  }
}
