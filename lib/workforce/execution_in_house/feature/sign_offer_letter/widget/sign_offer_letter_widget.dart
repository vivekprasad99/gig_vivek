import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_camera_or_gallery_bottom_sheet/widget/select_camera_or_gallery_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/model/location_item.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/widget/select_location_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_signature_bottom_sheet/widget/select_signature_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/signature_response.dart';
import 'package:awign/workforce/execution_in_house/feature/sign_offer_letter/cubit/sign_offer_letter_cubit.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SignOfferLetterWidget extends StatefulWidget {
  final Execution _execution;

  const SignOfferLetterWidget(this._execution, {Key? key}) : super(key: key);

  @override
  State<SignOfferLetterWidget> createState() => _SignOfferLetterWidgetState();
}

class _SignOfferLetterWidgetState extends State<SignOfferLetterWidget> {
  final SignOfferLetterCubit _signOfferLetterCubit = sl<SignOfferLetterCubit>();
  UserData? _currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    Map<String, dynamic> properties = await getEventProperty(
        widget._execution, widget._execution.selectedProjectRole ?? '');
    _signOfferLetterCubit.getSignatures(
        widget._execution.memberId ?? '', properties);
  }

  void setSignatureDetails(Signature? signature) {
    if (signature != null) {
      _nameController.text = signature.name ?? '';
      if ((signature.name ?? '').isNotEmpty) {
        _signOfferLetterCubit.changeName(signature.name);
      }
      _phoneController.text = signature.mobileNumber ?? '';
      _addressController.text = signature.address ?? '';
      if ((signature.address ?? '').isNotEmpty) {
        _signOfferLetterCubit.changeAddress(signature.address);
      }
      _pinCodeController.text = signature.pincode ?? '';
      if ((signature.pincode ?? '').isNotEmpty) {
        _signOfferLetterCubit.changePincode(signature.pincode);
      }
      _cityController.text = signature.city ?? '';
      if ((signature.city ?? '').isNotEmpty) {
        _signOfferLetterCubit.changeCity(signature.city);
      }
      _stateController.text = signature.state ?? '';
      if ((signature.state ?? '').isNotEmpty) {
        _signOfferLetterCubit.changeState(signature.state);
      }
    } else {
      _nameController.text = _currentUser?.name ?? '';
      if ((_currentUser?.name ?? '').isNotEmpty) {
        _signOfferLetterCubit.changeName(_currentUser?.name);
      }
      _phoneController.text = _currentUser?.userProfile?.mobileNumber ?? '';
      _currentUser?.userProfile?.addresses?.forEach((address) {
        if (address.primary) {
          _addressController.text = address.area ?? '';
          if ((address.area ?? '').isNotEmpty) {
            _signOfferLetterCubit.changeAddress(address.area);
          }
          _pinCodeController.text = address.pincode ?? '';
          if ((address.pincode ?? '').isNotEmpty) {
            _signOfferLetterCubit.changePincode(address.pincode);
          }
          _cityController.text = address.city ?? '';
          if ((address.city ?? '').isNotEmpty) {
            _signOfferLetterCubit.changeCity(address.city);
          }
          _stateController.text = address.state ?? '';
          if ((address.state ?? '').isNotEmpty) {
            _signOfferLetterCubit.changeState(address.state);
          }
          return;
        }
      });
    }
  }

  void subscribeUIStatus() {
    _signOfferLetterCubit.uiStatus.listen(
      (uiStatus) async {
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
          case Event.accepted:
            Map<String, dynamic> properties = await getEventProperty(
                widget._execution, widget._execution.selectedProjectRole ?? '');
            ClevertapData clevertapData = ClevertapData(
                eventName: ClevertapHelper.offerLetterAccepted,
                properties: properties);
            CaptureEventHelper.captureEvent(clevertapData: clevertapData);
            MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
            break;
          case Event.none:
            break;
        }
      },
    );
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
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: widget._execution.projectName ?? '',
            ),
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
              ? Dimens.margin_16
              : 0),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _signOfferLetterCubit.uiStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isOnScreenLoading) {
                return buildShimmerTiles();
              } else {
                if (_signOfferLetterCubit.signatureList.hasValue &&
                    _signOfferLetterCubit.signatureList.value != null &&
                    _signOfferLetterCubit.signatureList.value!.isNotEmpty) {
                  setSignatureDetails(
                      _signOfferLetterCubit.signatureList.value![0]);
                } else {
                  setSignatureDetails(null);
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_16, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'name'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildNameTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_24, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'mobile_no'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildMobileNumberTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_24, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'address'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildAddressTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_24, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'pincode'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildPinCodeTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_24, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'city'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildCityTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_24, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'state'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildStateTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_24, Dimens.padding_16, 0),
                        child: Row(
                          children: [
                            TextFieldLabel(label: 'signature'.tr),
                            Text(
                              '*',
                              style: Get.textTheme.bodyText2
                                  ?.copyWith(color: AppColors.error400),
                            ),
                          ],
                        ),
                      ),
                      buildSignatureBox(),
                      buildConfirmAndAcceptButton(),
                      const SizedBox(height: Dimens.padding_16),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildNameTextField() {
    return StreamBuilder<String?>(
      stream: _signOfferLetterCubit.nameStream,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _signOfferLetterCubit.changeName,
            controller: _nameController,
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'enter_name'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.primaryMain),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMobileNumberTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
      child: TextField(
        enabled: false,
        style: context.textTheme.bodyText1,
        controller: _phoneController,
        maxLines: 1,
        decoration: InputDecoration(
          filled: true,
          contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
          fillColor: context.theme.textFieldBackgroundColor,
          hintText: 'phone'.tr,
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
    );
  }

  Widget buildAddressTextField() {
    return StreamBuilder<String?>(
      stream: _signOfferLetterCubit.address,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _signOfferLetterCubit.changeAddress,
            controller: _addressController,
            keyboardType: TextInputType.streetAddress,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'enter_address'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.primaryMain),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPinCodeTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          showSelectLocationBottomSheet(
            context,
            LocationType.pincode,
            (locationItem) {
              _pinCodeController.text = locationItem?.name ?? '';
              _signOfferLetterCubit.changePincode(locationItem?.name);
            },
          );
        },
        child: TextField(
          enabled: false,
          style: context.textTheme.bodyText1,
          controller: _pinCodeController,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'pincode'.tr,
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
      ),
    );
  }

  Widget buildCityTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          showSelectLocationBottomSheet(
            context,
            LocationType.city,
            (locationItem) {
              _cityController.text = locationItem?.name ?? '';
              _signOfferLetterCubit.changeCity(locationItem?.name);
            },
          );
        },
        child: TextField(
          enabled: false,
          style: context.textTheme.bodyText1,
          controller: _cityController,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'city'.tr,
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
      ),
    );
  }

  Widget buildStateTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          showSelectLocationBottomSheet(
            context,
            LocationType.state,
            (locationItem) {
              _stateController.text = locationItem?.name ?? '';
              _signOfferLetterCubit.changeState(locationItem?.name);
            },
          );
        },
        child: TextField(
          enabled: false,
          style: context.textTheme.bodyText1,
          controller: _stateController,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'state'.tr,
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
      ),
    );
  }

  Widget buildSignatureBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          showSelectSignatureBottomSheet(
            context,
            _signOfferLetterCubit.nameValue ?? '',
            (fontType) {
              _signOfferLetterCubit.changeFontType(fontType);
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: Dimens.margin_80,
          decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border.all(color: AppColors.backgroundGrey700)),
          child: StreamBuilder<String?>(
              stream: _signOfferLetterCubit.fontType,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Text(
                      _nameController.text,
                      style: Get.textTheme.bodyText1?.copyWith(
                          fontFamily: snapshot.data, fontSize: Dimens.font_36),
                    ),
                  );
                } else {
                  return Center(
                    child: Text('tap_to_choose_signature'.tr,
                        style: Get.textTheme.bodyText2),
                  );
                }
              }),
        ),
      ),
    );
  }

  Widget buildConfirmAndAcceptButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.margin_16,
          Dimens.margin_24,
          Dimens.margin_16,
          defaultTargetPlatform == TargetPlatform.iOS ? Dimens.padding_16 : 0),
      child: RaisedRectButton(
        text: 'confirm_and_accept'.tr,
        onPressed: () {
          _createSignatureOrCaptureAadharOrDLDetails();
        },
      ),
    );
  }

  _createSignatureOrCaptureAadharOrDLDetails() {
    Helper.hideKeyBoard(context);
    _currentUser = spUtil?.getUserData();
    if (_currentUser?.userProfile?.aadharDetails?.aadharVerificationStatus !=
        PanStatus.verified &&
        (widget._execution.captureAadharCard ?? false)) {
      if ((_currentUser?.userProfile?.aadharDetails?.aadhaarVerificationCount ?? 0) >= 3) {
        _signOfferLetterCubit.changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
            'please_contact_support_to_get_your_aadhar_card_verified'.tr));
        return;
      }
      _showSelectCameraOrGalleryBottomSheet(KYCType.idProofAadhar);
    } else if ((_currentUser?.userProfile?.dlDetails?.dlVerificationStatus ==
        PanStatus.notSubmitted ||
        _currentUser?.userProfile?.dlDetails?.dlVerificationStatus ==
            PanStatus.unverified ||
        (_currentUser?.userProfile?.dlDetails?.isDateIsNotValid() ?? false)) &&
            (widget._execution.captureDrivingLicence ?? false)) {
      _showSelectCameraOrGalleryBottomSheet(KYCType.idProofDrivingLicence);
    } else {
      _signOfferLetterCubit.createSignature(
          widget._execution.memberId ?? '',
          _phoneController.text,
          widget._execution.projectId ?? '',
          widget._execution.id ?? '');
    }
  }

  _showSelectCameraOrGalleryBottomSheet(KYCType kycType) {
    showSelectCameraOrGalleryBottomSheet(Get.context!, (onSelectOption) {
      if (onSelectOption == UploadFromOptionEntity.camera) {
        _captureImage(kycType);
      } else if (onSelectOption == UploadFromOptionEntity.gallery) {
        _pickMedia(kycType);
      }
    });
  }

  void _captureImage(KYCType kycType) async {
    ImageDetails imageDetails = ImageDetails(uploadLater: false);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data != null) {
      DocumentVerificationData documentVerificationData =
          DocumentVerificationData(
              kycType: kycType, imageDetails: cameraWidgetResult!.data);
      WidgetResult? widgetResult = await MRouter.pushNamed(
          MRouter.documentVerificationWidget,
          arguments: documentVerificationData);
      if (widgetResult != null && widgetResult.event == Event.updated) {
        _addClevertapEvent(kycType);
        // _showSelectCameraOrGalleryBottomSheet(kycType);
      }
    }
  }

  void _pickMedia(KYCType kycType) {
    FilePickerHelper.pickMedia(
      SubType.image,
      null,
      (result) async {
        File file = File(result.files.single.path ?? '');
        ImageDetails imageDetailsResult = ImageDetails(
            originalFileName: result.names[0],
            originalFilePath: file.path,
            fileQuality: FileQuality.high);
        DocumentVerificationData documentVerificationData =
            DocumentVerificationData(
                kycType: kycType, imageDetails: imageDetailsResult);
        WidgetResult? widgetResult = await MRouter.pushNamed(
            MRouter.documentVerificationWidget,
            arguments: documentVerificationData);
        if (widgetResult != null && widgetResult.event == Event.updated) {
          _addClevertapEvent(kycType);
          // _showSelectCameraOrGalleryBottomSheet(kycType);
        }
      },
    );
  }

  _addClevertapEvent(KYCType kycType) async {
    Map<String, dynamic> properties = await getEventProperty(
        widget._execution, widget._execution.selectedProjectRole ?? '');
    switch (kycType) {
      case KYCType.idProofAadhar:
        ClevertapData clevertapData = ClevertapData(
            eventName: ClevertapHelper.aadhaarSubmittedOffice,
            properties: properties);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
        break;
      case KYCType.idProofDrivingLicence:
        ClevertapData clevertapData = ClevertapData(
            eventName: ClevertapHelper.drivingLicenceSubmittedOffice,
            properties: properties);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
        break;
    }
  }

  Widget buildShimmerTiles() {
    return ListView(
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_60, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.etHeight_48),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_80, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.etHeight_48),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_60, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.etHeight_48),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_60, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.etHeight_48),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_40, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.etHeight_48),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_40, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.etHeight_48),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(
              width: Dimens.padding_40, height: Dimens.padding_16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: ShimmerWidget.rectangular(height: Dimens.margin_80),
        ),
        SizedBox(height: Dimens.padding_16),
      ],
    );
  }

  Future<Map<String, dynamic>> getEventProperty(
      Execution execution, String projectRole) async {
    Map<String, dynamic> eventProperty = {};
    eventProperty[CleverTapConstant.projectName] = execution.projectName;
    eventProperty[CleverTapConstant.projectId] = execution.projectId;
    eventProperty[CleverTapConstant.roleName] =
        projectRole.replaceAll('_', ' ');
    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser);
    eventProperty.addAll(properties);
    return eventProperty;
  }
}
