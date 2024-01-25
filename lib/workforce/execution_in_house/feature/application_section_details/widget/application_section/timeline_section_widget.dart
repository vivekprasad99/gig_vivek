import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TimelineSectionWidget extends StatelessWidget {
  final TimelineSectionEntity timelineSectionEntity;
  final WorkApplicationEntity workApplicationEntity;
  const TimelineSectionWidget(this.timelineSectionEntity, this.workApplicationEntity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stepsIcon = [];
    List<Widget> stepsDivider = [];
    List<Widget> stepsTitle = [];
    List<Widget> subStepsTitle = [];
    List<Widget> stepsAeroIcon = [];
    int inProgressStepIndex = -1;
    for(int i = 0; i < timelineSectionEntity.timelineSteps!.length; i++) {
      String icon = 'assets/images/pending_step.svg';
      Color textColor = AppColors.backgroundGrey500;
      switch(timelineSectionEntity.timelineSteps![i].status) {
        case SectionStatusEntity.completed:
          icon = 'assets/images/done_step.svg';
          textColor = AppColors.success300;
          break;
        case SectionStatusEntity.inProgress:
          icon = 'assets/images/ongoing_step.svg';
          textColor = AppColors.success300;
          if(timelineSectionEntity.timelineSteps != null && timelineSectionEntity.timelineSteps![i].subSteps != null
            && timelineSectionEntity.timelineSteps![i].subSteps!.isNotEmpty) {
            for(int j = 0; j < timelineSectionEntity.timelineSteps![i].subSteps!.length; j++) {
              subStepsTitle.add(Text(timelineSectionEntity.timelineSteps![i].subSteps![j].stepName ?? '', style: Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundWhite)));
            }
          }
          inProgressStepIndex = i;
          break;
        default:
          inProgressStepIndex = -1;
          break;
      }
      stepsIcon.add(SvgPicture.asset(icon,
        width: Dimens.iconSize_32,
        height: Dimens.iconSize_32,
      ));
      stepsTitle.add(Text(timelineSectionEntity.timelineSteps?[i].stepName ?? '', style: Get.textTheme.bodyText2?.copyWith(color: textColor)));
      stepsAeroIcon.add(Visibility(
        visible: inProgressStepIndex != -1 ? true : false,
        child: const Icon(Icons.arrow_upward, color: AppColors.black),
      ));
    }
    for(int i = 0; i < timelineSectionEntity.timelineSteps!.length - 1; i++) {
      Color dividerColor = AppColors.backgroundGrey500;
      switch(timelineSectionEntity.timelineSteps![i].status) {
        case SectionStatusEntity.completed:
          dividerColor = AppColors.success300;
          break;
        case SectionStatusEntity.inProgress:
          dividerColor = AppColors.backgroundGrey500;
          break;
      }
      stepsDivider.add(Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: HDivider(
              dividerColor: dividerColor,
              dividerThickness: Dimens.dividerHeight_3,
            ),
          )));
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_48, Dimens.padding_24, Dimens.padding_48, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stepsDivider,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_40, Dimens.padding_16, Dimens.padding_40, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stepsIcon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_56, Dimens.padding_16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stepsTitle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_80, Dimens.padding_16, 0),
            child: subStepsTitle.isEmpty ? const SizedBox() : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stepsAeroIcon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, Dimens.padding_88, 0, 0),
            child: subStepsTitle.isEmpty ? const SizedBox() : Container(
              decoration: const BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Dimens.radius_16),
                  bottomRight: Radius.circular(Dimens.radius_16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16, vertical: Dimens.padding_16),
              child: Row(
                children: subStepsTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
