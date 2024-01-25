import 'package:awign/packages/google_maps_place_picker/src/models/pick_result.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/coordinates.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/select_location/widget/select_location_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import '../../../core/utils/implicit_intent_utils.dart';

class LocationInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const LocationInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  String? locationValue = "";

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return buildSelectLocationOrAnswerWidget(context);
  }

  Widget buildSelectLocationOrAnswerWidget(BuildContext context) {
    if (widget.question.answerUnit?.hasAnswered() ?? false) {
      return buildAnswerWidget(context);
    } else {
      return buildSelectLocationWidget(context);
    }
  }

  Widget buildSelectLocationWidget(BuildContext context) {
    return MyInkWell(
      onTap: () {
        _showSelectLocationDialog(context);
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(Icons.location_pin, color: Get.theme.iconColorNormal),
              const SizedBox(width: Dimens.padding_12),
              Text('tap_to_get_location'.tr,
                  style: Get.textTheme.bodyText1
                      ?.copyWith(color: context.theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnswerWidget(BuildContext context) {
    return Column(
      children: [
        MyInkWell(
          onTap: () {
            _showSelectLocationDialog(context);
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
              child: Text(
                  (widget.question.answerUnit?.stringValue.isNullOrEmpty ==
                          true)
                      ? locationValue ?? ""
                      : widget.question.answerUnit?.stringValue ?? "",
                  style: Get.textTheme.bodyText1),
            ),
          ),
        ),
        buildViewButton(),
      ],
    );
  }

  Widget buildViewButton() {
    if (!(widget.question.configuration?.isEditable ?? true)) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_8, Dimens.padding_16, Dimens.padding_8, 0),
          child: MyInkWell(
            onTap: () {
              if (widget.question.answerUnit?.coordinates?.latitude != null &&
                  widget.question.answerUnit?.coordinates?.longitude != null) {
                ImplicitIntentUtils().fireLocationIntent([
                  widget.question.answerUnit!.coordinates!.latitude.toString(),
                  widget.question.answerUnit!.coordinates!.longitude.toString()
                ]);
              }
            },
            child: Text(
              'view'.tr,
              style: Get.textTheme.bodyText2?.copyWith(
                  color: Get.theme.iconColorHighlighted,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  _showSelectLocationDialog(BuildContext context) {
    if (!(widget.question.configuration?.isEditable ?? true)) {
      return;
    }
    showSelectLocationDialog(context, (PickResult? pickResult) {
      widget.question.answerUnit?.stringValue =
          pickResult?.formattedAddress ?? '';
      widget.question.answerUnit?.coordinates = Coordinates(
          latitude: pickResult?.latitude ?? 0.0,
          longitude: pickResult?.longitude ?? 0.0);
      widget.onAnswerUpdate(widget.question);
    },
        isSearchBarVisible:
            widget.question.answerUnit?.inputType == InputType.geoAddress
                ? true
                : false);
  }

  Future<void> getLocation() async {
    if (widget.question.answerUnit?.stringValue != null) {
      setState(() {
        locationValue = widget.question.answerUnit?.stringValue;
      });
    } else {
      if (widget.question.answerUnit?.coordinates != null) {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
            widget.question.answerUnit!.coordinates!.latitude,
            widget.question.answerUnit!.coordinates!.longitude);
        final Placemark place = placemarks[0];
        setState(() {
          locationValue =
              "${place.name}, ${place.subLocality}, ${place.locality}, ${place.country}, ${place.postalCode}";
        });
      }
    }
  }
}
