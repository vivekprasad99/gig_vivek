import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';

class DateTimeConfiguration extends Configuration {
  static const String absent = 'absent';
  static const String past = 'past';
  static const String pastPresent = 'past_present';
  static const String future = 'future';
  static const String futurePresent = 'future_present';
  static const String timeHMS = '%H:%M:%S';
  static const String timeHM = '%H:%M';
  static const String timeMS = '%M:%S';
  static const String dateDMY = '%d/%m/%Y';
  static const String dateTimeDMYHM = '%d/%m/%Y %H:%M';
  static const String dateTimeDMYHMS = '%d/%m/%Y %H:%M:%S';

  DateTimeConfiguration({
    this.subType = SubType.date,
    this.dateValidation = DateTimeConfiguration.absent,
    this.isTimeIn24HoursFormat = true,
    this.dateTimeFormat = StringUtils.dateTimeFormatDMYHMSA,
  });

  late SubType? subType;
  late String? dateValidation;
  late bool? isTimeIn24HoursFormat;
  late String? dateTimeFormat;

  /// Use this method to get the Android compatible date time format
  /// according to the project's configured date time format,
  /// @param dateTimeFormat It is the project's configured date time format,
  /// @return returns the date time format string to show date time on UI.
  String getMappedDateTimeFormat() {
    switch (dateTimeFormat) {
      case timeHMS:
        return StringUtils.timeFormatHMS;
      case timeHM:
        return StringUtils.timeFormatHM;
      case timeMS:
        return StringUtils.timeFormatMS;
      case dateDMY:
        return StringUtils.dateFormatDMY;
      case dateTimeDMYHM:
        return StringUtils.dateTimeFormatDMYHMA;
      case dateTimeDMYHMS:
        return StringUtils.dateTimeFormatDMYHMSA;
      default:
        switch (subType) {
          case SubType.time:
            return StringUtils.timeFormatHMS;
          case SubType.date:
            return StringUtils.dateFormatYMD;
          default:
            return StringUtils.dateTimeFormatDMYHMSA;
        }
    }
  }

  void addFields(String columnTitle, String hintString, int imageLeft) {
    hintText = hintString;
    columnTitle = columnTitle;
    drawableLeft = imageLeft;
  }
}
