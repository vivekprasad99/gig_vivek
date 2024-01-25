class UserRequestDataPayload {
  late final UserRequestPayload? userRequestPayload;

  UserRequestDataPayload({required this.userRequestPayload});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = userRequestPayload?.toJson();
    return _data;
  }
}

class UserRequestPayload {
  UserRequestPayload({
    this.pin,
    this.otp,
    this.email,
    this.mobileNumber,
    this.dob,
  });

  String? pin;
  String? otp;
  String? email;
  String? mobileNumber;
  String? dob;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    if (pin != null) {
      _data['pin'] = pin;
    }
    if (otp != null) {
      _data['otp'] = otp;
    }
    if (email != null) {
      _data['email'] = email;
    }
    if (mobileNumber != null) {
      _data['mobile_number'] = mobileNumber;
    }
    if (dob != null) {
      _data['dob'] = dob;
    }
    return _data;
  }
}
