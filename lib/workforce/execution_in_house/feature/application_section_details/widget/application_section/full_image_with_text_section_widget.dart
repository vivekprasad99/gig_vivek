import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FullImageWithTextSectionWidget extends StatelessWidget {
  final LargeImageWithTextSection largeImageWithTextSection;
  final WorkApplicationEntity workApplicationEntity;

  const FullImageWithTextSectionWidget(
      this.largeImageWithTextSection, this.workApplicationEntity,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimens.margin_16),
      decoration: const BoxDecoration(
          color: AppColors.backgroundGrey800,
          borderRadius:
          BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                buildTitleWidget(),
                buildDescriptionWidget(),
              ],
            ),
          ),
          buildIcon(),
        ],
      ),
    );
  }

  Widget buildIcon() {
    if(largeImageWithTextSection.iconResource != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_8, Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
        child: Image.asset(largeImageWithTextSection.iconResource!),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_8, 0),
      child: Text(largeImageWithTextSection.title ?? '',
          style: Get.textTheme.bodyText1?.copyWith(color: AppColors.backgroundWhite, fontWeight: FontWeight.w500)),
    );
  }

  Widget buildDescriptionWidget() {
    String description = '';
    if(workApplicationEntity.telephonicInterview?.rejectionReason != null) {
      description = '${largeImageWithTextSection.description} as you ${workApplicationEntity.telephonicInterview?.rejectionReason?.toLowerCase()}';
    } else {
      description = largeImageWithTextSection.description ?? '';
    }
    if(!description.isNullOrEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_8, Dimens.padding_16),
        child: Text(description,
            // textAlign: TextAlign.center,
            style: Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundWhite)),
      );
    } else {
      return const SizedBox();
    }
  }
}
