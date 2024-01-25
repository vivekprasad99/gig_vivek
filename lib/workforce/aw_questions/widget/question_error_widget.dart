import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionErrorWidget extends StatelessWidget {
  final Question? question;
  late EdgeInsets? padding;
  QuestionErrorWidget(this.question, {this.padding, Key? key})
      : super(key: key) {
    padding ??= const EdgeInsets.only(
        left: Dimens.margin_16, top: Dimens.margin_4, right: Dimens.margin_16);
  }

  @override
  Widget build(BuildContext context) {
    return buildErrorTextWidget();
  }

  Widget buildErrorTextWidget() {
    if ((question?.configuration?.isEditable ?? false) &&
        (question?.configuration?.showErrMsg ?? false) &&
        question?.inputType?.getValue1() != ConfigurationType.dateTimeRange) {
      return Padding(
        padding: padding!,
        child: Text(
         question?.configuration?.errMsg ?? 'incorrect_value'.tr,
          style: Get.textTheme.bodyText2?.copyWith(color: AppColors.error400),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
