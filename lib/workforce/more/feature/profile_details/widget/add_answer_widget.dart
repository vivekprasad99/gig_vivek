import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddAnswerWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final bool showText;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;
  const AddAnswerWidget(this.screenRow, this.onAnswerAddOrUpdate,
      {this.showText = true, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((screenRow.question?.configuration?.isEditable ?? true)) {
      return MyInkWell(
        onTap: () {
          onAnswerAddOrUpdate(screenRow);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              showText ? 'add'.tr : '',
              style: Get.textTheme.bodyText2
                  ?.copyWith(color: AppColors.backgroundGrey900),
            ),
            const SizedBox(width: Dimens.padding_8),
            SvgPicture.asset(
              'assets/images/ic_arrow_right_grey_900.svg',
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
