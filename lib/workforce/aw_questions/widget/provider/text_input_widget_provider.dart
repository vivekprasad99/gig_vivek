import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/text/default_array_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/text/text_hash_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/text/text_input_widget.dart';
import 'package:flutter/cupertino.dart';
import '../code_scanner/widget/code_scanner_input_widget.dart';

class TextInputWidgetProvider {
  static Widget getInputWidget(Question question, RenderType renderType,
      Function(Question question) onAnswerUpdate) {
    if (question.inputType?.value2 == SubType.codeScanner) {
      return CodeScannerInputWidget(question, onAnswerUpdate);
    } else {
      switch (question.dataType) {
      case DataType.single:
        return TextInputWidget(question, onAnswerUpdate);
      case DataType.array:
        return DefaultArrayInputWidget(question, onAnswerUpdate);

      case DataType.hash:
        return TextHashInputWidget(question);

      default:
        return const SizedBox();
    }
    }
  }
}
