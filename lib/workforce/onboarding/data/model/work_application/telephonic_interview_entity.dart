import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';

import 'attachment.dart';

class TelephonicInterviewEntity {
  int? id;
  int? applicationId;
  int? telephonicInterviewConfigId;
  String? interviewSlotFrom;
  String? interviewSlotTo;
  String? mobileNumber;
  String? startedAt;
  String? completedAt;
  String? interviewConfirmationSupply;
  String? interviewConfirmationInterviewer;
  String? nonConfirmationReasonSupply;
  String? nonConfirmationReasonInterviewer;
  int? rescheduleCount;
  String? interviewExperience;
  StepStatus? status;
  int? version;
  String? createdAt;
  String? updatedAt;
  int? worklistingId;
  int? applicationChannelId;
  String? rejectionReason;
  String? saasOrgId;
  List<String>? notes;
  List<Attachment>? resources;

  TelephonicInterviewEntity(
      {this.id,
        this.applicationId,
        this.telephonicInterviewConfigId,
        this.interviewSlotFrom,
        this.interviewSlotTo,
        this.mobileNumber,
        this.startedAt,
        this.completedAt,
        this.interviewConfirmationSupply,
        this.interviewConfirmationInterviewer,
        this.nonConfirmationReasonSupply,
        this.nonConfirmationReasonInterviewer,
        this.rescheduleCount,
        this.interviewExperience,
        this.status,
        this.version,
        this.createdAt,
        this.updatedAt,
        this.worklistingId,
        this.applicationChannelId,
        this.rejectionReason,
        this.saasOrgId,
      this.notes,this.resources});

  TelephonicInterviewEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    applicationId = json['application_id'];
    telephonicInterviewConfigId = json['telephonic_interview_config_id'];
    interviewSlotFrom = json['interview_slot_from'];
    interviewSlotTo = json['interview_slot_to'];
    mobileNumber = json['mobile_number'];
    startedAt = json['started_at'];
    completedAt = json['completed_at'];
    interviewConfirmationSupply = json['interview_confirmation_supply'];
    interviewConfirmationInterviewer =
    json['interview_confirmation_interviewer'];
    nonConfirmationReasonSupply = json['non_confirmation_reason_supply'];
    nonConfirmationReasonInterviewer =
    json['non_confirmation_reason_interviewer'];
    rescheduleCount = json['reschedule_count'];
    interviewExperience = json['interview_experience'];
    status = StepStatus.getStatus(json['status']);
    version = json['version'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    worklistingId = json['worklisting_id'];
    applicationChannelId = json['application_channel_id'];
    rejectionReason = json['rejection_reason'];
    saasOrgId = json['saas_org_id'];
    if (json['notes'] != null) {
      notes = json['notes'].cast<String>();
    } else {
      notes = null;
    }
    resources = json['resources'] != null
        ? List.from(json['resources'])
        .map((e) => Attachment.fromJson(e))
        .toList()
        : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['application_id'] = applicationId;
    data['telephonic_interview_config_id'] = telephonicInterviewConfigId;
    data['interview_slot_from'] = interviewSlotFrom;
    data['interview_slot_to'] = interviewSlotTo;
    data['mobile_number'] = mobileNumber;
    data['started_at'] = startedAt;
    data['completed_at'] = completedAt;
    data['interview_confirmation_supply'] = interviewConfirmationSupply;
    data['interview_confirmation_interviewer'] =
        interviewConfirmationInterviewer;
    data['non_confirmation_reason_supply'] = nonConfirmationReasonSupply;
    data['non_confirmation_reason_interviewer'] =
        nonConfirmationReasonInterviewer;
    data['reschedule_count'] = rescheduleCount;
    data['interview_experience'] = interviewExperience;
    data['status'] = status;
    data['version'] = version;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['worklisting_id'] = worklistingId;
    data['application_channel_id'] = applicationChannelId;
    data['rejection_reason'] = rejectionReason;
    data['saas_org_id'] = saasOrgId;
    return data;
  }
}