import 'package:awign/workforce/core/data/model/enum.dart';

class DynamicModuleCategory<String> extends Enum1<String> {
  const DynamicModuleCategory(String val) : super(val);

  static const DynamicModuleCategory onboarding =
      DynamicModuleCategory('onboarding');
  static const DynamicModuleCategory dreamApplication =
      DynamicModuleCategory('dream_application');
  static const DynamicModuleCategory profileCompletion =
      DynamicModuleCategory('profile_completion');
  static const DynamicModuleCategory attendance =
  DynamicModuleCategory('attendance');

  static DynamicModuleCategory? get(dynamic inputType) {
    switch (inputType) {
      case 'onboarding':
        return DynamicModuleCategory.onboarding;
      case 'dream_application':
        return DynamicModuleCategory.dreamApplication;
      case 'profile_completion':
        return DynamicModuleCategory.profileCompletion;
      case 'attendance':
        return DynamicModuleCategory.attendance;
      default:
        return null;
    }
  }
}
