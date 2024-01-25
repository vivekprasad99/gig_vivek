import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_actions.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_events.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_page_names.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/location_captured_bottom_sheet/cubit/location_captured_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void showCaptureLocationBottomSheet(
    BuildContext context,bool? isNotLastScreen,Function(Position?) onSubmitTap,Function() onCancelTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.6,
        builder: (context, scrollController) {
          return CaptureLocationBottomSheet(isNotLastScreen,onSubmitTap,onCancelTap);
        },
      );
    },
  );
}

class CaptureLocationBottomSheet extends StatefulWidget {
  final bool? isNotLastScreen;
  final Function(Position?) onSubmitTap;
  final Function() onCancelTap;
  const CaptureLocationBottomSheet(this.isNotLastScreen,this.onSubmitTap,this.onCancelTap,{Key? key})
      : super(key: key);

  @override
  State<CaptureLocationBottomSheet> createState() => _CaptureLocationBottomSheetState();
}

class _CaptureLocationBottomSheetState extends State<CaptureLocationBottomSheet> {

  final LocationCapturedBottomSheetCubit _locationCapturedBottomSheetCubit = sl<LocationCapturedBottomSheetCubit>();
  String? locationValue = "";
  Position? currentPosition;
  LocationAccuracy? desiredAccuracy;
  @override
  void initState() {
    super.initState();
    getLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_36,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCloseButton(),
              buildEarthImage(),
            ],
          ),
        ),
        Positioned(
            left: MediaQuery.sizeOf(context).width * 0.40,
            top: MediaQuery.sizeOf(context).width * 0.25,
            child: CircleAvatar(
                backgroundColor: AppColors.link100,
                radius: Dimens.padding_36,
                child: SvgPicture.asset('assets/images/location-tick.svg'))),
        buildLocationCapturedText(),
      ],
    );
  }

  Widget buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
         widget.onCancelTap();
        },
        child: const CircleAvatar(
          backgroundColor: AppColors.backgroundGrey700,
          radius: Dimens.padding_12,
          child: Icon(
            Icons.close,
            color: AppColors.backgroundWhite,
            size: Dimens.padding_16,
          ),
        ),
      ),
    );
  }

  Widget buildEarthImage() {
    return SvgPicture.asset(
      'assets/images/earth.svg',
    );
  }

  Widget buildLocationCapturedText() {
    return Positioned(
      top: MediaQuery.sizeOf(Get.context!).width * 0.45,
      width: MediaQuery.sizeOf(Get.context!).width * 1,
      height: MediaQuery.sizeOf(Get.context!).width * 1,
      child: Container(
        color: AppColors.backgroundWhite,
        child: Column(
          children: [
            const SizedBox(height: Dimens.margin_8),
            Text(
              'location_captured'.tr,
              textAlign: TextAlign.center,
              style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: Dimens.margin_8),
            showTimeAndDateWidget(),
            const SizedBox(height: Dimens.margin_8),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_24),
              child: Text(
                '$locationValue',
                textAlign: TextAlign.center,
                style: Get.context?.textTheme.bodyMedium?.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: Dimens.margin_24),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_28),
              child: RaisedRectButton(
                text: widget.isNotLastScreen! ? 'submit_proceed'.tr :'submit'.tr,
                buttonStatus: _locationCapturedBottomSheetCubit.buttonStatus,
                borderColor: AppColors.backgroundGrey400,
                onPressed: () {
                  widget.onSubmitTap(currentPosition);
                  LoggingData loggingData = LoggingData(
                      event: LoggingEvents.submitProceedLocationClicked,
                      action: LoggingActions.clicked,pageName: LoggingPageNames.locationCaptured);
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
              ),
            ),
            const SizedBox(height: Dimens.margin_24),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_28),
              child: RaisedRectButton(
                text: 'retry'.tr,
                borderColor: AppColors.primaryMain,
                textColor: AppColors.primaryMain,
                backgroundColor: AppColors.backgroundWhite,
                onPressed: () async {
                 await getLocation();
                 LoggingData loggingData = LoggingData(
                     event: LoggingEvents.retakeLocationClicked,
                     action: LoggingActions.clicked,pageName: LoggingPageNames.locationCaptured);
                 CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getLocation() async {
    _locationCapturedBottomSheetCubit
        .changeButtonStatus(ButtonStatus(isEnable: false));
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy ?? LocationAccuracy.best);
    final List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition!.latitude, currentPosition!.longitude);
    final Placemark place = placemarks[0];
    setState(() {
      _locationCapturedBottomSheetCubit.changeButtonStatus(ButtonStatus(isEnable: true));
      locationValue = '${place.street}, ${place.subLocality},${place.locality},${place.administrativeArea}, ${place.country}, ${place.postalCode}';
    });
  }

  Widget showTimeAndDateWidget()
  {
    DateTime currentDateAndTime = DateTime.now();
    String time = DateFormat(StringUtils.timeFormatHMA).format(currentDateAndTime);
    String date =
        "${currentDateAndTime.day} ${DateFormat.MMM().format(currentDateAndTime)} ${currentDateAndTime.year}";
    return Text(
      '$time | $date',
      textAlign: TextAlign.center,
      style: Get.context?.textTheme.bodyMedium?.copyWith(
        color: AppColors.black,
      ),
    );
  }
}
