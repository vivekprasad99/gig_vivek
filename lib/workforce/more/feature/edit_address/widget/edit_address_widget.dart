import 'package:awign/packages/google_maps_place_picker/src/models/pick_result.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/dialog/select_location/widget/select_location_widget.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/edit_address/cubit/edit_address_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EditAddressWidget extends StatefulWidget {
  UserProfile userProfile;

  EditAddressWidget(this.userProfile, {Key? key}) : super(key: key);

  @override
  _EditAddressWidgetState createState() => _EditAddressWidgetState();
}

class _EditAddressWidgetState extends State<EditAddressWidget> {
  final _editAddressCubit = sl<EditAddressCubit>();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final _areaFN = FocusNode();
  final _cityFN = FocusNode();
  final _stateFN = FocusNode();
  final _pincodeFN = FocusNode();
  Address? _address;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    setAddressData();
  }

  void subscribeUIStatus() {
    _editAddressCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            MRouter.globalNavigatorKey.currentState?.popUntil((route) {
              if (route.settings.name == MRouter.myProfileWidget) {
                (route.settings.arguments as Map)[Constants.doRefresh] = true;
                return true;
              } else {
                return false;
              }
            });
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void setAddressData() {
    if (widget.userProfile.addresses != null &&
        widget.userProfile.addresses!.isNotEmpty) {
      List<Address> tempAddressList = [];
      for (var address in widget.userProfile.addresses!) {
        if (address.primary && tempAddressList.isEmpty) {
          tempAddressList.add(address);
          _address = address;
        }
      }
      if (tempAddressList.isNotEmpty) {
        Address address = tempAddressList[0];
        _areaController.text = address.area ?? '';
        if ((address.area ?? '').isNotEmpty) {
          _editAddressCubit.changeArea(address.area);
        }
        _cityController.text = address.city ?? '';
        if ((address.city ?? '').isNotEmpty) {
          _editAddressCubit.changeCity(address.city);
        }
        _stateController.text = address.state ?? '';
        if ((address.state ?? '').isNotEmpty) {
          _editAddressCubit.changeState(address.state);
        }
        _pinCodeController.text = address.pincode ?? '';
        if ((address.pincode ?? '').isNotEmpty) {
          _editAddressCubit.changePincode(address.pincode);
        }
        _editAddressCubit.changeAddress(address);
      }
    }
  }

  @override
  void dispose() {
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
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'edit_address'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(
          bottom: defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_32
              : 0),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<UIStatus>(
          stream: _editAddressCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, Dimens.padding_24, 0, Dimens.padding_24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildSearchTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'area'.tr),
                        ),
                        buildAreaTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'city'.tr),
                        ),
                        buildCityTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'state'.tr),
                        ),
                        buildStateTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'pincode'.tr),
                        ),
                        buildPincodeTextField(),
                        buildSaveChangesButton(),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildSearchTextField() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_24, 0, Dimens.padding_24, 0),
      child: MyInkWell(
        onTap: () {
          showSelectLocationDialog(context, (PickResult? pickResult) {
            _areaController.text = pickResult?.formattedAddress ?? '';
            _editAddressCubit.changeArea(pickResult?.formattedAddress ?? '');
            _cityController.text = pickResult?.city ?? '';
            _editAddressCubit.changeCity(pickResult?.city ?? '');
            _stateController.text = pickResult?.state ?? '';
            _editAddressCubit.changeState(pickResult?.state ?? '');
            _pinCodeController.text = pickResult?.postalCode ?? '';
            _editAddressCubit.changePincode(pickResult?.postalCode ?? '');
            Address address = Address.fromLocationResult(pickResult);
            address.primary = true;
            address.id = _address?.id;
            _editAddressCubit.changeAddress(address);
            Helper.hideKeyBoard(context);
          });
        },
        child: Stack(
          children: [
            TextField(
              enabled: false,
              style: context.textTheme.bodyText1,
              maxLines: 1,
              decoration: InputDecoration(
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_48,
                    Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                fillColor: context.theme.textFieldBackgroundColor,
                hintText: 'search'.tr,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: Dimens.padding_16),
                  child: Icon(
                    Icons.search,
                    color: Get.theme.iconColorNormal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAreaTextField() {
    return StreamBuilder<String?>(
      stream: _editAddressCubit.area,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _editAddressCubit.changeArea,
            controller: _areaController,
            keyboardType: TextInputType.streetAddress,
            maxLines: 1,
            textInputAction: TextInputAction.next,
            onSubmitted: (v) {
              FocusScope.of(context).requestFocus(_cityFN);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'area'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildCityTextField() {
    return StreamBuilder<String?>(
      stream: _editAddressCubit.city,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _editAddressCubit.changeCity,
            controller: _cityController,
            focusNode: _cityFN,
            keyboardType: TextInputType.name,
            maxLines: 1,
            textInputAction: TextInputAction.next,
            onSubmitted: (v) {
              FocusScope.of(context).requestFocus(_stateFN);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'city'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildStateTextField() {
    return StreamBuilder<String?>(
      stream: _editAddressCubit.stateName,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _editAddressCubit.changeState,
            controller: _stateController,
            focusNode: _stateFN,
            keyboardType: TextInputType.name,
            maxLines: 1,
            textInputAction: TextInputAction.next,
            onSubmitted: (v) {
              FocusScope.of(context).requestFocus(_pincodeFN);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'state'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPincodeTextField() {
    return StreamBuilder<String?>(
      stream: _editAddressCubit.pincode,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _editAddressCubit.changePincode,
            controller: _pinCodeController,
            focusNode: _pincodeFN,
            keyboardType: TextInputType.number,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'pincode'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSaveChangesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_32, Dimens.padding_24, 0),
      child: RaisedRectButton(
        text: 'save_changes'.tr,
        onPressed: () {
          Helper.hideKeyBoard(context);
          _editAddressCubit.updateAddress(widget.userProfile.userId);
        },
      ),
    );
  }
}
