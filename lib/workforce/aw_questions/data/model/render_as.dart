import 'package:awign/workforce/core/data/model/enum.dart';

class RenderAs<String> extends Enum1<String> {
  const RenderAs(String val) : super(val);

  static const RenderAs shortText = RenderAs('short_text');
  static const RenderAs radioButton = RenderAs('radio_button');
  static const RenderAs dropDown = RenderAs('dropdown');
  static const RenderAs box = RenderAs('box');
  static const RenderAs slider = RenderAs('slider');
  static const RenderAs checkBox = RenderAs('check_box');
  static const RenderAs checkboxRight = RenderAs('checkbox_right');
  static const RenderAs file = RenderAs('file');
  static const RenderAs image = RenderAs('image');
  static const RenderAs dateTime = RenderAs('date_time');

  static RenderAs? get(dynamic inputType) {
    switch (inputType) {
      case 'short_text':
        return RenderAs.shortText;
      case 'radio_button':
        return RenderAs.radioButton;
      case 'dropdown':
        return RenderAs.dropDown;
      case 'box':
        return RenderAs.box;
      case 'slider':
        return RenderAs.slider;
      case 'check_box':
        return RenderAs.checkBox;
      case 'checkbox_right':
        return RenderAs.checkboxRight;
      case 'file':
        return RenderAs.file;
      case 'image':
        return RenderAs.image;
      case 'date_time':
        return RenderAs.dateTime;
      default:
        return null;
    }
  }
}
