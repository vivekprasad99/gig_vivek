import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:intl/intl.dart';

class StringUtils {
  static const String dateTimeFormatDMYHMSA = "dd-MM-yyyy hh:mm:ss a";
  static const String dateTimeFormatYMDHM = "yyyy-MM-dd HH:mm";
  static const String dateTimeFormatYMDHMS = "yyyy-MM-dd HH:mm:ss";
  static const String dateTimeFormatYMDHMSA = "yyyy-MM-dd hh:mm:ss a";
  static const String dateTimeFormatDMYHMA = "dd-MM-yyyy hh:mm a";
  static const String dateTimeFormatYMDTHMSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
  static const String dateTimeFormatYMDTHMSX = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX";
  static const String dateTimeFormatYMDTHMSS = "yyyy-MM-dd'T'HH:mm:ss.sss";
  static const String dateTimeFormatYMDHMSZ = "yyyy-MM-dd HH:mm:ss Z";
  static const String dateTimeFormatEDMY = "EEEE, dd MMM, yyyy";
  static const String dateTimeFormatDMHMA = "dd MMMM, hh:mm a";
  static const String dateTimeFormatYMDhMS = "yyyy-MM-dd hh:mm:ss";

  static const String dateFormatYMD = "yyyy-MM-dd";
  static const String dateFormatDMY = "dd-MM-yyyy";
  static const String dateFormatDMYS = "dd/MM/yyyy";
  static const String dateFormatMY = "MMM yyyy";
  static const String dateFormatDDMMMYYYY = "dd MMM, yyyy";
  static const String dateFormatDDMMMMYYYY = "dd MMMM, yyyy";

  static const String timeFormatHMS = "HH:mm:ss";
  static const String timeFormatHM = "HH:mm";
  static const String timeFormatMS = "mm:ss";
  static const String timeFormatHMA = "hh:mm a";

  static const String prettyDateTimeFormatE = "EEEE";

  static String getIndianFormatNumber(number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }

  static String convertDigitsToString(int n) => n.toString().padLeft(2, '0');

  static String maskString(String? input, int fromStart, int fromEnd) {
    String result = "";
    if (input != null) {
      int length = input.length;
      if (fromStart > length) {
        fromStart = length;
      }
      String openStart = input.substring(0, fromStart);

      int endStartIndex = length - fromEnd;
      if (endStartIndex < fromStart) {
        endStartIndex = fromStart;
      }
      String openEnd = input.substring(endStartIndex, length);

      int rem = length - (openStart.length + openEnd.length);
      result += openStart;
      for (int i = 0; i < rem; i++) {
        result += "x";
      }
      result += openEnd;
    }
    return result;
  }

  static String getFormattedDateTime(String outputFormat,
      {DateTime? inputDateTime}) {
    inputDateTime ??= DateTime.now();
    var outputDateFormat = DateFormat(outputFormat);
    return outputDateFormat.format(inputDateTime);
  }

  static String getCurrentDateTimeWithIST() {
    final now = DateTime.now();
    final indianTimeZoneOffset = Duration(hours: 5, minutes: 30);
    final indianTime = now.toUtc().add(indianTimeZoneOffset);

    final formatter = DateFormat(dateTimeFormatYMDHMS);
    final formattedDateTime = formatter.format(indianTime);
    const timeZoneAbbreviation = 'IST';
    return '$formattedDateTime $timeZoneAbbreviation';
  }

  static String? getDateTimeInYYYYMMDDHHMMSSFormat(DateTime dateTime) {
    try {
      var inputFormat = DateFormat(StringUtils.dateTimeFormatYMDHMS);
      var inputDate = inputFormat.format(dateTime);
      return inputDate;
    } catch (e, st) {
      AppLog.e(
          'getDateTimeInYYYYMMDDHHMMSSFormat : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getMonth(DateTime dateTime) {
    try {
      return DateFormat.MMMM().format(dateTime);
    } catch (e, st) {
      AppLog.e('getMonth : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getWeekDay(DateTime dateTime) {
    try {
      return DateFormat('EEEE').format(dateTime);
    } catch (e, st) {
      AppLog.e('getMonth : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getNextWeekDay(DateTime dateTime) {
    try {
      return DateFormat('EEEE').format(dateTime);
    } catch (e, st) {
      AppLog.e('getMonth : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getTimeInLocalFromUtc(String time) {
    try {
      if (time.isNotEmpty) {
        DateTime inputDate = DateFormat(dateTimeFormatYMDhMS).parse(time, true);
        return DateFormat(timeFormatHMA).format(inputDate.toLocal());
      }
      return "";
    } catch (e, st) {
      AppLog.e('getTimeInLocalFromUtc : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getDateInLocalFromUtc(String time) {
    try {
      if (time.isNotEmpty) {
        DateTime inputDate = DateFormat(dateTimeFormatYMDhMS).parse(time, true);
        return DateFormat("dd MMM yyyy").format(inputDate.toLocal());
      }
      return "";
    } catch (e, st) {
      AppLog.e('getDateInLocalFromUtc : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static bool compareWithCurrDate(String strDate) {
    try {
      var dateTime = DateTime.parse(strDate);
      var today = DateTime.now();
      if (dateTime.microsecondsSinceEpoch < today.microsecondsSinceEpoch) {
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      AppLog.e('compareWithCurrDate : ${e.toString()} \n${st.toString()}');
      return false;
    }
  }

  static String? calculateTimeDifferenceBetween(
      DateTime startDate, DateTime endDate) {
    int seconds1 = endDate.difference(startDate).inSeconds;
    String str = '';
    if (seconds1 < 60) {
      str = '$seconds1 second';
    } else if (seconds1 >= 60 && seconds1 < 3600) {
      str = '${startDate.difference(endDate).inMinutes.abs()} minute';
    } else if (seconds1 >= 3600 && seconds1 < 86400) {
      str = '${startDate.difference(endDate).inHours} hour';
    } else {
      str = '${startDate.difference(endDate).inDays} day';
    }
    AppLog.e("Time 1: $str");
    // DateTime a = DateTime(2022, 3, 29, 4, 56);
    // DateTime b = DateTime.now();

    // Duration difference = b.difference(a);
    Duration difference = endDate.difference(startDate);
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;
    if (days > 0) {
      if (days > 1) {
        return '$days days';
      } else {
        return '$days day';
      }
    } else if (hours > 0) {
      return '$hours hours $minutes minutes';
    } else if (minutes > 0) {
      return '$minutes minutes';
    } else {
      return null;
    }
  }

  static String? getNoOfDaysLeftInMonth() {
    try {
      DateTime now = DateTime.now();
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      int noOfDayLeftInMonth = lastDayOfMonth.day - now.day;
      return noOfDayLeftInMonth.toString();
    } catch (e, st) {
      AppLog.e('getNoOfDaysLeftInMonth : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getMonthAndYear() {
    try {
      DateTime now = DateTime.now();
      return "${DateFormat.MMM().format(now)} ${now.year}";
    } catch (e, st) {
      AppLog.e('getMonthAndYear : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static String? getDayMonthAndYear(String date) {
    try {
      DateTime tempDate =  DateFormat("yyyy-MM-dd").parse(date);
      return "${tempDate.day} ${DateFormat.MMM().format(tempDate)} ${tempDate.year}";
    } catch (e, st) {
      AppLog.e('getDayMonthAndYear : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }

  static Duration? getRemainingTime(String? time)
  {
    try {
      DateTime dateTime = DateTime.parse(time!).toLocal();
      DateTime currentTime = DateTime.now();
      DateTime upcomingTime = DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,dateTime.minute);
      Duration difference = upcomingTime.difference(currentTime);
      return difference;
    } catch (e, st) {
      AppLog.e('getRemainingTime : ${e.toString()} \n${st.toString()}');
      return null;
    }
  }
}
