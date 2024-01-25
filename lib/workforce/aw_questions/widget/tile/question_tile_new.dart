import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/question_widget_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/model/widget_result.dart';

class QuestionTileNew extends StatelessWidget {
  final ScreenRow screenRow;
  final RenderType renderType;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;

  const QuestionTileNew(
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
          return QuestionWidgetNew(
              screenRow.question!, renderType, onAnswerUpdate);
        } else {
          return const SizedBox();
        }
      case ScreenRowType.category:
        return const SizedBox();
      default:
        return Text('Coming soon...', style: Get.context?.textTheme.headline5);
    }
  }
}
