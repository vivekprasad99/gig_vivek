import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/group/group_question_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_widget.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/model/widget_result.dart';
import '../../data/model/configuration/configuration_type.dart';

class QuestionTile extends StatelessWidget {
  final ScreenRow screenRow;
  final RenderType renderType;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;

  const QuestionTile(
      {Key? key,
      required this.screenRow,
      required this.renderType,
      required this.onAnswerUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWidgetFromViewType();
  }

  Widget buildWidgetFromViewType() {
    switch (screenRow.rowType) {
      case ScreenRowType.question:
        if (screenRow.question != null) {
          return QuestionWidget(
              screenRow.question!, renderType, _onAnswerUpdate);
        } else {
          return const SizedBox();
        }
      case ScreenRowType.category:
        if (screenRow.groupData != null &&
            !screenRow.groupData!.questions.isNullOrEmpty) {
          return GroupQuestionWidget(
              screenRow: screenRow,
              renderType: RenderType.DEFAULT,
              onAnswerUpdate: _onAnswerUpdate);
        } else {
          return const SizedBox();
        }
      default:
        return Text('Coming soon...', style: Get.context?.textTheme.headline5);
    }
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    if(question.inputType?.getValue1() != ConfigurationType.text) {
      question.uuid = DateTime.now().millisecondsSinceEpoch.toString();
    }
    onAnswerUpdate(question, widgetResult: widgetResult);
  }
}
