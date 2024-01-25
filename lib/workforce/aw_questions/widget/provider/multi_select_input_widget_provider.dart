import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/select/multi_select_checkbox_right_widget.dart';
import 'package:awign/workforce/aw_questions/widget/select/multi_select_checkbox_widget.dart';
import 'package:awign/workforce/aw_questions/widget/select/multi_select_drop_down_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MultiSelectInputWidgetProvider {
  static Widget getInputWidget(
      Question question, Function(Question question) onAnswerUpdate) {
    if (question.inputType?.getValue2() == SubType.dropDown) {
      return MultiSelectDropDownWidget(question, onAnswerUpdate);
    } else if (question.inputType?.getValue2() == SubType.checkboxRight) {
      return MultiSelectCheckboxRightWidget(question, onAnswerUpdate);
    } else if (question.inputType?.getValue2() == SubType.image) {
      return Text('Multi Select Image View, Coming Soon...',
          style: Get.textTheme.bodyText1);
    } else {
      return MultiSelectCheckBoxWidget(question, onAnswerUpdate);
    }
    // if (question.inputType?.getValue2() == SubType.dropDown) {
    //   return Text('Un Editable Multi Select Drop Down View, Coming Soon...',
    //       style: Get.textTheme.bodyText1);
    // } else {
    //   return Text('Un Editable Multi Select Input View, Coming Soon...',
    //       style: Get.textTheme.bodyText1);
    // }
  }
}
