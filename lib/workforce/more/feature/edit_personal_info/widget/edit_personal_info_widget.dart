import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/packages/flutter_switch/flutter_switch.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/select_language_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/tile/selected_language_tile.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/whatsapp_bottom_sheet/widget/whatsapp_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/edit_personal_info/cubit/edit_personal_info_cubit.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';

class EditPersonalInfoWidget extends StatefulWidget {
  late UserData currentUser;

  EditPersonalInfoWidget(this.currentUser, {Key? key}) : super(key: key);

  @override
  _EditPersonalInfoWidgetState createState() => _EditPersonalInfoWidgetState();
}

class _EditPersonalInfoWidgetState extends State<EditPersonalInfoWidget> {
  final _editPersonalInfoCubit = sl<EditPersonalInfoCubit>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final _dateFN = FocusNode();
  final _monthFN = FocusNode();
  final _yearFN = FocusNode();
  bool isProfileUpdated = false;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    setProfileData();
  }

  void subscribeUIStatus() {
    _editPersonalInfoCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage,
              color: AppColors.success300);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            MRouter.popNamedWithResult(
                MRouter.myProfileWidget, Constants.doRefresh, true);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void setProfileData() {
    _editPersonalInfoCubit.changeUserProfile(widget.currentUser.userProfile!);
    _nameController.text =
        widget.currentUser.userProfile?.name ?? ''.toTitleCase();
    if ((widget.currentUser.userProfile?.name ?? '').isNotEmpty) {
      _editPersonalInfoCubit
          .changeName(widget.currentUser.userProfile?.name ?? ''.toTitleCase());
    }
    _phoneController.text = StringUtils.maskString(
        widget.currentUser.userProfile?.mobileNumber, 3, 3);
    _editPersonalInfoCubit.changeIsWhatsappSubscribed(
        (widget.currentUser.userProfile?.subscribedToWhatsapp ?? false));
    _editPersonalInfoCubit
        .changeSelectedGender(widget.currentUser.userProfile?.gender);
    setDOB();
    setLanguage();
  }

  void setDOB() {
    _dateController.text =
        widget.currentUser.userProfile?.dob?.split('-')[2] ?? '';
    _monthController.text =
        widget.currentUser.userProfile?.dob?.split('-')[1] ?? '';
    _yearController.text =
        widget.currentUser.userProfile?.dob?.split('-')[0] ?? '';
    _editPersonalInfoCubit
        .changeDate(widget.currentUser.userProfile?.dob?.split('-')[2]);
    _editPersonalInfoCubit
        .changeMonth(widget.currentUser.userProfile?.dob?.split('-')[1]);
    _editPersonalInfoCubit
        .changeYear(widget.currentUser.userProfile?.dob?.split('-')[0]);
  }

  void setLanguage() {
    _editPersonalInfoCubit
        .changeSelectedLanguages(widget.currentUser.userProfile?.languages);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    return WillPopScope(
      onWillPop: () {
        if (isProfileUpdated) {
          MRouter.popNamedWithResult(
              MRouter.myProfileWidget, Constants.doRefresh, true);
          return Future.value(true);
        } else {
          return Future.value(true);
        }
      },
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        bottomPadding: 0,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              DefaultAppBar(
                  isCollapsable: true, title: 'edit_personal_info'.tr),
            ];
          },
          body: buildBody(),
        ),
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
          stream: _editPersonalInfoCubit.uiStatus,
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_24, 0, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'name'.tr),
                        ),
                        buildNameTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'mobile_no'.tr),
                        ),
                        buildMobileNumberTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'email_id'.tr),
                        ),
                        buildEmailText(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'gender'.tr),
                        ),
                        buildRadioButtons(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_8, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'date_of_birth'.tr),
                        ),
                        buildDateOfBirthContainer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_16, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'languages'.tr),
                        ),
                        buildSelectLanguageContainer(),
                        buildPANCardWidgets(),
                        buildAadharCardWidgets(),
                        buildDLCardWidgets(),
                        buildWhatsappSwitch(),
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

  Widget buildNameTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
      child: Text(widget.currentUser.userProfile?.name ?? '',
          style: context.textTheme.bodyText1),
    );
  }

  Widget buildMobileNumberTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: Stack(
        children: [
          TextField(
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
          // buildChangeMobileNumberButton(),
        ],
      ),
    );
  }

  Widget buildChangeMobileNumberButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColors.transparent,
        ),
        onPressed: () => {
          MRouter.pushNamed(MRouter.phoneVerificationWidget,
              arguments: MRouter.editPersonalInfoWidget),
        },
        child: Text(
          'change'.tr,
          style: context.textTheme.bodyText2?.copyWith(
              color: context.theme.iconColorHighlighted,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildEmailText() {
    String email =
        StringUtils.maskString(widget.currentUser.userProfile?.email, 4, 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
      child: Text(email, style: context.textTheme.bodyText1),
    );
  }

  Widget buildRadioButtons() {
    return StreamBuilder<Gender?>(
      stream: _editPersonalInfoCubit.selectedGender,
      builder: (context, selectedGender) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
          child: Column(
            children: [
              Row(
                children: [
                  Radio<Gender?>(
                    value: Gender.male,
                    groupValue: selectedGender.data,
                    onChanged: _editPersonalInfoCubit.changeSelectedGender,
                  ),
                  Text('male'.tr, style: context.textTheme.bodyText1)
                ],
              ),
              Row(
                children: [
                  Radio<Gender?>(
                    value: Gender.female,
                    groupValue: selectedGender.data,
                    onChanged: _editPersonalInfoCubit.changeSelectedGender,
                  ),
                  Text('female'.tr, style: context.textTheme.bodyText1)
                ],
              ),
              Row(
                children: [
                  Radio<Gender?>(
                    value: Gender.other,
                    groupValue: selectedGender.data,
                    onChanged: _editPersonalInfoCubit.changeSelectedGender,
                  ),
                  Text('other'.tr, style: context.textTheme.bodyText1)
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDateOfBirthContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.margin_16, Dimens.padding_24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildDateTextField(),
          const SizedBox(width: Dimens.margin_16),
          buildMonthTextField(),
          const SizedBox(width: Dimens.margin_16),
          buildYearTextField(),
        ],
      ),
    );
  }

  Widget buildDateTextField() {
    return StreamBuilder<String?>(
      stream: _editPersonalInfoCubit.date,
      builder: (context, snapshot) {
        return SizedBox(
          width: Dimens.etWidth_56,
          child: TextField(
            enabled: false,
            style: context.textTheme.bodyText1,
            onChanged: _editPersonalInfoCubit.changeDate,
            controller: _dateController,
            focusNode: _dateFN,
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 2,
            textInputAction: TextInputAction.next,
            onSubmitted: (v) {
              FocusScope.of(context).requestFocus(_monthFN);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'dd'.tr,
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
              counter: const Offstage(),
            ),
          ),
        );
      },
    );
  }

  Widget buildMonthTextField() {
    return StreamBuilder<String?>(
      stream: _editPersonalInfoCubit.month,
      builder: (context, snapshot) {
        return SizedBox(
          width: Dimens.etWidth_56,
          child: TextField(
            enabled: false,
            style: context.textTheme.bodyText1,
            onChanged: _editPersonalInfoCubit.changeMonth,
            controller: _monthController,
            focusNode: _monthFN,
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 2,
            textInputAction: TextInputAction.next,
            onSubmitted: (v) {
              FocusScope.of(context).requestFocus(_yearFN);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'mm'.tr,
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
              counter: const Offstage(),
            ),
          ),
        );
      },
    );
  }

  Widget buildYearTextField() {
    return StreamBuilder<String?>(
      stream: _editPersonalInfoCubit.year,
      builder: (context, snapshot) {
        return SizedBox(
          width: Dimens.etWidth_72,
          child: TextField(
            enabled: false,
            style: context.textTheme.bodyText1,
            onChanged: _editPersonalInfoCubit.changeYear,
            controller: _yearController,
            focusNode: _yearFN,
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 4,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'yyyy'.tr,
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
              counter: const Offstage(),
            ),
          ),
        );
      },
    );
  }

  Widget buildSelectLanguageContainer() {
    return StreamBuilder<List<Languages>?>(
      stream: _editPersonalInfoCubit.selectedLanguages,
      builder: (context, selectedLanguages) {
        if (selectedLanguages.hasData && selectedLanguages.data!.isNotEmpty) {
          return buildLanguageList(selectedLanguages.data);
        } else {
          return buildSelectLanguageTextField();
        }
      },
    );
  }

  Widget buildSelectLanguageTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: MyInkWell(
        onTap: () {
          showSelectLanguageBottomSheet(
            context,
            () {
              _editPersonalInfoCubit.updateSelectedLanguage();
            },
          );
        },
        child: Stack(
          children: [
            TextField(
              style: context.textTheme.bodyText1,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                    Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                fillColor: context.theme.textFieldBackgroundColor,
                hintText: 'select_language'.tr,
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
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(Dimens.padding_12),
                child: Icon(Icons.arrow_drop_down),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLanguageList(List<Languages>? languageList) {
    return MyInkWell(
      onTap: () {
        showSelectLanguageBottomSheet(
          context,
          () {
            _editPersonalInfoCubit.updateSelectedLanguage();
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_8),
        margin: const EdgeInsets.fromLTRB(
            Dimens.margin_24, Dimens.margin_16, Dimens.margin_24, 0),
        color: context.theme.textFieldBackgroundColor,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 0),
          itemCount: languageList?.length,
          itemBuilder: (_, i) {
            return SelectedLanguageTile(
              index: i,
              language: languageList![i],
            );
          },
        ),
      ),
    );
  }

  Widget buildWhatsappSwitch() {
    return StreamBuilder<bool?>(
      stream: _editPersonalInfoCubit.isWhatsappSubscribed,
      builder: (context, subscribeWhatsapp) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_40, Dimens.padding_16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset('assets/images/whatsapp.png'),
                        const SizedBox(width: Dimens.margin_8),
                        Text('receive_message_on'.tr,
                            style: context.textTheme.bodyText1),
                      ],
                    ),
                  ),
                  FlutterSwitch(
                    activeColor: AppColors.success400,
                    inactiveColor: AppColors.backgroundGrey500,
                    value: subscribeWhatsapp.data ?? false,
                    height: Dimens.font_24,
                    width: Dimens.padding_48,
                    onToggle: (value) {
                      isProfileUpdated = true;
                      _editPersonalInfoCubit.changeIsWhatsappSubscribed(value);
                      if (value) {
                        _editPersonalInfoCubit.subscribeWhatsapp(
                            widget.currentUser.userProfile!.userId!);
                      } else {
                        showWhatsAppBottomSheet(context, () {
                          _editPersonalInfoCubit.unSubscribeWhatsapp(
                              widget.currentUser.userProfile!.userId!);
                          MRouter.pop(null);
                        }, () {
                          _editPersonalInfoCubit
                              .changeIsWhatsappSubscribed(true);
                          _editPersonalInfoCubit.subscribeWhatsapp(
                              widget.currentUser.userProfile!.userId!);
                          MRouter.pop(null);
                        });
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPANCardWidgets() {
    if ((widget.currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hideIdProof) ??
        false)) {
      return const SizedBox();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_24, Dimens.margin_16, Dimens.padding_24, 0),
            child: TextFieldLabel(label: 'pan_card'.tr),
          ),
          StreamBuilder<UserProfile>(
            stream: _editPersonalInfoCubit.userProfile,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data!.kycDetails?.panVerificationStatus ==
                    PanStatus.verified) {
                  String maskNumber = StringUtils.maskString(
                      snapshot.data!.kycDetails?.panCardNumber, 2, 2);
                  return buildCardNumberVerifyInProgressWidgets(
                      maskNumber, buildVerifiedWidget());
                } else if (snapshot.data!.kycDetails?.panVerificationStatus ==
                    PanStatus.inProgress) {
                  String maskNumber = StringUtils.maskString(
                      snapshot.data!.kycDetails?.panCardNumber, 2, 2);
                  return buildCardNumberVerifyInProgressWidgets(
                      maskNumber, buildInProgressWidget());
                } else {
                  return buildUploadOptionsCardWidgets(KYCType.idProofPAN);
                }
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      );
    }
  }

  Widget buildCardNumberVerifyInProgressWidgets(
      String maskNumber, Widget verifyInProgressWidget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.margin_8, Dimens.padding_24, 0),
      child: Row(
        children: [
          Text(maskNumber,
              style: Get.textTheme.bodyText2
                  ?.copyWith(color: AppColors.backgroundBlack)),
          const SizedBox(width: Dimens.padding_8),
          verifyInProgressWidget,
        ],
      ),
    );
  }

  Widget buildVerifiedWidget() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_4),
      decoration: BoxDecoration(
        color: AppColors.secondary2100,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_4)),
        border: Border.all(
          color: AppColors.secondary2100,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/ic_verify.svg',
          ),
          const SizedBox(width: Dimens.padding_4),
          Text('verified'.tr,
              style: Get.textTheme.captionMedium
                  ?.copyWith(color: AppColors.backgroundBlack)),
        ],
      ),
    );
  }

  Widget buildInProgressWidget() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_4),
      decoration: BoxDecoration(
        color: AppColors.warning200,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_4)),
        border: Border.all(
          color: AppColors.warning200,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/ic_in_progress.svg',
          ),
          const SizedBox(width: Dimens.padding_4),
          Text('in_progress'.tr,
              style: Get.textTheme.captionMedium
                  ?.copyWith(color: AppColors.backgroundBlack)),
        ],
      ),
    );
  }

  Widget buildUploadOptionsCardWidgets(KYCType kycType) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.margin_16, Dimens.padding_24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KYCType.idProofPAN == kycType
              ? TextFieldLabel(
                  label: 'upload_pan_card_to_withdraw_your_earnings'.tr,
                  color: AppColors.backgroundGrey800)
              : const SizedBox(),
          SizedBox(
              height: KYCType.idProofPAN == kycType ? Dimens.padding_16 : 0),
          Row(
            children: [
              Expanded(child: buildSelectFromCameraWidget(context, kycType)),
              const SizedBox(width: Dimens.padding_16),
              Expanded(child: buildSelectFromGalleryWidget(context, kycType))
            ],
          )
        ],
      ),
    );
  }

  Widget buildSelectFromCameraWidget(BuildContext context, KYCType kycType) {
    return MyInkWell(
      onTap: () async {
        _captureImage(kycType);
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
              const Icon(Icons.camera_alt,
                  color: AppColors.backgroundGrey600, size: Dimens.iconSize_20),
              const SizedBox(width: Dimens.padding_12),
              Text(
                'camera'.tr,
                style: Get.textTheme.bodyText1
                    ?.copyWith(color: context.theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectFromGalleryWidget(BuildContext context, KYCType kycType) {
    String hint = 'gallery'.tr;
    return MyInkWell(
      onTap: () async {
        _pickMedia(kycType);
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
              const Icon(Icons.photo_library,
                  color: AppColors.backgroundGrey600, size: Dimens.iconSize_20),
              const SizedBox(width: Dimens.padding_12),
              Text(
                hint,
                style: Get.textTheme.bodyText1
                    ?.copyWith(color: context.theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _captureImage(KYCType kycType) async {
    if (kycType == KYCType.idProofPAN &&
        (widget.currentUser.userProfile?.kycDetails?.panVerificationCount ??
                0) >=
            3) {
      _editPersonalInfoCubit.changeUIStatus(UIStatus(
          failedWithoutAlertMessage:
              'please_contact_support_to_get_your_pan_card_verified'.tr));
      return;
    } else if (kycType == KYCType.idProofAadhar &&
        (widget.currentUser.userProfile?.aadharDetails
                    ?.aadhaarVerificationCount ??
                0) >=
            3) {
      _editPersonalInfoCubit.changeUIStatus(UIStatus(
          failedWithoutAlertMessage:
              'please_contact_support_to_get_your_aadhar_card_verified'.tr));
      return;
    }
    switch (kycType) {
      case KYCType.idProofPAN:
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.verifyPanProfile,
            pageName: LoggingPageNames.profiles);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
      case KYCType.idProofAadhar:
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.verifyAadhaarProfile,
            pageName: LoggingPageNames.profiles);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
      case KYCType.idProofDrivingLicence:
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.verifyDlProfile,
            pageName: LoggingPageNames.profiles);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
    }
    ImageDetails imageDetails = ImageDetails(uploadLater: false);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data != null) {
      DocumentVerificationData documentVerificationData =
          DocumentVerificationData(
              kycType: kycType, imageDetails: cameraWidgetResult.data);
      WidgetResult? widgetResult = await MRouter.pushNamed(
          MRouter.documentVerificationWidget,
          arguments: documentVerificationData);
      if (widgetResult != null && widgetResult.event == Event.updated) {
        SPUtil? spUtil = await SPUtil.getInstance();
        UserData? currentUser = spUtil?.getUserData();
        if (currentUser != null) {
          isProfileUpdated = true;
          _editPersonalInfoCubit.getUserProfile(widget.currentUser.id);
        }
      }
    }
  }

  void _pickMedia(KYCType kycType) {
    if (kycType == KYCType.idProofPAN &&
        (widget.currentUser.userProfile?.kycDetails?.panVerificationCount ??
                0) >=
            3) {
      _editPersonalInfoCubit.changeUIStatus(UIStatus(
          failedWithoutAlertMessage:
              'please_contact_support_to_get_your_pan_card_verified'.tr));
      return;
    } else if (kycType == KYCType.idProofAadhar &&
        (widget.currentUser.userProfile?.aadharDetails
                    ?.aadhaarVerificationCount ??
                0) >=
            3) {
      _editPersonalInfoCubit.changeUIStatus(UIStatus(
          failedWithoutAlertMessage:
              'please_contact_support_to_get_your_aadhar_card_verified'.tr));
      return;
    }
    switch (kycType) {
      case KYCType.idProofPAN:
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.verifyPanProfile,
            pageName: LoggingPageNames.profiles);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
      case KYCType.idProofAadhar:
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.verifyAadhaarProfile,
            pageName: LoggingPageNames.profiles);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
      case KYCType.idProofDrivingLicence:
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.verifyDlProfile,
            pageName: LoggingPageNames.profiles);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
    }
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
          SPUtil? spUtil = await SPUtil.getInstance();
          UserData? currentUser = spUtil?.getUserData();
          if (currentUser != null) {
            isProfileUpdated = true;
            _editPersonalInfoCubit.getUserProfile(widget.currentUser.id);
          }
        }
      },
    );
  }

  Widget buildAadharCardWidgets() {
    if ((widget.currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hideIdProof) ??
        false)) {
      return const SizedBox();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_24, Dimens.margin_16, Dimens.padding_24, 0),
            child: TextFieldLabel(label: 'aadhar_card'.tr),
          ),
          StreamBuilder<UserProfile>(
            stream: _editPersonalInfoCubit.userProfile,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data!.aadharDetails?.aadharVerificationStatus ==
                    PanStatus.verified) {
                  String maskNumber = StringUtils.maskString(
                      snapshot.data!.aadharDetails?.aadhardNumber, 2, 2);
                  return buildCardNumberVerifyInProgressWidgets(
                      maskNumber, buildVerifiedWidget());
                } else if (snapshot
                        .data!.aadharDetails?.aadharVerificationStatus ==
                    PanStatus.inProgress) {
                  String maskNumber = StringUtils.maskString(
                      snapshot.data!.aadharDetails?.aadhardNumber, 2, 2);
                  return buildCardNumberVerifyInProgressWidgets(
                      maskNumber, buildInProgressWidget());
                } else {
                  return buildUploadOptionsCardWidgets(KYCType.idProofAadhar);
                }
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      );
    }
  }

  Widget buildDLCardWidgets() {
    if ((widget.currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hideIdProof) ??
        false)) {
      return const SizedBox();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_24, Dimens.margin_16, Dimens.padding_24, 0),
            child: TextFieldLabel(label: 'driving_licence'.tr),
          ),
          StreamBuilder<UserProfile>(
            stream: _editPersonalInfoCubit.userProfile,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data!.dlDetails?.dlVerificationStatus ==
                    PanStatus.verified) {
                  String maskNumber = StringUtils.maskString(
                      snapshot.data!.dlDetails?.dldNumber, 2, 2);
                  return buildCardNumberVerifyInProgressWidgets(
                      maskNumber, buildVerifiedWidget());
                } else if (snapshot.data!.dlDetails?.dlVerificationStatus ==
                    PanStatus.inProgress) {
                  String maskNumber = StringUtils.maskString(
                      snapshot.data!.dlDetails?.dldNumber, 2, 2);
                  return buildCardNumberVerifyInProgressWidgets(
                      maskNumber, buildInProgressWidget());
                } else {
                  return buildUploadOptionsCardWidgets(
                      KYCType.idProofDrivingLicence);
                }
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      );
    }
  }

  Widget buildSaveChangesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: RaisedRectButton(
        text: 'save_changes'.tr,
        onPressed: () {
          Helper.hideKeyBoard(context);
          _editPersonalInfoCubit.updateUserProfile(
              widget.currentUser.userProfile!.userId!,
              widget.currentUser.userProfile?.email);
          _editPersonalInfoCubit
              .updateLanguages(widget.currentUser.userProfile!.userId!);
        },
      ),
    );
  }
}
