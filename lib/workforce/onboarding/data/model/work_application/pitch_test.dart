import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';

class PitchTest {
  int? id;
  StepStatus? status;
  List<Attachment>? attachmentSections;
  List<String>? notes;
  List<Attachment>? resources;
  PitchTest({this.id, this.status, this.attachmentSections, this.notes,this.resources});

  PitchTest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = StepStatus.getStatus(json['status']);
    if (json['resources'] != null) {
      attachmentSections = <Attachment>[];
      json['resources'].forEach((v) {
        attachmentSections!.add(Attachment.fromJson(v));
      });
    }
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

class PitchTestAnswerRequestEntity {
  late PitchTestAnswerEntity pitchTestAnswerEntity;

  PitchTestAnswerRequestEntity(
      {required this.pitchTestAnswerEntity});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pitch_test_answer'] = pitchTestAnswerEntity.toJson();
    return data;
  }
}

class PitchTestAnswerEntity {
  late int pitchTestQuestionId;
  late dynamic answer;

  PitchTestAnswerEntity(
      {required this.pitchTestQuestionId,
        this.answer});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pitch_test_question_id'] = pitchTestQuestionId;
    data['answer'] = answer;
    return data;
  }
}
