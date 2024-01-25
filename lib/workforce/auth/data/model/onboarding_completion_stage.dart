import 'package:awign/workforce/core/data/model/enum.dart';

class OnboardingCompletionStage<String> extends Enum1<String> {
  const OnboardingCompletionStage(String val) : super(val);

  static const OnboardingCompletionStage personalDetails =
      OnboardingCompletionStage('personal_details');
  static const OnboardingCompletionStage workPreferences =
      OnboardingCompletionStage('work_preferences');
  static const OnboardingCompletionStage availabilityType =
      OnboardingCompletionStage('availability_type');
  static const OnboardingCompletionStage completed =
      OnboardingCompletionStage('completed');

  static OnboardingCompletionStage? get(dynamic inputType) {
    switch (inputType) {
      case 'personal_details':
        return OnboardingCompletionStage.personalDetails;
      case 'work_preferences':
        return OnboardingCompletionStage.workPreferences;
      case 'availability_type':
        return OnboardingCompletionStage.availabilityType;
      case 'completed':
        return OnboardingCompletionStage.completed;
      default:
        return null;
    }
  }
}
