class UserNewLoginRequest {
  UserNewLoginRequest({
    required this.userNewMobileVerificationRequest
  });

  late final UserNewMobileVerificationRequest? userNewMobileVerificationRequest;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = userNewMobileVerificationRequest?.toJson();
    return _data;
  }
}

class UserNewMobileVerificationRequest {
  UserNewMobileVerificationRequest({
    required this.otp,
    required this.mobileNumber,
    required this.signInWithOtp,
  });

  late String? otp;
  late String? mobileNumber;
  late bool? signInWithOtp;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    if(otp!=null) {
      _data['otp'] = otp;
    }
    if(mobileNumber!=null) {
      _data['mobile_number'] = mobileNumber;
    }
    if(signInWithOtp!=null) {
      _data['sign_in_with_otp'] = signInWithOtp;
    }
    return _data;
  }

}