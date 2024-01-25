import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';

class ProfileAttributesAndApplicationQuestions {
  late List<Question> questions;
  late List<ProfileAttributes> userProfileAttributes;

  ProfileAttributesAndApplicationQuestions({required this.questions, required this.userProfileAttributes});
}