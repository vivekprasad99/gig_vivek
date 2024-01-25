import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/select/bottom_sheet/multi_select_bottom_sheet/multi_select_bottom_sheet_widget.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class MultiSelectDropDownWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const MultiSelectDropDownWidget(this.question, this.onAnswerUpdate,
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
        showMultiSelectBottomSheet(
          context,
          question,
          (selectedOptions, selectedOptionEntities) {
            if (selectedOptions.isNotEmpty) {
              question.answerUnit?.listValue = selectedOptions;
              question.answerUnit?.optionListValue = selectedOptionEntities;
              onAnswerUpdate(question);
            } else {
              Helper.showErrorToast('not_answered'.tr);
            }
          },
        );
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
    List<String> strList = [];
    if (!question.answerUnit!.listValue.isNullOrEmpty) {
      for (String element in question.answerUnit!.listValue!) {
        strList.add(element);
      }
    } else if (!question.answerUnit!.optionListValue.isNullOrEmpty) {
      for (Option element in question.answerUnit!.optionListValue!) {
        strList.add(element.name);
      }
    }
    return MyInkWell(
      onTap: () {
        Helper.hideKeyBoard(context);
        if (!(question.configuration?.isEditable ?? true)) {
          return;
        }
        showMultiSelectBottomSheet(
          context,
          question,
          (selectedOptions, selectedOptionEntities) {
            if (selectedOptions.isNotEmpty) {
              question.answerUnit?.listValue = selectedOptions;
              question.answerUnit?.optionListValue = selectedOptionEntities;
              onAnswerUpdate(question);
            } else {
              Helper.showErrorToast('not_answered'.tr);
            }
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: strList.length > 2 ? 3 : strList.length,
          itemBuilder: (_, i) {
            if (i == 2) {
              return Container(
                height: Dimens.etHeight_48,
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('+${strList.length - 2}',
                      style: Get.textTheme.bodyText1),
                ),
              );
            } else {
              return Container(
                height: Dimens.etHeight_48,
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(strList[i], style: Get.textTheme.bodyText1),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
