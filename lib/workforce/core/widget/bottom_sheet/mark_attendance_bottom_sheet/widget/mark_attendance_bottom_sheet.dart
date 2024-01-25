import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../buttons/my_ink_well.dart';

void markAttendanceBottomSheet(
    BuildContext context, Function() onPunchInTap,Function() onLaterTap) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return  MarkAttendanceBottomSheet(onPunchInTap,onLaterTap);
      });
}

class MarkAttendanceBottomSheet extends StatelessWidget {
  final Function() onPunchInTap;
  final Function() onLaterTap;
  const MarkAttendanceBottomSheet(this.onPunchInTap,this.onLaterTap,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_16,
        Dimens.padding_16,
        Dimens.padding_40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          closeButton(),
          const SizedBox(height: Dimens.margin_8),
          SvgPicture.asset('assets/images/mark_attendance.svg'),
          const SizedBox(height: Dimens.margin_16),
          Text('mark_attendance'.tr,
              style: Get.context?.textTheme.bodyText1SemiBold?.copyWith(
                  color: AppColors.backgroundBlack, fontSize: Dimens.font_18)),
          const SizedBox(height: Dimens.margin_8),
          markAttendanceTest(),
          const SizedBox(height: Dimens.margin_16),
          buildPunchInButton(),
          const SizedBox(height: Dimens.margin_16),
          doItLaterButton(),
        ],
      ),
    );
  }

  Widget closeButton()
  {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          onLaterTap();
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

  Widget markAttendanceTest()
  {
    return Text(
      'kindly_mark_your_attendance'.tr,
      textAlign: TextAlign.center,
      style: Get.context?.textTheme.bodyLarge?.copyWith(
        color: AppColors.black,
      ),
    );
  }

  Widget doItLaterButton()
  {
    return CustomTextButton(
      text: 'do_it_later'.tr,
      backgroundColor: AppColors.transparent,
      borderColor: AppColors.transparent,
      textColor: AppColors.backgroundBlack,
      onPressed: () {
        onLaterTap();
      },
    );
  }

  Widget buildPunchInButton()
  {
    return RaisedRectButton(
      text: 'punch_in'.tr,
      width: MediaQuery.of(Get.context!).size.width * 0.8,
      backgroundColor: AppColors.backgroundBlack,
      onPressed: () {
        onPunchInTap();
      },
    );
  }
}
