import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/widget/question_error_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_hint_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_index_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_required_icon_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_text_widget.dart';
import 'package:awign/workforce/aw_questions/widget/tile/input_tile.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

import '../../core/data/model/widget_result.dart';
import 'question_resources/question_resource_widget.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final RenderType? renderType;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;

  const QuestionWidget(this.question, this.renderType, this.onAnswerUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              0, Dimens.padding_16, 0, Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestionResourceWidget(question: question),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: Dimens.margin_16),
                  QuestionIndexWidget(question),
                  const SizedBox(width: Dimens.margin_16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuestionTextWidget(question),
                        QuestionHintWidget(question),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimens.margin_16),
                  QuestionRequiredIconWidget(question),
                ],
              ),
              buildInputListWidget(),
              QuestionErrorWidget(question),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputListWidget() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      itemCount: 1,
      itemBuilder: (_, i) {
        return InputTile(
          question: question,
          renderType: renderType,
          onAnswerUpdate: onAnswerUpdate,
        );
      },
    );
  }
}
