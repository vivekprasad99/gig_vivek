import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/question_required_icon_widget.dart';
import 'package:awign/workforce/aw_questions/widget/whatsapp/widget/whatsapp_subscription_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/attachment_answer_widget.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/location_answer_widget.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/multi_select_answer_widget.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/question_name_widget.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/single_select_answer_widget.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/text_answer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSectionQuestionTile extends StatelessWidget {
  final int index;
  final ScreenRow screenRow;
  final QuestionEntity questionEntity;
  final Function(int index, ScreenRow screenRow, QuestionEntity questionEntity)
      onAnswerAddOrUpdate;
  const ProfileSectionQuestionTile(
      {required this.index,
      required this.screenRow,
      required this.questionEntity,
      required this.onAnswerAddOrUpdate,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.padding_24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuestionNameWidget(screenRow.question),
              const SizedBox(width: Dimens.padding_4),
              buildRequiredIconWidget(),
            ],
          ),
          const SizedBox(width: Dimens.padding_16),
          buildAnswerWidget(),
        ],
      ),
    );
  }

  Widget buildRequiredIconWidget() {
    if (screenRow.question?.hasAnswered() ?? false) {
      return const SizedBox();
    } else {
      return QuestionRequiredIconWidget(
        screenRow.question,
        padding: const EdgeInsets.only(top: 0),
        textStyle: Get.textTheme.caption2.copyWith(color: AppColors.error300),
      );
    }
  }

  Widget buildAnswerWidget() {
    switch (screenRow.question?.inputType?.getValue1()) {
      case ConfigurationType.text:
      case ConfigurationType.dateTime:
        return TextAnswerWidget(screenRow, _onAnswerAddOrUpdate);
      case ConfigurationType.singleSelect:
        return SingleSelectAnswerWidget(screenRow, _onAnswerAddOrUpdate);
      case ConfigurationType.multiSelect:
        return MultiSelectAnswerWidget(screenRow, _onAnswerAddOrUpdate);
      case ConfigurationType.dateTimeRange:
        return const SizedBox();
      case ConfigurationType.file:
        return AttachmentAnswerWidget(screenRow, _onAnswerAddOrUpdate);
      case ConfigurationType.audioRecording:
        return const SizedBox();
      case ConfigurationType.location:
        return LocationAnswerWidget(screenRow, _onAnswerAddOrUpdate);
      case ConfigurationType.bool:
        return WhatsappSubscriptionWidget(screenRow, _onAnswerAddOrUpdate);
      case ConfigurationType.nested:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  _onAnswerAddOrUpdate(ScreenRow screenRow) {
    onAnswerAddOrUpdate(index, screenRow, questionEntity);
  }
}
