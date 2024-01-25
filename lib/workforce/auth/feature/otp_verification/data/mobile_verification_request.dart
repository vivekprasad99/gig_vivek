class UserMobileVerificationRequest {
  UserMobileVerificationRequest({
    required this.user
  });

  late final OTPVerificationRequest? user;

  UserMobileVerificationRequest.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? OTPVerificationRequest.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = user?.toJson();
    return _data;
  }
}

class OTPVerificationRequest {
  OTPVerificationRequest({
    required this.otp,
    required this.mobileNumber,
  });

  late final String? otp;
  late final String mobileNumber;

  OTPVerificationRequest.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    mobileNumber = json['mobile_number'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['otp'] = otp;
    _data['mobile_number'] = mobileNumber;
    return _data;
  }
}