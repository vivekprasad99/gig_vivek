import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndActionTile extends StatelessWidget {
  final int index;
  final EndAction endAction;
  final Function(int index, EndAction endAction) onEndActionTap;

  const EndActionTile(
      {Key? key,
      required this.index,
      required this.endAction,
      required this.onEndActionTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onEndActionTap(index, endAction);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border.all(color: AppColors.backgroundGrey600),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Text(endAction.action ?? '',
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyText1SemiBold),
      ),
    );
  }
}
