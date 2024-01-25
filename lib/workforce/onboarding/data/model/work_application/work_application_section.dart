import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/section_type.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';

class StatusSection extends BaseSection {
  ActionData actionData;

  StatusSection(this.actionData) : super(SectionType.status);
}

class BulletPointsSection extends BaseSection {
  String title;
  List<String> points;

  BulletPointsSection(this.title, this.points) : super(SectionType.bulletPoint);
}

class ScheduleSlotSection extends BaseSection {
  SlotEntity autoScheduleSlot;
  bool hasSlots;
  ActionData? actionData;

  ScheduleSlotSection(this.autoScheduleSlot, this.hasSlots, this.actionData)
      : super(SectionType.scheduleInterview);
}

class ScheduledSlotSection extends BaseSection {
  SlotEntity scheduledSlot;
  bool enableReschedule;
  SlotType slotType;
  ActionData? actionData;

  ScheduledSlotSection(
      this.scheduledSlot, this.enableReschedule, this.slotType, this.actionData)
      : super(SectionType.slotScheduled);
}

class SmallImageWithTextSection extends BaseSection {
  String? iconResource;
  String? title;
  String? description;
  String? lottiFileName;
  String? bigLottiFileName;
  bool contactSupportEnabled;
  ActionData? actionData;

  SmallImageWithTextSection(
      {this.iconResource,
      this.title,
      this.description,
      this.lottiFileName,
      this.bigLottiFileName,
      this.actionData,
      this.contactSupportEnabled = false})
      : super(SectionType.smallImageWithText);
}

class LargeImageWithTextSection extends BaseSection {
  String? iconResource;
  String? title;
  String? description;

  LargeImageWithTextSection({this.iconResource, this.title, this.description})
      : super(SectionType.largeImageWithText);
}

class ScheduleBatchSection extends BaseSection {
  BatchEntity? autoScheduleBatch;
  String? buttonText;
  bool? hasSlots;

  ScheduleBatchSection({this.autoScheduleBatch, this.buttonText, this.hasSlots})
      : super(SectionType.scheduleTraining);
}

class ScheduledBatchSection extends BaseSection {
  int? applicationId;
  BatchEntity? scheduledBatch;
  String? meetingId;
  String? meetingPassword;
  bool? enableReschedule;
  ActionData? actionData;

  ScheduledBatchSection(
      {this.applicationId,
      this.scheduledBatch,
      this.meetingId,
      this.meetingPassword,
      this.enableReschedule,
      this.actionData})
      : super(SectionType.batchScheduled);
}

class AttachmentSection extends BaseSection {
  String? title;
  String? description;
  List<Attachment>? attachments;

  AttachmentSection({this.title, this.description, this.attachments})
      : super(SectionType.resource);
}

class SupplyConfirmSection extends BaseSection {
  static const interviewNotHappenedReason1 = "I missed my interview";
  static const interviewNotHappenedReason2 = "I didn't get any call";
  static const pitchNotHappenedReason1 = "I missed my pitch demo";
  static const pitchNotHappenedReason2 = "I didn't get any call";
  static const trainingDidntJoin = "Yes, I didn’t join the training";
  static const trainingJoined1 = "Training Completed Successfully";
  static const trainingJoined2 = "I want to re-attend training";
  static const trainingJoined3 = "Trainer didn’t come";
  static const trainingReAttendReason1 = "I missed some part";
  static const trainingReAttendReason2 = "Training didn't happened";

  ActionData? actionData;

  SupplyConfirmSection({this.actionData})
      : super(SectionType.slotSupplyConfirm);
}

class TrainingData {
  String? meetingID;
  String? meetingPassword;

  TrainingData({this.meetingID, this.meetingPassword});
}
