import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/available_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AvailabilityTile extends StatelessWidget {
  final Function(int screenRowIndex, Slot slot) onStartTimeTap;
  final Function(int screenRowIndex, Slot slot) onEndTimeTap;
  final Slot slot;
  final int screenRowIndex;
  final Function(int) onDeleteTap;
  const AvailabilityTile(this.slot, this.onStartTimeTap, this.onEndTimeTap,
      this.screenRowIndex, this.onDeleteTap,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
      child: Row(
        children: [
          buildTimePick('start_time'.tr, onStartTimeTap, slot.startTime ?? ''),
          const SizedBox(width: Dimens.margin_24),
          buildTimePick('end_time'.tr, onEndTimeTap, slot.endTime ?? ''),
          const SizedBox(width: Dimens.margin_28),
          screenRowIndex != 0
              ? MyInkWell(
                  onTap: () {
                    onDeleteTap(screenRowIndex);
                  },
                  child: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.backgroundGrey800,
                    size: Dimens.iconSize_16,
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget buildTimePick(
      String title, Function(int screenRowIndex, Slot slot) onTimeTap, time) {
    String newTime = getTime(time);
    return MyInkWell(
      onTap: () {
        onTimeTap(screenRowIndex, slot);
      },
      child: Container(
        height: Dimens.etHeight_48,
        width: Dimens.etWidth_140,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(Icons.schedule, color: Get.theme.iconColorNormal),
              const SizedBox(width: Dimens.padding_12),
              Text(newTime.isEmpty ? title : newTime,
                  style: Get.textTheme.bodyText1?.copyWith(
                      color: Get.context!.theme.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  String getTime(String time) {
    if (time.isNotEmpty) {
      DateTime tempDate =
          DateFormat(StringUtils.dateTimeFormatYMDhMS).parse(time);
      String date = DateFormat(StringUtils.timeFormatHMA).format(tempDate);
      return date;
    }
    return "";
  }
}
