import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionHintWidget extends StatelessWidget {
  final Question? question;

  const QuestionHintWidget(this.question, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildHintText();
  }

  Widget buildHintText() {
    if ((question?.configuration?.isEditable ?? false) &&
        (question?.configuration?.hintText ?? '').isNotEmpty) {
      String hint = '';
      if (question?.dynamicModuleCategory == DynamicModuleCategory.onboarding) {
        hint = question?.configuration?.hintText ?? '';
      } else {
        hint = (question?.configuration?.hintText ?? '').toCapitalized();
      }
      return Padding(
        padding: const EdgeInsets.only(top: Dimens.margin_4),
        child: Text(
          hint,
          style: Get.textTheme.caption
              ?.copyWith(color: AppColors.backgroundGrey800),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
