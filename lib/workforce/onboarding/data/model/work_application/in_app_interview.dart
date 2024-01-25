import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';

import 'attachment.dart';

class InAppInterview {
  int? id;
  int? applicationId;
  int? inAppInterviewConfigId;
  String? startedAt;
  String? completedAt;
  String? totalTimeTaken;
  int? score;
  String? rescheduleCount;
  String? interviewExperience;
  StepStatus? status;
  int? version;
  String? createdAt;
  String? updatedAt;
  int? worklistingId;
  int? applicationChannelId;
  List<String>? notes;
  List<String>? pending;
  List<String>? started;
  List<String>? passed;
  List<String>? failed;
  List<Attachment>? resources;

  InAppInterview({this.id,
    this.applicationId,
    this.inAppInterviewConfigId,
    this.startedAt,
    this.completedAt,
    this.totalTimeTaken,
    this.score,
    this.rescheduleCount,
    this.interviewExperience,
    this.status,
    this.version,
    this.createdAt,
    this.updatedAt,
    this.worklistingId,
    this.applicationChannelId,
    this.notes,
    this.pending, this.started, this.passed, this.failed, this.resources});

  InAppInterview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    applicationId = json['application_id'];
    inAppInterviewConfigId = json['in_app_interview_config_id'];
    startedAt = json['started_at'];
    completedAt = json['completed_at'];
    totalTimeTaken = json['total_time_taken'];
    score = json['score'];
    rescheduleCount = json['reschedule_count'];
    interviewExperience = json['interview_experience'];
    status = StepStatus.getStatus(json['status']);
    version = json['version'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    worklistingId = json['worklisting_id'];
    applicationChannelId = json['application_channel_id'];
    if (json['notes'] != null) {
      notes = json['notes'].cast<String>();
    } else {
      notes = null;
    }
    if (json['pending'] != null) {
      pending = json['pending'].cast<String>();
    } else {
      pending = null;
    }
    if (json['started'] != null) {
      started = json['started'].cast<String>();
    } else {
      started = null;
    }
    if (json['passed'] != null) {
      passed = json['passed'].cast<String>();
    } else {
      passed = null;
    }
    if (json['failed'] != null) {
      failed = json['failed'].cast<String>();
    } else {
      failed = null;
    }
   resources = json['resources'] != null
    ? List.from(json['resources'])
        .map((e) => Attachment.fromJson(e))
        .toList()
        : null;
  }
}

class InAppInterviewAnswerRequestEntity {
  late InAppInterviewAnswerEntity answerRequest;

  InAppInterviewAnswerRequestEntity({required this.answerRequest});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['interview_answer'] = answerRequest.toJson();
    return data;
  }
}

class InAppInterviewAnswerEntity {
  late int inAppInterviewQuestionId;
  late dynamic answer;
  late int timeToAnswer;

  InAppInterviewAnswerEntity({required this.inAppInterviewQuestionId,
    this.answer,
    required this.timeToAnswer});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['in_app_interview_question_id'] = inAppInterviewQuestionId;
    data['answer'] = answer;
    data['time_to_answer'] = timeToAnswer;
    return data;
  }
}
