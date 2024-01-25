import 'package:equatable/equatable.dart';

class PANDetailsRequest {
  PANDetailsData? panDetails;

  PANDetailsRequest({this.panDetails});

  PANDetailsRequest.fromJson(Map<String, dynamic> json) {
    panDetails = json['pan_details'] != null
        ? PANDetailsData.fromJson(json['pan_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (panDetails != null) {
      data['pan_details'] = panDetails!.toJson();
    }
    return data;
  }
}

class PANDetailsData extends Equatable {
  String? name;
  String? panName;
  String? panNumber;
  String? panDob;
  String? panStatus;
  String? panStatusMessage;
  int? thirdPartyVerifiedCount;
  int? panVerificationCount;

  PANDetailsData({this.name,
    this.panName,
    this.panNumber,
    this.panDob,
    this.panStatus,
    this.panStatusMessage,
    this.thirdPartyVerifiedCount,
    this.panVerificationCount});

  PANDetailsData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    panName = json['pan_name'];
    panNumber = json['pan_number'];
    panDob = json['pan_dob'];
    panStatus = json['pan_status'];
    panStatusMessage = json['pan_status_message'];
    thirdPartyVerifiedCount = json['third_party_verified_count'];
    panVerificationCount = json['pan_verification_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(name != null) {
      data['name'] = name;
    }
    if(panName != null) {
      data['pan_name'] = panName;
    }
    if(panNumber != null) {
      data['pan_number'] = panNumber;
    }
    if(panDob != null) {
      data['pan_dob'] = panDob;
    }
    if(panStatus != null) {
      data['pan_status'] = panStatus;
    }
    if(panStatusMessage != null) {
      data['pan_status_message'] = panStatusMessage;
    }
    if(thirdPartyVerifiedCount != null) {
      data['third_party_verified_count'] = thirdPartyVerifiedCount;
    }
    if(panVerificationCount != null) {
      data['pan_verification_count'] = panVerificationCount;
    }
    return data;
  }

  @override
  List<Object?> get props => [
    name,
    panNumber,
    panDob,
    panStatus,
    panStatusMessage,
  ];
}