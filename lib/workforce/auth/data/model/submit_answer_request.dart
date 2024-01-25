import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';

class SubmitAnswerRequest {
  List<ProfileAttributeData> profileAttributes;
  OnboardingCompletionStage? onboardingCompletionStage;
  DreamApplicationCompletionStage? dreamApplicationCompletionStage;

  SubmitAnswerRequest(
      {required this.profileAttributes,
      this.onboardingCompletionStage,
      this.dreamApplicationCompletionStage});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['profile_attribute'] =
        profileAttributes.map((e) => e.toJson()).toList();
    if (onboardingCompletionStage != null) {
      _data['onboarding_completed_stage'] = onboardingCompletionStage?.value;
    }
    if (dreamApplicationCompletionStage != null) {
      _data['dream_application_completed_stage'] =
          dreamApplicationCompletionStage?.value;
    }
    return _data;
  }
}

class ProfileAttributeData {
  int? id;
  int? userId;
  String? attributeName;
  String? attributeUid;
  String? attributeType;
  dynamic attributeValue;
  String? createdAt;
  String? updatedAt;

  ProfileAttributeData({
    required this.attributeName,
    required this.attributeUid,
    required this.attributeType,
    required this.attributeValue,
  });

  ProfileAttributeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    attributeUid = json['attribute_uid'];
    attributeName = json['attribute_name'];
    attributeValue = json['attribute_value'];
    attributeType = json['attribute_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) {
      data['id'] = id;
    }
    if (userId != null) {
      data['user_id'] = userId;
    }
    data['attribute_uid'] = attributeUid;
    data['attribute_name'] = attributeName;
    data['attribute_value'] = attributeValue;
    data['attribute_type'] = attributeType;
    if (createdAt != null) {
      data['created_at'] = createdAt;
    }
    if (updatedAt != null) {
      data['updated_at'] = updatedAt;
    }
    return data;
  }
}

class SubmitAnswerResponse {
  List<ProfileAttributeData>? profileAttribute;
  OnboardingCompletionStage? onboardingCompletionStage;
  DreamApplicationCompletionStage? dreamApplicationCompletionStage;
  String? message;

  SubmitAnswerResponse({this.profileAttribute, this.onboardingCompletionStage});

  SubmitAnswerResponse.fromJson(Map<String, dynamic> json, String? msg) {
    if (json['profile_attribute'] != null) {
      profileAttribute = <ProfileAttributeData>[];
      json['profile_attribute'].forEach((v) {
        profileAttribute!.add(ProfileAttributeData.fromJson(v));
      });
    }
    onboardingCompletionStage =
        OnboardingCompletionStage.get(json['onboarding_completion_stage']);
    dreamApplicationCompletionStage = DreamApplicationCompletionStage.get(
        json['dream_application_completion_stage']);
    message = msg;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (profileAttribute != null) {
      data['profile_attribute'] =
          profileAttribute!.map((v) => v.toJson()).toList();
    }
    data['onboarding_completion_stage'] = onboardingCompletionStage?.value;
    return data;
  }
}
