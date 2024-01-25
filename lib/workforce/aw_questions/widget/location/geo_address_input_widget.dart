import 'package:awign/packages/google_maps_place_picker/src/models/pick_result.dart';
import 'package:awign/packages/google_maps_place_picker/src/place_picker.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/coordinates.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/your_location_button.dart';
import 'package:awign/workforce/core/widget/dialog/select_location/widget/select_location_widget.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoAddressInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  const GeoAddressInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  State<GeoAddressInputWidget> createState() => _GeoAddressInputWidgetState();
}

class _GeoAddressInputWidgetState extends State<GeoAddressInputWidget> {
  final TextEditingController _addressController = TextEditingController();
  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 200));

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.question.answerUnit?.textEditingController ??=
        TextEditingController();
    if (widget.question.answerUnit?.address?.pincode != null &&
        (widget.question.answerUnit!.address?.pincode! !=
            widget.question.answerUnit?.textEditingController?.text)) {
      widget.question.answerUnit?.textEditingController?.text =
          widget.question.answerUnit!.address!.pincode!;
      widget.question.answerUnit?.textEditingController?.selection =
          TextSelection.fromPosition(TextPosition(
              offset: widget
                  .question.answerUnit!.textEditingController!.text.length));
    }
    return buildSelectLocationOrAnswerWidget(context);
  }

  Widget buildSelectLocationOrAnswerWidget(BuildContext context) {
    if (widget.question.answerUnit?.hasAnswered() ?? false) {
      if (widget.question.answerUnit?.stringValue != null) {
        _addressController.text = widget.question.answerUnit?.stringValue ?? '';
      } else if (widget.question.answerUnit?.address?.area != null) {
        _addressController.text =
            widget.question.answerUnit?.address?.area ?? '';
      }
      return buildSelectLocationWidgets(context);
    } else {
      return buildSelectLocationWidgets(context);
    }
  }

  Widget buildSelectLocationWidgets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildYourCurrentLocationButton(),
        buildDividerContainer(),
        const Padding(
          padding:
              EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, Dimens.padding_12),
          child: TextFieldLabel(label: 'Enter Area'),
        ),
        buildAddressTextField(),
        buildPinCodeTextField(),
      ],
    );
  }

  Widget buildYourCurrentLocationButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: YourLocationButton(
        text: 'use_my_current_location'.tr,
        onPressed: () {
          showSelectLocationDialog(context, (PickResult? pickResult) {
            Helper.hideKeyBoard(context);
            _addressController.text = pickResult?.formattedAddress ?? '';
            widget.question.answerUnit?.textEditingController?.text =
                pickResult?.postalCode ?? '';
            Address address = Address.fromLocationResult(pickResult);
            widget.question.answerUnit?.address = address;
            widget.question.answerUnit?.stringValue =
                pickResult?.formattedAddress ?? '';
            widget.question.answerUnit?.coordinates = Coordinates(
                latitude: pickResult?.latitude ?? 0.0,
                longitude: pickResult?.longitude ?? 0.0);
            if (widget.question.answerUnit?.hasAnswered() != null &&
                !(widget.question.answerUnit!.hasAnswered())) {
              widget.question.configuration?.showErrMsg = true;
            } else {
              widget.question.configuration?.showErrMsg = false;
            }
            widget.onAnswerUpdate(widget.question);
          });
        },
      ),
    );
  }

  Widget buildDividerContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: Row(
        children: [
          Expanded(child: HDivider(dividerColor: AppColors.backgroundGrey300)),
          buildOrText(),
          Expanded(child: HDivider(dividerColor: AppColors.backgroundGrey300)),
        ],
      ),
    );
  }

  Widget buildOrText() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_8),
      margin: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
      child: Text(
        'or'.tr,
        style: Get.context?.textTheme.bodyText1
            ?.copyWith(color: AppColors.backgroundGrey700),
      ),
    );
  }

  Widget buildAddressTextField() {
    return IntrinsicHeight(
      child: PlacePicker(
        onScreenAutocomplete: true,
        onScreenTextEditingController: _addressController,
        apiKey: Constants.googleApiKey,
        initialPosition: const LatLng(-33.8567844, 151.213108),
        useCurrentLocation: true,
        selectInitialPosition: true,
        hintText: 'search_locality'.tr,
        onPlacePicked: (pickResult) {
          Helper.hideKeyBoard(context);
          _addressController.text = pickResult?.formattedAddress ?? '';
          widget.question.answerUnit?.textEditingController?.text =
              pickResult?.postalCode ?? '';
          Address address = Address.fromLocationResult(pickResult);
          widget.question.answerUnit?.address = address;
          widget.question.answerUnit?.stringValue =
              pickResult?.formattedAddress ?? '';
          widget.question.answerUnit?.coordinates = Coordinates(
              latitude: pickResult?.latitude ?? 0.0,
              longitude: pickResult?.longitude ?? 0.0);
          if (widget.question.answerUnit?.hasAnswered() != null &&
              !(widget.question.answerUnit!.hasAnswered())) {
            widget.question.configuration?.showErrMsg = true;
          } else {
            widget.question.configuration?.showErrMsg = false;
          }
          widget.onAnswerUpdate(widget.question);
        },
      ),
    );
  }

  Widget buildPinCodeTextField() {
    if (widget.question.answerUnit?.address != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, Dimens.padding_32, 0, 0),
            child: TextFieldLabel(label: 'Enter Pincode'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, Dimens.padding_12, 0, 0),
            child: TextField(
              style: context.textTheme.bodyText1,
              onChanged: (value) {
                _debouncer(() {
                  Address? address = widget.question.answerUnit?.address;
                  address?.pincode = value;
                  widget.question.answerUnit?.address = address;
                  if (widget.question.answerUnit?.hasAnswered() != null &&
                      !(widget.question.answerUnit!.hasAnswered())) {
                    widget.question.configuration?.showErrMsg = true;
                  } else {
                    widget.question.configuration?.showErrMsg = false;
                  }
                  widget.onAnswerUpdate(widget.question);
                  // _changeText(value);
                });
              },
              controller: widget.question.answerUnit?.textEditingController,
              keyboardType: TextInputType.number,
              maxLines: 1,
              maxLength: 6,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                      Dimens.margin_8, Dimens.margin_12, Dimens.margin_8),
                  child: SvgPicture.asset("assets/images/ic_location.svg"),
                ),
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                    Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                fillColor: context.theme.textFieldBackgroundColor,
                hintText: 'pincode'.tr,
                // errorText: errorMessage,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.inputBoxBorderColor),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.inputBoxBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.inputBoxBorderColor),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
