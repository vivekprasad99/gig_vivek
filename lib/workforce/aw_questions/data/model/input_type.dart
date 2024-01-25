import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart'
    as ct;
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart' as st;
import 'package:awign/workforce/core/data/model/enum.dart';

class InputType<ConfigurationType, SubType>
    extends Enum2<ConfigurationType, SubType> {
  const InputType(ConfigurationType configurationType, SubType subType)
      : super(configurationType, subType);

  static const InputType singleSelect =
      InputType(ct.ConfigurationType.singleSelect, st.SubType.radio);
  static const InputType singleSelectBox =
      InputType(ct.ConfigurationType.singleSelect, st.SubType.box);
  static const InputType singleSelectSlider =
      InputType(ct.ConfigurationType.singleSelect, st.SubType.slider);
  static const InputType shortText =
      InputType(ct.ConfigurationType.text, st.SubType.short);
  static const InputType longText =
      InputType(ct.ConfigurationType.text, st.SubType.long);
  static const InputType number =
      InputType(ct.ConfigurationType.text, st.SubType.number);
  static const InputType email =
      InputType(ct.ConfigurationType.text, st.SubType.email);
  static const InputType float =
      InputType(ct.ConfigurationType.text, st.SubType.float);
  static const InputType url =
      InputType(ct.ConfigurationType.text, st.SubType.url);
  static const InputType singleSelectDropDown =
      InputType(ct.ConfigurationType.singleSelect, st.SubType.dropDown);
  static const InputType multiSelect =
      InputType(ct.ConfigurationType.multiSelect, st.SubType.checkBox);
  static const InputType multiSelectDropDown =
      InputType(ct.ConfigurationType.multiSelect, st.SubType.dropDown);
  static const InputType multiSelectBox =
      InputType(ct.ConfigurationType.multiSelect, st.SubType.box);
  static const InputType multiSelectCheckBoxRight =
      InputType(ct.ConfigurationType.multiSelect, st.SubType.checkboxRight);
  static const InputType singleSelectImage =
      InputType(ct.ConfigurationType.singleSelect, st.SubType.image);
  static const InputType multiSelectImage =
      InputType(ct.ConfigurationType.multiSelect, st.SubType.image);
  static const InputType singleSelectDecisionButton = InputType(
      ct.ConfigurationType.singleSelect, st.SubType.selectDecisionButton);
  static const InputType date =
      InputType(ct.ConfigurationType.dateTime, st.SubType.date);
  static const InputType dateTime =
      InputType(ct.ConfigurationType.dateTime, st.SubType.dateTime);
  static const InputType time =
      InputType(ct.ConfigurationType.dateTime, st.SubType.time);
  static const InputType timeRange =
      InputType(ct.ConfigurationType.dateTimeRange, st.SubType.time);
  static const InputType dateRange =
      InputType(ct.ConfigurationType.dateTimeRange, st.SubType.date);
  static const InputType dateTimeRange =
      InputType(ct.ConfigurationType.dateTimeRange, st.SubType.dateTime);
  static const InputType audioRecording =
      InputType(ct.ConfigurationType.audioRecording, st.SubType.audioRecording);
  static const InputType image =
      InputType(ct.ConfigurationType.file, st.SubType.image);
  static const InputType audio =
      InputType(ct.ConfigurationType.file, st.SubType.audio);
  static const InputType video =
      InputType(ct.ConfigurationType.file, st.SubType.video);
  static const InputType pdf =
      InputType(ct.ConfigurationType.file, st.SubType.pdf);
  static const InputType file =
      InputType(ct.ConfigurationType.file, st.SubType.file);
  static const InputType signature =
      InputType(ct.ConfigurationType.signature, st.SubType.signature);
  static const InputType geoAddress =
      InputType(ct.ConfigurationType.location, st.SubType.location);
  static const InputType currentLocation =
      InputType(ct.ConfigurationType.location, st.SubType.myLocation);
  static const InputType nested =
      InputType(ct.ConfigurationType.nested, st.SubType.nested);
  static const InputType phone =
      InputType(ct.ConfigurationType.text, st.SubType.phone);
  static const InputType whatsApp =
      InputType(ct.ConfigurationType.bool, st.SubType.switchButton);
  static const InputType pinCode =
  InputType(ct.ConfigurationType.text, st.SubType.pinCode);
  static const InputType codeScanner =
  InputType(ct.ConfigurationType.text, st.SubType.codeScanner);

  @override
  ConfigurationType getValue1() {
    return value1;
  }

  @override
  SubType getValue2() {
    return value2;
  }
}
