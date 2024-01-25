import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/theme_manager.dart';

void webinarTrainingBottomSheet(
    BuildContext context,Function() onDoLaterTap) {
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
        return WebinarTrainingBottomSheet(onDoLaterTap);
      });
}


class WebinarTrainingBottomSheet extends StatelessWidget {
  final Function() onDoLaterTap;
  const WebinarTrainingBottomSheet(this.onDoLaterTap,{Key? key}) : super(key: key);

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
        children: [
          Text(
            'download_file_text'.tr,
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.black, fontSize: Dimens.font_16),
          ),
          const SizedBox(height: Dimens.margin_16),
          buildDownloadFileButton(),
          const SizedBox(height: Dimens.margin_8),
          buildDoLaterButton(),
        ],
      ),
    );
  }

  Widget buildDownloadFileButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: RaisedRectButton(
        backgroundColor: AppColors.primaryMain,
        icon: const Icon(Icons.download,
            color: AppColors.backgroundWhite, size: Dimens.iconSize_20),
        text: 'Download File',
        textColor: AppColors.backgroundWhite,
        onPressed: () {
          MRouter.pop(null);
          Helper.showInfoToast('Coming soon...');
        },
      ),
    );
  }

  Widget buildDoLaterButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      child: RaisedRectButton(
        backgroundColor: AppColors.backgroundWhite,
        borderColor: AppColors.black,
        text: 'Do Later',
        textColor: AppColors.black,
        onPressed: () {
          MRouter.pop(null);
        },
      ),
    );
  }
}

