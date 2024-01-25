import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/add_answer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectAnswerWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;
  const MultiSelectAnswerWidget(this.screenRow, this.onAnswerAddOrUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildAnswerText();
  }

  Widget buildAnswerText() {
    if ((screenRow.question?.hasAnswered() ?? false)) {
      SelectConfiguration? selectConfiguration =
          screenRow.question?.configuration as SelectConfiguration?;
      String answerValue = '';

      if (screenRow.question!.answerUnit!.optionListValue!.length <= 2) {
        for (int i = 0; i < screenRow.question!.answerUnit!.optionListValue!.length; i++) {
          answerValue += screenRow.question!.answerUnit!.optionListValue![i].name;
          if (i + 1 < screenRow.question!.answerUnit!.optionListValue!.length) {
            answerValue += ", ";
          }
        }
      } else {
        for (int i = 0; i < 2; i++) {
          answerValue += screenRow.question!.answerUnit!.optionListValue![i].name;
          if (i + 1 < 2) {
            answerValue += ", ";
          }
        }
        answerValue += " +${screenRow.question!.answerUnit!.optionListValue!.length - 2}";
      }
      return Expanded(
        child: MyInkWell(
          onTap: () {
            if ((screenRow.question?.configuration?.isEditable ?? true)) {
              onAnswerAddOrUpdate(screenRow);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  answerValue,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Get.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey900),
                ),
              ),
              AddAnswerWidget(screenRow, onAnswerAddOrUpdate, showText: false),
            ],
          ),
        ),
      );
    } else {
      if (!(screenRow.question?.configuration?.isEditable ?? true)) {
        screenRow.question?.configuration?.isEditable = true;
      }
      return AddAnswerWidget(screenRow, onAnswerAddOrUpdate);
    }
  }
}
