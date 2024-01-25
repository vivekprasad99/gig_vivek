import 'package:awign/packages/google_maps_place_picker/src/models/pick_result.dart';
import 'package:awign/packages/google_maps_place_picker/src/place_picker.dart';
import 'package:awign/workforce/auth/feature/user_location/cubit/user_location_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/new_default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/buttons/your_location_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/select_location/widget/select_location_widget.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/stepper/stepper.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

class UserLocationWidget extends StatefulWidget {
  const UserLocationWidget({Key? key}) : super(key: key);

  @override
  _UserLocationWidgetState createState() => _UserLocationWidgetState();
}

class _UserLocationWidgetState extends State<UserLocationWidget> {
  final _yourLocationCubit = sl<UserLocationCubit>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    setData();
  }

  void subscribeUIStatus() {
    _yourLocationCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            SPUtil? spUtil = await SPUtil.getInstance();
            _currentUser = spUtil?.getUserData();
            Map<String, dynamic> properties =
                await UserProperty.getUserProperty(_currentUser);
            ClevertapHelper.instance().addCleverTapEvent(
                ClevertapHelper.onboardingLocationProvided, properties);
            AuthHelper.checkOnboardingStages(_currentUser!);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void setData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          NewDefaultAppBar(
            isBackButton: true,
            isActionButton: true,
            title: "Personal Details",
            description: "Please give your location details",
            image: "assets/images/location_icon.svg",
          ),
          buildBody(),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Expanded(
      child: InternetSensitive(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, Dimens.margin_12, 0, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: Dimens.margin_16),
                        child: CustomStepper(
                          icon1: "assets/images/done_step.svg",
                          hDivider1: AppColors.success300,
                          icon2: 'assets/images/ongoing_step.svg',
                          icon3: 'assets/images/pending_step.svg',
                          icon2TextColor: AppColors.success300,
                        ),
                      ),
                      buildTitleText(),
                      buildYourCurrentLocationButton(),
                      buildDividerContainer(),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                            Dimens.margin_16,
                            Dimens.padding_32,
                            Dimens.margin_16,
                            Dimens.padding_12),
                        child: TextFieldLabel(label: 'Enter Area'),
                      ),
                      buildAddressTextField(),
                      buildPinCodeTextField(),
                      // buildNextButton(),
                    ],
                  ),
                ),
              ),
            ),
            buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.padding_32, Dimens.margin_16, 0),
      child: TextFieldLabel(label: 'user_location'.tr),
    );
  }

  Widget buildYourCurrentLocationButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
      child: YourLocationButton(
        text: 'use_current_location'.tr,
        onPressed: () {
          showSelectLocationDialog(context, (PickResult? pickResult) {
            _addressController.text = pickResult?.formattedAddress ?? '';
            _yourLocationCubit
                .changeFormattedAddress(pickResult?.formattedAddress ?? '');
            _pinCodeController.text = pickResult?.postalCode ?? '';
            _yourLocationCubit.changePincode(pickResult?.postalCode ?? '');
            Address address = Address.fromLocationResult(pickResult);
            address.primary = true;
            _yourLocationCubit.changeAddress(address);
            Helper.hideKeyBoard(context);
          });
        },
      ),
    );
  }

  Widget buildDividerContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
      child: Row(
        children: [
          Expanded(child: HDivider()),
          buildOrText(),
          Expanded(child: HDivider()),
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
    return StreamBuilder<String?>(
      stream: _yourLocationCubit.formattedAddress,
      builder: (context, snapshot) {
        return PlacePicker(
          onScreenAutocomplete: true,
          onScreenTextEditingController: _addressController,
          errorText: snapshot.error?.toString(),
          apiKey: Constants.googleApiKey,
          initialPosition: const LatLng(-33.8567844, 151.213108),
          useCurrentLocation: true,
          selectInitialPosition: true,
          hintText: 'search_locality'.tr,
          onPlacePicked: (pickResult) {
            AppLog.i(
                pickResult?.formattedAddress ?? '..... Area not found......');
            _addressController.text = pickResult?.formattedAddress ?? '';
            _yourLocationCubit
                .changeFormattedAddress(pickResult?.formattedAddress ?? '');
            _pinCodeController.text = pickResult?.postalCode ?? '';
            _yourLocationCubit.changePincode(pickResult?.postalCode ?? '');
            Address address = Address.fromLocationResult(pickResult);
            address.primary = true;
            _yourLocationCubit.changeAddress(address);
            Helper.hideKeyBoard(context);
          },
        );
      },
    );
  }

  Widget buildPinCodeTextField() {
    return StreamBuilder<Address?>(
      stream: _yourLocationCubit.address,
      builder: (context, address) {
        if (address.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
                child: TextFieldLabel(label: 'Enter Pincode'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
                child: TextField(
                  style: context.textTheme.bodyText1,
                  onChanged: _yourLocationCubit.changePincode,
                  controller: _pinCodeController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                        Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                    fillColor: AppColors.backgroundWhite,
                    hintText: 'pincode'.tr,
                    errorText: address.error?.toString(),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(Dimens.radius_8)),
                      borderSide:
                          BorderSide(color: AppColors.backgroundGrey400),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(Dimens.radius_8)),
                      borderSide: BorderSide(color: AppColors.primaryMain),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox(height: 98);
        }
      },
    );
  }

  Widget buildNextButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_40,
            Dimens.padding_16, Dimens.padding_16),
        child: RaisedRectButton(
          text: 'next'.tr,
          buttonStatus: _yourLocationCubit.buttonStatus,
          onPressed: () {
            _yourLocationCubit.createAddress(_currentUser!);
            _yourLocationCubit.updateUserProfile(_currentUser!);
          },
        ));
  }
}
