import 'package:awign/workforce/core/data/model/enum.dart';

class ConfigurationType<String> extends Enum1<String> {
  const ConfigurationType(String val) : super(val);

  static const ConfigurationType text = ConfigurationType('text');
  static const ConfigurationType verifyable = ConfigurationType('verifyable');
  static const ConfigurationType singleSelect =
      ConfigurationType('singleSelect');
  static const ConfigurationType multiSelect = ConfigurationType('multiSelect');
  static const ConfigurationType dateTime = ConfigurationType('dateTime');
  static const ConfigurationType dateTimeRange =
      ConfigurationType('dateTimeRange');
  static const ConfigurationType file = ConfigurationType('file');
  static const ConfigurationType location = ConfigurationType('location');
  static const ConfigurationType signature = ConfigurationType('signature');
  static const ConfigurationType audioRecording =
      ConfigurationType('audioRecording');
  static const ConfigurationType nested = ConfigurationType('nested');
  static const ConfigurationType bool = ConfigurationType('bool');
}
