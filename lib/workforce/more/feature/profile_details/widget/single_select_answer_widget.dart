import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/add_answer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingleSelectAnswerWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;
  const SingleSelectAnswerWidget(this.screenRow, this.onAnswerAddOrUpdate,
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
      if (selectConfiguration?.optionEntities != null &&
          screenRow.question?.answerUnit?.stringValue != null) {
        for (int i = 0; i < selectConfiguration!.optionEntities!.length; i++) {
          if (selectConfiguration.optionEntities![i].uid ==
              screenRow.question?.answerUnit?.stringValue) {
            answerValue = selectConfiguration.optionEntities![i].name;
            break;
          }
        }
      } else {
        answerValue = screenRow.question?.answerUnit?.stringValue ?? '';
      }
      return Expanded(
        child: MyInkWell(
          onTap: () {
            if ((screenRow.question?.configuration?.isEditable ?? true)) {
              onAnswerAddOrUpdate(screenRow);
            }
          },
          child: Row(
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
