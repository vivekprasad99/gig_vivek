import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/question_error_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_index_widget.dart';
import 'package:awign/workforce/aw_questions/widget/tile/input_tile.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

import '../../../../../core/data/model/widget_result.dart';

class ArrayQuestionTile extends StatelessWidget {
  final Question question;
  final RenderType? renderType;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;
  final Function(Question question) onDeleteTap;
  late bool isShowCard;

  ArrayQuestionTile(
      this.question, this.renderType, this.onAnswerUpdate, this.onDeleteTap,
      {Key? key, this.isShowCard = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isShowCard ? Dimens.elevation_1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                buildQuestionIndexWidget(),
                Expanded(child: buildInputListWidget()),
                buildDeleteWidget(),
              ],
            ),
            QuestionErrorWidget(question),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionIndexWidget() {
    if (question.inputType?.getValue2() != SubType.image) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, 0, 0),
        child: QuestionIndexWidget(question),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildInputListWidget() {
    return InputTile(
      padding: isShowCard ? null : const EdgeInsets.all(0),
      question: question,
      renderType: renderType,
      onAnswerUpdate: onAnswerUpdate,
    );
  }

  Widget buildDeleteWidget() {
    if (question.dataType == DataType.single &&
        question.inputType?.getValue2() == SubType.image &&
        (question.hasAnswered() ||
            question.hasAnswered(isCheckImageDetails: true))) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            0, Dimens.padding_16, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            onDeleteTap(question);
          },
          child: const Icon(
            Icons.delete_rounded,
            color: AppColors.backgroundGrey800,
            size: Dimens.iconSize_20,
          ),
        ),
      );
    }
  }
}
