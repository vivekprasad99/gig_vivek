import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_range.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/coordinates.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/hash_answer.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/trackable_data_holder.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/verifyable_answer.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/date_time/helper/date_time_validation_helper.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';

class AnswerUnit {
  AnswerUnit({
    this.inputType,
    this.dateType,
    this.stringValue,
    this.listValue,
    this.coordinates,
    this.arrayValue,
    this.hashValue,
    this.answerRange,
    this.trackableDataHolder,
    this.verifyableAnswer,
    this.imageDetails,
    this.documentDetailsData,
  });

  late InputType? inputType;
  late DataType? dateType;
  late String? stringValue;
  bool? boolValue;
  Option? optionValue;
  late List<String>? listValue;
  List<Option>? optionListValue;
  late Coordinates? coordinates;
  late List<AnswerUnit>? arrayValue;
  late List<HashAnswer>? hashValue;
  late AnswerRange? answerRange;
  late TrackableDataHolder? trackableDataHolder;
  late VerifyableAnswer? verifyableAnswer;
  TextEditingController? textEditingController;
  late ImageDetails? imageDetails;
  Address? address;
  DocumentDetailsData? documentDetailsData;

  bool hasAnswered(
      {bool isCheckImageDetails = false, Configuration? configuration}) {
    return isValid(
        isCheckImageDetails: isCheckImageDetails, configuration: configuration);
  }

  bool isValid(
      {bool isCheckImageDetails = false, Configuration? configuration}) {
    bool isValid = false;
    switch (dateType) {
      case DataType.single:
        switch (inputType?.getValue1()) {
          case ConfigurationType.text:
            switch (inputType?.getValue2()) {
              case SubType.short:
              case SubType.long:
                isValid = !stringValue.isNullOrEmpty;
                break;
              case SubType.codeScanner:
                if (configuration?.characterFormat == Constants.number) {
                  if (configuration?.characterLimit != null) {
                    if (stringValue?.trim().length == configuration!.characterLimit! &&
                        Validator.checkNumber(stringValue) == null) {
                      isValid = true;
                    } else {
                      isValid = false;
                    }
                  } else if (Validator.checkNumber(stringValue) == null) {
                    isValid = true;
                  } else {
                    isValid = false;
                  }
                } else if (configuration?.characterFormat ==
                    Constants.alphanumeric) {
                  if (configuration?.characterLimit != null) {
                    if(stringValue?.trim().length == configuration!.characterLimit! &&
                    Validator.checkAlphaNumeric(stringValue) == null)
                      {
                        isValid = true;
                      }else {
                      isValid = false;
                    }

                  } else if (Validator.checkAlphaNumeric(stringValue) == null) {
                    isValid = true;
                  } else {
                    isValid = false;
                  }
                } else {
                  isValid = !stringValue.isNullOrEmpty;
                }
                break;
              case SubType.phone:
                isValid = Validator.checkMobileNumber(stringValue) == null
                    ? true
                    : false;
                break;
              case SubType.email:
                isValid =
                    Validator.checkEmail(stringValue) == null ? true : false;
                break;
              case SubType.number:
                isValid =
                    Validator.checkNumber(stringValue) == null ? true : false;
                break;
              case SubType.panCardNumber:
                isValid = Validator.checkPANCardNumber(stringValue) == null
                    ? true
                    : false;
                break;
              case SubType.float:
                isValid = Validator.checkFloatNumber(stringValue) == null
                    ? true
                    : false;
                break;
              case SubType.url:
                isValid =
                    Validator.checkURL(stringValue) == null ? true : false;
                break;
              case SubType.pinCode:
                isValid =
                    Validator.checkPincode(stringValue) == null ? true : false;
            }
            break;
          case ConfigurationType.singleSelect:
          case ConfigurationType.dateTime:
            isValid = !stringValue.isNullOrEmpty;
            break;
          case ConfigurationType.multiSelect:
            if (listValue != null && listValue!.isNotEmpty) {
              isValid = true;
            } else if (optionListValue != null && optionListValue!.isNotEmpty) {
              isValid = true;
            } else {
              isValid = false;
            }
            break;
          case ConfigurationType.dateTimeRange:
            isValid = DateTimeValidationHelper.validateRange(
                inputType?.getValue2(), answerRange?.from, answerRange?.to);
            break;
          case ConfigurationType.file:
          case ConfigurationType.audioRecording:
            if (documentDetailsData != null) {
              isValid = true;
            } else if (isCheckImageDetails) {
              isValid = imageDetails != null ? true : false;
            } else {
              isValid = Validator.checkURL(stringValue) == null ? true : false;
            }
            break;
          case ConfigurationType.location:
            if (inputType?.getValue2() == SubType.location) {
              if (Validator.checkGPSCoordinates(coordinates?.latitude) !=
                      null ||
                  Validator.checkGPSCoordinates(coordinates?.longitude) !=
                      null ||
                  Validator.checkPincode(address?.pincode) != null) {
                isValid = false;
              } else {
                isValid = true;
              }
            } else {
              if (Validator.checkGPSCoordinates(coordinates?.latitude) !=
                      null ||
                  Validator.checkGPSCoordinates(coordinates?.longitude) !=
                      null) {
                isValid = false;
              } else {
                isValid = true;
              }
            }
            break;
          case ConfigurationType.signature:
            switch (inputType?.getValue2()) {
              case SubType.signature:
                isValid =
                    Validator.checkURL(stringValue) == null ? true : false;
                break;
            }
            break;
          case ConfigurationType.nested:
            if (hashValue != null && hashValue!.isNotEmpty) {
              isValid = true;
            } else {
              isValid = false;
            }
            break;
          // case ConfigurationType.bool:
          //   if (boolValue != null && boolValue!) {
          //     isValid = true;
          //   } else {
          //     isValid = false;
          //   }
          //   break;
        }
        break;
      case DataType.array:
        if (arrayValue.isNullOrEmpty) {
          isValid = false;
        } else {
          bool lIsValid = true;
          for (AnswerUnit answerUnit in arrayValue!) {
            if (!answerUnit.isValid(isCheckImageDetails: isCheckImageDetails)) {
              lIsValid = false;
              break;
            }
          }
          isValid = lIsValid;
        }
        break;
    }
    return isValid;
  }

  TextInputType getTextInputType() {
    TextInputType textInputType = TextInputType.text;
    switch (inputType?.getValue2()) {
      case SubType.short:
      case SubType.long:
        textInputType = TextInputType.text;
        break;
      case SubType.phone:
        textInputType = TextInputType.phone;
        break;
      case SubType.email:
        textInputType = TextInputType.emailAddress;
        break;
      case SubType.number:
        textInputType = TextInputType.numberWithOptions(decimal: false);
        break;
      case SubType.panCardNumber:
        textInputType = TextInputType.text;
        break;
      case SubType.float:
        textInputType = const TextInputType.numberWithOptions(decimal: true);
        break;
      case SubType.url:
        textInputType = TextInputType.url;
        break;
      case SubType.pinCode:
        textInputType = TextInputType.number;
        break;
      default:
        textInputType = TextInputType.text;
    }
    return textInputType;
  }
}
