import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/application_section_interview_scheduled_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/application_section_training_scheduled_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/full_image_with_text_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/small_image_with_text_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/status_button_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/supply_confirm_section_widget.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/cupertino.dart';

class ApplicationTileSectionWidgetProvider {
  static Widget getActionSection(
      BaseSection? baseSection,
      WorkApplicationEntity workApplicationEntity,
      Function(WorkApplicationEntity workApplicationEntity,
              ActionData actionData)
          onApplicationAction) {
    Widget widget;
    switch (workApplicationEntity.applicationStatus) {
      case ApplicationStatus.applied:
      case ApplicationStatus.inAppInterviewPending:
      case ApplicationStatus.inAppInterviewStarted:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.waitListed:
      case ApplicationStatus.inAppInterviewCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.inAppInterviewSelected:
      case ApplicationStatus.inAppInterviewRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.telephonicInterviewPending:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.telephonicInterviewStarted:
      case ApplicationStatus.telephonicInterviewScheduled:
        widget = ApplicationSectionScheduledInterviewWidget(
            baseSection as ScheduledSlotSection,
            workApplicationEntity,
            workApplicationEntity.fromRoute ?? MRouter.categoryApplicationDetailsWidget,
            onApplicationAction);
        break;
      case ApplicationStatus.telephonicInterviewSupplyConfirmationPending:
        widget = SupplyConfirmSectionWidget(baseSection as SupplyConfirmSection,
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.telephonicInterviewCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.telephonicInterviewInComplete:
      case ApplicationStatus.telephonicInterviewSelected:
      case ApplicationStatus.telephonicInterviewRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;

      case ApplicationStatus.inAppTrainingPending:
      case ApplicationStatus.inAppTrainingStarted:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.inAppTrainingCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.inAppTrainingSelected:
      case ApplicationStatus.inAppTrainingRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;

      case ApplicationStatus.webinarTrainingPending:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.webinarTrainingStarted:
      case ApplicationStatus.webinarTrainingScheduled:
        widget = ApplicationSectionTrainingScheduledWidget(
            baseSection as ScheduledBatchSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.webinarTrainingSupplyConfirmationPending:
        widget = SupplyConfirmSectionWidget(baseSection as SupplyConfirmSection,
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.webinarTrainingCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.webinarTrainingInComplete:
      case ApplicationStatus.webinarTrainingSelected:
      case ApplicationStatus.webinarTrainingRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.webinarTrainingMissed:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;

      case ApplicationStatus.automatedPitchDemoPending:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.automatedPitchDemoStarted:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.automatedPitchDemoCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.automatedPitchDemoSelected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.automatedPitchDemoRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoPending:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoStarted:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoScheduled:
        widget = ApplicationSectionScheduledInterviewWidget(
            baseSection as ScheduledSlotSection,
            workApplicationEntity,
            workApplicationEntity.fromRoute ?? MRouter.categoryApplicationDetailsWidget,
            onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoSupplyConfirmationPending:
        widget = SupplyConfirmSectionWidget(baseSection as SupplyConfirmSection,
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoInComplete:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.manualPitchDemoSelected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.manualPitchDemoRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.pitchTestPending:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.pitchTestStarted:
        widget = StatusButtonSectionWidget(
            workApplicationEntity, onApplicationAction);
        break;
      case ApplicationStatus.pitchTestCompleted:
        widget = FullImageWithTextSectionWidget(
            baseSection as LargeImageWithTextSection, workApplicationEntity);
        break;
      case ApplicationStatus.pitchTestSelected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case ApplicationStatus.pitchTestRejected:
        widget = SmallImageWithTextSectionWidget(
            baseSection as SmallImageWithTextSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      default:
        widget = const SizedBox(height: Dimens.margin_16);
    }
    return widget;
  }
}
