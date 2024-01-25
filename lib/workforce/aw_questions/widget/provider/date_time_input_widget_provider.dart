import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/widget/date_time/date_time_input_array_widget.dart';
import 'package:awign/workforce/aw_questions/widget/date_time/date_time_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/text/default_array_input_widget.dart';
import 'package:flutter/cupertino.dart';

class DateTimeInputWidgetProvider {
  static Widget getInputWidget(Question question, RenderType renderType,
      Function(Question question) onAnswerUpdate) {
    switch (question.dataType) {
      case DataType.single:
        if (renderType == RenderType.ARRAY) {
          return const DateTimeInputArrayWidget();
        } else {
          return DateTimeInputWidget(question, onAnswerUpdate);
        }
      case DataType.array:
        return DefaultArrayInputWidget(question, onAnswerUpdate);
      case DataType.hash:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }
}
