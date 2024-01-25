import 'package:awign/workforce/core/extension/string_extension.dart';

class MemberTimeSlotResponse {
  MemberTimeSlot? memberTimeSlot;

  MemberTimeSlotResponse({this.memberTimeSlot});

  MemberTimeSlotResponse.fromJson(Map<String, dynamic> json) {
    memberTimeSlot = json['member_time_slot'] != null
        ? MemberTimeSlot.fromJson(json['member_time_slot'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (memberTimeSlot != null) {
      data['member_time_slot'] = memberTimeSlot!.toJson();
    }
    return data;
  }
}

class MemberTimeSlot {
  String? sId;
  String? sStatus;
  String? createdAt;
  String? date;
  String? memberId;
  late List<Slot> slots;
  String? updatedAt;

  MemberTimeSlot(
      {this.sId,
      this.sStatus,
      this.createdAt,
      this.date,
      this.memberId,
      required this.slots,
      this.updatedAt});

  MemberTimeSlot.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    sStatus = json['_status'];
    createdAt = json['created_at'];
    date = json['date'];
    memberId = json['member_id'];
    if (json['slots'] != null) {
      slots = <Slot>[];
      json['slots'].forEach((v) {
        slots.add(Slot.fromJson(v));
      });
    }
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['_status'] = sStatus;
    data['created_at'] = createdAt;
    data['date'] = date;
    data['member_id'] = memberId;
    data['slots'] = slots.map((v) => v.toJson()).toList();
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Slot {
  String? endTime;
  String? startTime;
  bool? isUpdated;

  Slot({this.endTime, this.startTime, this.isUpdated = false});

  Slot.fromJson(Map<String, dynamic> json) {
    endTime = json['end_time'];
    endTime = endTime!.getPrettyIstDateTimeFromUTC();
    startTime = json['start_time'];
    startTime = startTime!.getPrettyIstDateTimeFromUTC();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['end_time'] = endTime;
    data['start_time'] = startTime;
    return data;
  }
}
