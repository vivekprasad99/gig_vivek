import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/question_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/model/widget_result.dart';

class GroupQuestionWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final RenderType renderType;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;

  const GroupQuestionWidget(
      {Key? key,
      required this.screenRow,
      required this.renderType,
      required this.onAnswerUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildGroupQuestions();
  }

  Widget buildGroupQuestions() {
    List<Widget> widgets = [];
    for (int i = 0; i < screenRow.groupData!.questions!.length; i++) {
      Question question = screenRow.groupData!.questions![i];
      widgets.add(QuestionWidget(question, renderType, onAnswerUpdate));
    }
    return Theme(
      data:
          Theme.of(Get.context!).copyWith(dividerColor: AppColors.transparent),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundGrey400,
        ),
        margin: const EdgeInsets.only(top: Dimens.padding_16),
        child: ExpansionTile(
          onExpansionChanged: (value) {
            (value) ? screenRow.groupData?.isExpanded = true : screenRow.groupData?.isExpanded = false;
          },
          childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
          tilePadding: const EdgeInsets.symmetric(horizontal: 0),
          textColor: Get.context!.theme.iconColorNormal,
          iconColor: Get.context!.theme.iconColorNormal,
          initiallyExpanded: screenRow.groupData!.isExpanded,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimens.padding_4),
            child: Row(
              children: [
                const SizedBox(width: Dimens.padding_16),
                Expanded(
                  child: Text(
                    screenRow.groupData!.groupName ?? '',
                    style: Get.context!.textTheme.headline6
                        ?.copyWith(color: AppColors.backgroundGrey800),
                  ),
                ),
                Text(
                  '${screenRow.groupData!.answerQuestionCount}/${screenRow.groupData!.questions!.length}',
                  style: Get.context!.textTheme.caption,
                ),
              ],
            ),
          ),
          children: <Widget>[
            Container(
              color: AppColors.backgroundGrey200,
              child: Column(
                children: widgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
