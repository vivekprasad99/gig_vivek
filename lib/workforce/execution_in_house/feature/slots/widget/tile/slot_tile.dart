import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlotTile extends StatelessWidget {
  final int index;
  final SlotEntity slotEntity;
  final Function(int index, SlotEntity slotEntity) onSlotTapped;

  const SlotTile(
      {Key? key,
        required this.index,
        required this.slotEntity,
        required this.onSlotTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: slotEntity.isSelected ? AppColors.primaryMain : AppColors.transparent,
          border: Border.all(color: slotEntity.isSelected ? AppColors.primaryMain : AppColors.backgroundGrey800),
          borderRadius:
          const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: MyInkWell(
        onTap: () {
          onSlotTapped(index, slotEntity);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildSlotTime(),
        ),
      ),
    );
  }

  Widget buildSlotTime() {
    return Center(child: Text(slotEntity.startTime!.getFormattedDateTime(StringUtils.timeFormatHMA), style: Get.textTheme.bodyText2?.copyWith(fontSize: Dimens.font_12,
    color: slotEntity.isSelected ? AppColors.backgroundWhite : AppColors.textColor)));
  }
}
