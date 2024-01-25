import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';

class WebinarTraining {
  int? id;
  StepStatus? status;
  String? batchFromTime;
  String? batchToTime;
  String? batchName;
  List<Attachment>? attachmentSections;
  BatchEntity? suggestedBatch;
  String? trainingPlatform;
  String? trainingLink;
  String? meetingId;
  String? meetingPassword;
  List<String>? notes;
  List<Attachment>? resources;

  WebinarTraining(
      {this.id,
      this.status,
      this.batchFromTime,
      this.batchToTime,
      this.batchName,
      this.attachmentSections,
      this.suggestedBatch,
      this.trainingPlatform,
      this.trainingLink,
      this.meetingId,
      this.meetingPassword,
      this.notes,this.resources});

  WebinarTraining.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = StepStatus.getStatus(json['status']);
    batchFromTime = json['training_batch_from'];
    batchToTime = json['training_batch_to'];
    batchName = json['batch_name'];
    resources = json['resources'] != null
        ? List.from(json['resources'])
        .map((e) => Attachment.fromJson(e))
        .toList()
        : null;

    suggestedBatch = json['suggested_slot'] != null
        ? BatchEntity.fromJson(json['suggested_slot'])
        : null;
    trainingPlatform = json['training_platform'];
    trainingLink = json['training_link'];
    meetingId = json['meeting_id'];
    meetingPassword = json['meeting_password'];
    if (json['notes'] != null) {
      notes = json['notes'].cast<String>();
    } else {
      notes = null;
    }
  }
}

class TrainingConfirmReason {
  late String? trainingConfirmationSupply;

  TrainingConfirmReason(
      {this.trainingConfirmationSupply});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['training_confirmation_supply'] = trainingConfirmationSupply;
    return _data;
  }
}

class ConfirmWebinarTrainingRequest {
  late TrainingConfirmReason? trainingConfirmReason;

  ConfirmWebinarTrainingRequest({this.trainingConfirmReason});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['webinar_training'] =
        trainingConfirmReason?.toJson();
    return _data;
  }
}

class TrainingUnConfirmReason {
  late String? nonConfirmationReasonSupply;

  TrainingUnConfirmReason(
      {this.nonConfirmationReasonSupply});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['non_confirmation_reason_supply'] = nonConfirmationReasonSupply;
    return _data;
  }
}

class UnConfirmWebinarTrainingRequest {
  late TrainingUnConfirmReason? trainingUnConfirmReason;

  UnConfirmWebinarTrainingRequest({this.trainingUnConfirmReason});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['webinar_training'] =
        trainingUnConfirmReason?.toJson();
    return _data;
  }
}


