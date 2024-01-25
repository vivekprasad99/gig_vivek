import 'package:awign/workforce/core/data/model/enum.dart';

class InputTypeEntityNew<String> extends Enum1<String> {
  const InputTypeEntityNew(String val) : super(val);

  static const InputTypeEntityNew text = InputTypeEntityNew('TEXT');
  static const InputTypeEntityNew singleSelect =
      InputTypeEntityNew('SINGLE_SELECT');
  static const InputTypeEntityNew multiSelect =
      InputTypeEntityNew('MULTI_SELECT');
  static const InputTypeEntityNew date = InputTypeEntityNew('DATE');
  // static const InputTypeEntityNew location = InputTypeEntityNew('LOCATION');
  static const InputTypeEntityNew attachment = InputTypeEntityNew('ATTACHMENT');
  static const InputTypeEntityNew geoAddress =
      InputTypeEntityNew('GEO_ADDRESS');
  static const InputTypeEntityNew whatsApp = InputTypeEntityNew('whatsApp');

  static InputTypeEntityNew? get(dynamic inputType) {
    switch (inputType) {
      case 'TEXT':
        return InputTypeEntityNew.text;
      case 'SINGLE_SELECT':
        return InputTypeEntityNew.singleSelect;
      case 'MULTI_SELECT':
        return InputTypeEntityNew.multiSelect;
      case 'DATE':
        return InputTypeEntityNew.date;
      // case 'LOCATION':
      //   return InputTypeEntityNew.location;
      case 'ATTACHMENT':
        return InputTypeEntityNew.attachment;
      case 'GEO_ADDRESS':
        return InputTypeEntityNew.geoAddress;
      case 'whatsApp':
        return InputTypeEntityNew.whatsApp;
      default:
        return null;
    }
  }
}
