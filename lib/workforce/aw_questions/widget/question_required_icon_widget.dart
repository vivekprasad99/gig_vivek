import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionRequiredIconWidget extends StatelessWidget {
  final Question? question;
  late EdgeInsets? padding;
  late TextStyle? textStyle;
  QuestionRequiredIconWidget(this.question,
      {this.padding, this.textStyle, Key? key})
      : super(key: key) {
    padding ??= const EdgeInsets.only(right: Dimens.margin_16);
    textStyle ??=
        Get.textTheme.bodyText2SemiBold?.copyWith(color: AppColors.error400);
  }

  @override
  Widget build(BuildContext context) {
    return buildRequiredIcon();
  }

  Widget buildRequiredIcon() {
    if ((question?.configuration?.isEditable ?? false) &&
        (question?.configuration?.isRequired ?? false)) {
      return Padding(
        padding: padding!,
        child: Text(
          '*',
          style: textStyle,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
