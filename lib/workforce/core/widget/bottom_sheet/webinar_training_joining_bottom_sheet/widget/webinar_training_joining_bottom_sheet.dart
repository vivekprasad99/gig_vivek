import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/webinar_training.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void webinarTrainingJoiningBottomSheet(
    BuildContext context,WebinarTraining? webinarTraining) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return  WebinarTrainingJoiningBottomSheet(webinarTraining);
      });
}

class WebinarTrainingJoiningBottomSheet extends StatelessWidget {
  final WebinarTraining? webinarTraining;
  const WebinarTrainingJoiningBottomSheet(this.webinarTraining,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_48,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'webinar_training'.tr,
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.black, fontSize: Dimens.font_16),
          ),
          const SizedBox(height: Dimens.margin_16),
          buildStepNoWidget('step_1'.tr),
          const SizedBox(height: Dimens.margin_16),
          buildStepWidget('download_zoom_app'.tr),
          const SizedBox(height: Dimens.margin_16),
          buildStepNoWidget('step_2'.tr),
          const SizedBox(height: Dimens.margin_16),
          buildStepWidget('copy_meeting_id'.tr),
          const SizedBox(height: Dimens.margin_16),
          buildMeetingId(webinarTraining?.meetingId),
          const SizedBox(height: Dimens.margin_16),
          buildStepNoWidget('step_3'.tr),
          const SizedBox(height: Dimens.margin_16),
          buildStepWidget('copy_meeting_password'.tr),
          const SizedBox(height: Dimens.margin_16),
          buildMeetingId(webinarTraining?.meetingPassword),
        ],
      ),
    );
  }

  Widget buildStepNoWidget(String step)
  {
    return Text(
      step,
      style: Get.context?.textTheme.titleLarge?.copyWith(
          color: AppColors.backgroundGrey800, fontSize: Dimens.font_12),
    );
  }

  Widget buildStepWidget(String stepName)
  {
    return Row(
      children: [
        Image.asset('assets/images/ic_vedio.jpg',height: 28,),
        const SizedBox(width: Dimens.margin_16),
        Text(
          stepName,
          style: Get.context?.textTheme.titleLarge?.copyWith(
              color: AppColors.black, fontSize: Dimens.font_14),
        ),
      ],
    );
  }

  Widget buildMeetingId(String? meetingId)
  {
    return SizedBox(
      width: double.infinity,
      child: DottedBorder(
        color: AppColors.success300,
        strokeWidth: 2,
        child: MyInkWell(
          onTap: (){
            final value = ClipboardData(text: meetingId!);
            Clipboard.setData(value);
            Helper.showInfoToast('text_copied'.tr);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            child: Center(
              child: Text(
                "$meetingId",
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryMain, fontSize: Dimens.font_18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
