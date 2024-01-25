import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/select/single_select_box_button_wiget.dart';
import 'package:awign/workforce/aw_questions/widget/select/single_select_drop_down_widget.dart';
import 'package:awign/workforce/aw_questions/widget/select/single_select_radio_button_widget.dart';
import 'package:awign/workforce/aw_questions/widget/select/single_select_slider_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SingleSelectInputWidgetProvider {
  static Widget getInputWidget(
      Question question, Function(Question question) onAnswerUpdate) {
    if (question.inputType?.getValue2() == SubType.dropDown) {
      return SingleSelectDropDownWidget(question, onAnswerUpdate);
    } else if (question.inputType?.getValue2() == SubType.box) {
      return SingleSelectBoxButtonWidget(question, onAnswerUpdate);
    } else if (question.inputType?.getValue2() == SubType.slider) {
      return SingleSelectSliderWidget(question, onAnswerUpdate);
    } else if (question.inputType?.getValue2() == SubType.image) {
      return Text('Single Select Image View, Coming Soon...',
          style: Get.textTheme.bodyText1);
    } else {
      return SingleSelectRadioButtonWidget(question, onAnswerUpdate);
    }
  }
}
