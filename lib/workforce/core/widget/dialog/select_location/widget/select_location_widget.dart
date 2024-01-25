import 'package:awign/packages/google_maps_place_picker/src/models/pick_result.dart';
import 'package:awign/packages/google_maps_place_picker/src/place_picker.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void showSelectLocationDialog(BuildContext context, Function(PickResult? pickResult) onPlacePicked, {bool isSearchBarVisible = true}) async {
  bool serviceEnabled;
  LocationPermission locationPermission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
      Helper.showErrorToast("Location services are disabled.");
      Geolocator.openLocationSettings();
      return;
  }

  locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.denied) {
      Helper.showErrorToast("Location permissions are denied");
      return;
    }
  }
  if (locationPermission == LocationPermission.deniedForever) {
    Helper.showErrorToast(
        'Location permissions are permanently denied, we cannot request permissions.');
    Geolocator.openAppSettings();
  }

  showDialog<bool>(
    context: context,
    builder: (_) => CustomDialog(
      child: SelectLocationWidget(onPlacePicked: onPlacePicked, isSearchBarVisible: isSearchBarVisible),
    ),
  );
}

class SelectLocationWidget extends StatelessWidget {
  Function(PickResult? pickResult) onPlacePicked;
  late bool isSearchBarVisible;
  SelectLocationWidget({Key? key, required this.onPlacePicked, required this.isSearchBarVisible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_32)),
      ),
      child: InternetSensitive(
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return buildGoogleMap();
  }

  Widget buildGoogleMap() {
    return PlacePicker(
      apiKey: Constants.googleApiKey,
      initialPosition: const LatLng(-33.8567844, 151.213108),
      useCurrentLocation: true,
      selectInitialPosition: true,
      hintText: 'search_locality'.tr,
      isSearchBarVisible: isSearchBarVisible,
      onPlacePicked: (result) {
        onPlacePicked(result);
        MRouter.pop(null);
      },
    );
  }
}
