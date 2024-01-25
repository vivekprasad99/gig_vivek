import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchesDayTile extends StatelessWidget {
  final int index;
  final DayBatchesEntity dayBatchesEntity;
  final Function(int index, DayBatchesEntity dayBatchesEntity) onDayTapped;

  const BatchesDayTile(
      {Key? key,
      required this.index,
      required this.dayBatchesEntity,
      required this.onDayTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onDayTapped(index, dayBatchesEntity);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(Dimens.margin_8),
            decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                border: Border.all(color: AppColors.primaryMain),
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimens.radius_8))),
            child: Padding(
              padding: const EdgeInsets.all(Dimens.padding_16),
              child: Column(
                children: [
                  buildSlotsCount(),
                  const SizedBox(height: Dimens.padding_8),
                  buildDayOfMonth(),
                  const SizedBox(height: Dimens.padding_8),
                  buildDayOfWeek(),
                ],
              ),
            ),
          ),
          buildSelectedDot(),
        ],
      ),
    );
  }

  Widget buildSlotsCount() {
    int count = dayBatchesEntity.morningBatches.length +
        dayBatchesEntity.noonBatches.length +
        dayBatchesEntity.eveningBatches.length;
    return Text('$count slots', style: Get.textTheme.bodyText2);
  }

  Widget buildDayOfMonth() {
    return Text(dayBatchesEntity.date.getPrettyMonthDay(),
        style: Get.textTheme.headline4);
  }

  Widget buildDayOfWeek() {
    return Text(dayBatchesEntity.date.getPrettyWeekDay(),
        style: Get.textTheme.bodyText2);
  }

  Widget buildSelectedDot() {
    if (dayBatchesEntity.isSelected) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.margin_4),
        height: Dimens.margin_8,
        width: Dimens.margin_8,
        decoration: const BoxDecoration(
            color: AppColors.primaryMain,
            borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_12))),
      );
    } else {
      return const SizedBox(height: Dimens.margin_8);
    }
  }
}
