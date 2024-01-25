import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/attendance_sucessfull_bottom_sheet/widget/attendance_sucessfull_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class AttendanceTile extends StatelessWidget {
  final AttendancePunches? attendancePunches;
  final Function(bool punchStatus, String attendanceId) onPunchTap;
  final bool isComingFromOffice;
  const AttendanceTile(this.attendancePunches, this.onPunchTap,this.isComingFromOffice, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:
      (attendancePunches?.nextPunchCta != null) &&
          (attendancePunches?.nextPunchCta != Constants.punchedIn) && (attendancePunches?.nextPunchCta != Constants.punchedOut) && (attendancePunches?.nextPunchCta != Constants.punchInNotStarted) && (attendancePunches?.nextPunchCta != Constants.punchOutNotStarted),
      child: Card(
        color: attendancePunches?.nextPunchCta == Constants.punchOut || attendancePunches?.nextPunchCta == Constants.punchOutTimePassed
            ? AppColors.backgroundViolet
            : AppColors.backgroundYellow,
        margin: const EdgeInsets.fromLTRB(Dimens.margin_8, Dimens.margin_16,
            Dimens.margin_8, Dimens.margin_16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return buildAttendanceCard();
  }

  Widget buildAttendanceCard() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              'assets/images/background_circle.png',
            )),
        Positioned(
          bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/${attendancePunches?.nextPunchCta == Constants.punchOut || attendancePunches?.nextPunchCta == Constants.punchOutTimePassed ? 'Maze_purple.png': 'Maze_yellow.png'}',
              width: Dimens.margin_120,
            )),
        showWidgetBasedonNextPunchCtaCondition(),
      ],
    );
  }

  Widget showWidgetBasedonNextPunchCtaCondition()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
          Dimens.margin_20, Dimens.margin_16, Dimens.margin_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('mark_attendance'.tr,
              style: Get.context?.textTheme.bodyText1Medium?.copyWith(
                  color: attendancePunches?.nextPunchCta ==
                      Constants.punchOut || attendancePunches?.nextPunchCta == Constants.punchOutTimePassed
                      ? AppColors.backgroundYellow
                      : AppColors.backgroundBlack,fontWeight: FontWeight.bold)),
          const SizedBox(height: Dimens.margin_8),
          Visibility(
            visible: isComingFromOffice,
            child: Text(attendancePunches?.attendanceConfiguration?.projectName ?? "",
                style: Get.context?.textTheme.bodyText1Bold?.copyWith(
                    color: attendancePunches?.nextPunchCta ==
                        Constants.punchOut || attendancePunches?.nextPunchCta == Constants.punchOutTimePassed
                        ? AppColors.backgroundYellow
                        : AppColors.backgroundBlack)),
          ),
          const SizedBox(height: Dimens.margin_8),
          if (attendancePunches?.nextPunchCta ==
              Constants.punchInTimePassed) ...[
            Text('you_have_missed_to_punch_in_today'.tr,
                style: Get.context?.textTheme.bodyText1Medium
                    ?.copyWith(color: AppColors.googleRed)),
            const SizedBox(height: Dimens.margin_24),
            Text('contact_your_manager'.tr,
                style: Get.context?.textTheme.bodyText1Medium
                    ?.copyWith(color: AppColors.backgroundBlack)),
          ] else if (attendancePunches?.nextPunchCta ==
              Constants.punchOutTimePassed) ...[
            Text('you_have_missed_to_punch_out_today'.tr,
                style: Get.context?.textTheme.bodyText1Medium
                    ?.copyWith(color: AppColors.backgroundWhite)),
            const SizedBox(height: Dimens.margin_24),
            Text('contact_your_manager'.tr,
                style: Get.context?.textTheme.bodyText1Medium
                    ?.copyWith(color: AppColors.backgroundWhite)),
          ] else if (attendancePunches?.nextPunchCta ==
              Constants.punchOut) ...[
            totalHoursWidget(),
          ] else ...[
            if (attendancePunches!.attendanceConfiguration!
                .punchesConfiguration!.isNotEmpty) ...[
              for (int i = 0;
              i <
                  attendancePunches!.attendanceConfiguration!
                      .punchesConfiguration!.length;
              i++) ...[
                if (attendancePunches!.attendanceConfiguration!
                    .punchesConfiguration![i].punchType ==
                    Constants.punchIn) ...[
                  Text(
                      '${'time_limit'.tr} ${attendancePunches!.attendanceConfiguration!.punchesConfiguration![i].minTime?.convertTimeToAMPM()} to ${attendancePunches!.attendanceConfiguration!.punchesConfiguration![i].maxTime?.convertTimeToAMPM()}',
                      style: Get.context?.textTheme.bodyText1Medium
                          ?.copyWith(color: AppColors.backgroundBlack)),
                ]
              ],
            ],
            const SizedBox(height: Dimens.margin_24),
            RaisedRectButton(
              height: Dimens.margin_40,
              width: Dimens.btnWidth_100,
              text: 'punch_in'.tr,
              onPressed: () {
                onPunchTap(true, attendancePunches!.sId!);
              },
              backgroundColor: AppColors.backgroundBlack,
            ),
          ],
        ],
      ),
    );
  }

  Widget totalHoursWidget() {
    DateTime? punchInTime = attendancePunches?.punchInTime
        ?.getDateTimeObjectFromStrDateTime(StringUtils.dateTimeFormatYMDTHMSS,
            isUTC: false);
    DateTime punchInInIst = punchInTime!.add(const Duration(hours: 5, minutes: 30));
    String? strRemainingTime = StringUtils.calculateTimeDifferenceBetween(punchInInIst,
        DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${'total_work_hour'.tr} ${strRemainingTime ?? '00 minutes'}',
            style: Get.context?.textTheme.bodyText1Medium
                ?.copyWith(color: AppColors.backgroundYellow)),
        const SizedBox(height: Dimens.margin_24),
        RaisedRectButton(
          height: Dimens.margin_40,
          width: Dimens.btnWidth_128,
          text: 'punch_out'.tr,
          onPressed: () {
            onPunchTap(false, attendancePunches!.sId!);
          },
          backgroundColor: AppColors.backgroundBlack,
        ),
      ],
    );
  }
}
