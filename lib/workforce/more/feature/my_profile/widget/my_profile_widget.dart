import 'package:awign/workforce/auth/data/model/profile_attributes_and_application_questions.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/edit_address/widget/edit_address_widget.dart';
import 'package:awign/workforce/more/feature/edit_collage_details/widget/edit_collage_details_widget.dart';
import 'package:awign/workforce/more/feature/edit_other_details/widget/edit_other_details_widget.dart';
import 'package:awign/workforce/more/feature/edit_personal_info/widget/edit_personal_info_widget.dart';
import 'package:awign/workforce/more/feature/edit_professional_details/widget/edit_professional_details_widget.dart';
import 'package:awign/workforce/more/feature/my_profile/cubit/my_profile_cubit.dart';
import 'package:awign/workforce/more/feature/my_profile/widget/tile/address_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MyProfileWidget extends StatefulWidget {
  const MyProfileWidget({Key? key}) : super(key: key);

  @override
  _MyProfileWidgetState createState() => _MyProfileWidgetState();
}

class _MyProfileWidgetState extends State<MyProfileWidget> {
  final _myProfileCubit = sl<MyProfileCubit>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  UserData? _curUser;
  bool isCollegevisible = true;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _myProfileCubit.uiStatus.listen(
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
      },
    );
    _myProfileCubit.userProfileResponse.listen((userProfileResponse) {
      setProfileData(userProfileResponse.userProfile);
    });
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _curUser = spUtil?.getUserData();
    _myProfileCubit.getProfileAndAttributes(_curUser?.id);
    _myProfileCubit.changenudgePercentage(
        _curUser?.userProfile?.profileCompletionPercentage ?? 20);
  }

  void setProfileData(UserProfile? userProfile) {
    _nameController.text = userProfile?.name ?? ''.toTitleCase();
    _phoneController.text = userProfile?.mobileNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _monthController.dispose();
    _yearController.dispose();
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
            StreamBuilder<int?>(
                stream: _myProfileCubit.nudgePercentage,
                builder: (context, nudgePercentage) {
                  if (nudgePercentage.hasData) {
                    return DefaultAppBar(
                        isCollapsable: true,
                        isNudgeVisible: true,
                        nudgeValue: nudgePercentage.data,
                        title: 'my_profile'.tr);
                  } else {
                    return DefaultAppBar(
                        isCollapsable: true, title: 'my_profile'.tr);
                  }
                }),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<UIStatus>(
          stream: _myProfileCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: StreamBuilder<UserProfileResponse>(
                    stream: _myProfileCubit.userProfileResponse,
                    builder: (context, userProfileResponse) {
                      if (userProfileResponse.hasData) {
                        isCollegevisible =
                            _myProfileCubit.isCollegeDetailsVisible(
                                userProfileResponse.data?.userProfile);
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, Dimens.padding_24, 0, Dimens.padding_16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimens.padding_24, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildTitleText(),
                                      if (_myProfileCubit
                                          .isProfileSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        buildIncompleteIndicator(),
                                      if (_myProfileCubit
                                          .isProfileSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        const Spacer(),
                                      if (_myProfileCubit
                                          .isProfileSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        buildWeightageIndicator(),
                                      buildPersonalInfoEditButton(
                                          userProfileResponse
                                              .data?.currentUser),
                                    ],
                                  ),
                                ),
                                buildNameRow(
                                    userProfileResponse.data?.userProfile),
                                buildMobileNoRow(
                                    userProfileResponse.data?.userProfile),
                                buildEmailIDRow(
                                    userProfileResponse.data?.userProfile),
                                buildGenderRow(
                                    userProfileResponse.data?.userProfile),
                                buildDOBRow(
                                    userProfileResponse.data?.userProfile),
                                buildLanguageRow(
                                    userProfileResponse.data?.userProfile),
                                buildWhatsappUpdatesRow(
                                    userProfileResponse.data?.userProfile),
                                buildPANCardWidgets(
                                    userProfileResponse.data?.currentUser),
                                buildAadharCardWidgets(
                                    userProfileResponse.data?.currentUser),
                                buildDLCardWidgets(
                                    userProfileResponse.data?.currentUser),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimens.padding_24,
                                      Dimens.margin_16,
                                      Dimens.padding_24,
                                      0),
                                  child: HDivider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimens.padding_24, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildAddressText(),
                                      if (_myProfileCubit
                                          .isAddressSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        buildIncompleteIndicator(),
                                      if (_myProfileCubit
                                          .isAddressSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        const Spacer(),
                                      if (_myProfileCubit
                                          .isAddressSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        buildWeightageIndicator(),
                                      buildAddressEditButton(userProfileResponse
                                          .data?.userProfile),
                                    ],
                                  ),
                                ),
                                buildAddressContainer(
                                    userProfileResponse.data?.userProfile),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimens.padding_24,
                                      Dimens.margin_8,
                                      Dimens.padding_24,
                                      0),
                                  child: HDivider(),
                                ),
                                if (isCollegevisible)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        Dimens.padding_24, 0, 0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildCollageDetailsText(),
                                        if (_myProfileCubit
                                            .isCollegeSectionComplete(
                                                userProfileResponse
                                                    .data?.userProfile))
                                          buildIncompleteIndicator(),
                                        if (_myProfileCubit
                                            .isCollegeSectionComplete(
                                                userProfileResponse
                                                    .data?.userProfile))
                                          const Spacer(),
                                        if (_myProfileCubit
                                            .isCollegeSectionComplete(
                                                userProfileResponse
                                                    .data?.userProfile))
                                          buildWeightageIndicator(),
                                        buildCollageDetailsEditButton(
                                            userProfileResponse
                                                .data?.userProfile),
                                      ],
                                    ),
                                  ),
                                if (isCollegevisible)
                                  buildCollageRow(userProfileResponse
                                      .data?.userProfile?.education),
                                // buildDegreeRow(userProfileResponse.data?.userProfile?.education),
                                if (isCollegevisible)
                                  buildFieldRow(userProfileResponse
                                      .data?.userProfile?.education),
                                if (isCollegevisible)
                                  buildYearRow(userProfileResponse
                                      .data?.userProfile?.education),
                                if (isCollegevisible)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        Dimens.padding_24,
                                        Dimens.margin_16,
                                        Dimens.padding_24,
                                        0),
                                    child: HDivider(),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimens.padding_24, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildProfessionalDetailsText(),
                                      if (_myProfileCubit
                                          .isProfessionalDetailSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        buildIncompleteIndicator(),
                                      if (_myProfileCubit
                                          .isProfessionalDetailSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        const Spacer(),
                                      if (_myProfileCubit
                                          .isProfessionalDetailSectionComplete(
                                              userProfileResponse
                                                  .data?.userProfile))
                                        buildWeightageIndicator(),
                                      buildProfessionalDetailsEditButton(
                                          userProfileResponse
                                              .data?.userProfile),
                                    ],
                                  ),
                                ),
                                buildQualificationRow(
                                    userProfileResponse.data?.userProfile),
                                buildProfessionalDomainRow(userProfileResponse
                                    .data
                                    ?.userProfile
                                    ?.professionalExperiences),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimens.padding_24,
                                      Dimens.margin_16,
                                      Dimens.padding_24,
                                      0),
                                  child: HDivider(),
                                ),
                                buildOtherDetailsWidgets(
                                    userProfileResponse.data?.userProfile),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return AppCircularProgressIndicator();
                      }
                    }),
              );
            }
          }),
    );
  }

  Widget buildTitleText() {
    return Text('personal_info'.tr, style: context.textTheme.bodyText1SemiBold);
  }

  Widget buildPersonalInfoEditButton(UserData? currentUser) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () => {openEditPersonalInfoWidget(currentUser)},
      child: Text(
        'edit'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  void openEditPersonalInfoWidget(UserData? currentUser) async {
    Map? map = await MRouter.pushNamedWithResult(context,
        EditPersonalInfoWidget(currentUser!), MRouter.editPersonalInfoWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _myProfileCubit.getProfileAndAttributes(_curUser?.id);
    }
  }

  Widget buildNameRow(UserProfile? userProfile) {
    String name = userProfile?.name ?? ''.toTitleCase();
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_24, 0, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'name'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMobileNoRow(UserProfile? userProfile) {
    String mobileNo = StringUtils.maskString(userProfile?.mobileNumber, 3, 3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'mobile_no'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              mobileNo,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailIDRow(UserProfile? userProfile) {
    String email = StringUtils.maskString(userProfile?.email, 4, 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'email_id'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              email,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGenderRow(UserProfile? userProfile) {
    String gender = (userProfile?.gender?.name() ?? '').toCapitalized();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'gender'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              gender,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDOBRow(UserProfile? userProfile) {
    String dob = '';
    if ((userProfile?.dob ?? '').isNotEmpty) {
      dob = (userProfile?.dob ?? '').getDateWithMonthName();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'dob'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              dob,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLanguageRow(UserProfile? userProfile) {
    List<Languages>? languages = userProfile?.languages;
    String languagesText = '';
    if (languages != null && languages.isNotEmpty) {
      languagesText = languages[0].name ?? '';
      for (int i = 1; i < languages.length; i++) {
        languagesText = '$languagesText, ${languages[i].name}';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'language'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              languagesText,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWhatsappUpdatesRow(UserProfile? userProfile) {
    var isSubscribedToWhatsapp = userProfile?.subscribedToWhatsapp ?? false;
    String strSubscribedToWhatsapp = 'inactive'.tr;
    if (isSubscribedToWhatsapp) {
      strSubscribedToWhatsapp = 'active'.tr;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'whatsapp_updates'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              strSubscribedToWhatsapp,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPANCardWidgets(UserData? currentUser) {
    if (currentUser != null &&
        (currentUser.permissions?.awign
                ?.contains(AwignPermissionConstants.hideIdProof) ??
            false)) {
      return const SizedBox();
    } else if (currentUser != null &&
        currentUser.userProfile?.kycDetails?.panVerificationStatus ==
            PanStatus.verified) {
      String maskNumber = StringUtils.maskString(
          currentUser.userProfile?.kycDetails?.panCardNumber, 2, 2);
      return buildCardNumberVerifyInProgressWidgets(
          'pan_card'.tr, maskNumber, buildVerifiedWidget());
    } else if (currentUser != null &&
        currentUser.userProfile?.kycDetails?.panVerificationStatus ==
            PanStatus.inProgress) {
      String maskNumber = StringUtils.maskString(
          currentUser.userProfile?.kycDetails?.panCardNumber, 2, 2);
      return buildCardNumberVerifyInProgressWidgets(
          'pan_card'.tr, maskNumber, buildInProgressWidget());
    } else {
      return buildDocumentNotSubmittedWidgets('pan_card'.tr);
    }
  }

  Widget buildAadharCardWidgets(UserData? currentUser) {
    if (currentUser != null &&
        (currentUser.permissions?.awign
                ?.contains(AwignPermissionConstants.hideIdProof) ??
            false)) {
      return const SizedBox();
    } else if (currentUser != null &&
        currentUser.userProfile?.aadharDetails?.aadharVerificationStatus ==
            PanStatus.verified) {
      String maskNumber = StringUtils.maskString(
          currentUser.userProfile?.aadharDetails?.aadhardNumber, 2, 2);
      return buildCardNumberVerifyInProgressWidgets(
          'aadhar_card'.tr, maskNumber, buildVerifiedWidget());
    } else if (currentUser != null &&
        currentUser.userProfile?.aadharDetails?.aadharVerificationStatus ==
            PanStatus.inProgress) {
      String maskNumber = StringUtils.maskString(
          currentUser.userProfile?.aadharDetails?.aadhardNumber, 2, 2);
      return buildCardNumberVerifyInProgressWidgets(
          'aadhar_card'.tr, maskNumber, buildInProgressWidget());
    } else {
      return buildDocumentNotSubmittedWidgets('aadhar_card'.tr);
    }
  }

  Widget buildDLCardWidgets(UserData? currentUser) {
    if (currentUser != null &&
        (currentUser.permissions?.awign
                ?.contains(AwignPermissionConstants.hideIdProof) ??
            false)) {
      return const SizedBox();
    } else if (currentUser != null &&
        currentUser.userProfile?.dlDetails?.dlVerificationStatus ==
            PanStatus.verified) {
      String maskNumber = StringUtils.maskString(
          currentUser.userProfile?.dlDetails?.dldNumber, 2, 2);
      return buildCardNumberVerifyInProgressWidgets(
          'driving_licence'.tr, maskNumber, buildVerifiedWidget());
    } else if (currentUser != null &&
        currentUser.userProfile?.dlDetails?.dlVerificationStatus ==
            PanStatus.inProgress) {
      String maskNumber = StringUtils.maskString(
          currentUser.userProfile?.dlDetails?.dldNumber, 2, 2);
      return buildCardNumberVerifyInProgressWidgets(
          'driving_licence'.tr, maskNumber, buildInProgressWidget());
    } else {
      return buildDocumentNotSubmittedWidgets('driving_licence'.tr);
    }
  }

  Widget buildCardNumberVerifyInProgressWidgets(
      String label, String maskNumber, Widget verifyInProgressWidget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: label),
          ),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(maskNumber,
                    style: Get.textTheme.bodyText2
                        ?.copyWith(color: AppColors.backgroundBlack)),
                const SizedBox(width: Dimens.padding_8),
                verifyInProgressWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerifiedWidget() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_4, 0, Dimens.padding_4, 0),
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
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_4, 0, Dimens.padding_4, 0),
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

  Widget buildDocumentNotSubmittedWidgets(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: label),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text('not_submitted'.tr,
                    style: Get.textTheme.bodyText2
                        ?.copyWith(color: AppColors.backgroundBlack)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddressText() {
    return Text('address'.tr, style: context.textTheme.bodyText1SemiBold);
  }

  Widget buildAddressEditButton(UserProfile? userProfile) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () => {
        openEditAddressWidget(userProfile),
      },
      child: Text(
        'edit'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  void openEditAddressWidget(UserProfile? userProfile) async {
    Map? map = await MRouter.pushNamedWithResult(
        context, EditAddressWidget(userProfile!), MRouter.editAddressWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _myProfileCubit.getProfileAndAttributes(_curUser?.id);
    }
  }

  Widget buildAddressContainer(UserProfile? userProfile) {
    if (userProfile?.addresses != null && userProfile!.addresses!.isNotEmpty) {
      List<Address> tempAddressList = [];
      for (var address in userProfile.addresses!) {
        if (address.primary && tempAddressList.isEmpty) {
          tempAddressList.add(address);
        }
      }
      if (tempAddressList.isNotEmpty) {
        return buildAddressList(tempAddressList);
      } else {
        return buildAddNewAddressButton();
      }
    } else {
      return buildAddNewAddressButton();
    }
  }

  Widget buildAddressList(List<Address> addressList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount: addressList.length,
        itemBuilder: (_, i) {
          return AddressTile(
            index: i,
            address: addressList[i],
          );
        },
      ),
    );
  }

  Widget buildAddNewAddressButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.transparent,
          ),
          onPressed: () => {
            //MRouter.pushNamed(MRouter.phoneVerificationWidget),
          },
          child: Text(
            'add_new'.tr,
            style: context.textTheme.bodyText1?.copyWith(
                color: context.theme.iconColorHighlighted,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildCollageDetailsText() {
    return Text('college_details'.tr,
        style: context.textTheme.bodyText1SemiBold);
  }

  Widget buildCollageDetailsEditButton(UserProfile? userProfile) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () => {
        openEditCollageDetailWidget(userProfile),
      },
      child: Text(
        'edit'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  void openEditCollageDetailWidget(UserProfile? userProfile) async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        EditCollageDetailsWidget(userProfile!),
        MRouter.editCollageDetailsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _myProfileCubit.getProfileAndAttributes(_curUser?.id);
    }
  }

  Widget buildCollageRow(Education? education) {
    String collageName = education?.collegeName ?? '';
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_24, 0, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'collage'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              collageName,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDegreeRow(Education? education) {
    String degree = education?.stream ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'degree'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              degree,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldRow(Education? education) {
    String field = education?.fieldOfStudy ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'field'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              field,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildYearRow(Education? education) {
    String year = '';
    if ((education?.fromYear ?? '').isNotEmpty &&
        (education?.toYear ?? '').isNotEmpty) {
      year = '${education?.fromYear ?? ''} - ${education?.toYear ?? ''}';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: TextFieldLabel(label: 'year'.tr),
          ),
          Expanded(
            flex: 3,
            child: Text(
              year,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfessionalDetailsText() {
    return Text('professional_details'.tr,
        style: context.textTheme.bodyText1SemiBold);
  }

  Widget buildProfessionalDetailsEditButton(UserProfile? userProfile) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () => {
        openEditProfessionalDetailsWidget(userProfile),
      },
      child: Text(
        'edit'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  void openEditProfessionalDetailsWidget(UserProfile? userProfile) async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        EditProfessionalDetailsWidget(userProfile!),
        MRouter.editProfessionalDetailsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _myProfileCubit.getProfileAndAttributes(_curUser?.id);
    }
  }

  Widget buildQualificationRow(UserProfile? userProfile) {
    String qualification = userProfile?.educationLevel ?? '';
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_24, 0, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFieldLabel(label: 'qualification'.tr),
          ),
          Expanded(
            flex: 5,
            child: Text(
              qualification.replaceAll('_', ' ').toCapitalized(),
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfessionalDomainRow(
      List<ProfessionalExperiences>? professionalExperiences) {
    String domain = '';
    if (professionalExperiences != null && professionalExperiences.isNotEmpty) {
      for (int i = 0; i < professionalExperiences.length; i++) {
        if (i == 0) {
          domain = (professionalExperiences[i].skill ?? '')
              .replaceAll('_', ' ')
              .toCapitalized();
        } else {
          domain =
              '$domain, ${(professionalExperiences[i].skill ?? '').replaceAll('_', ' ').toCapitalized()}';
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFieldLabel(label: 'professional_domain'.tr),
          ),
          Expanded(
            flex: 5,
            child: Text(
              domain,
              style: Get.textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOtherDetailsWidgets(UserProfile? userProfile) {
    return StreamBuilder<ProfileAttributesAndApplicationQuestions>(
      stream: _myProfileCubit.profileAttributesAndApplicationQuestions,
      builder: (context, profileAttributesAndApplicationQuestions) {
        if (profileAttributesAndApplicationQuestions.hasData) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Dimens.padding_24, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildOtherDetailsText(),
                    if (_myProfileCubit.isOtherDetailsSectionComplete(
                        profileAttributesAndApplicationQuestions.data))
                      buildIncompleteIndicator(),
                    if (_myProfileCubit.isOtherDetailsSectionComplete(
                        profileAttributesAndApplicationQuestions.data))
                      const Spacer(),
                    if (_myProfileCubit.isOtherDetailsSectionComplete(
                        profileAttributesAndApplicationQuestions.data))
                      buildWeightageIndicator(),
                    buildOtherDetailsEditButton(
                        profileAttributesAndApplicationQuestions.data!),
                  ],
                ),
              ),
              buildOtherQuestionList(
                  profileAttributesAndApplicationQuestions.data),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildOtherDetailsText() {
    return Text('other_details'.tr, style: context.textTheme.bodyText1SemiBold);
  }

  Widget buildOtherDetailsEditButton(
      ProfileAttributesAndApplicationQuestions
          profileAttributesAndApplicationQuestions) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () => {
        openEditOtherDetailsWidget(profileAttributesAndApplicationQuestions),
      },
      child: Text(
        'edit'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  void openEditOtherDetailsWidget(
      ProfileAttributesAndApplicationQuestions
          profileAttributesAndApplicationQuestions) async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        EditOtherDetailsWidget(profileAttributesAndApplicationQuestions),
        MRouter.editOtherDetailsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _myProfileCubit.getProfileAndAttributes(_curUser?.id);
    }
  }

  Widget buildOtherQuestionList(
      ProfileAttributesAndApplicationQuestions?
          profileAttributesAndApplicationQuestions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount: profileAttributesAndApplicationQuestions?.questions.length,
        itemBuilder: (_, i) {
          Question? question =
              profileAttributesAndApplicationQuestions?.questions[i];
          if (question?.configuration?.attributeName == null) {
            return const SizedBox();
          } else {
            ProfileAttributes? profileAttributes =
                ProfileAttributes.getProfileAttribute(
                    question?.configuration?.attributeName,
                    profileAttributesAndApplicationQuestions
                        ?.userProfileAttributes);
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_8, 0, Dimens.padding_8, Dimens.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFieldLabel(
                      label: question?.configuration?.questionText ?? ''),
                  const SizedBox(height: Dimens.padding_8),
                  Text(
                    profileAttributes?.attributeValue ?? '',
                    style: Get.textTheme.bodyText1,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildIncompleteIndicator() {
    return Padding(
      padding:
          const EdgeInsets.only(left: Dimens.margin_4, bottom: Dimens.margin_8),
      child: Container(
        width: Dimens.radius_4,
        height: Dimens.radius_4,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.error400),
      ),
    );
  }

  Widget buildWeightageIndicator() {
    String weightage = "";
    if (isCollegevisible) {
      weightage = '+20%';
    } else {
      weightage = '+25%';
    }
    return Text(
      weightage,
      style: context.textTheme.bodyText1Bold
          ?.copyWith(color: AppColors.success300),
    );
  }
}
