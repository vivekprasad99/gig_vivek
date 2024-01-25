import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/widget/question_error_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_hint_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_required_icon_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_text_widget.dart';
import 'package:awign/workforce/aw_questions/widget/tile/input_tile.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

import '../../core/data/model/widget_result.dart';

class QuestionWidgetNew extends StatelessWidget {
  final Question question;
  final RenderType? renderType;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;

  const QuestionWidgetNew(this.question, this.renderType, this.onAnswerUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!question.visibilityConditions.isNullOrEmpty && !question.isVisible) {
      return const SizedBox();
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
        padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: QuestionTextWidget(question),
                ),
                const SizedBox(width: Dimens.padding_12),
                QuestionRequiredIconWidget(question,
                    padding: const EdgeInsets.only(top: 0)),
              ],
            ),
            buildUpperHint(),
            buildInputListWidget(),
            QuestionErrorWidget(question,
                padding: const EdgeInsets.only(top: Dimens.padding_4)),
            const SizedBox(height: Dimens.padding_12),
            buildBottomHint(),
          ],
        ),
      );
    }
  }

  Widget buildUpperHint() {
    if (question.isUpperHintVisible()) {
      return QuestionHintWidget(question);
    } else {
      return const SizedBox();
    }
  }

  Widget buildBottomHint() {
    if (question.isUpperHintVisible()) {
      return const SizedBox();
    } else {
      return QuestionHintWidget(question);
    }
  }

  Widget buildInputListWidget() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      itemCount: 1,
      itemBuilder: (_, i) {
        return InputTile(
          padding: const EdgeInsets.only(top: Dimens.padding_16),
          question: question,
          renderType: renderType,
          onAnswerUpdate: onAnswerUpdate,
        );
      },
    );
  }
}
