import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/application_section_interview_scheduled_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/application_section_schedule_training_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/application_section_training_scheduled_details_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/empty_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/note_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/resource_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/schedule_interview_section_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section/timeline_section_widget.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/section_type.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/cupertino.dart';

class ApplicationDetailsSectionWidgetProvider {
  static Widget getActionSection(
      BaseSection baseSection,
      WorkApplicationEntity workApplicationEntity,
      Function(WorkApplicationEntity workApplicationEntity,
              ActionData actionData)
          onApplicationAction) {
    Widget widget;
    switch (baseSection.sectionType) {
      case SectionType.timeline:
        widget = TimelineSectionWidget(
            baseSection as TimelineSectionEntity, workApplicationEntity);
        break;
      case SectionType.smallImageWithText:
        widget = EmptySectionWidget(
            baseSection as SmallImageWithTextSection, workApplicationEntity);
        break;
      case SectionType.bulletPoint:
        widget = NoteSectionWidget(
            baseSection as BulletPointsSection, workApplicationEntity);
        break;
      case SectionType.scheduleInterview:
        widget = ScheduleInterviewSectionWidget(
            baseSection as ScheduleSlotSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case SectionType.slotScheduled:
        widget = ApplicationSectionScheduledInterviewWidget(
            baseSection as ScheduledSlotSection,
            workApplicationEntity,
            MRouter.applicationSectionDetailsWidget,
            onApplicationAction);
        break;
      case SectionType.scheduleTraining:
        widget = ApplicationSectionScheduleTrainingWidget(
            baseSection as ScheduleBatchSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case SectionType.batchScheduled:
        widget = ApplicationSectionTrainingScheduledDetailsWidget(
            baseSection as ScheduledBatchSection,
            workApplicationEntity,
            onApplicationAction);
        break;
      case SectionType.resource:
        widget= ResourceSectionWidget(baseSection as AttachmentSection, workApplicationEntity);
        break;
      default:
        widget = const SizedBox();
    }
    return widget;
  }
}
