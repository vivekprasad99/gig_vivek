import 'package:awign/workforce/aw_questions/data/model/configuration/date/date_time_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/custom_time_picker/custom_time_picker.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

class DateTimeConfigurationHelper {
  static Widget getIcon(SubType? subType) {
    switch (subType) {
      case SubType.time:
        return SvgPicture.asset(
          'assets/images/ic_calendar.svg',
          color: Get.theme.iconColorNormal,
          width: Dimens.iconSize_24,
          height: Dimens.iconSize_24,
        );
      case SubType.date:
      case SubType.dateTime:
        return SvgPicture.asset(
          'assets/images/ic_calendar.svg',
          color: Get.theme.iconColorNormal,
          width: Dimens.iconSize_24,
          height: Dimens.iconSize_24,
        );
      default:
        return const SizedBox();
    }
  }

  static String getHintTextForDateTimeRange(SubType? subType, bool isStart) {
    switch (subType) {
      case SubType.time:
        return isStart ? 'start_time'.tr : 'end_time'.tr;
      case SubType.date:
        return isStart ? 'start_date'.tr : 'end_date'.tr;
      case SubType.dateTime:
        return isStart ? 'from'.tr : 'to'.tr;
      default:
        return '';
    }
  }

  static void showPicker(
      BuildContext context,
      DateTimeConfiguration dateTimeConfiguration,
      String? selectedDateTime,
      Function(String? strDateTime) onSelect,
      {bool isDOBPicker = false}) async {
    try {
      switch (dateTimeConfiguration.subType) {
        case SubType.date:
          DateTime? pickedDate =
              await showDatePickerDialog(context, isDOBPicker: isDOBPicker);
          if (pickedDate != null) {
            var outputFormat = DateFormat(StringUtils.dateFormatYMD);
            onSelect(outputFormat.format(pickedDate));
          }
          break;
        case SubType.time:
          showTimePickerDialog(context, (pickedTime) {
            if (pickedTime != null) {
              onSelect(
                  '${pickedTime.hour}:${pickedTime.minute}:${pickedTime.second}');
            }
          });
          break;
        case SubType.dateTime:
          DateTime? pickedDate = await showDatePickerDialog(context);
          if (pickedDate != null) {
            showTimePickerDialog(context, (pickedTime) {
              if (pickedTime != null) {
                DateTime updatedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                    pickedTime.second);
                var outputFormat =
                    DateFormat(StringUtils.dateTimeFormatDMYHMSA);
                onSelect(outputFormat.format(updatedDateTime));
              }
            });
          }
          break;
        default:
      }
    } catch (e, st) {
      AppLog.e('showPicker : ${e.toString()} \n${st.toString()}');
    }
  }

  static Future<DateTime?> showDatePickerDialog(BuildContext context,
      {bool isDOBPicker = false}) async {
    if (isDOBPicker) {
      DateTime today = DateTime.now();
      final DateTime eighteenY =
          DateTime(today.year - 18, today.month, today.day);
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: eighteenY, // Refer step 1
        firstDate: DateTime(1950),
        lastDate: eighteenY,
      );
      if (pickedDate != null) {
        return pickedDate;
      } else {
        return null;
      }
    } else {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // Refer step 1
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (pickedDate != null) {
        return pickedDate;
      } else {
        return null;
      }
    }
  }

  static Future<DateTime?> showTimePickerDialog(
      BuildContext context, Function(DateTime?) onSelectTime) async {
    showCustomTimePickerDialog(context, (pickedDateTime) {
      if (pickedDateTime != null) {
        onSelectTime(pickedDateTime);
      } else {
        onSelectTime(null);
      }
    });
  }
}
