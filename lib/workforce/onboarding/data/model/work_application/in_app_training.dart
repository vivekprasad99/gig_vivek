import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';

class InAppTraining {
  int? id;
  String? rescheduleCount;
  StepStatus? status;
  List<String>? notes;
  List<Attachment>? resources;

  InAppTraining(
      {this.id,
        this.rescheduleCount,
        this.status,
        this.notes,
        this.resources
      });

  InAppTraining.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rescheduleCount = json['reschedule_count'];
    status = StepStatus.getStatus(json['status']);
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
}

class InAppTrainingAnswerRequestEntity {
  late InAppTrainingAnswerEntity answerRequest;

  InAppTrainingAnswerRequestEntity(
      {required this.answerRequest});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['training_answer'] = answerRequest.toJson();
    return data;
  }
}

class InAppTrainingAnswerEntity {
  late int inAppTrainingQuestionId;
  late dynamic answer;
  late int timeToAnswer;

  InAppTrainingAnswerEntity(
      {required this.inAppTrainingQuestionId,
        this.answer,
        required this.timeToAnswer});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['in_app_training_question_id'] = inAppTrainingQuestionId;
    data['answer'] = answer;
    data['time_to_answer'] = timeToAnswer;
    return data;
  }
}
