import 'package:awign/workforce/core/data/model/enum.dart';

class SubType<String> extends Enum1<String> {
  const SubType(String val) : super(val);

  static const SubType short = SubType('short');
  static const SubType long = SubType('long');
  static const SubType phone = SubType('phone');
  static const SubType email = SubType('email');
  static const SubType number = SubType('number');
  static const SubType panCardNumber = SubType('panCardNumber');
  static const SubType float = SubType('float');
  static const SubType date = SubType('date');
  static const SubType dateTime = SubType('dateTime');
  static const SubType time = SubType('time');
  static const SubType image = SubType('image');
  static const SubType audio = SubType('audio');
  static const SubType video = SubType('video');
  static const SubType pdf = SubType('pdf');
  static const SubType file = SubType('file');
  static const SubType location = SubType('location');
  static const SubType myLocation = SubType('myLocation');
  static const SubType signature = SubType('signature');
  static const SubType audioRecording = SubType('audioRecording');
  static const SubType nested = SubType('nested');
  static const SubType dropDown = SubType('dropDown');
  static const SubType radio = SubType('radio');
  static const SubType checkBox = SubType('checkBox');
  static const SubType url = SubType('url');
  static const SubType selectDecisionButton = SubType('selectDecisionButton');
  static const SubType dateRange = SubType('dateRange');
  static const SubType dateTimeRange = SubType('dateTimeRange');
  static const SubType box = SubType('box');
  static const SubType checkboxRight = SubType('checkbox_right');
  static const SubType slider = SubType('slider');
  static const SubType switchButton = SubType('switchButton');
  static const SubType pinCode = SubType('pincode');
  static const SubType codeScanner = SubType('code_scanner');
}
