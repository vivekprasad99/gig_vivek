import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_pending_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_status.dart';

import '../model/work_application/attachment.dart';

class ApplicationDetailsSectionProvider {
  static List<BaseSection> getDetailsSectionList(
      WorkApplicationEntity workApplicationEntity) {
    List<BaseSection> baseSectionList = [];
    BaseSection? actionSection = _getActionSection(workApplicationEntity);
    if (actionSection != null) {
      baseSectionList.add(actionSection);
    }
    _addAttachment(baseSectionList, workApplicationEntity);
    _addNotes(baseSectionList, workApplicationEntity);
    return baseSectionList;
  }

  static BaseSection? _getActionSection(
      WorkApplicationEntity workApplicationEntity) {
    ActionData? actionData = workApplicationEntity.pendingAction;
    ApplicationStatus? applicationStatus =
        ApplicationStatus.transformWorkApplicationForDetails(
            workApplicationEntity);
    switch (applicationStatus) {
      case ApplicationStatus.telephonicInterviewPending:
        SlotEntity? slotEntity = workApplicationEntity.suggestedSlot;
        if (slotEntity != null) {
          return ScheduleSlotSection(slotEntity, true, actionData);
        } else {
          return SmallImageWithTextSection(
              iconResource: '',
              title: 'No slots available',
              description: 'Check later after some time');
        }
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

      case ApplicationStatus.webinarTrainingPending:
        if (workApplicationEntity.suggestedBatch != null) {
          return ScheduleBatchSection(
              autoScheduleBatch: workApplicationEntity.suggestedBatch,
              buttonText: 'Schedule',
              hasSlots: true);
        } else {
          return getNoBatchesSection(
              workApplicationEntity.pendingAction ?? ActionData());
        }
      case ApplicationStatus.webinarTrainingStarted:
      case ApplicationStatus.webinarTrainingScheduled:
        BatchEntity batchEntity = BatchEntity(
            id: -1,
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

      case ApplicationStatus.manualPitchDemoPending:
        SlotEntity? slotEntity = workApplicationEntity.suggestedSlot;
        if (slotEntity != null) {
          return ScheduleSlotSection(slotEntity, true, actionData);
        } else {
          return SmallImageWithTextSection(
              iconResource: '',
              title: 'No slots available',
              description: 'Check later after some time');
        }
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
    }
    return null;
  }

  static void _addAttachment(List<BaseSection> baseSectionList,
      WorkApplicationEntity workApplicationEntity) {
    List<Attachment>? attachmentEntityList = [];
    String? text;

    if (workApplicationEntity.cta?.toLowerCase().contains("telephonic") ??
        false) {
      text =
          "Refer the attached study material to answer telephonic interview questions.";
    } else if (workApplicationEntity.cta
            ?.toLowerCase()
            .contains("in app interview") ??
        false) {
      text =
          "Refer the attached study material to answer in-app interview questions.";
    } else if (workApplicationEntity.cta?.toLowerCase().contains("webinar") ??
        false) {
      text =
          "Refer the attached study material to answer webinar training questions.";
    } else if (workApplicationEntity.cta
            ?.toLowerCase()
            .contains("in app training") ??
        false) {
      text =
          "Refer the attached study material to answer in-app training questions.";
    }

    if (workApplicationEntity.inAppTraining?.resources != null) {
      attachmentEntityList = workApplicationEntity.inAppTraining?.resources;
    } else if (workApplicationEntity.inAppInterview?.resources != null) {
      attachmentEntityList = workApplicationEntity.inAppInterview?.resources;
    } else if (workApplicationEntity.telephonicInterview?.resources != null) {
      attachmentEntityList =
          workApplicationEntity.telephonicInterview?.resources;
    } else if (workApplicationEntity.webinarTraining?.resources != null) {
      attachmentEntityList = workApplicationEntity.webinarTraining?.resources;
    } else if (workApplicationEntity.pitchTest?.resources != null) {
      attachmentEntityList = workApplicationEntity.pitchTest?.resources;
    } else {
      if (workApplicationEntity.pitchDemo?.resources != null) {
        attachmentEntityList = workApplicationEntity.pitchDemo?.resources;
      }
    }

    if (attachmentEntityList != null) {
      List<Attachment> attachments = [];

      for (Attachment entity in attachmentEntityList) {
        attachments.add(
          Attachment(
            id: 0,
            title: entity.title,
            fileType: entity.fileType,
            filePath: entity.filePath ?? "",
          ),
        );
      }

      AttachmentSection attachmentSection = AttachmentSection(
        title: text,
        description: null,
        attachments: attachments,
      );
      baseSectionList.add(attachmentSection);
    }
  }

  static void _addNotes(List<BaseSection> baseSectionList,
      WorkApplicationEntity workApplicationEntity) {
    switch (workApplicationEntity.status) {
      case WorkApplicationStatusEntity.inAppInterview:
        _addProperNotes(baseSectionList, 'Interview Details',
            workApplicationEntity.inAppInterview?.notes);
        break;
      case WorkApplicationStatusEntity.telephonicInterview:
        _addProperNotes(baseSectionList, 'Interview Details',
            workApplicationEntity.telephonicInterview?.notes);
        break;
      case WorkApplicationStatusEntity.inAppTraining:
        _addProperNotes(baseSectionList, 'Interview Details',
            workApplicationEntity.inAppTraining?.notes);
        break;
      case WorkApplicationStatusEntity.webinarTraining:
        _addProperNotes(baseSectionList, 'Training Details',
            workApplicationEntity.webinarTraining?.notes);
        break;
      case WorkApplicationStatusEntity.pitchDemo:
        _addProperNotes(baseSectionList, 'Pitch Demo Details',
            workApplicationEntity.pitchDemo?.notes);
        break;
      case WorkApplicationStatusEntity.pitchTest:
        _addProperNotes(baseSectionList, 'Pitch Test Details',
            workApplicationEntity.pitchTest?.notes);
        break;
      default:
        return;
    }
  }

  static void _addProperNotes(
      List<BaseSection> baseSectionList, String title, List<String>? notes) {
    if (notes == null) {
      return;
    }
    baseSectionList.add(BulletPointsSection(title, notes));
  }

  static SmallImageWithTextSection getNoBatchesSection(ActionData actionData) {
    return SmallImageWithTextSection(
        iconResource: 'assets/images/ic_sorry.svg',
        title: 'No batches available',
        description: 'Check later after some time',
        actionData: actionData);
  }

  transformAttachmentFileType(FileType<dynamic> fileType) {
    switch (fileType) {}
  }
}
