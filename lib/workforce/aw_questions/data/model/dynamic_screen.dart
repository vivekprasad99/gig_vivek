import 'package:awign/workforce/core/data/model/enum.dart';

class DynamicScreen<String> extends Enum1<String> {
  const DynamicScreen(String val) : super(val);

  static const DynamicScreen personalDetails =
      DynamicScreen('personal_details');
  static const DynamicScreen workPreferences =
      DynamicScreen('work_preferences');
  static const DynamicScreen availabilityType =
      DynamicScreen('availability_type');
  static const DynamicScreen professionalDetails1 =
      DynamicScreen('professional_details_1');
  static const DynamicScreen professionalDetails2 =
      DynamicScreen('professional_details_2');
  static const DynamicScreen educationalDetails =
      DynamicScreen('educational_details');
  static const DynamicScreen skills = DynamicScreen('skills');
  static const DynamicScreen preference = DynamicScreen('preference');
  static const DynamicScreen profileDetails = DynamicScreen('profile_details');

  static DynamicScreen? get(dynamic inputType) {
    switch (inputType) {
      case 'personal_details':
        return DynamicScreen.personalDetails;
      case 'work_preferences':
        return DynamicScreen.workPreferences;
      case 'availability_type':
        return DynamicScreen.availabilityType;
      case 'professional_details_1':
        return DynamicScreen.professionalDetails1;
      case 'professional_details_2':
        return DynamicScreen.professionalDetails2;
      case 'educational_details':
        return DynamicScreen.educationalDetails;
      case 'skills':
        return DynamicScreen.skills;
      case 'preference':
        return DynamicScreen.preference;
      case 'profile_details':
        return DynamicScreen.profileDetails;
      default:
        return null;
    }
  }
}
