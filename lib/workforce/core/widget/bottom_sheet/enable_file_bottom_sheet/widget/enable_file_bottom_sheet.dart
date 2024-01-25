import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../theme/theme_manager.dart';

void showEnableFileBottomSheet(BuildContext context,Function() onOpenTap,Function() onCancelTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return EnableFileBottomSheet(onOpenTap,onCancelTap);
    },
  );
}

class EnableFileBottomSheet extends StatelessWidget {
  final Function() onOpenTap;
  final Function() onCancelTap;
  const EnableFileBottomSheet(this.onOpenTap,this.onCancelTap,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCloseButton(),
              buildEnableText(),
              const SizedBox(height: Dimens.margin_16),
              buildCameraImage(),
            ],
          ),
        ),
        Positioned(
            left: MediaQuery.sizeOf(context).width * 0.40,
            top: MediaQuery.sizeOf(context).width * 0.35,
            child: CircleAvatar(
                backgroundColor: AppColors.link100,
                radius: Dimens.padding_40,
                child: SvgPicture.asset('assets/images/gallery.svg'))),
        buildAccessCameraText(),
      ],
    );
  }

  Widget buildCloseButton()
  {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          onCancelTap();
        },
        child: const CircleAvatar(
          backgroundColor: AppColors.backgroundGrey700,
          radius: Dimens.padding_12,
          child: Icon(
            Icons.close,
            color: AppColors.backgroundWhite,
            size: Dimens.padding_16,
          ),
        ),
      ),
    );
  }

  Widget buildEnableText()
  {
    return Text(
      'please_enable_access_to_your_files'.tr,
      textAlign: TextAlign.center,
      style: Get.context?.textTheme.titleLarge?.copyWith(
        color: AppColors.black,
      ),
    );
  }

  Widget buildAccessCameraText()
  {
    return Positioned(
      top: MediaQuery.sizeOf(Get.context!).width * 0.6,
      width: MediaQuery.sizeOf(Get.context!).width * 1,
      height: MediaQuery.sizeOf(Get.context!).width * 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_20),
            child: Text(
              'please_access_photos'.tr,
              textAlign: TextAlign.center,
              style: Get.context?.textTheme.bodyMedium?.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: Dimens.margin_16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.font_28),
            child: RaisedRectButton(
              text: 'open_settings'.tr,
              borderColor: AppColors.backgroundGrey400,
              onPressed: () {
                onOpenTap();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildCameraImage()
  {
    return SvgPicture.asset(
      'assets/images/Images_file.svg',
    );
  }
}
