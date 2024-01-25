import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/hash_answer.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NestedQuestionInputWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const NestedQuestionInputWidget(this.question, this.onAnswerUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (question.answerUnit?.hasAnswered() ?? false) {
      return buildAnsweredWidget(context);
    } else {
      return buildUnAnsweredWidget(context);
    }
  }

  Widget buildAnsweredWidget(BuildContext context) {
    if (question.dataType == DataType.array) {
      return buildAnsweredArrayWidget(context);
    } else {
      return buildUnAnsweredNestedWidget(context);
    }
  }

  Widget buildAnsweredArrayWidget(BuildContext context) {
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

  Widget buildUnAnsweredNestedWidget(BuildContext context) {
    int filledAnswerCount = _getFilledAnswerCount(question.answerUnit);
    int questionCount =
        _getQuestionCount(question.answerUnit, filledAnswerCount);
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_32),
      child: Row(
        children: [
          Text(
            '${'answers_filled'.tr} $filledAnswerCount/$questionCount',
            style: Get.textTheme.bodyText1
                ?.copyWith(color: AppColors.backgroundGrey800),
          ),
          const SizedBox(width: Dimens.padding_16),
          MyInkWell(
            onTap: () async {
              AnswerUnit? answerUnit = await MRouter.pushNamed(
                  MRouter.nestedQuestionWidget,
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
    if (question.dataType == DataType.array) {
      return buildUnAnsweredArrayWidget(context);
    } else {
      return buildUnAnsweredNestedWidget(context);
    }
  }

  Widget buildUnAnsweredArrayWidget(BuildContext context) {
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

  int _getFilledAnswerCount(AnswerUnit? answerUnit) {
    int count = 0;
    for (HashAnswer hashAnswer in answerUnit?.hashValue ?? []) {
      if (hashAnswer.value.hasAnswered()) {
        count++;
      }
    }
    return count;
  }

  int _getQuestionCount(AnswerUnit? answerUnit, int filledAnswerCount) {
    int count = 0;
    if (question.dataType == DataType.array) {
      if (filledAnswerCount == 0) {
        count = 1;
      } else {
        count = filledAnswerCount;
      }
    } else {
      count = question.nestedQuestionList?.length ?? 0;
    }
    return count;
  }
}
