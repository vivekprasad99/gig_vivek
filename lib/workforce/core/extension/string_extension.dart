import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  static final RegExp invalidRegExp = RegExp('([^a-zA-Z0-9-_\\/.])');

  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');

  String getDateWithMonthName() {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var inputDate = inputFormat.parse(this);
    var outputFormat = DateFormat('dd MMMM, yyyy');
    return outputFormat.format(inputDate);
  }

  String getDateWithDDMMMYYYYFormat() {
    var inputDate = DateTime.parse(this);
    var outputFormat = DateFormat(StringUtils.dateFormatDDMMMYYYY);
    return outputFormat.format(inputDate);
  }

  String getFormattedDateTime(String outputFormat,
      {String inputFormat = StringUtils.dateTimeFormatYMDTHMSS}) {
    var inputDateFormat = DateFormat(inputFormat);
    var inputDate = inputDateFormat.parse(this);
    var outputDateFormat = DateFormat(outputFormat);
    return outputDateFormat.format(inputDate);
  }

  String getFormattedDateTime2(String outputFormat) {
    var inputDate = DateTime.parse(this);
    var outputDateFormat = DateFormat(outputFormat);
    return outputDateFormat.format(inputDate);
  }

  String getPrettyMonthDay() {
    try {
      var dateTime = DateTime.parse(this);
      return dateTime.day.toString();
    } catch (e, st) {
      AppLog.e('getPrettyMonthDay : ${e.toString()} \n${st.toString()}');
    }
    return '';
  }

  String getPrettyWeekDay() {
    try {
      var dateTime = DateTime.parse(this);
      var today = DateTime.now();
      var tomorrow = DateTime(today.year, today.month, today.day + 1);
      if (dateTime.day == today.day) {
        return 'today'.tr;
      } else if (dateTime == tomorrow) {
        return 'tomorrow'.tr;
      } else {
        return DateFormat(StringUtils.prettyDateTimeFormatE).format(dateTime);
      }
    } catch (e, st) {
      AppLog.e('getPrettyWeekDay : ${e.toString()} \n${st.toString()}');
    }
    return '';
  }

  String getTodayWeekDay() {
    try {
      var dateTime = DateTime.parse(this);
      return dateTime.day.toString();
    } catch (e, st) {
      AppLog.e('getTodayWeekDay : ${e.toString()} \n${st.toString()}');
    }
    return '';
  }

  String getTommorowWeekDay() {
    try {
      var dateTime = DateTime.parse(this);
      int date = dateTime.day + 1;
      return date.toString();
    } catch (e, st) {
      AppLog.e('getTommorowWeekDay : ${e.toString()} \n${st.toString()}');
    }
    return '';
  }

  String dashAfter3() {
    String temp1 = this;
    String op = '';
    for (int i = 0; i < temp1.length; i++) {
      if (i % 3 == 0 && i != 0 && i + 3 <= temp1.length)
        op += '-' + temp1[i];
      else
        op += temp1[i];
    }
    return op;
  }

  Operator? getOperatorByName() {
    Operator? operator;
    switch (this) {
      case 'eq':
        operator = Operator.equal;
        break;
      case 'not':
        operator = Operator.notEqual;
        break;
      case 'gt':
        operator = Operator.greaterThan;
        break;
      case 'gte':
        operator = Operator.greaterThanEqual;
        break;
      case 'lt':
        operator = Operator.lessThen;
        break;
      case 'lte':
        operator = Operator.lessThenEqual;
        break;
      case 'between':
        operator = Operator.between;
        break;
      case 'contains':
        operator = Operator.contains;
        break;
      case 'not_contains':
        operator = Operator.notContains;
        break;
      case 'starts_with':
        operator = Operator.startsWith;
        break;
      case 'ends_with':
        operator = Operator.endsWith;
        break;
      case 'empty':
        operator = Operator.isEmpty;
        break;
      case 'not_empty':
        operator = Operator.notEmpty;
        break;
      case 'in':
        operator = Operator.IN;
        break;
      case 'not_in':
        operator = Operator.notIn;
        break;
      default:
        operator = null;
    }
    return operator;
  }

  String getFormattedDateTimeFromUTCDateTime(String dateTimeFormat) {
    try {
      var inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      var inputDate = inputFormat.parse(this);
      var outputFormat = DateFormat(dateTimeFormat);
      return outputFormat.format(inputDate);
    } catch (e, st) {
      AppLog.e(
          'getFormattedDateTimeFromUTCDateTime : ${e.toString()} \n${st.toString()}');
      return '';
    }
  }

  String getPrettyIstDateTimeFromUTC() {
    try {
      var inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.sss");
      var inputDate = inputFormat.parse(this);
      var outputFormat = DateFormat(StringUtils.dateTimeFormatYMDHMS);
      return outputFormat.format(inputDate);
    } catch (e, st) {
      AppLog.e(
          'getPrettyIstDateTimeFromUTC : ${e.toString()} \n${st.toString()}');
      return '';
    }
  }

  DateTime? getDateTimeObjectFromUTCDateTime() {
    try {
      var inputFormat = DateFormat(StringUtils.dateTimeFormatYMDHMSZ);
      var inputDate = inputFormat.parse(this, true);
      return inputDate.toLocal();
    } catch (e, st) {
      AppLog.e(
          'getDateTimeObjectFromUTCDateTime : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  DateTime? getDateTimeObjectFromStrDateTime(String strInputFormat,
      {bool isUTC = true}) {
    try {
      var inputFormat = DateFormat(strInputFormat);
      var inputDate = inputFormat.parse(this, isUTC);
      return inputDate;
    } catch (e, st) {
      AppLog.e(
          'getDateTimeObjectFromUTCDateTime : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  DateTime? getDateObjectFromYYYYMMDDHHMMSS() {
    try {
      var inputFormat = DateFormat(StringUtils.dateTimeFormatYMDHMS);
      var inputDate = inputFormat.parse(this, true);
      return inputDate;
    } catch (e, st) {
      AppLog.e(
          'getDateObjectFromYYYYMMDDHHMMSS : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  String cleanForUrl() {
    return replaceAll(invalidRegExp, "-");
  }

  int getNoOfDays(String dateTimeFormat) {
    DateTime inputDate =
        DateFormat(StringUtils.dateTimeFormatYMDhMS).parse(dateTimeFormat);
    DateTime dt = DateTime.now();
    Duration diff = dt.difference(inputDate);
    return diff.inDays;
  }

  String parseDateToYMD({String fromFormat = "yyyy-MM-ddTHH:mm"}) {
    final DateFormat inputFormat = DateFormat(fromFormat);
    final DateTime dateTime = inputFormat.parse(this);
    final DateFormat outputFormat = DateFormat(StringUtils.dateFormatYMD);
    return outputFormat.format(dateTime);
  }

  String parseDateToMonthAndYear({String fromFormat = "yyy-MM-dd hh:mm:ss"}) {
    final DateFormat inputFormat = DateFormat(fromFormat);
    final DateTime dateTime = inputFormat.parse(this);
    return "${DateFormat.MMM().format(dateTime)} ${dateTime.year}";
  }

  String convertTimeToAMPM() {
    final DateFormat inputFormat = DateFormat(StringUtils.timeFormatHMS);
    final DateFormat outputFormat = DateFormat(StringUtils.timeFormatHMA);
    final DateTime time = inputFormat.parse(this);
    final String formattedTime = outputFormat.format(time);
    return formattedTime;
  }
}

extension IsNullOrEmpty on String? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }
}
