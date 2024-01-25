import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionNameWidget extends StatelessWidget {
  final Question? question;

  const QuestionNameWidget(this.question, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildQuestionText();
  }

  Widget buildQuestionText() {
    return Text(
      (question?.configuration?.questionNameText ?? '').toCapitalized(),
      style: Get.textTheme.bodyText2Medium
          ?.copyWith(color: AppColors.backgroundBlack),
    );
  }
}
