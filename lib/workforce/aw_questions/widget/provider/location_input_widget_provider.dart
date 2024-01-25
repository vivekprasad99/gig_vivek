import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/location/geo_address_input_widget.dart';
import 'package:awign/workforce/aw_questions/widget/location/location_input_widget.dart';
import 'package:flutter/cupertino.dart';

class LocationInputWidgetProvider {
  static Widget getInputWidget(
      Question question, Function(Question question) onAnswerUpdate) {
    if (question.inputType?.getValue2() == SubType.location) {
      return GeoAddressInputWidget(question, onAnswerUpdate);
    } else {
      return LocationInputWidget(question, onAnswerUpdate);
    }
  }
}
