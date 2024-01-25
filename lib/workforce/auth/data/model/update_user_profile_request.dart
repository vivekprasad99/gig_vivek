import 'package:awign/workforce/core/data/model/user_data.dart';

class UpdateUserProfileRequest {
  UpdateUserProfileRequest({
    required this.workforceDetails
  });

  late final WorkforceDetailsRequest? workforceDetails;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['workforce_details'] = workforceDetails?.toJson();
    return _data;
  }
}

class WorkforceDetailsRequest {
  WorkforceDetailsRequest({
    required this.name,
    required this.email,
    required this.gender,
    required this.educationLevel,
    required this.dob,
    required this.profileCompletionStage,
    required this.userDetailsRequired,
    required this.workedBefore,
  });

  String? name;
  String? email;
  Gender? gender;
  String? educationLevel;
  String? dob;
  String? profileCompletionStage;
  bool? userDetailsRequired;
  bool? workedBefore;


  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    if (email != null) {
      _data['email'] = email;
    }
    switch(gender) {
      case Gender.male:
        _data['gender'] = 'male';
        break;
      case Gender.female:
        _data['gender'] = 'female';
        break;
      case Gender.other:
        _data['gender'] = 'other';
        break;
      default:
        _data['gender'] = null;
    }
    _data['education_level'] = educationLevel;
    _data['dob'] = dob;
    if(profileCompletionStage != null) {
      _data['profile_completion_stage'] = profileCompletionStage;
    }
    if(userDetailsRequired != null) {
      _data['user_details_required'] = userDetailsRequired;
    }
    if(workedBefore != null) {
      _data['worked_before'] = workedBefore;
    }
    return _data;
  }
}