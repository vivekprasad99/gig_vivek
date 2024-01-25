import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rxdart/rxdart.dart';

class TextInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const TextInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> with Validator {
  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 200));
  final _text = BehaviorSubject<String?>();

  Function(String?) get _changeText => _text.sink.add;

  Stream<String?> get _textStream {
    switch (widget.question.answerUnit?.inputType?.getValue2()) {
      case SubType.short:
      case SubType.long:
        return _text.stream.transform(validateIsEmpty);
      case SubType.phone:
        return _text.stream.transform(validateMobileNumber);
      case SubType.email:
        return _text.stream.transform(validateEmail);
      case SubType.number:
        return _text.stream.transform(validateNumber);
      case SubType.panCardNumber:
        return _text.stream.transform(validatePANCardNumber);
      case SubType.float:
        return _text.stream.transform(validateFloatNumber);
      case SubType.url:
        return _text.stream.transform(validateURL);
      case SubType.pinCode:
        return _text.stream.transform(validatePincode);
      default:
        return _text.stream.transform(validateIsEmpty);
    }
  }

  @override
  void dispose() {
    _text.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildTextOptionOrAnswerWidget(context);
  }

  Widget buildTextOptionOrAnswerWidget(BuildContext context) {
    widget.question.answerUnit?.textEditingController ??=
        TextEditingController();

    if (widget.question.answerUnit?.stringValue != null &&
        (widget.question.answerUnit!.stringValue! !=
            widget.question.answerUnit?.textEditingController?.text)) {
      widget.question.answerUnit?.textEditingController?.text =
          widget.question.answerUnit!.stringValue!;
      widget.question.answerUnit?.textEditingController?.selection =
          TextSelection.fromPosition(TextPosition(
              offset: widget
                  .question.answerUnit!.textEditingController!.text.length));
    }
    return buildTextOptionWidget(context);
  }

  Widget buildTextOptionWidget(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _textStream,
      builder: (context, snapshot) {
        return TextField(
          onChanged: (value) {
            _debouncer(() {
              widget.question.answerUnit?.stringValue = value;
              if (widget.question.answerUnit?.hasAnswered() != null &&
                  !(widget.question.answerUnit!.hasAnswered())) {
                widget.question.configuration?.showErrMsg =
                    widget.question.uid == UID.referralCode ? false : true;
              } else {
                widget.question.configuration?.showErrMsg = false;
              }
              widget.onAnswerUpdate(widget.question);
              _changeText(value);
            });
          },
          readOnly: !(widget.question.configuration?.isEditable ?? false),
          controller: widget.question.answerUnit?.textEditingController,
          style: context.textTheme.bodyText1,
          maxLines: 1,
          keyboardType: widget.question.answerUnit?.getTextInputType(),
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.text_fields, color: context.theme.iconColorNormal),
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_8,
                Dimens.padding_8, Dimens.padding_8, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: widget.question.getPlaceHolderText() ?? 'enter_here'.tr,
            errorText: widget.question.uid == UID.referralCode
                ? null
                : (snapshot.error?.toString() != null ? '' : null),
            errorStyle: widget.question.uid == UID.referralCode
                ? null
                : context.textTheme.bodyText2?.copyWith(fontSize: 0),
            hintStyle: Get.textTheme.bodyText1
                ?.copyWith(color: context.theme.hintColor),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.theme.inputBoxBorderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.theme.inputBoxBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.theme.inputBoxBorderColor),
            ),
          ),
        );
      },
    );
  }
}
