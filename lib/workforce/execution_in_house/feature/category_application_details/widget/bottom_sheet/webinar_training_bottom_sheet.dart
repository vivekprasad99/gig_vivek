import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void showWebinarTrainingBottomSheet(
    BuildContext context, TrainingData trainingData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.55,
        initialChildSize: 0.55,
        builder: (_, controller) {
          return WebinarTrainingBottomSheetWidget(trainingData);
        },
      );
    },
  );
}

class WebinarTrainingBottomSheetWidget extends StatefulWidget {
  final TrainingData trainingData;
  const WebinarTrainingBottomSheetWidget(this.trainingData, {Key? key})
      : super(key: key);

  @override
  State<WebinarTrainingBottomSheetWidget> createState() =>
      WebinarTrainingBottomSheetWidgetState();
}

class WebinarTrainingBottomSheetWidgetState
    extends State<WebinarTrainingBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTitleText(),
            buildCloseIcon(),
          ],
        ),
        buildStepText('step_1'.tr),
        buildStepInfoWidgets('download_zoom_app'.tr),
        const SizedBox(height: Dimens.padding_16),
        buildStepText('step_2'.tr),
        buildStepInfoWidgets('copy_meeting_id'.tr),
        buildMeetingIDWidget(),
        const SizedBox(height: Dimens.padding_16),
        buildStepText('step_3'.tr),
        buildStepInfoWidgets(''),
        buildPasswordWidget(),
      ],
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text('webinar_training'.tr,
          style: context.textTheme.headline7SemiBold),
    );
  }

  Widget buildStepText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text(text, style: context.textTheme.bodyText2),
    );
  }

  Widget buildStepInfoWidgets(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Row(
        children: [
          Image.asset('assets/images/ic_video.jpg',
              width: Dimens.iconSize_24, height: Dimens.iconSize_24),
          const SizedBox(width: Dimens.padding_8),
          Text(text,
              style: context.textTheme.bodyText2SemiBold
                  ?.copyWith(decoration: TextDecoration.underline)),
        ],
      ),
    );
  }

  Widget buildMeetingIDWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () async {
          await Clipboard.setData(
              ClipboardData(text: widget.trainingData.meetingID!));
          Helper.showInfoToast('copied'.tr);
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(Dimens.radius_4),
          dashPattern: const [6, 6, 6, 6],
          color: AppColors.success400,
          child: ClipRRect(
            child: SizedBox(
              height: Dimens.btnHeight_40,
              child: Center(
                  child: Text(widget.trainingData.meetingID ?? '',
                      style: Get.textTheme.bodyText1Bold
                          ?.copyWith(color: AppColors.primaryMain))),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () async {
          await Clipboard.setData(
              ClipboardData(text: widget.trainingData.meetingPassword!));
          Helper.showInfoToast('copied'.tr);
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(Dimens.radius_4),
          dashPattern: const [6, 6, 6, 6],
          color: AppColors.success400,
          child: ClipRRect(
            child: SizedBox(
              height: Dimens.btnHeight_40,
              child: Center(
                  child: Text(widget.trainingData.meetingPassword ?? '',
                      style: Get.textTheme.bodyText1Bold
                          ?.copyWith(color: AppColors.primaryMain))),
            ),
          ),
        ),
      ),
    );
  }
}
