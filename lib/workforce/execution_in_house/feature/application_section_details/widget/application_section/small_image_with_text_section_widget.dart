import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SmallImageWithTextSectionWidget extends StatelessWidget {
  final SmallImageWithTextSection smallImageWithTextSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onActionTapped;

  const SmallImageWithTextSectionWidget(this.smallImageWithTextSection,
      this.workApplicationEntity, this.onActionTapped,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimens.margin_16),
      decoration: const BoxDecoration(
          color: AppColors.backgroundGrey200,
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildIcon(),
          buildTitleWidget(),
          buildDescriptionWidget(),
          buildButton(context),
        ],
      ),
    );
  }

  Widget buildIcon() {
    if (smallImageWithTextSection.iconResource != null) {
      if (smallImageWithTextSection.iconResource!.contains('.svg')) {
        return Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: SvgPicture.asset(smallImageWithTextSection.iconResource!),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: SizedBox(
            width: Dimens.iconSize_48,
            height: Dimens.iconSize_48,
            child: Image.asset(smallImageWithTextSection.iconResource!),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  Widget buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text(smallImageWithTextSection.title ?? '',
          style:
              Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w500)),
    );
  }

  Widget buildDescriptionWidget() {
    String description = '';
    if (workApplicationEntity.telephonicInterview?.rejectionReason != null) {
      description =
          '${smallImageWithTextSection.description} as you ${workApplicationEntity.telephonicInterview?.rejectionReason?.toLowerCase()}';
    } else {
      description = smallImageWithTextSection.description ?? '';
    }
    if (!description.isNullOrEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        child: Text(description,
            textAlign: TextAlign.center, style: Get.textTheme.bodyText2),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_16),
      child: RaisedRectButton(
        width: MediaQuery.of(context).size.width,
        height: Dimens.btnHeight_40,
        // text:
        //     '${workApplicationEntity.supplyPendingAction?.value.replaceAll("_", " ")}'
        //         .toTitleCase(),
        text: smallImageWithTextSection.actionData?.ctaText ??
            '${workApplicationEntity.supplyPendingAction?.value.replaceAll("_", " ")}'
                .toTitleCase(),
        fontSize: Dimens.font_14,
        onPressed: () {
          onActionTapped(workApplicationEntity,
              workApplicationEntity.pendingAction ?? ActionData());
        },
      ),
    );
  }
}
