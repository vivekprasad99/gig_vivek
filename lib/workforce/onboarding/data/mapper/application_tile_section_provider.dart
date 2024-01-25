import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_pending_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';

class ApplicationTileSectionProvider {
  static BaseSection? getTileActionSection(
      WorkApplicationEntity workApplicationEntity) {
    switch (workApplicationEntity.applicationStatus) {
      case ApplicationStatus.applied:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.waitListed:
        return getWaitListedsSection(workApplicationEntity.waitlistMessage);
      case ApplicationStatus.inAppInterviewPending:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.inAppInterviewStarted:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.inAppInterviewCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.inAppInterviewSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.inAppInterviewRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.telephonicInterviewPending:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.telephonicInterviewStarted:
      case ApplicationStatus.telephonicInterviewScheduled:
        SlotEntity slotEntity = SlotEntity(
            startTime:
                workApplicationEntity.telephonicInterview?.interviewSlotFrom,
            endTime: workApplicationEntity.telephonicInterview?.interviewSlotTo,
            mobileNumber:
                workApplicationEntity.telephonicInterview?.mobileNumber);
        bool enableReschedule = workApplicationEntity.supplyPendingAction !=
            WorkApplicationPendingAction.allTheBest;
        return ScheduledSlotSection(
            slotEntity, enableReschedule, SlotType.interview, null);
      case ApplicationStatus.telephonicInterviewSupplyConfirmationPending:
        return getSupplyConfirmSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.telephonicInterviewCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.telephonicInterviewInComplete:
        return SmallImageWithTextSection(
            description: workApplicationEntity.displayMessage ??
                "Your interview could not be completed",
            contactSupportEnabled:
                isSupportEnabled(workApplicationEntity.supplyPendingAction),
            actionData: workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.telephonicInterviewSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.telephonicInterviewRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.inAppTrainingPending:
      case ApplicationStatus.inAppTrainingStarted:
      case ApplicationStatus.inAppTrainingCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.inAppTrainingSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.inAppTrainingRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingPending:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingScheduled:
      case ApplicationStatus.webinarTrainingStarted:
        BatchEntity batchEntity = BatchEntity(
            id: workApplicationEntity.id,
            batchName: workApplicationEntity.webinarTraining?.batchName,
            startTime: workApplicationEntity.webinarTraining?.batchFromTime,
            endTime: workApplicationEntity.webinarTraining?.batchToTime,
            meetingId: workApplicationEntity.webinarTraining?.meetingId);
        bool enableReschedule = workApplicationEntity.supplyPendingAction !=
                WorkApplicationPendingAction.allTheBest &&
            workApplicationEntity.supplyPendingAction !=
                WorkApplicationPendingAction.joinTraining;
        return ScheduledBatchSection(
            applicationId: workApplicationEntity.id,
            scheduledBatch: batchEntity,
            meetingId: workApplicationEntity.webinarTraining?.meetingId,
            meetingPassword:
                workApplicationEntity.webinarTraining?.meetingPassword,
            enableReschedule: enableReschedule,
            actionData: workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingSupplyConfirmationPending:
        return getSupplyConfirmSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.webinarTrainingInComplete:
        return SmallImageWithTextSection(
            description: workApplicationEntity.displayMessage ??
                "Your training could not be completed",
            contactSupportEnabled:
                isSupportEnabled(workApplicationEntity.supplyPendingAction),
            actionData: workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.webinarTrainingMissed:
        return SmallImageWithTextSection(
            iconResource: 'assets/images/ic_missed.png',
            title: "You missed your training",
            actionData: workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.automatedPitchDemoPending:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.automatedPitchDemoStarted:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.automatedPitchDemoCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.automatedPitchDemoSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.automatedPitchDemoRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.manualPitchDemoPending:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.manualPitchDemoStarted:
      case ApplicationStatus.manualPitchDemoScheduled:
        SlotEntity slotEntity = SlotEntity(
            startTime:
                workApplicationEntity.telephonicInterview?.interviewSlotFrom,
            endTime: workApplicationEntity.telephonicInterview?.interviewSlotTo,
            mobileNumber:
                workApplicationEntity.telephonicInterview?.mobileNumber);
        bool enableReschedule = workApplicationEntity.supplyPendingAction !=
            WorkApplicationPendingAction.allTheBest;
        return ScheduledSlotSection(
            slotEntity, enableReschedule, SlotType.pitch, null);
      case ApplicationStatus.manualPitchDemoSupplyConfirmationPending:
        return getSupplyConfirmSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.manualPitchDemoInComplete:
        return SmallImageWithTextSection(
            description: workApplicationEntity.displayMessage ??
                "Your pitch demo could not be completed",
            contactSupportEnabled:
                isSupportEnabled(workApplicationEntity.supplyPendingAction),
            actionData: workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.manualPitchDemoCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.manualPitchDemoSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.manualPitchDemoRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.pitchTestPending:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.pitchTestStarted:
        return StatusSection(
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.pitchTestCompleted:
        return getWaitForResultStatusSection();
      case ApplicationStatus.pitchTestSelected:
        return getSelectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
      case ApplicationStatus.pitchTestRejected:
        return getRejectedStatusSection(workApplicationEntity.applicationStatus,
            workApplicationEntity.pendingAction ?? ActionData());
    }
    return null;
  }

  static SmallImageWithTextSection getSelectedStatusSection(
      ApplicationStatus? applicationStatus, ActionData actionData) {
    String description = '';
    switch (applicationStatus) {
      case ApplicationStatus.inAppInterviewSelected:
        description = 'You qualified your in app interview round';
        break;
      case ApplicationStatus.telephonicInterviewSelected:
        description = 'You qualified your telephonic interview round';
        break;
      case ApplicationStatus.inAppTrainingSelected:
        description = 'You qualified your in app training round';
        break;
      case ApplicationStatus.webinarTrainingSelected:
        description = 'You qualified your webinar training round';
        break;
      case ApplicationStatus.automatedPitchDemoSelected:
        description = 'You qualified your pitch demo round';
        break;
      case ApplicationStatus.manualPitchDemoSelected:
        description = 'You qualified your pitch demo round';
        break;
      case ApplicationStatus.pitchTestSelected:
        description = 'You qualified your pitch test round';
        break;
      case ApplicationStatus.genericSelected:
        description = 'You qualified this round';
        break;
      default:
        description = 'You qualified this round';
        break;
    }
    return SmallImageWithTextSection(
        iconResource: 'assets/images/ic_congrats.svg',
        title: 'Congrats',
        description: description,
        contactSupportEnabled: false,
        actionData: actionData);
  }

  static SmallImageWithTextSection getRejectedStatusSection(
      ApplicationStatus? applicationStatus, ActionData actionData) {
    String description = '';
    switch (applicationStatus) {
      case ApplicationStatus.inAppInterviewRejected:
        description = 'You have been rejected for in app interview round';
        break;
      case ApplicationStatus.telephonicInterviewRejected:
        description = 'You have been rejected for telephonic interview round';
        break;
      case ApplicationStatus.inAppTrainingRejected:
        description = 'You have been rejected for in app training round';
        break;
      case ApplicationStatus.webinarTrainingRejected:
        description = 'You have been rejected for webinar training round';
        break;
      case ApplicationStatus.automatedPitchDemoRejected:
        description = 'You have been rejected for pitch demo round';
        break;
      case ApplicationStatus.manualPitchDemoRejected:
        description = 'You have been rejected for pitch demo round';
        break;
      case ApplicationStatus.pitchTestRejected:
        description = 'You have been rejected for pitch test round';
        break;
      case ApplicationStatus.genericSelected:
        description = 'You have been rejected';
        break;
      default:
        description = 'You have been rejected';
        break;
    }
    return SmallImageWithTextSection(
        iconResource: 'assets/images/ic_sorry.svg',
        title: 'Sorry!',
        description: description,
        contactSupportEnabled: false,
        actionData: actionData);
  }

  static SupplyConfirmSection getSupplyConfirmSection(ActionData actionData) {
    return SupplyConfirmSection(actionData: actionData);
  }

  static LargeImageWithTextSection getWaitForResultStatusSection() {
    return LargeImageWithTextSection(
        iconResource: 'assets/images/ic_wait_.png',
        title: 'Wait for Result',
        description: "Your Manager will soon give out your result…");
  }

  static LargeImageWithTextSection getWaitListedsSection(
      String? waitlistMessage) {
    return LargeImageWithTextSection(
        iconResource: 'assets/images/ic_wait_.png',
        title: 'Waitlisted',
        description: waitlistMessage ??
            "You have been waitlisted. We will let you know once you get shortlisted.");
  }

  static bool isSupportEnabled(
      WorkApplicationPendingAction? workApplicationPendingAction) {
    switch (workApplicationPendingAction) {
      case WorkApplicationPendingAction
          .rescheduleTelephonicInterviewOrContactSupport:
      case WorkApplicationPendingAction.reScheduleWebinarTrainingOrSupport:
        return true;
      default:
        return false;
    }
  }
}
