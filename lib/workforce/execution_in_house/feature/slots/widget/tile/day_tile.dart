import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DayTile extends StatelessWidget {
  final int index;
  final DaySlotsEntity daySlotsEntity;
  final Function(int index, DaySlotsEntity daySlotsEntity) onDayTapped;

  const DayTile(
      {Key? key,
      required this.index,
      required this.daySlotsEntity,
      required this.onDayTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onDayTapped(index, daySlotsEntity);
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  buildSlotsCount(),
                  const SizedBox(height: Dimens.padding_16),
                  buildDayOfMonth(),
                  const SizedBox(height: Dimens.padding_16),
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
    int count = daySlotsEntity.morningSlots.length + daySlotsEntity.noonSlots.length + daySlotsEntity.eveningSlots.length;
    return Text('$count slots', style: Get.textTheme.bodyText2);
  }

  Widget buildDayOfMonth() {
    return Text(daySlotsEntity.date.getPrettyMonthDay(), style: Get.textTheme.headline4);
  }

  Widget buildDayOfWeek() {
    return Text(daySlotsEntity.date.getPrettyWeekDay(), style: Get.textTheme.bodyText2);
  }

  Widget buildSelectedDot() {
    if(daySlotsEntity.isSelected) {
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
