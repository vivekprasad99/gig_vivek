import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/widget/nested/nested_question_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/provider/audio_recording_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/date_time_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/date_time_range_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/file_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/location_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/multi_select_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/signature_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/single_select_input_widget_provider.dart';
import 'package:awign/workforce/aw_questions/widget/provider/text_input_widget_provider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

import '../../../core/data/model/widget_result.dart';

class InputTile extends StatelessWidget {
  final Question question;
  final RenderType? renderType;
  late EdgeInsets? padding;
  final Function(Question question, {WidgetResult? widgetResult})
      onAnswerUpdate;

  InputTile(
      {Key? key,
      this.padding,
      required this.question,
      required this.renderType,
      required this.onAnswerUpdate})
      : super(key: key) {
    padding ??= const EdgeInsets.fromLTRB(
        Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: buildInputWidgetByConfigurationType(),
    );
  }

  Widget buildInputWidgetByConfigurationType() {
    switch (question.inputType?.getValue1()) {
      case ConfigurationType.text:
        return TextInputWidgetProvider.getInputWidget(
            question, renderType!, onAnswerUpdate);
      case ConfigurationType.singleSelect:
        return SingleSelectInputWidgetProvider.getInputWidget(
            question, onAnswerUpdate);
      case ConfigurationType.multiSelect:
        return MultiSelectInputWidgetProvider.getInputWidget(
            question, onAnswerUpdate);
      case ConfigurationType.dateTime:
        return DateTimeInputWidgetProvider.getInputWidget(
            question, renderType!, onAnswerUpdate);
      case ConfigurationType.dateTimeRange:
        return DateTimeRangeInputWidgetProvider.getInputWidget(
            question, renderType!, onAnswerUpdate);
      case ConfigurationType.file:
        return FileInputWidgetProvider.getInputWidget(question, onAnswerUpdate);
      case ConfigurationType.audioRecording:
        return AudioRecordingInputWidgetProvider.getInputWidget(
            question, onAnswerUpdate);
      case ConfigurationType.location:
        return LocationInputWidgetProvider.getInputWidget(
            question, onAnswerUpdate);
      case ConfigurationType.signature:
        return SignatureInputWidgetProvider.getInputWidget(
            question, onAnswerUpdate);
      case ConfigurationType.nested:
        return NestedQuestionInputWidget(question, onAnswerUpdate);
      default:
        return const SizedBox();
    }
  }
}
