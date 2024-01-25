import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';

import '../../../../aw_questions/data/model/question.dart';

class ScreenQuestionArguments {
  final List<Question> questionList;
  final List<ScreenQuestion> screenQuestionList;
  final bool? isNotLastScreen;

  ScreenQuestionArguments({required this.questionList,required this.screenQuestionList,this.isNotLastScreen});
}
