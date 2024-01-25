import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchTile extends StatelessWidget {
  final int index;
  final BatchEntity batchEntity;
  final Function(int index, BatchEntity batchEntity) onBatchTapped;

  const BatchTile(
      {Key? key,
      required this.index,
      required this.batchEntity,
      required this.onBatchTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: batchEntity.isSelected
              ? AppColors.primaryMain
              : AppColors.transparent,
          border: Border.all(
              color: batchEntity.isSelected
                  ? AppColors.primaryMain
                  : AppColors.backgroundGrey800),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: MyInkWell(
        onTap: () {
          onBatchTapped(index, batchEntity);
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBatchName(),
              const SizedBox(height: Dimens.padding_4),
              buildBatchTime(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBatchName() {
    return Text(batchEntity.batchName ?? '',
        style: Get.textTheme.bodyText2?.copyWith(
            fontSize: Dimens.font_12,
            color: batchEntity.isSelected
                ? AppColors.backgroundWhite
                : AppColors.textColor));
  }

  Widget buildBatchTime() {
    return Text(
        '${batchEntity.startTime!.getFormattedDateTime(StringUtils.timeFormatHMA)} - ${batchEntity.endTime!.getFormattedDateTime(StringUtils.timeFormatHMA)}',
        style: Get.textTheme.headline5?.copyWith(
            fontSize: Dimens.font_12,
            color: batchEntity.isSelected
                ? AppColors.backgroundWhite
                : AppColors.textColor));
  }
}
