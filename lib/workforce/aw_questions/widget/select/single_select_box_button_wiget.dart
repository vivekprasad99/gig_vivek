import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingleSelectBoxButtonWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  List<Option> optionList = [];
  int _groupValue = -1;

  SingleSelectBoxButtonWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    question.hasAnswered();
    SelectConfiguration? selectConfiguration =
        question.configuration as SelectConfiguration?;
    if (selectConfiguration != null && selectConfiguration.options != null) {
      addAllOptions(
          selectConfiguration.options!, question.answerUnit?.stringValue ?? '');
    } else if (selectConfiguration?.optionEntities != null) {
      addAllOptionsEntities(selectConfiguration!.optionEntities!,
          question.answerUnit?.optionValue);
    }
    return buildOptionList();
  }

  void addAllOptions(List<String> options, String answerValue) {
    for (int i = 0; i < options.length; i++) {
      Option option = Option(index: i, name: options[i]);
      if (option.name == answerValue) {
        _groupValue = i;
      }
      optionList.add(option);
    }
  }

  void addAllOptionsEntities(List<Option> options, Option? answerValue) {
    for (int i = 0; i < options.length; i++) {
      Option option = options[i];
      if (option.uid == answerValue?.uid) {
        _groupValue = i;
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
            color: _groupValue == i
                ? AppColors.primary50
                : AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(Dimens.radius_8),
            border: Border.all(
              color: _groupValue == i
                  ? AppColors.primaryMain
                  : AppColors.backgroundGrey400,
            ),
          ),
          child: MyInkWell(
            onTap: () {
              if (!(question.configuration?.isEditable ?? true)) {
                return;
              }
              question.answerUnit?.stringValue = optionList[i].name;
              question.answerUnit?.optionValue = optionList[i];
              onAnswerUpdate(question);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_14, Dimens.padding_16, Dimens.padding_14),
              child: Text(optionList[i].name ?? '',
                  style: Get.context?.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundBlack)),
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
