import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/array_question_widget/cubit/array_question_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/array_question_widget/widget/tile/array_question_tile.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../core/data/model/widget_result.dart';
import '../../../../core/router/router.dart';
import '../../../data/model/answer/answer_unit.dart';
import '../../../data/model/questions_validation_error.dart';
import '../../../data/model/render_type.dart';
import '../../../data/model/result.dart';
import '../../attachment/helper/file_picker_helper.dart';

class ArrayQuestionWidget extends StatefulWidget {
  final Question question;

  const ArrayQuestionWidget(this.question, {Key? key}) : super(key: key);

  @override
  State<ArrayQuestionWidget> createState() => ArrayQuestionWidgetState();
}

class ArrayQuestionWidgetState extends State<ArrayQuestionWidget> {
  final ArrayQuestionCubit _arrayQuestionCubit = sl<ArrayQuestionCubit>();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    if (widget.question.configuration?.isAsync ?? false) {
      if (widget.question.answerUnit != null &&
          !(widget.question.answerUnit!.arrayValue.isNullOrEmpty)) {
        _arrayQuestionCubit.addQuestionList(widget.question,
            answerUnitList: widget.question.answerUnit?.arrayValue);
      }
    } else {
      _arrayQuestionCubit.addFirstQuestion(widget.question);
    }
  }

  void subscribeUIStatus() {
    _arrayQuestionCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.question.configuration?.isAsync ?? false) {
          AnswerUnit? answerUnit =
              _arrayQuestionCubit.getAnswerUnit(widget.question);
          MRouter.pop(answerUnit);
        } else {
          MRouter.pop(null);
        }
        return false;
      },
      child: ScreenTypeLayout(
        mobile: buildMobileUI(),
        desktop: const DesktopComingSoonWidget(),
      ),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: (widget.question.configuration?.questionText ?? '')
                  .toCapitalized(),
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_16,
                    Dimens.padding_16,
                    Dimens.padding_16,
                    Dimens.padding_16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.question.configuration?.isAsync ?? false) ...[
                        buildImageSelectionOption(),
                      ] else ...[
                        buildAddMoreWidget(),
                      ],
                      const SizedBox(
                        height: Dimens.margin_16,
                      ),
                      buildQuestionList(),
                    ],
                  ),
                ),
              ),
            ),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget buildAddMoreWidget() {
    if ((widget.question.configuration?.isEditable ?? true)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'add_multiple_values'.tr,
            style: Get.context?.textTheme.headline6SemiBold
                ?.copyWith(color: AppColors.black),
          ),
          MyInkWell(
            onTap: () {
              Result result = _arrayQuestionCubit.validateRequiredAnswers(
                  isCheckImageDetails: true);
              if (result.success) {
                _arrayQuestionCubit.addQuestion(widget.question);
              } else {
                Helper.showErrorToast(
                    (result.error as QuestionsValidationError).error ?? '');
              }
            },
            child: Text(
              '+ Add More',
              style: Get.context?.textTheme.bodyText2
                  ?.copyWith(color: AppColors.primaryMain),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildImageSelectionOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildAddMoreImagesWidget(),
        buildPickFromGalleryWidget(),
      ],
    );
  }

  Widget buildAddMoreImagesWidget() {
    return Expanded(
      child: MyInkWell(
        onTap: () {
          _captureImage();
        },
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: AppColors.primaryMain),
            const SizedBox(width: Dimens.padding_8),
            Flexible(
              child: Text('add_more_images'.tr,
                  style: Get.textTheme.bodyText1SemiBold),
            ),
          ],
        ),
      ),
    );
  }

  void _captureImage() async {
    if ((widget.question.configuration?.isEditable ?? true)) {
      Question question = _arrayQuestionCubit.getNewQuestion(widget.question);
      ImageDetails imageDetails = ImageDetails(
          uploadLater: question.configuration?.uploadLater ?? false,
          dataType: question.dataType ?? DataType.single,
          isAsync: widget.question.configuration?.isAsync ?? false,
          question: question);
      WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
          MRouter.inAppCameraWidget,
          arguments: imageDetails);
      if (cameraWidgetResult != null &&
          cameraWidgetResult.event == Event.selected &&
          cameraWidgetResult.data is List<ImageDetails>) {
        _arrayQuestionCubit.addQuestionList(widget.question,
            imageDetailsList: cameraWidgetResult.data, isStartUploading: true);
      }
    }
  }

  Widget buildPickFromGalleryWidget() {
    return MyInkWell(
        onTap: () {
          _pickMedia();
        },
        child: Text('pick_from_gallery'.tr,
            style: Get.textTheme.bodyText1SemiBold));
  }

  void _pickMedia() async {
    if ((widget.question.configuration?.isEditable ?? true)) {
      if(widget.question.dataType == DataType.array) {
        final List<XFile> xFileList = await FilePickerHelper.pickMultipleImage();
        for(int i = 0; i < xFileList.length; i++) {
          _addImage(xFileList[i].path ?? '', xFileList[i].name[i] ?? '');
        }
      } else {
        FilePickerHelper.pickMedia(
          widget.question.inputType?.getValue2(),
          widget.question.dataType,
              (result) async {
                _addImage(result.files[0].path ?? '', result.names[0] ?? '');
          },
          isSelectMultiple: widget.question.dataType == DataType.array,
        );
      }
    }
  }

  _addImage(String path, String name) {
    File file = File(path);
    Question question = _arrayQuestionCubit.getNewQuestion(widget.question);
    ImageDetails imageDetailsResult = ImageDetails(
        originalFileName: name,
        originalFilePath: file.path,
        fileQuality: FileQuality.high,
        question: question);
    if (widget.question.dataType == DataType.array) {
      _arrayQuestionCubit.addQuestionList(widget.question,
          imageDetailsList: [imageDetailsResult],
          isStartUploading: true,
          isUpsertEntity: true);
    }
  }

  Widget buildIndex() {
    return Container(
      width: Dimens.avatarWidth_20,
      height: Dimens.avatarHeight_20,
      decoration: BoxDecoration(
          color: AppColors.transparent,
          border: Border.all(
            color: AppColors.pattensBlue,
          ),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_16))),
      child: Center(
        child: Text(
          '1',
          style: Get.textTheme.overline?.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.pattensBlue),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    String text = 'submit'.tr;
    if (widget.question.configuration?.isAsync ?? false) {
      text = 'sync_again'.tr;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_16,
          Dimens.padding_24, Dimens.padding_24),
      child: StreamBuilder<List<Question>>(
        stream: _arrayQuestionCubit.questionListStream,
        builder: (context, questionListStream) {
          if (questionListStream.hasData &&
              questionListStream.data != null &&
              questionListStream.data!.isNotEmpty) {
            return RaisedRectButton(
              text: text,
              onPressed: () {
                Helper.hideKeyBoard(context);
                Result result = _arrayQuestionCubit.validateRequiredAnswers(
                    isCheckImageDetails: true);
                if (result.success) {
                  submitResultToParentQuestion();
                } else {
                  Helper.showErrorToast(
                      (result.error as QuestionsValidationError).error ?? '');
                }
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  void submitResultToParentQuestion() {
    if (widget.question.configuration?.isAsync ?? false) {
      _arrayQuestionCubit.updateUploadEntriesAndStartSyncing(widget.question);
    } else {
      AnswerUnit? answerUnit =
          _arrayQuestionCubit.getAnswerUnit(widget.question);
      MRouter.pop(answerUnit);
    }
  }

  Widget buildQuestionList() {
    return StreamBuilder<List<Question>>(
      stream: _arrayQuestionCubit.questionListStream,
      builder: (context, questionListStream) {
        if (questionListStream.hasData &&
            questionListStream.data != null &&
            questionListStream.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0),
            itemCount: questionListStream.data?.length,
            itemBuilder: (_, i) {
              return ArrayQuestionTile(questionListStream.data![i],
                  RenderType.DEFAULT, _onAnswerUpdate, onDeleteTap,
                  key: Key(questionListStream.data![i].uuid));
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    if (widgetResult != null && widgetResult.data is List<ImageDetails>) {
      List<ImageDetails>? imageDetailsList = widgetResult.data;
      if (!imageDetailsList.isNullOrEmpty) {
        _arrayQuestionCubit.addQuestionList(question,
            imageDetailsList: imageDetailsList!, isStartUploading: true);
      }
    } else {
      _arrayQuestionCubit.updateQuestionList(question, widget.question);
    }
  }

  onDeleteTap(Question question) async {
    ConfirmAction? confirmAction = await Helper.asyncConfirmDialog(
        context, 'are_you_sure'.tr,
        heading: 'Delete Entry', textOKBtn: 'yes'.tr, textCancelBtn: 'no'.tr);
    if (confirmAction == ConfirmAction.OK) {
      _arrayQuestionCubit.deleteQuestion(question);
    }
  }
}
