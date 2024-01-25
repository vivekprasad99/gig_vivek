import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CaApplicationTile extends StatelessWidget {
  final WorkApplicationEntity workApplicationEntity;
  const CaApplicationTile({Key? key, required this.workApplicationEntity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? date =
        (workApplicationEntity.updatedAt ?? '').getDateWithDDMMMYYYYFormat();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, 0, Dimens.padding_16, Dimens.padding_8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workApplicationEntity.supplyName ?? "",
                    style: Get.context?.textTheme.labelLarge?.copyWith(
                        color: AppColors.backgroundGrey800,
                        fontSize: Dimens.font_14,
                        fontWeight: FontWeight.w400),
                  ),
                  Text(
                    date,
                    style: Get.context?.textTheme.labelLarge?.copyWith(
                        color: AppColors.backgroundGrey800,
                        fontSize: Dimens.font_14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Text(
                workApplicationEntity.workListingTitle ?? "",
                style: Get.context?.textTheme.labelLarge?.copyWith(
                    color: AppColors.backgroundGrey800,
                    fontSize: Dimens.font_14,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
