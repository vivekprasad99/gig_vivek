import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/mark_attendance_bottom_sheet/widget/mark_attendance_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

void attendanceSucessfullBottomSheet(
    BuildContext context, String date, Function() onStartWorkTap) {
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
        return AttendanceSucesfullBottomSheet(date, onStartWorkTap);
      });
}

class AttendanceSucesfullBottomSheet extends StatelessWidget {
  final String? dateInUtC;
  final Function() onStartWorkTap;

  const AttendanceSucesfullBottomSheet(this.dateInUtC, this.onStartWorkTap,
      {Key? key})
      : super(key: key);

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
          CircleAvatar(
            radius: Dimens.padding_40,
            backgroundColor: AppColors.success100,
            child: SvgPicture.asset(
              'assets/images/verify.svg',
            ),
          ),
          const SizedBox(height: Dimens.margin_8),
          Text(
            'attendance_marked'.tr,
            style: Get.context?.textTheme.titleLarge?.copyWith(
              color: AppColors.black,
            ),
          ),
          Text(
            'successfully'.tr,
            style: Get.context?.textTheme.titleLarge?.copyWith(
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: Dimens.margin_8),
          showTimeAndDateWidget(),
          const SizedBox(height: Dimens.margin_12),
          showWorkButton(),
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
          onStartWorkTap();
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

  Widget showTimeAndDateWidget()
  {
    DateTime? punchInTime = dateInUtC?.getDateTimeObjectFromStrDateTime(
        StringUtils.dateTimeFormatYMDTHMSS,
        isUTC: false);
    DateTime punchInInIst =
    punchInTime!.add(const Duration(hours: 5, minutes: 30));
    String time = DateFormat(StringUtils.timeFormatHMA).format(punchInInIst);
    String date =
        "${punchInInIst.day} ${DateFormat.MMM().format(punchInInIst)} ${punchInInIst.year}";
    return Text(
      '$time | $date',
      style: Get.context?.textTheme.bodyMedium?.copyWith(
        color: AppColors.black,
      ),
    );
  }

  Widget showWorkButton()
  {
    return RaisedRectButton(
      text: 'start_work'.tr,
      borderColor: AppColors.backgroundGrey400,
      onPressed: () {
        onStartWorkTap();
      },
    );
  }
}
