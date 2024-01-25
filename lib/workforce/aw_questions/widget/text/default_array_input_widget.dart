import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DefaultArrayInputWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const DefaultArrayInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildUnAnsweredOrAnsweredWidget(context);
  }

  Widget buildUnAnsweredOrAnsweredWidget(BuildContext context) {
    if (question.answerUnit?.hasAnswered() ?? false) {
      return buildAnsweredWidget(context);
    } else {
      return buildUnAnsweredWidget(context);
    }
  }

  Widget buildAnsweredWidget(BuildContext context) {
    int filledAnswerCount = question.answerUnit?.arrayValue?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_32),
      child: Row(
        children: [
          Text(
            '$filledAnswerCount ${'fields_added'.tr}',
            style: Get.textTheme.bodyText1
                ?.copyWith(color: AppColors.backgroundGrey800),
          ),
          const SizedBox(width: Dimens.padding_16),
          MyInkWell(
            onTap: () async {
              AnswerUnit? answerUnit = await MRouter.pushNamed(
                  MRouter.arrayQuestionWidget,
                  arguments: question);
              if (answerUnit != null) {
                question.answerUnit = answerUnit;
                onAnswerUpdate(question);
              }
            },
            child: Text(
              '${'view'.tr} >',
              style: Get.textTheme.bodyText1
                  ?.copyWith(color: AppColors.primaryMain),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUnAnsweredWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_32),
      child: MyInkWell(
        onTap: () async {
          AnswerUnit? answerUnit = await MRouter.pushNamed(
              MRouter.arrayQuestionWidget,
              arguments: question);
          if (answerUnit != null) {
            question.answerUnit = answerUnit;
            onAnswerUpdate(question);
          }
        },
        child: Text(
          'click_to_add_answer'.tr,
          style:
              Get.textTheme.bodyText1?.copyWith(color: AppColors.primaryMain),
        ),
      ),
    );
  }
}
