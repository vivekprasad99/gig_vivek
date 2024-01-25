import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionIndexWidget extends StatelessWidget {
  final Question? question;

  const QuestionIndexWidget(this.question, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildQuestionIndexWidget();
  }

  Widget buildQuestionIndexWidget() {
    Color bgColor = AppColors.transparent;
    Color borderColor = AppColors.pattensBlue;
    Color? textColor = AppColors.pattensBlue;
    if ((question?.configuration?.isEditable ?? false) &&
        (question?.configuration?.showErrMsg ?? false)) {
      bgColor = AppColors.error400;
      textColor = AppColors.backgroundWhite;
      borderColor = AppColors.error400;
    } else if ((question?.answerUnit?.hasAnswered() ?? false)) {
      bgColor = AppColors.success300;
      textColor = AppColors.backgroundWhite;
      borderColor = AppColors.success300;
      if (question?.inputType?.getValue1() == ConfigurationType.file
          && question?.inputType?.getValue2() == SubType.image) {
        if (question?.answerUnit?.hasAnswered(isCheckImageDetails: true) == false) {
          bgColor = AppColors.transparent;
          textColor = AppColors.pattensBlue;
          borderColor = AppColors.pattensBlue;
        }
      }
    }
    return Container(
      width: Dimens.avatarWidth_20,
      height: Dimens.avatarHeight_20,
      decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
          ),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_16))),
      child: Center(
        child: Text(
          question?.configuration?.questionIndex?.toString() ?? '',
          style: Get.textTheme.overline
              ?.copyWith(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}
