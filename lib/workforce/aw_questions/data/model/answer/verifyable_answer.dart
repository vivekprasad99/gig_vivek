import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';

class VerifyableAnswer {
  late bool isVerified;
  late AnswerUnit? answer;

  VerifyableAnswer({this.isVerified = false, this.answer});
}
