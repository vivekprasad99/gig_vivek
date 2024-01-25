import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../../core/data/model/widget_result.dart';
import '../../../../../core/di/app_injection_container.dart';
import '../../../../../core/utils/helper.dart';
import '../../../../data/model/render_type.dart';
import '../../../array_question_widget/cubit/array_question_cubit.dart';
import '../../../array_question_widget/widget/tile/array_question_tile.dart';

class AsyncImageArrayInputWidget extends StatelessWidget {
  final ArrayQuestionCubit _arrayQuestionCubit = sl<ArrayQuestionCubit>();
  final Question question;
  final Function(Question question) onAnswerUpdate;

  AsyncImageArrayInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildUnAnsweredOrAnsweredWidget(context);
  }

  Widget buildUnAnsweredOrAnsweredWidget(BuildContext context) {
    if (question.answerUnit != null &&
        !(question.answerUnit!.arrayValue.isNullOrEmpty)) {
      _arrayQuestionCubit.addQuestionList(question,
          answerUnitList: question.answerUnit?.arrayValue);
      return buildQuestionList(context);
    } else {
      return buildUnAnsweredWidget(context);
    }
  }

  Widget buildUploadedCountWidget(List<Question> questionList) {
    int totalImageCount = questionList.length ?? 0;
    int uploadedCount = 0;
    for (int i = 0; i < questionList.length; i++) {
      if (questionList[i].hasAnswered()) {
        uploadedCount++;
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_4, 0, 0, 0),
      child: Text(
        '${'uploaded'.tr} $uploadedCount ${'of'.tr} $totalImageCount',
        style: Get.textTheme.bodyText2,
      ),
    );
  }

  Widget buildQuestionList(BuildContext context) {
    return StreamBuilder<List<Question>>(
      stream: _arrayQuestionCubit.questionListStream,
      builder: (context, questionListStream) {
        if (questionListStream.hasData &&
            questionListStream.data != null &&
            questionListStream.data!.isNotEmpty) {
          question.answerUnit = _arrayQuestionCubit.getAnswerUnit(question);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUploadedCountWidget(questionListStream.data!),
              const SizedBox(height: Dimens.padding_16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 0),
                itemCount: questionListStream.data!.length > 2
                    ? 2
                    : questionListStream.data!.length,
                itemBuilder: (_, i) {
                  return ArrayQuestionTile(
                    questionListStream.data![i],
                    RenderType.DEFAULT,
                    _onAnswerUpdate,
                    onDeleteTap,
                    key: Key(questionListStream.data![i].uuid),
                    isShowCard: false,
                  );
                },
              ),
              buildViewImagesWidget(context),
            ],
          );
        } else {
          return buildUnAnsweredWidget(context);
        }
      },
    );
  }

  _onAnswerUpdate(Question lQuestion, {WidgetResult? widgetResult}) {
    if (widgetResult != null && widgetResult.data is List<ImageDetails>) {
      List<ImageDetails>? imageDetailsList = widgetResult.data;
      if (!imageDetailsList.isNullOrEmpty) {
        _arrayQuestionCubit.addQuestionList(lQuestion,
            imageDetailsList: imageDetailsList!, isStartUploading: true);
      }
    } else {
      _arrayQuestionCubit.updateQuestionList(lQuestion, question);
    }
  }

  onDeleteTap(Question question) {
    Future<ConfirmAction?> deleteTap = Helper.asyncConfirmDialog(
        Get.context!, 'are_you_sure'.tr,
        heading: 'Delete Entry', textOKBtn: 'yes'.tr, textCancelBtn: 'no'.tr);
    deleteTap.then((value) {
      if (value == ConfirmAction.OK) {
        _arrayQuestionCubit.deleteQuestion(question);
      }
    });
  }

  Widget buildUnAnsweredWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_32),
      child: MyInkWell(
        onTap: () {
          _openArrayQuestionWidget();
        },
        child: Text(
          'click_to_add_answer'.tr,
          style:
              Get.textTheme.bodyText1?.copyWith(color: AppColors.primaryMain),
        ),
      ),
    );
  }

  Widget buildViewImagesWidget(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: MyInkWell(
        onTap: () {
          _openArrayQuestionWidget();
        },
        child: Text(
          'view_images'.tr,
          style:
              Get.textTheme.bodyText1?.copyWith(color: AppColors.primaryMain),
        ),
      ),
    );
  }

  _openArrayQuestionWidget() async {
    AnswerUnit? answerUnit = await MRouter.pushNamed(
        MRouter.arrayQuestionWidget,
        arguments: question);
    if (answerUnit != null) {
      question.answerUnit = answerUnit;
      onAnswerUpdate(question);
    }
  }
}
