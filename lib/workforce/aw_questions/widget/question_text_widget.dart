import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionTextWidget extends StatelessWidget {
  final Question? question;

  const QuestionTextWidget(this.question, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildQuestionText();
  }

  Widget buildQuestionText() {
    return Text(
      (question?.configuration?.questionText ?? (question?.dynamicData.toString() ?? "")).toCapitalized(),
      style: Get.textTheme.bodyText2SemiBold,
    );
  }
}
