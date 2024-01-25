import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/add_answer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextAnswerWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;
  const TextAnswerWidget(this.screenRow, this.onAnswerAddOrUpdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildQuestionText();
  }

  Widget buildQuestionText() {
    if ((screenRow.question?.hasAnswered() ?? false)) {
      String? answerValue = screenRow.question?.answerUnit?.stringValue;
      if (screenRow.question?.uid == UID.mobileNumber) {
        answerValue = StringUtils.maskString(answerValue, 3, 3);
      } else if (screenRow.question?.uid == UID.email) {
        answerValue = StringUtils.maskString(answerValue, 4, 4);
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
                  answerValue ?? '',
                  style: Get.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey900),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              AddAnswerWidget(screenRow, onAnswerAddOrUpdate, showText: false),
            ],
          ),
        ),
      );
    } else {
      return AddAnswerWidget(screenRow, onAnswerAddOrUpdate);
    }
  }
}
