import 'package:awign/workforce/core/data/model/enum.dart';

class UID<String> extends Enum1<String> {
  const UID(String val) : super(val);

  static const UID name = UID('name');
  static const UID mobileNumber = UID('mobile_number');
  static const UID email = UID('email');
  static const UID gender = UID('gender');
  static const UID dateOfBirth = UID('date_of_birth');
  static const UID languages = UID('languages');
  static const UID sourceMedium = UID('source_medium');
  static const UID yearOfPassing = UID('year_of_passing');
  static const UID skillSets = UID('skill_sets');
  static const UID devicesAndAssets = UID('devices_and_assets');
  static const UID resume = UID('resume');
  static const UID panCard = UID('pan_card');
  static const UID aadharCard = UID('aadhar_card');
  static const UID drivingLicense = UID('driving_license');
  static const UID collegeName = UID('college_name');
  static const UID referralCode = UID('referral_code');
  static const UID whatsapp = UID('whatsapp');
  static const UID yourLocation = UID('your_location');
  static const UID workLocation = UID('work_location');

  static UID? get(dynamic inputType) {
    switch (inputType) {
      case 'name':
        return UID.name;
      case 'mobile_number':
        return UID.mobileNumber;
      case 'email':
        return UID.email;
      case 'gender':
        return UID.gender;
      case 'date_of_birth':
        return UID.dateOfBirth;
      case 'languages':
        return UID.languages;
      case 'source_medium':
        return UID.sourceMedium;
      case 'year_of_passing':
        return UID.yearOfPassing;
      case 'skill_sets':
        return UID.skillSets;
      case 'devices_and_assets':
        return UID.devicesAndAssets;
      case 'resume':
        return UID.resume;
      case 'pan_card':
        return UID.panCard;
      case 'aadhar_card':
        return UID.aadharCard;
      case 'driving_license':
        return UID.drivingLicense;
      case 'college_name':
        return UID.collegeName;
      case 'referral_code':
        return UID.referralCode;
      case 'whatsapp':
        return UID.whatsapp;
      case 'your_location':
        return UID.yourLocation;
      case 'work_location':
        return UID.workLocation;
      default:
        return null;
    }
  }
}
