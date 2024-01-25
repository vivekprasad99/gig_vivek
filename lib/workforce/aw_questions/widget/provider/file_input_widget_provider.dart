import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/async_image/widget/async_image_array_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/async_image/widget/async_image_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/file_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/attendance_image/widget/attendance_image_input_widget.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/data/model/widget_result.dart';
import '../attachment/audio/audio_input_widget.dart';
import '../attachment/sync_image/widget/sync_image_input_widget.dart';
import '../text/default_array_input_widget.dart';

class FileInputWidgetProvider {
  static Widget getInputWidget(
      Question question,
      Function(Question question, {WidgetResult? widgetResult})
          onAnswerUpdate) {
    switch (question.dataType) {
      case DataType.single:
        if (question.configuration?.isAsync ?? false) {
          if(question.dynamicModuleCategory?.value == DynamicModuleCategory.attendance.value)
            {
              return AttendanceImageInputWidget(question, onAnswerUpdate);
            }else {
            return AsyncImageInputWidget(question, onAnswerUpdate);
          }
        } else if (question.inputType?.getValue2() == SubType.image) {
          if(question.dynamicModuleCategory?.value == DynamicModuleCategory.attendance.value)
          {
            return AttendanceImageInputWidget(question, onAnswerUpdate);
          }else {
            return SyncImageInputWidget(question, onAnswerUpdate);
          }
        } else if (question.inputType?.getValue2() == SubType.audio) {
          return AudioInputWidget(question, onAnswerUpdate);
          return SyncImageInputWidget(question, onAnswerUpdate);
        } else if (question.inputType?.getValue2() == SubType.audio) {
          return AudioInputWidget(question, onAnswerUpdate);
        } else {
          return FileInputWidget(question, onAnswerUpdate);
        }
      case DataType.array:
        if (question.configuration?.isAsync ?? false) {
          return AsyncImageArrayInputWidget(question, onAnswerUpdate);
        } else {
          return DefaultArrayInputWidget(question, onAnswerUpdate);
        }
      case DataType.hash:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }
}
