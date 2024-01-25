import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/bottom_sheet/widget/profile_questions_bottom_sheet.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/tile/profile_section_question_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../../core/data/remote/capture_event/logging_data.dart';

class ProfileSectionTile extends StatefulWidget {
  SectionDetailsQuestions sectionDetailsQuestions;
  Function(SectionDetailsQuestions sectionDetailsQuestions)
      onUpdateRequiredAnswer;
  ProfileSectionTile(
      {required this.sectionDetailsQuestions,
      required this.onUpdateRequiredAnswer,
      Key? key})
      : super(key: key);

  @override
  State<ProfileSectionTile> createState() => _ProfileSectionTileState();
}

class _ProfileSectionTileState extends State<ProfileSectionTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimens.padding_24),
        Text(widget.sectionDetailsQuestions.title ?? '',
            style: Get.textTheme.bodyText1Bold),
        // const SizedBox(height: Dimens.padding_24),
        buildQuestionList(),
      ],
    );
  }

  Widget buildQuestionList() {
    if (!widget.sectionDetailsQuestions.screenRowList.isNullOrEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemBuilder: (_, i) {
          if (!widget.sectionDetailsQuestions.screenRowList![i].question!
                  .visibilityConditions.isNullOrEmpty &&
              !sl<AwQuestionsCubit>().checkVisibility(
                  widget.sectionDetailsQuestions.screenRowList![i].question!
                      .visibilityConditions![0],
                  widget.sectionDetailsQuestions.screenRowList)) {
            return const SizedBox();
          } else {
            return ProfileSectionQuestionTile(
                index: i,
                screenRow: widget.sectionDetailsQuestions.screenRowList![i],
                questionEntity: widget.sectionDetailsQuestions.questions![i],
                onAnswerAddOrUpdate: _onAnswerAddOrUpdate);
          }
        },
        itemCount: widget.sectionDetailsQuestions.questions!.length,
      );
    } else {
      return const SizedBox();
    }
  }

  _onAnswerAddOrUpdate(
      int index, ScreenRow screenRow, QuestionEntity questionEntity) async {
    if (screenRow.question?.uid == UID.whatsapp) {
      _onAnswerUpdated(index, screenRow, null);
    } else if (screenRow.question?.uid == UID.panCard) {
      LoggingData loggingData = LoggingData(
          event: LoggingEvents.profileJourneyVerify,
          pageName: LoggingPageNames.panDetails,
          sectionName: LoggingSectionNames.profileSection);
      CaptureEventHelper.captureEvent(loggingData: loggingData);
      dynamic data = await MRouter.pushNamed(MRouter.verifyPANWidget);
      if(data is DocumentDetailsData) {
        screenRow.question?.answerUnit = AnswerUnitMapper.getAnswerUnit(
            screenRow.question?.inputType,
            screenRow.question?.dataType,
            'www.google.com', /// Putting dummy URL because AnswerUnit.isValid() is checking doc URL
            null,
            configuration: screenRow.question?.configuration);
        screenRow.question?.answerUnit?.documentDetailsData = data;
        setState(() {
          widget.sectionDetailsQuestions.questions?[index] = questionEntity;
          widget.sectionDetailsQuestions.screenRowList?[index] = screenRow;
        });
      }
    } else {
      screenRow.question?.answerUnit = AnswerUnitMapper.getAnswerUnit(
          screenRow.question?.inputType,
          screenRow.question?.dataType,
          questionEntity.answer,
          null,
          configuration: screenRow.question?.configuration);
      showProfileQuestionsBottomSheet(
          Get.context!,
          widget.sectionDetailsQuestions.title ?? '',
          index,
          screenRow,
          _onAnswerUpdated);
    }
  }

  _onAnswerUpdated(int index, ScreenRow screenRow,
      SubmitAnswerResponse? submitAnswerResponse) {
    if (submitAnswerResponse != null &&
        !submitAnswerResponse.profileAttribute.isNullOrEmpty &&
        !widget.sectionDetailsQuestions.questions.isNullOrEmpty) {
      QuestionEntity questionEntity =
          widget.sectionDetailsQuestions.questions![index];
      if (questionEntity.uid ==
          submitAnswerResponse.profileAttribute![0].attributeUid) {
        questionEntity.answer =
            submitAnswerResponse.profileAttribute![0].attributeValue;
        screenRow.question?.answerUnit = AnswerUnitMapper.getAnswerUnit(
            screenRow.question?.inputType,
            screenRow.question?.dataType,
            questionEntity.answer,
            null,
            configuration: screenRow.question?.configuration,
            uid: screenRow.question?.uid);
        setState(() {
          widget.sectionDetailsQuestions.questions?[index] = questionEntity;
          widget.sectionDetailsQuestions.screenRowList?[index] = screenRow;
        });
        widget.onUpdateRequiredAnswer(widget.sectionDetailsQuestions);
      }
    } else {
      QuestionEntity questionEntity =
          widget.sectionDetailsQuestions.questions![index];
      setState(() {
        widget.sectionDetailsQuestions.questions![index] = questionEntity;
        widget.sectionDetailsQuestions.screenRowList![index] = screenRow;
      });
      widget.onUpdateRequiredAnswer(widget.sectionDetailsQuestions);
    }
  }
}
