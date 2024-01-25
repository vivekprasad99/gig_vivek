import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import '../../../../core/router/router.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../data/model/question.dart';

class CodeScannerInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const CodeScannerInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  State<CodeScannerInputWidget> createState() => _CodeScannerInputWidgetState();
}

class _CodeScannerInputWidgetState extends State<CodeScannerInputWidget>
    with Validator {
  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 200));
  final _text = BehaviorSubject<String?>();

  Function(String?) get _changeText => _text.sink.add;

  Stream<String?> get _textStream {
    switch (widget.question.configuration?.characterFormat) {
      case 'number':
        return _text.stream.transform(Validator().validateNumber);
      case 'alphanumeric':
        return _text.stream.transform(Validator().validateAlphaNumeric);
      default:
        return _text.stream;
    }
  }

  Stream<String?> get _checkTextLimitStream {
    if (widget.question.configuration?.characterLimit != null) {
      return _text.stream
          .transform(StreamTransformer<String?, String?>.fromHandlers(
        handleData: (value, sink) {
          if (value?.trim().length == widget.question.configuration!.characterLimit!) {
            sink.add(value);
          } else {
            sink.addError('character_limit_exceeded'.tr);
          }
        },
      ));
    } else {
      return _text.stream;
    }
  }

  @override
  void dispose() {
    _text.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Stack(
      children: [
        StreamBuilder<String?>(
            stream: _checkTextLimitStream,
            builder: (context, textLimit) {
              return StreamBuilder<String?>(
                  stream: _textStream,
                  builder: (context, snapshot) {
                    if (textLimit.error?.toString() != null ||
                        snapshot.error?.toString() != null) {
                      widget.question.configuration?.errMsg = snapshot.error?.toString() ??
                          textLimit.error?.toString();
                    }
                    return TextField(
                        onChanged: (value) {
                          _debouncer(() {
                            checkValidation(value,snapshot.error?.toString() ?? textLimit.error?.toString(),false);
                          });
                        },
                        controller:
                            widget.question.answerUnit?.textEditingController,
                        style: context.textTheme.bodyText1,
                        maxLines: 1,
                        keyboardType:
                            widget.question.answerUnit?.getTextInputType(),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.fromLTRB(
                              Dimens.padding_8,
                              Dimens.padding_8,
                              Dimens.padding_8,
                              Dimens.padding_8),
                          fillColor: context.theme.textFieldBackgroundColor,
                          hintText:
                              '${'enter_text_or_open_scanner'.tr}${widget.question.configuration?.uploadFrom == UploadFromOption.gallery ? 'Gallery' : 'Scanner'}',
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.inputBoxBorderColor),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.inputBoxBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.inputBoxBorderColor),
                          ),
                        ));
                  });
            }),
        Align(
          alignment: Alignment.centerRight,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: widget.question.answerUnit?.textEditingController
                          ?.text.isEmpty ==
                      false,
                  child: IconButton(
                      splashRadius: Dimens.radius_4,
                      onPressed: () {
                        checkValidation("","",true);
                      },
                      icon: SvgPicture.asset(
                          'assets/images/ic_close_circle.svg')),
                ),
                const VerticalDivider(
                  width: Dimens.dividerWidth_1,
                  thickness: Dimens.dividerWidth_1,
                  indent: Dimens.padding_8,
                  endIndent: Dimens.padding_8,
                  color: Colors.grey,
                ),
                buildUploadFromScannerOrGallery()
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildUploadFromScannerOrGallery() {
    return IconButton(
        onPressed: () async {
          if (widget.question.configuration?.uploadFrom ==
              UploadFromOption.gallery) {
            FilePickerHelper.pickMedia(SubType.image, DataType.single,
                (result) async {
              File file = File(result.files.single.path ?? '');
              XFile xFile = XFile(file.path);
              Code? resultFromXFile = await zx.readBarcodeImagePath(xFile);
              if (resultFromXFile.isValid) {
                _debouncer(() {
                  checkValidation(resultFromXFile.text.toString(),"",true);
                });
              } else {
                _debouncer(() {
                  checkValidation("",'unable_to_recognise_a_valid_code_from_the_uploaded_image'.tr,true);
                });
              }
            });
          } else {
            String? scannerValue = await MRouter.pushNamed(
                MRouter.codeScannerWidget,
                arguments: widget.question);
            _debouncer(() {
              checkValidation(scannerValue!,"",true);
            });
          }
        },
        icon: SvgPicture.asset(
          widget.question.configuration?.uploadFrom == UploadFromOption.gallery
              ? 'assets/images/code_scanner_gallery.svg'
              : 'assets/images/ic_scan.svg',
        ));
  }

  void checkValidation(String value,String? errorText,bool isNotComingFromOnChange) {
    widget.question.answerUnit?.stringValue = value;
    if (widget.question.answerUnit?.hasAnswered(
        configuration:
        widget.question.configuration) !=
        null &&
        !(widget.question.answerUnit!.hasAnswered(
            configuration:
            widget.question.configuration))) {
      widget.question.configuration?.showErrMsg = true;
      if(errorText != null)
        {
          widget.question.configuration?.errMsg =
              errorText;
        }
    } else {
      widget.question.configuration?.showErrMsg = false;
    }
    widget.onAnswerUpdate(widget.question);
    if(isNotComingFromOnChange)
      {
        widget.question.answerUnit?.textEditingController?.text = value;
      }
    _changeText(value);
  }
}
