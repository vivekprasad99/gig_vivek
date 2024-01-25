import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectCheckBoxWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  List<Option> optionList = [];

  MultiSelectCheckBoxWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SelectConfiguration? selectConfiguration =
        question.configuration as SelectConfiguration?;
    if (selectConfiguration != null && selectConfiguration.options != null) {
      addAllOptions(
          selectConfiguration.options!, question.answerUnit?.listValue ?? []);
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

  Widget buildOptionList() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.inputBoxBackgroundColor,
        border: Border.all(color: Get.theme.inputBoxBorderColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount: optionList.length,
        itemBuilder: (_, i) {
          return MyInkWell(
            onTap: () {
              if (!(question.configuration?.isEditable ?? true)) {
                return;
              }
              List<String> selectedOptions =
                  question.answerUnit?.listValue ?? [];
              if (!optionList[i].isSelected) {
                selectedOptions.add(optionList[i].name);
              } else {
                List<String> tempList = [];
                tempList.addAll(selectedOptions);
                for (int j = 0; j < selectedOptions.length; j++) {
                  if (optionList[i].name == selectedOptions[j]) {
                    tempList.removeAt(j);
                    break;
                  }
                }
                selectedOptions.clear();
                selectedOptions.addAll(tempList);
              }
              question.answerUnit?.listValue = selectedOptions;
              onAnswerUpdate(question);
            },
            child: Row(
              children: [
                Checkbox(
                  value: optionList[i].isSelected,
                  onChanged: (v) {},
                ),
                Flexible(
                  child: Text(optionList[i].name ?? '',
                      style: Get.context?.textTheme.bodyText1),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
