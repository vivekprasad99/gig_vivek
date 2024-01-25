import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/add_answer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationAnswerWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;
  const LocationAnswerWidget(this.screenRow, this.onAnswerAddOrUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildAnswerText();
  }

  Widget buildAnswerText() {
    if ((screenRow.question?.hasAnswered() ?? false) &&
        screenRow.question?.answerUnit?.address != null) {
      String answerValue =
          '${screenRow.question?.answerUnit?.address?.city}, ${screenRow.question?.answerUnit?.address?.pincode}';
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
      return AddAnswerWidget(screenRow, onAnswerAddOrUpdate);
    }
  }
}
