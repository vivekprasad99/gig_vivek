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

class EmptySectionWidget extends StatelessWidget {
  final SmallImageWithTextSection smallImageWithTextSection;
  final WorkApplicationEntity workApplicationEntity;

  const EmptySectionWidget(
      this.smallImageWithTextSection, this.workApplicationEntity,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimens.margin_16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildIcon(),
            buildTitleWidget(),
            buildDescriptionWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildIcon() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
      child: Icon(Icons.calendar_today, size: Dimens.iconSize_32),
    );
  }

  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: Text(smallImageWithTextSection.title ?? '',
          style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w500)),
    );
  }

  Widget buildDescriptionWidget() {
    String description = '';
    if(workApplicationEntity.telephonicInterview?.rejectionReason != null) {
      description = '${smallImageWithTextSection.description} as you ${workApplicationEntity.telephonicInterview?.rejectionReason?.toLowerCase()}';
    } else {
      description = smallImageWithTextSection.description ?? '';
    }
    if(!description.isNullOrEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, Dimens.padding_32),
        child: Text(description,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyText2),
      );
    } else {
      return const SizedBox();
    }
  }
}
