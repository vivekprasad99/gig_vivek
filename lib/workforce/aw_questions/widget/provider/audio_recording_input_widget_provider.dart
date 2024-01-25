import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/audio/audio_recording_input_widget.dart';
import 'package:flutter/cupertino.dart';

class AudioRecordingInputWidgetProvider {
  static Widget getInputWidget(
      Question question, Function(Question question) onAnswerUpdate) {
    if ((question.configuration?.isEditable ?? false)) {
      return AudioRecordingInputWidget(question, onAnswerUpdate);
    } else {
      return const SizedBox();
    }
  }
}
