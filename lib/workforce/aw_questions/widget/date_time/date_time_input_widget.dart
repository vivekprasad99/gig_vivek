import 'package:awign/workforce/aw_questions/data/model/configuration/date/date_time_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/aw_questions/widget/date_time/helper/date_time_configuration_helper.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateTimeInputWidget extends StatelessWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  late final DateTimeConfiguration _dateTimeConfiguration;

  DateTimeInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key) {
    _dateTimeConfiguration = question.configuration as DateTimeConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    return buildSelectOptionOrAnswerWidget(context);
  }

  Widget buildSelectOptionOrAnswerWidget(BuildContext context) {
    if (question.answerUnit?.stringValue != null &&
        question.answerUnit!.stringValue!.isNotEmpty) {
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
        _showDateTimePicker(context);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: Dimens.padding_8),
                child: DateTimeConfigurationHelper.getIcon(
                    _dateTimeConfiguration.subType)),
            const SizedBox(width: Dimens.padding_12),
            Text(question.getPlaceHolderText() ?? 'enter_here'.tr,
                style: Get.textTheme.bodyText1
                    ?.copyWith(color: context.theme.hintColor)),
          ],
        ),
      ),
    );
  }

  Widget buildAnswerWidget(BuildContext context) {
    String? answerValue = question.answerUnit?.stringValue ?? '';
    if ((question.answerUnit?.stringValue ?? '').contains('T')) {
      answerValue = question.answerUnit?.stringValue!
          .getFormattedDateTimeFromUTCDateTime(
              _dateTimeConfiguration.getMappedDateTimeFormat());
    }
    return MyInkWell(
      onTap: () {
        Helper.hideKeyBoard(context);
        if (!(question.configuration?.isEditable ?? true)) {
          return;
        }
        _showDateTimePicker(context);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: Dimens.padding_8),
                child: DateTimeConfigurationHelper.getIcon(
                    _dateTimeConfiguration.subType),
              ),
              const SizedBox(width: Dimens.padding_12),
              Flexible(
                  child:
                      Text(answerValue ?? '', style: Get.textTheme.bodyText1)),
            ],
          ),
        ),
      ),
    );
  }

  _showDateTimePicker(BuildContext context) {
    DateTimeConfigurationHelper.showPicker(context, _dateTimeConfiguration, '',
        (strDateTime) {
      if (strDateTime != null) {
        question.answerUnit?.stringValue = strDateTime;
        onAnswerUpdate(question);
      } else {
        Helper.showErrorToast('not_answered'.tr);
      }
    }, isDOBPicker: question.uid == UID.dateOfBirth ? true : false);
  }
}
