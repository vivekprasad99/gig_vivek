import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_camera_or_gallery_bottom_sheet/widget/select_camera_or_gallery_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:awign/workforce/payment/feature/document_verification/cubit/document_verification_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';

class DocumentVerificationWidget extends StatefulWidget {
  final DocumentVerificationData documentVerificationData;

  const DocumentVerificationWidget(this.documentVerificationData, {Key? key})
      : super(key: key);

  @override
  _DocumentVerificationWidgetState createState() =>
      _DocumentVerificationWidgetState();
}

class _DocumentVerificationWidgetState
    extends State<DocumentVerificationWidget> {
  final DocumentVerificationCubit _documentVerificationCubit =
      sl<DocumentVerificationCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _validityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _documentVerificationCubit.kycType =
        widget.documentVerificationData.kycType;
    subscribeUIStatus();
    getCurrentUser();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _validityController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  void subscribeUIStatus() {
    _documentVerificationCubit.uiStatus.listen(
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
          case Event.updated:
            WidgetResult? widgetResult = WidgetResult(event: Event.updated);
            if (uiStatus.data != null) {
              DocumentDetailsData? documentDetailsData =
                  uiStatus.data as DocumentDetailsData?;
              widgetResult.data = documentDetailsData;
            }
            if (widget.documentVerificationData.kycType ==
                KYCType.idProofAadhar) {
              _openOTPVerificationWidget(widgetResult);
            } else {
              MRouter.pop(widgetResult);
            }
            break;
        }
      },
    );
    _documentVerificationCubit.userProfileResponse
        .listen((userProfileResponse) {
      if (_currentUser != null && userProfileResponse.userProfile != null) {
        _currentUser!.userProfile = userProfileResponse.userProfile;
        spUtil?.putUserData(_currentUser);
      }
    });
  }

  _openOTPVerificationWidget(WidgetResult? widgetResult) async {
    WidgetResult? widgetResult =
        await MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
      'mobile_number': _currentUser?.mobileNumber ?? '',
      'from_route': MRouter.documentVerificationWidget,
      'page_type': PageType.verifyAadhar,
    });
    if (widgetResult != null && widgetResult.event == Event.verified) {
      MRouter.pop(widgetResult);
    } else {
      _documentVerificationCubit.getUserProfile(_currentUser?.id ?? -1);
    }
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      if (widget.documentVerificationData.imageDetails.url != null) {
        _documentVerificationCubit
            .parseDocument(widget.documentVerificationData.imageDetails.url!);
      } else {
        _documentVerificationCubit.upload(
            _currentUser?.id ?? -1,
            widget.documentVerificationData.imageDetails,
            widget.documentVerificationData.kycType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    switch (widget.documentVerificationData.kycType) {
      case KYCType.idProofPAN:
        title = 'pan_card'.tr;
        break;
      case KYCType.idProofAadhar:
        title = 'aadhar_card'.tr;
        break;
      case KYCType.idProofDrivingLicence:
        title = 'driving_license'.tr;
        break;
    }
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: title),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
          stream: _documentVerificationCubit.uiStatus,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isOnScreenLoading) {
              return buildProgressWidget();
            } else {
              switch (widget.documentVerificationData.kycType) {
                case KYCType.idProofPAN:
                  return buildPANCardDetailsWidgets();
                case KYCType.idProofAadhar:
                  return buildAadharDetailsWidgets();
                case KYCType.idProofDrivingLicence:
                  return buildDLDetailsWidgets();
                default:
                  return const SizedBox();
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildPANCardDetailsWidgets() {
    if (_documentVerificationCubit.number.hasValue) {
      _numberController.text = _documentVerificationCubit.number.value ?? '';
    }
    if (_documentVerificationCubit.name.hasValue) {
      _nameController.text = _documentVerificationCubit.name.value ?? '';
    }
    if (_documentVerificationCubit.dateOfBirth.hasValue) {
      _dobController.text = _documentVerificationCubit.dateOfBirth.value ?? '';
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_32, Dimens.padding_16, Dimens.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTitle('confirm_your_pan_number_and_verify'.tr),
                  buildLabelWidget('pan_number'.tr),
                  buildPANCardNumberTextField('enter_pan_number'.tr),
                  buildLabelWidget('name'.tr),
                  buildNameTextField('enter_pan_name'.tr),
                  buildLabelWidget('date_of_birth'.tr),
                  buildDateOfBirthContainer(),
                  buildImageContainer(),
                ],
              ),
            ),
          ),
        ),
        buildVerifyNowButton('verify_now'.tr),
      ],
    );
  }

  Widget buildAadharDetailsWidgets() {
    if (_documentVerificationCubit.number.hasValue) {
      _numberController.text = _documentVerificationCubit.number.value ?? '';
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_32, Dimens.padding_16, Dimens.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTitle('confirm_your_aadhar_number_and_verify'.tr),
                  buildSubTitle('we_will_send_an_otp_to_the_number'.tr),
                  buildLabelWidget('aadhar_number'.tr),
                  buildNumberTextField('enter_aadhar_number'.tr),
                  buildImageContainer(),
                ],
              ),
            ),
          ),
        ),
        buildVerifyNowButton('verify_via_otp'.tr),
      ],
    );
  }

  Widget buildDLDetailsWidgets() {
    if (_documentVerificationCubit.name.hasValue) {
      _nameController.text = _documentVerificationCubit.name.value ?? '';
    }
    if (_documentVerificationCubit.validity.hasValue) {
      _validityController.text =
          _documentVerificationCubit.validity.value ?? '';
    }
    if (_documentVerificationCubit.number.hasValue) {
      _numberController.text = _documentVerificationCubit.number.value ?? '';
    }
    if (_documentVerificationCubit.dateOfBirth.hasValue) {
      _dobController.text = _documentVerificationCubit.dateOfBirth.value ?? '';
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_32, Dimens.padding_16, Dimens.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTitle('confirm_your_driving_license_details'.tr),
                  buildSubTitle('make_sure_your_name_validity_dl_number'.tr),
                  buildLabelWidget('name'.tr),
                  buildNameTextField('enter_name'.tr),
                  buildLabelWidget('validity'.tr),
                  buildValidityContainer(),
                  buildLabelWidget('driving_license_number'.tr),
                  buildNumberTextField('enter_driving_license_number'.tr),
                  buildLabelWidget('date_of_birth'.tr),
                  buildDateOfBirthContainer(),
                  buildImageContainer(),
                ],
              ),
            ),
          ),
        ),
        buildVerifyNowButton('verify_now'.tr),
      ],
    );
  }

  Widget buildProgressWidget() {
    String loadingMessage = '';
    switch (widget.documentVerificationData.kycType) {
      case KYCType.idProofPAN:
        loadingMessage = 'loading_pan_card'.tr;
        break;
      case KYCType.idProofAadhar:
        loadingMessage = 'loading_aadhar_card'.tr;
        break;
      case KYCType.idProofDrivingLicence:
        loadingMessage = 'loading_driving_licence'.tr;
        break;
    }
    return StreamBuilder<dynamic>(
      stream: sl<RemoteStorageRepository>().getUploadPercentageStream(),
      builder: (context, snapshot) {
        int percentValue = snapshot.hasData ? (snapshot.data as int) : 0;
        double value =
            snapshot.hasData ? ((snapshot.data as int).toDouble() / 100) : 0.0;
        if (widget.documentVerificationData.imageDetails.url != null) {
          value = 100;
        }
        return Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_12),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: Dimens.pbWidth_72,
                                height: Dimens.pbHeight_72,
                                child: CircularProgressIndicator(
                                  value: value,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.success300),
                                  backgroundColor: AppColors.backgroundWhite,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimens.padding_24),
                                child: Text(
                                  '$percentValue%',
                                  style: Get.textTheme.headline7SemiBold
                                      .copyWith(
                                          color: AppColors.backgroundBlack),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimens.padding_16),
                        Text(
                          loadingMessage,
                          style: Get.textTheme.bodyText2
                              ?.copyWith(color: AppColors.backgroundBlack),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              buildVerifyNowButton(widget.documentVerificationData.kycType ==
                      KYCType.idProofAadhar
                  ? 'verify_via_otp'.tr
                  : 'verify_now'.tr),
            ],
          ),
        );
      },
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.bodyText1Bold
          ?.copyWith(color: AppColors.backgroundBlack),
    );
  }

  Widget buildSubTitle(String title) {
    return Text(
      title,
      style:
          Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundGrey700),
    );
  }

  Widget buildLabelWidget(String label) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, Dimens.padding_32, 0, Dimens.padding_12),
      child: Text(
        label,
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildNumberTextField(String hint) {
    return StreamBuilder<String?>(
      stream: widget.documentVerificationData.kycType == KYCType.idProofAadhar
          ? _documentVerificationCubit.aadhaarNumberStream
          : _documentVerificationCubit.dlNumberStream,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _documentVerificationCubit.changeNumber,
          controller: _numberController,
          keyboardType:
              widget.documentVerificationData.kycType == KYCType.idProofAadhar
                  ? TextInputType.number
                  : TextInputType.text,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: hint,
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
        );
      },
    );
  }

  Widget buildPANCardNumberTextField(String hint) {
    return StreamBuilder<String?>(
      stream: _documentVerificationCubit.panNumberStream,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _documentVerificationCubit.changePanNumber,
          controller: _panNumberController,
          keyboardType: TextInputType.text,
          maxLines: 1,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: hint,
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
        );
      },
    );
  }

  Widget buildNameTextField(String hint) {
    return StreamBuilder<String?>(
      stream: _documentVerificationCubit.nameStream,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _documentVerificationCubit.changeName,
          // focusNode: _nameFN,
          controller: _nameController,
          keyboardType: TextInputType.text,
          maxLines: 1,
          // textInputAction: TextInputAction.none,
          // onSubmitted: (v) {
          //   // FocusScope.of(context).requestFocus(_dobFN);
          // },
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: hint,
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
        );
      },
    );
  }

  Widget buildDateOfBirthContainer() {
    return StreamBuilder<String?>(
      stream: _documentVerificationCubit.dateOfBirthStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _dobController.text = snapshot.data!;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_12, 0, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            maxLines: 1,
            // focusNode: _dobFN,
            controller: _dobController,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: AppColors.backgroundGrey300,
              hintText: 'enter_date_of_birth'.tr,
              counterText: "",
              hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  context: context,
                  initialDate: Jiffy.now().subtract(years: 18).dateTime,
                  firstDate: DateTime(1920),
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: Jiffy.now().subtract(years: 18).dateTime);
              if (pickedDate != null) {
                String formattedDate =
                    DateFormat(StringUtils.dateFormatDMY).format(pickedDate);
                _documentVerificationCubit.changeDateOfBirth(formattedDate);
              }
            },
            readOnly: true,
          ),
        );
      },
    );
  }

  Widget buildValidityContainer() {
    return StreamBuilder<String?>(
      stream: _documentVerificationCubit.validity,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _validityController.text = snapshot.data!;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_12, 0, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            maxLines: 1,
            // focusNode: _validityFN,
            controller: _validityController,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: AppColors.backgroundGrey300,
              hintText: 'dl_validity'.tr,
              counterText: "",
              hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  context: context,
                  initialDate:
                      Jiffy.now().add(days: 1).dateTime,
                  firstDate: Jiffy.now().add(days: 1).dateTime,
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: Jiffy.now().add(years: 50).dateTime);
              if (pickedDate != null) {
                String formattedDate =
                    DateFormat(StringUtils.dateFormatDMY).format(pickedDate);
                _documentVerificationCubit.changeValidity(formattedDate);
              }
            },
            readOnly: true,
          ),
        );
      },
    );
  }

  Widget buildImageContainer() {
    return StreamBuilder<String?>(
        stream: _documentVerificationCubit.docURL,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Card(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.margin_4, Dimens.margin_20, Dimens.margin_4, 0),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_16)),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(Dimens.margin_32,
                    Dimens.margin_16, Dimens.margin_32, Dimens.margin_32),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      filterQuality: FilterQuality.high,
                      errorWidget: (context, url, error) =>
                          Container(color: AppColors.backgroundGrey600),
                    ),
                    const SizedBox(height: Dimens.padding_16),
                    buildReUploadButton(),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildReUploadButton() {
    return MyInkWell(
      onTap: () {
        _showSelectCameraOrGalleryBottomSheet();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/ic_re_upload.svg',
          ),
          const SizedBox(width: Dimens.padding_16),
          Text('re_upload'.tr,
              style: Get.textTheme.bodyText1SemiBold
                  ?.copyWith(color: AppColors.primaryMain)),
        ],
      ),
    );
  }

  _showSelectCameraOrGalleryBottomSheet() {
    if ((_currentUser?.userProfile?.kycDetails?.panVerificationCount ?? 0) >=
        3) {
      _documentVerificationCubit.changeUIStatus(UIStatus(
          failedWithoutAlertMessage:
              'please_contact_support_to_get_your_pan_card_verified'.tr));
      return;
    } else if ((_currentUser
                ?.userProfile?.aadharDetails?.aadhaarVerificationCount ??
            0) >=
        3) {
      _documentVerificationCubit.changeUIStatus(UIStatus(
          failedWithoutAlertMessage:
              'please_contact_support_to_get_your_aadhar_card_verified'.tr));
      return;
    }
    showSelectCameraOrGalleryBottomSheet(Get.context!, (onSelectOption) {
      if (onSelectOption == UploadFromOptionEntity.camera) {
        _captureImage();
      } else if (onSelectOption == UploadFromOptionEntity.gallery) {
        _pickMedia();
      }
    });
  }

  void _captureImage() async {
    ImageDetails imageDetails = ImageDetails(uploadLater: false);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data != null) {
      widget.documentVerificationData.imageDetails = cameraWidgetResult.data;
      _documentVerificationCubit.upload(
          _currentUser?.id ?? -1,
          widget.documentVerificationData.imageDetails,
          widget.documentVerificationData.kycType);
    }
  }

  void _pickMedia() {
    FilePickerHelper.pickMedia(
      SubType.image,
      null,
      (result) async {
        File file = File(result.files.single.path ?? '');
        ImageDetails imageDetailsResult = ImageDetails(
            originalFileName: result.names[0],
            originalFilePath: file.path,
            fileQuality: FileQuality.high);
        widget.documentVerificationData.imageDetails = imageDetailsResult;
        _documentVerificationCubit.upload(
            _currentUser?.id ?? -1,
            widget.documentVerificationData.imageDetails,
            widget.documentVerificationData.kycType);
      },
    );
  }

  Widget buildVerifyNowButton(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_16,
          Dimens.padding_24, Dimens.padding_24),
      child: RaisedRectButton(
        text: text,
        buttonStatus: _documentVerificationCubit.buttonStatus,
        onPressed: () {
          switch (widget.documentVerificationData.kycType) {
            case KYCType.idProofPAN:
              _documentVerificationCubit.updatePanDetails(
                  _currentUser?.id ?? -1,
                  _currentUser?.userProfile?.kycDetails?.panVerificationCount ??
                      0,
                  (_currentUser!
                              .userProfile?.kycDetails?.panVerificationCount ??
                          0) >=
                      2);
              break;
            case KYCType.idProofAadhar:
              _documentVerificationCubit.updateAadharDetails(
                  _currentUser?.id ?? -1,
                  _currentUser?.userProfile?.aadharDetails
                          ?.aadhaarVerificationCount ??
                      0);
              LoggingData loggingData = LoggingData(
                  event: LoggingEvents.verifyNowPAN,
                  pageName: LoggingPageNames.panVerificationPage);
              CaptureEventHelper.captureEvent(loggingData: loggingData);
              break;
            case KYCType.idProofDrivingLicence:
              _documentVerificationCubit
                  .updateDLDetails(_currentUser?.id ?? -1);
              break;
          }
        },
      ),
    );
  }
}
