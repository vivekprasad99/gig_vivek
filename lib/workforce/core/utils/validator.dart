import 'dart:async';

import 'package:get/get.dart';

class Validator {
  static final RegExp nameRegExp = RegExp('[a-zA-Z]');
  static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp panCardNumberRegExp = RegExp('[A-Z]{5}[0-9]{4}[A-Z]{1}');
  static final RegExp dlNumberRegExp = RegExp(r'^(([A-Z]{2}[0-9]{2})( )|([A-Z]{2}-[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$');
  static final RegExp accountNumberRegExp = RegExp('[0-9]{9,18}');
  static final RegExp ifscCodeRegExp = RegExp(r'^[A-Za-z]{4}0[A-Z0-9a-z]{6}$');
  static final RegExp upiRegExp =
      RegExp('[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}');
  static final RegExp floatRegExp = RegExp('^(\d*\.)?\d+');
  static final RegExp phoneNumberRegExp =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  static final RegExp gpsCoordinatesRegExp =
      RegExp(r'^([-+]?)([\d]{1,3})(\.)(\d+)$');
  static final RegExp alphaNumeric = RegExp('^[a-zA-Z0-9]');

  final validateIsEmpty = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkIsEmpty(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkIsEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'incorrect_value'.tr;
    } else {
      return null;
    }
  }

  final StreamTransformer<String?, String?> validateEmail =
      StreamTransformer<String?, String?>.fromHandlers(
    handleData: (email, sink) {
      String? result = checkEmail(email);
      if (result == null) {
        sink.add(email);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_email'.tr;
    } else if (GetUtils.isEmail(value)) {
      return null;
    } else {
      return 'enter_valid_email'.tr;
    }
  }

  final validatePassword = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkPassword(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_password'.tr;
    } else if (value.length < 6) {
      return 'password_must_be'.tr;
    } else {
      return null;
    }
  }

  final validName = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkName(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkName(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_name'.tr;
    } else if (nameRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'name_should_contain'.tr;
    }
  }

  final validateAddress = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkAddress(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'select_valid_address'.tr;
    } else {
      return null;
    }
  }

  final validatePincode = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkPincode(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkPincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_pincode'.tr;
    }
    if (value.length < 6 || value.length > 6) {
      return 'enter_valid_pincode'.tr;
    } else {
      return null;
    }
  }

  final validArea = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkArea(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkArea(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_area'.tr;
    } else {
      return null;
    }
  }

  final validateCity = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkCity(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_city'.tr;
    } else {
      return null;
    }
  }

  final validateState = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkState(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkState(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_state'.tr;
    } else {
      return null;
    }
  }

  final validateMobileNumber = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkMobileNumber(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkMobileNumber(String? value) {
    if (value == null) return 'enter_valid_mobile_number'.tr;
    if (value.length != 10) {
      return 'enter_valid_mobile_number'.tr;
    } else if (value.length == 10 && phoneNumberRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'enter_valid_mobile_number'.tr;
    }
  }

  final validateOTP = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkOTP(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  final validateDateOfBirth = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkDateOfBirthCombined(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  final validateValidity = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkValidity(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_otp'.tr;
    } else if (value.length < 5) {
      return 'enter_valid_otp'.tr;
    } else {
      return null;
    }
  }

  static String? check6DigitOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_otp'.tr;
    } else if (value.length < 6) {
      return 'enter_valid_otp'.tr;
    } else {
      return null;
    }
  }

  static String? checkPIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_pin'.tr;
    } else if (value.length < 4) {
      return 'enter_valid_pin'.tr;
    } else {
      return null;
    }
  }

  static String? checkValidity(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_valid_validity'.tr;
    } else if (value.length < 4) {
      return 'please_enter_valid_validity'.tr;
    } else {
      return null;
    }
  }

  static String? checkDateOfBirthCombined(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_dob'.tr;
    } else if (value.length < 4) {
      return 'please_enter_dob'.tr;
    } else {
      return null;
    }
  }

  static String? checkDateOfBirth(
      String? dayMonth, String? month, String? year) {
    if (checkMonthDay(dayMonth) != null ||
        checkMonth(month) != null ||
        checkYear(year) != null) {
      return 'please_enter_dob'.tr;
    } else {
      return null;
    }
  }

  static String? checkMonthDay(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_dob'.tr;
    } else {
      try {
        int day = int.parse(value);
        if (day == 0 || day > 31) {
          return 'please_enter_dob'.tr;
        } else {
          return null;
        }
      } catch (e) {
        return 'please_enter_dob'.tr;
      }
    }
  }

  static String? checkMonth(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_dob'.tr;
    } else {
      try {
        int month = int.parse(value);
        if (month == 0 || month > 12) {
          return 'please_enter_dob'.tr;
        } else {
          return null;
        }
      } catch (e) {
        return 'please_enter_dob'.tr;
      }
    }
  }

  static String? checkYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_dob'.tr;
    } else {
      try {
        int year = int.parse(value);
        int currentYear = DateTime.now().year;
        if (year < 4 || year > currentYear || year < 1920) {
          return 'please_enter_dob'.tr;
        } else {
          return null;
        }
      } catch (e) {
        return 'please_enter_dob'.tr;
      }
    }
  }

  String? checkIsAdult(DateTime birthDate) {
    // String datePattern = "dd-MM-yyyy";

    // Current time - at this moment
    DateTime today = DateTime.now();
    // Parsed date to check
    // DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 18 years ahead
    DateTime adultDate = DateTime(
      birthDate.year + 18,
      birthDate.month,
      birthDate.day,
    );
    if (adultDate.isBefore(today)) {
      return null;
    } else {
      return 'please_enter_dob'.tr;
    }
  }

  final validCollageName = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkCollageName(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkCollageName(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_collage_name'.tr;
    } else {
      return null;
    }
  }

  final validFieldOfStudy = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkFieldOfStudy(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkFieldOfStudy(String? value) {
    if (value == null || value.isEmpty) {
      return 'select_field_of_study'.tr;
    } else {
      return null;
    }
  }

  final validOtherStream = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkOtherStream(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkOtherStream(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_other_stream'.tr;
    } else {
      return null;
    }
  }

  final validStartYear = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkStartYear(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkStartYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'select_valid_start_year'.tr;
    } else {
      return null;
    }
  }

  final validEndYear = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkEndYear(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkEndYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'select_valid_end_year'.tr;
    } else {
      return null;
    }
  }

  static String? checkStartYearAndEndYear(String startYear, String endYear) {
    var intStartYear = int.parse(startYear);
    var intEndYear = int.parse(endYear);
    try {
      int currentYear = DateTime.now().year;
      if (intStartYear < currentYear && intStartYear < intEndYear) {
        return null;
      } else {
        return 'please_select_valid_start_year_end_year'.tr;
      }
    } catch (e) {
      return 'please_select_valid_start_year_end_year'.tr;
    }
  }

  final validateAlphaNumeric = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkAlphaNumeric(value);
      if(result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    }
  );

  final validateNumber = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkNumber(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  final validateDlNumber = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkDLNumber(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    }
  );

  static String? checkNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_number'.tr;
    } else if (GetUtils.isNum(value)) {
      return null;
    } else {
      return 'enter_valid_number'.tr;
    }
  }

  static String? checkAlphaNumeric(String? value) {
    if (value == null) {
      return 'enter_valid_input'.tr;
    } else if (alphaNumeric.hasMatch(value.toString())) {
      return null;
    } else {
      return 'enter_valid_input'.tr;
    }
  }

  final validatePANCardNumber =
      StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkPANCardNumber(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkPANCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_pan_number'.tr;
    } else if (panCardNumberRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'enter_valid_pan_number'.tr;
    }
  }

  static String? checkDLNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_dl_number'.tr;
    } else if (dlNumberRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'enter_valid_dl_number'.tr;
    }
  }

  final validateAccountNumber =
      StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkAccountNumber(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_account_number'.tr;
    } else if (accountNumberRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'enter_valid_account_number'.tr;
    }
  }

  final validateIFSCCode = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkIFSCCode(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkIFSCCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_ifsc_code'.tr;
    } else if (ifscCodeRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'enter_valid_ifsc_code'.tr;
    }
  }

  final validateUPI = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkUPI(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkUPI(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_upi'.tr;
    } else if (upiRegExp.hasMatch(value)) {
      return null;
    } else {
      return 'enter_valid_upi'.tr;
    }
  }

  final validateFloatNumber = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkFloatNumber(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkFloatNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_float_number'.tr;
    } else if (GetUtils.isNum(value)) {
      return null;
    } else {
      return 'enter_valid_float_number'.tr;
    }
  }

  final validateURL = StreamTransformer<String?, String?>.fromHandlers(
    handleData: (value, sink) {
      String? result = checkURL(value);
      if (result == null) {
        sink.add(value);
      } else {
        sink.addError(result);
      }
    },
  );

  static String? checkURL(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter_valid_url'.tr;
    } else if (GetUtils.isURL(value)) {
      return null;
    } else {
      return 'enter_valid_url'.tr;
    }
  }

  static String? checkGPSCoordinates(double? value) {
    if (value == null) {
      return 'please_select_location'.tr;
    } else if (gpsCoordinatesRegExp.hasMatch(value.toString())) {
      return null;
    } else {
      return 'please_select_location'.tr;
    }
  }
}
