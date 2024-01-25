import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectCheckboxRightWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  List<Option> optionList = [];

  MultiSelectCheckboxRightWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SelectConfiguration? selectConfiguration =
        question.configuration as SelectConfiguration?;
    if (selectConfiguration != null && selectConfiguration.options != null) {
      addAllOptions(
          selectConfiguration.options!, question.answerUnit?.listValue ?? []);
    } else if (selectConfiguration?.optionEntities != null) {
      addAllOptionsEntities(selectConfiguration!.optionEntities!,
          question.answerUnit?.optionListValue);
    }
    return buildOptionList();
  }

  void addAllOptions(List<String> options, List<String> selectedOptions) {
    for (int i = 0; i < options.length; i++) {
      Option option = Option(index: i, name: options[i]);
      for (int j = 0; j < selectedOptions.length; j++) {
        if (option.name == selectedOptions[j]) {
          option.isSelected = true;
          continue;
        }
      }
      optionList.add(option);
    }
  }

  void addAllOptionsEntities(
      List<Option> options, List<Option>? selectedOptions) {
    for (int i = 0; i < options.length; i++) {
      Option option = options[i];
      option.isSelected = false;
      if (selectedOptions != null) {
        for (int j = 0; j < selectedOptions.length; j++) {
          if (option.uid == selectedOptions[j].uid) {
            option.isSelected = true;
            continue;
          }
        }
      }
      optionList.add(option);
    }
  }

  Widget buildOptionList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      itemCount: optionList.length,
      itemBuilder: (_, i) {
        return Container(
          decoration: BoxDecoration(
            color: optionList[i].isSelected
                ? AppColors.primary50
                : AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(Dimens.radius_8),
            border: Border.all(
              color: optionList[i].isSelected
                  ? AppColors.primaryMain
                  : AppColors.backgroundGrey400,
            ),
          ),
          child: MyInkWell(
            onTap: () {
              if (!(question.configuration?.isEditable ?? true)) {
                return;
              }
              List<String> selectedListValue =
                  question.answerUnit?.listValue ?? [];
              List<Option> selectedOptionListValue =
                  question.answerUnit?.optionListValue ?? [];
              if (!optionList[i].isSelected) {
                selectedListValue.add(optionList[i].name);
                selectedOptionListValue.add(optionList[i]);
              } else {
                List<String> tempList = [];
                tempList.addAll(selectedListValue);
                List<Option> tempOptionList = [];
                tempOptionList.addAll(selectedOptionListValue);
                for (int j = 0; j < selectedListValue.length; j++) {
                  if (optionList[i].name == selectedListValue[j]) {
                    tempList.removeAt(j);
                    break;
                  }
                }
                for (int j = 0; j < selectedOptionListValue.length; j++) {
                  if (optionList[i].name == selectedOptionListValue[j].name) {
                    tempOptionList.removeAt(j);
                    break;
                  }
                }
                selectedListValue.clear();
                selectedOptionListValue.clear();
                selectedListValue.addAll(tempList);
                selectedOptionListValue.addAll(tempOptionList);
              }
              question.answerUnit?.listValue = selectedListValue;
              question.answerUnit?.optionListValue = selectedOptionListValue;
              onAnswerUpdate(question);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, 0, Dimens.padding_16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(optionList[i].name ?? '',
                        style: Get.context?.textTheme.bodyText2
                            ?.copyWith(color: AppColors.backgroundBlack)),
                  ),
                  Checkbox(
                    value: optionList[i].isSelected,
                    onChanged: (v) {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: Dimens.padding_12);
      },
    );
  }
}
