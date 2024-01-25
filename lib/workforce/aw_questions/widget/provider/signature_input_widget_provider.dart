import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/signature/widget/signature_input_widget.dart';
import 'package:flutter/cupertino.dart';

class SignatureInputWidgetProvider {
  static Widget getInputWidget(
      Question question, Function(Question question) onAnswerUpdate) {
    if ((question.configuration?.isEditable ?? false)) {
      return SignatureInputWidget(question, onAnswerUpdate);
    } else {
      return const SizedBox();
    }
  }
}