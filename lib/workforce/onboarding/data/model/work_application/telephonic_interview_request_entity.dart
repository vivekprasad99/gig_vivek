class TelephonicInterviewRequestEntity {
  late TelephonicInterviewRequestDataEntity?
      telephonicInterviewRequestDataEntity;

  TelephonicInterviewRequestEntity({this.telephonicInterviewRequestDataEntity});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['telephonic_interview'] =
        telephonicInterviewRequestDataEntity?.toJson();
    return _data;
  }
}

class TelephonicInterviewRequestDataEntity {
  late int? slotID;
  late String? mobileNumber;
  late String? supplyNonConfirmation;
  late String? supplyConfirmation;
  late int? interviewExperience;

  TelephonicInterviewRequestDataEntity(
      {this.slotID,
      this.mobileNumber,
      this.supplyNonConfirmation,
      this.supplyConfirmation,
      this.interviewExperience});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['telephonic_interview_slot_id'] = slotID;
    _data['mobile_number'] = mobileNumber;
    _data['non_confirmation_reason_supply'] = supplyNonConfirmation;
    _data['interview_confirmation_supply'] = supplyConfirmation;
    _data['interview_experience'] = interviewExperience;
    return _data;
  }
}
