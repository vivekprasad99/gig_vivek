import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/group/group_question_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_widget.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/data/model/widget_result.dart';

class QuestionInflateHelper extends StatelessWidget {
  final ScreenRow screenRow;
  final RenderType renderType;
  final int index;
  final int total;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;
  final Stream<String?>? timerText;
  final Function() timerCompleted;
  final bool showTimerInQuestion;

  const QuestionInflateHelper(this.screenRow, this.renderType, this.index,
      this.total, this.timerText, this.showTimerInQuestion,
      this.timerCompleted, this.onAnswerUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: Column(
        children: [
          buildQuestionIndexCounterWidget(),
          buildTimerWidget(),
          const SizedBox(height: Dimens.margin_16),
          buildWidgetFromRenderType(),
        ],
      ),
    );
  }

  Widget buildQuestionIndexCounterWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.padding_12, vertical: Dimens.padding_8),
      decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.backgroundGrey800,
          ),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_20))),
      child: Text('${index + 1}/$total', style: Get.textTheme.bodyText1),
    );
  }

  Widget buildTimerWidget() {
    if (screenRow.question?.configuration?.timeToAnswer != null &&
        (screenRow.question?.configuration?.showTimer ?? false)) {
      if (showTimerInQuestion) {
        return Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_16),
          child: Row(
            children: [
              const Icon(Icons.timer),
              const SizedBox(width: 8.0),
              Expanded(
                child: StreamBuilder<String?>(
                  stream: timerText,
                  builder: (context, snapshot) {
                    final timerText = snapshot.data;
                    const totalTime = Duration(seconds: 10);
                    final currentTime = timerText != null
                        ? Duration(
                            seconds: int.parse(timerText.split(':')[1]),
                          )
                        : totalTime;
                    final progress = 1 -
                        (totalTime.inSeconds - currentTime.inSeconds) /
                            totalTime.inSeconds;

                    return LinearProgressIndicator(
                      value: progress,
                      color: AppColors.orange,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              StreamBuilder<String?>(
                stream: timerText,
                builder: (context, timerText) {
                  if(timerText.data == '00:00') {
                    timerCompleted();
                  }
                  return Text(
                    timerText.data.toString(),
                    style: const TextStyle(fontSize: 8.0),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        return const Padding(
          padding: EdgeInsets.only(top: Dimens.padding_16),
          child: Row(
            children: [
              Icon(Icons.timer),
              SizedBox(width: 8.0),
              Expanded(
                  child: LinearProgressIndicator(
                value: 0,
                color: AppColors.orange,
              )),
              SizedBox(width: 8.0),
              Text(
                '00:00',
                style: TextStyle(fontSize: 8.0),
              )
            ],
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  Widget buildWidgetFromRenderType() {
    switch (screenRow.rowType) {
      case ScreenRowType.question:
        if (screenRow.question != null) {
          return QuestionWidget(
              screenRow.question!, renderType, onAnswerUpdate);
        } else {
          return const SizedBox();
        }
      case ScreenRowType.category:
        if (screenRow.groupData != null &&
            !screenRow.groupData!.questions.isNullOrEmpty) {
          return GroupQuestionWidget(
              screenRow: screenRow,
              renderType: RenderType.DEFAULT,
              onAnswerUpdate: onAnswerUpdate);
        } else {
          return const SizedBox();
        }
      default:
        return Text('Coming soon...', style: Get.context?.textTheme.headline5);
    }
  }
}
