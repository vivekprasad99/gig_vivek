import 'package:awign/workforce/core/data/model/enum.dart';

class DreamApplicationCompletionStage<String> extends Enum1<String> {
  const DreamApplicationCompletionStage(String val) : super(val);

  static const DreamApplicationCompletionStage professionalDetails1 =
      DreamApplicationCompletionStage('professional_details_1');
  static const DreamApplicationCompletionStage professionalDetails2 =
      DreamApplicationCompletionStage('professional_details_2');
  static const DreamApplicationCompletionStage educationalDetails =
      DreamApplicationCompletionStage('educational_details');
  static const DreamApplicationCompletionStage skills =
      DreamApplicationCompletionStage('skills');
  static const DreamApplicationCompletionStage personalDetails =
      DreamApplicationCompletionStage('personal_details');
  static const DreamApplicationCompletionStage preference =
      DreamApplicationCompletionStage('preference');
  static const DreamApplicationCompletionStage completed =
      DreamApplicationCompletionStage('completed');

  static DreamApplicationCompletionStage? get(dynamic inputType) {
    switch (inputType) {
      case 'professional_details_1':
        return DreamApplicationCompletionStage.professionalDetails1;
      case 'professional_details_2':
        return DreamApplicationCompletionStage.professionalDetails2;
      case 'educational_details':
        return DreamApplicationCompletionStage.educationalDetails;
      case 'skills':
        return DreamApplicationCompletionStage.skills;
      case 'personal_details':
        return DreamApplicationCompletionStage.personalDetails;
      case 'preference':
        return DreamApplicationCompletionStage.preference;
      case 'completed':
        return DreamApplicationCompletionStage.completed;
      default:
        return null;
    }
  }

  static DreamApplicationCompletionStage getNextDreamApplicationStage(
      DreamApplicationCompletionStage? dreamApplicationCompletionStage) {
    switch (dreamApplicationCompletionStage) {
      case DreamApplicationCompletionStage.professionalDetails1:
        return DreamApplicationCompletionStage.professionalDetails2;
      case DreamApplicationCompletionStage.professionalDetails2:
        return DreamApplicationCompletionStage.educationalDetails;
      case DreamApplicationCompletionStage.educationalDetails:
        return DreamApplicationCompletionStage.skills;
      case DreamApplicationCompletionStage.skills:
        return DreamApplicationCompletionStage.personalDetails;
      case DreamApplicationCompletionStage.personalDetails:
        return DreamApplicationCompletionStage.preference;
      default:
        return DreamApplicationCompletionStage.professionalDetails1;
    }
  }
}
