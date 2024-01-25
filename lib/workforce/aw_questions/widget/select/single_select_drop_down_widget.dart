import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/aw_questions/widget/select/bottom_sheet/single_select_bottom_sheet/single_select_bottom_sheet_widget.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_collage_bottom_sheet/widget/select_collage_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SingleSelectDropDownWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const SingleSelectDropDownWidget(this.question, this.onAnswerUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildSelectOptionOrAnswerWidget(context);
  }

  Widget buildSelectOptionOrAnswerWidget(BuildContext context) {
    if (question.hasAnswered()) {
      return buildAnswerWidget(context);
    } else {
      return buildSelectOptionWidget(context);
    }
  }

  Widget buildSelectOptionWidget(BuildContext context) {
    return MyInkWell(
      onTap: () {
        Helper.hideKeyBoard(context);
        if (!(question.configuration?.isEditable ?? true)) {
          return;
        }
        if (question.uid == UID.collegeName) {
          showSelectCollageBottomSheet(
            context,
            (selectedCollage) {
              question.answerUnit?.stringValue =
                  selectedCollage?.collegeName ?? '';
              onAnswerUpdate(question);
            },
            isLocalNavigation: true,
          );
        } else {
          showSingleSelectBottomSheet(
            context,
            question,
            (selectedOption, selectedOptionEntity) {
              if (selectedOption != null) {
                question.answerUnit?.stringValue = selectedOption;
                question.answerUnit?.optionValue = selectedOptionEntity;
                onAnswerUpdate(question);
              } else {
                Helper.showErrorToast('not_answered'.tr);
              }
            },
          );
        }
      },
      child: Container(
        height: Dimens.etHeight_48,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SvgPicture.asset('assets/images/ic_multi_select.svg'),
              const SizedBox(width: Dimens.padding_12),
              Text(question.getPlaceHolderText() ?? 'select_from_options'.tr,
                  style: Get.textTheme.bodyText1
                      ?.copyWith(color: context.theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnswerWidget(BuildContext context) {
    String answerValue = '';
    SelectConfiguration? selectConfiguration =
        question.configuration as SelectConfiguration?;
    if (selectConfiguration?.optionEntities != null &&
        question.answerUnit?.stringValue != null) {
      for (int i = 0; i < selectConfiguration!.optionEntities!.length; i++) {
        if (selectConfiguration.optionEntities![i].uid ==
            question.answerUnit?.stringValue) {
          answerValue = selectConfiguration.optionEntities![i].name;
          break;
        } else if (selectConfiguration.optionEntities![i].name ==
            question.answerUnit?.stringValue) {
          answerValue = selectConfiguration.optionEntities![i].name;
        }
      }
    } else {
      answerValue = question.answerUnit?.stringValue ?? '';
    }
    return MyInkWell(
      onTap: () {
        Helper.hideKeyBoard(context);
        if (!(question.configuration?.isEditable ?? true)) {
          return;
        }
        if (question.uid == UID.collegeName) {
          showSelectCollageBottomSheet(
            context,
            (selectedCollage) {
              question.answerUnit?.stringValue =
                  selectedCollage?.collegeName ?? '';
              onAnswerUpdate(question);
            },
            isLocalNavigation: true,
          );
        } else {
          showSingleSelectBottomSheet(
            context,
            question,
            (selectedOption, selectedOptionEntity) {
              if (selectedOption != null) {
                question.answerUnit?.stringValue = selectedOption;
                question.answerUnit?.optionValue = selectedOptionEntity;
                onAnswerUpdate(question);
              } else {
                Helper.showErrorToast('not_answered'.tr);
              }
            },
          );
        }
      },
      child: Container(
        height: Dimens.etHeight_48,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(answerValue, style: Get.textTheme.bodyText1),
        ),
      ),
    );
  }
}
