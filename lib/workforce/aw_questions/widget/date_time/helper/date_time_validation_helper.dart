import 'package:awign/workforce/aw_questions/data/model/configuration/date/date_time_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

class DateTimeValidationHelper {
  static bool validateRange(SubType? subType, String? from, String? to) {
    if (subType == null || from == null || to == null) {
      return false;
    } else if (from.isNullOrEmpty || to.isNullOrEmpty) {
      return false;
    }
    switch (subType) {
      case SubType.date:
        try {
          var dateFormat = DateFormat(StringUtils.dateFormatYMD);
          var fromDate = dateFormat.parse(from);
          var toDate = dateFormat.parse(to);
          return fromDate.isBefore(toDate);
        } catch (e, st) {
          AppLog.e('validateRange : ${e.toString()} \n${st.toString()}');
          return false;
        }
      case SubType.time:
        try {
          var dateFormat = DateFormat(StringUtils.timeFormatHMS);
          var fromDate = dateFormat.parse(from);
          var toDate = dateFormat.parse(to);
          return fromDate.isBefore(toDate);
        } catch (e, st) {
          AppLog.e('validateRange : ${e.toString()} \n${st.toString()}');
          return false;
        }
      case SubType.dateTime:
        String dateTimeFormat = '';
        if (from.contains('T')) {
          // dateTimeFormat = StringUtils.dateTimeFormatYMDTHMSX; // Temp comment on date 15-09-2022
          dateTimeFormat = StringUtils.dateTimeFormatYMDTHMSZ;
        } else if (from.length == StringUtils.dateTimeFormatDMYHMA.length + 1) {
          dateTimeFormat = StringUtils.dateTimeFormatDMYHMA;
        } else if (from.length ==
            StringUtils.dateTimeFormatDMYHMSA.length + 1) {
          dateTimeFormat = StringUtils.dateTimeFormatDMYHMSA;
        }
        try {
          var dateFormat = DateFormat(dateTimeFormat);
          var fromDate = dateFormat.parse(from);
          var toDate = dateFormat.parse(to);
          return fromDate.isBefore(toDate);
        } catch (e, st) {
          AppLog.e('validateRange : ${e.toString()} \n${st.toString()}');
          return false;
        }
    }
    return false;
  }

  static String getInvalidRangeValueError(
      DateTimeConfiguration dateTimeConfiguration) {
    switch (dateTimeConfiguration.subType) {
      case SubType.date:
        return 'invalid_end_date'.tr;
      case SubType.time:
        return 'invalid_end_time'.tr;
      case SubType.dateTime:
        return 'invalid_end_date_time'.tr;
    }
    return '';
  }
}
