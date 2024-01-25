import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';

class PitchDemo {
  int? id;
  DemoType? demoType;
  StepStatus? status;
  int? rescheduleCount;
  List<Attachment>? attachmentSections;
  SlotEntity? suggestedSlot;
  String? slotFromTime;
  String? slotToTime;
  String? mobileNumber;
  List<String>? notes;
  List<Attachment>? resources;

  PitchDemo(
      {this.id,
        this.demoType,
        this.status,
        this.rescheduleCount,
        this.attachmentSections,
        this.suggestedSlot,
        this.slotFromTime,
        this.slotToTime,
        this.mobileNumber,
        this.notes,this.resources});

  PitchDemo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    demoType = DemoType.get(json['demo_type']);
    status = StepStatus.getStatus(json['status']);
    rescheduleCount = json['reschedule_count'];
    if (json['resources'] != null) {
      attachmentSections = <Attachment>[];
      json['resources'].forEach((v) {
        attachmentSections!.add(Attachment.fromJson(v));
      });
    }
    suggestedSlot = json['suggested_slot'] != null
        ? SlotEntity.fromJson(json['suggested_slot'])
        : null;
    slotFromTime = json['demo_slot_from'];
    slotToTime = json['demo_slot_to'];
    mobileNumber = json['mobile_number'];
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

class DemoType<String> extends Enum1<String> {
  const DemoType(String val) : super(val);

  static const DemoType automated = DemoType('automated');
  static const DemoType manual = DemoType('manual');

  static DemoType? get(dynamic status) {
    switch(status) {
      case 'automated':
        return  DemoType.automated;
      case 'manual':
        return DemoType.manual;
    }
    return null;
  }
}

class PitchDemoEntityRequest {
  late PitchDemoRequest? pitchDemoRequest;

  PitchDemoEntityRequest({this.pitchDemoRequest});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['pitch_demo'] =
        pitchDemoRequest?.toJson();
    return _data;
  }
}

class PitchDemoRequest {
  late int? slotID;
  late String? mobileNumber;

  PitchDemoRequest(
      {this.slotID,
        this.mobileNumber});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['pitch_demo_slot_id'] = slotID;
    _data['mobile_number'] = mobileNumber;
    return _data;
  }
}

class ConfirmPitchDemoRequest {
  late ConfirmPitchDemo? confirmPitchDemo;

  ConfirmPitchDemoRequest({this.confirmPitchDemo});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['pitch_demo'] =
        confirmPitchDemo?.toJson();
    return _data;
  }
}

class ConfirmPitchDemo {
  late String? confirmSupply;
  late int? experience;

  ConfirmPitchDemo(
      {this.confirmSupply,
        this.experience});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['demo_confirmation_supply'] = confirmSupply;
    _data['demo_experience'] = experience;
    return _data;
  }
}

class UnConfirmPitchDemoRequest {
  late UnConfirmPitchDemo? unConfirmPitchDemo;

  UnConfirmPitchDemoRequest({this.unConfirmPitchDemo});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['pitch_demo'] =
        unConfirmPitchDemo?.toJson();
    return _data;
  }
}

class UnConfirmPitchDemo {
  late String? unConfirmSupply;

  UnConfirmPitchDemo(
      {this.unConfirmSupply});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['non_confirmation_reason_supply'] = unConfirmSupply;
    return _data;
  }
}

class PitchDemoAnswerRequestEntity {
  late PitchDemoAnswerEntity pitchDemoAnswerEntity;

  PitchDemoAnswerRequestEntity(
      {required this.pitchDemoAnswerEntity});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pitch_demo_answer'] = pitchDemoAnswerEntity.toJson();
    return data;
  }
}

class PitchDemoAnswerEntity {
  late int pitchDemoQuestionId;
  late dynamic answer;

  PitchDemoAnswerEntity(
      {required this.pitchDemoQuestionId,
        this.answer});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pitch_demo_question_id'] = pitchDemoQuestionId;
    data['answer'] = answer;
    return data;
  }
}
