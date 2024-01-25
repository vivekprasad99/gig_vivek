import 'package:awign/workforce/aw_questions/data/model/answer/answer_range.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/date/date_time_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/date_time/helper/date_time_configuration_helper.dart';
import 'package:awign/workforce/aw_questions/widget/date_time/helper/date_time_validation_helper.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateTimeRangeInputWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  late final DateTimeConfiguration _dateTimeConfiguration;

  DateTimeRangeInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key) {
    _dateTimeConfiguration = question.configuration as DateTimeConfiguration;
    question.answerUnit?.answerRange ??= AnswerRange();
  }

  @override
  Widget build(BuildContext context) {
    return buildSelectOptionWidget(context);
  }

  Widget buildSelectOptionWidget(BuildContext context) {
    return Column(
      children: [
        buildFromDateTimeAnswerWidget(context),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.padding_8),
          child: HDivider(),
        ),
        buildToDateTimeAnswerWidget(context),
      ],
    );
  }

  Widget buildTextWidget(String text) {
    return Container(
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
            Padding(
                padding: const EdgeInsets.only(top: Dimens.padding_8),
                child: DateTimeConfigurationHelper.getIcon(
                    _dateTimeConfiguration.subType)),
            const SizedBox(width: Dimens.padding_12),
            Text(text,
                style: Get.textTheme.bodyText1?.copyWith(
                    color: text.isEmpty
                        ? Get.theme.hintColor
                        : Get.textTheme.bodyText1?.color)),
          ],
        ),
      ),
    );
  }

  Widget buildFromDateTimeAnswerWidget(BuildContext context) {
    String? answerValue =
        DateTimeConfigurationHelper.getHintTextForDateTimeRange(
            _dateTimeConfiguration.subType, true);
    if (question.answerUnit?.answerRange?.from != null) {
      answerValue = question.answerUnit?.answerRange?.from;
    }
    if ((question.answerUnit?.answerRange?.from ?? '').contains('T')) {
      answerValue = question.answerUnit?.answerRange?.from!
          .getFormattedDateTimeFromUTCDateTime(
              _dateTimeConfiguration.getMappedDateTimeFormat());
    }
    return MyInkWell(
      onTap: () {
        Helper.hideKeyBoard(context);
        if (!(question.configuration?.isEditable ?? true)) {
          return;
        }
        DateTimeConfigurationHelper.showPicker(
            context, _dateTimeConfiguration, '', (strDateTime) {
          if (strDateTime != null) {
            question.answerUnit?.answerRange?.from = strDateTime;
            question.answerUnit?.answerRange?.to = null;
            question.configuration?.showErrMsg = true;
            onAnswerUpdate(question);
          } else {
            Helper.showErrorToast('not_answered'.tr);
          }
        });
      },
      child: buildTextWidget(answerValue ?? ''),
    );
  }

  Widget buildToDateTimeAnswerWidget(BuildContext context) {
    String? answerValue =
        DateTimeConfigurationHelper.getHintTextForDateTimeRange(
            _dateTimeConfiguration.subType, false);
    if (question.answerUnit?.answerRange?.to != null) {
      answerValue = question.answerUnit?.answerRange?.to;
    }
    if ((question.answerUnit?.answerRange?.to ?? '').contains('T')) {
      answerValue = question.answerUnit?.answerRange?.to!
          .getFormattedDateTimeFromUTCDateTime(
              _dateTimeConfiguration.getMappedDateTimeFormat());
    }
    return MyInkWell(
      onTap: () {
        Helper.hideKeyBoard(context);
        if (!(question.configuration?.isEditable ?? true)) {
          return;
        }
        if ((question.answerUnit?.answerRange?.from ?? '').isEmpty) {
          Helper.showErrorToast('start_date_time_is_empty'.tr);
          return;
        }
        DateTimeConfigurationHelper.showPicker(
            context, _dateTimeConfiguration, '', (strDateTime) {
          if (strDateTime != null) {
            if (DateTimeValidationHelper.validateRange(
                question.inputType?.getValue2(),
                question.answerUnit?.answerRange?.from,
                strDateTime)) {
              question.answerUnit?.answerRange?.to = strDateTime;
              question.configuration?.showErrMsg = false;
              onAnswerUpdate(question);
            } else {
              question.answerUnit?.answerRange?.to = null;
              question.configuration?.showErrMsg = true;
              onAnswerUpdate(question);
              Helper.showErrorToast(
                  DateTimeValidationHelper.getInvalidRangeValueError(
                      _dateTimeConfiguration));
            }
          } else {
            Helper.showErrorToast('not_answered'.tr);
          }
        });
      },
      child: buildTextWidget(answerValue ?? ''),
    );
  }
}
