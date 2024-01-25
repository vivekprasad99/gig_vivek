import 'dart:io';

import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_event_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/nps_bottom_sheet/widget/nps_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_icon_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/cubit/theme_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/dream_application/widget/bottom_sheet/widget/dream_application_questions_bottom_sheet.dart';
import 'package:awign/workforce/more/feature/more/cubit/more_cubit.dart';
import 'package:awign/workforce/more/feature/more/data/model/more_widget_data.dart';
import 'package:awign/workforce/more/feature/more/widget/dream_application_nudge_widget.dart';
import 'package:awign/workforce/more/feature/more/widget/profile_completion_percent_widget.dart';
import 'package:awign/workforce/more/feature/rate_us/widget/rate_us_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/src/provider.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';

class MoreWidget extends StatefulWidget {
  final MoreWidgetData _moreWidgetData;

  const MoreWidget(this._moreWidgetData, {Key? key}) : super(key: key);

  @override
  _MoreWidgetState createState() => _MoreWidgetState();
}

class _MoreWidgetState extends State<MoreWidget> {
  final _moreCubit = sl<MoreCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;


  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
    checkAndSetThemMode();
    _moreCubit.getDeviceInfo();
  }

  void subscribeUIStatus() {
    _moreCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.deleted:
            Helper.doLogout();
            break;
          case Event.none:
            break;
        }
      },
    );
    if (widget._moreWidgetData.openProfileWidget) {
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        _openProfileWidget();
      });
    }
    if (widget._moreWidgetData.openCampusAmbassadorWidget) {
      _moreCubit.campusAmbassadorResponseStream.listen((event) {
        if (event.status!.isNotEmpty &&
            _currentUser!.permissions!.awign!
                .contains(AwignPermissionConstants.referral)) {
          MRouter.pushNamed(MRouter.openCaTaskWidget);
        } else {
          MRouter.pushNamed(MRouter.noAccessWidget);
        }
      }).onError((e) {
        MRouter.pushNamed(MRouter.campusAmbassadorWidget);
      });
    }
    if (widget._moreWidgetData.shareAwignAppLink) {
      Helper.shareAwignAppLink(_currentUser);
    }
  }

  void checkAndSetThemMode() async {
    bool isDarkModeEnabled =
        await context.read<ThemeCubit>().getIsDarkModeEnabled();
    _moreCubit.changeIsDarkMode(isDarkModeEnabled);
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    setState(() {
      _currentUser = spUtil?.getUserData();
    });
    if (_currentUser != null) {
      _moreCubit.changeCurrentUser(_currentUser!);
    }
    if(_currentUser?.id != null){
      _moreCubit.getCampusAmbassador(_currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        return true;
      },
      child: RouteWidget(
        bottomNavigation: true,
        child: AppScaffold(
          backgroundColor: AppColors.primaryMain,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                DefaultAppBar(
                  isCollapsable: true,
                  isAvatarVisible: true,
                  isNudgeVisibleAroundCircularAvatar: /*(_currentUser?.userProfile?.profileCompletionPercentage != 100)*/
                      false,
                  nudgeValue:
                      _currentUser?.userProfile?.profileCompletionPercentage ??
                          20,
                  profileURL: _currentUser?.image,
                  name: _currentUser?.name,
                ),
              ];
            },
            body: buildBody(),
          ),
        ),
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
      child: InternetSensitive(
        child: StreamBuilder<UserData>(
            stream: _moreCubit.currentUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  Dimens.padding_16,
                                  Dimens.padding_16,
                                  Dimens.padding_16,
                                  0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        buildNameText(),
                                        buildProfileCompletedIcon(),
                                      ],
                                    ),
                                  ),
                                  buildViewDetailsButton(),
                                ],
                              ),
                            ),
                            buildDreamApplicationNudgeBannerWidgets(
                                snapshot.data!),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: Dimens.padding_12),
                            //   child: HDivider(),
                            // ),
                            const SizedBox(height: Dimens.padding_8),
                            // buildMyProfileText(),
                            Visibility(
                              visible: snapshot.data != null,
                              child: Column(
                                children: [
                                  buildCampusAmbassadorText(),
                                  Visibility(
                                      visible: RemoteConfigHelper.instance()
                                          .isLeaderboardEnabled,
                                      child: buildLeaderBoardText()),
                                  // buildHelpAndSupportText(),
                                  // buildKYCDetailsText(),
                                  // buildLanguageText(),
                                  // buildDarkModeContainer(),
                                  buildApplicationHistoryText(),
                                  buildShareText(),
                                  buildResetPINText(),
                                  buildFaqsAndSupport(),
                                  buildHowAppWorks(),
                                  buildDND(),
                                  buildRateUs(),
                                  buildDeleteAccount(),
                                  buildLogout(),
                                  buildInspectApi()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    buildAppVersionWidget(),
                  ],
                );
              } else {
                return buildLoginCard();
              }
            }),
      ),
    );
  }

  Widget buildNameText() {
    String name = '';
    if ((_currentUser?.userProfile?.name ?? '').isNotEmpty) {
      name = (_currentUser?.userProfile?.name ?? ''.toTitleCase());
    }
    return Flexible(
        child: Text(name, style: Get.context?.textTheme.headline5SemiBold));
  }

  Widget buildProfileCompletedIcon() {
    if (_currentUser?.userProfile?.profileCompletionPercentage == 100) {
      return Padding(
        padding: const EdgeInsets.only(left: Dimens.padding_8),
        child: SvgPicture.asset('assets/images/ic_profile_complete.svg'),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildViewDetailsButton() {
    return CustomTextButton(
      height: Dimens.btnHeight_40,
      width: Dimens.btnWidth_128,
      text: 'view_details'.tr,
      backgroundColor: AppColors.transparent,
      borderColor: AppColors.primaryMain,
      textStyle:
          Get.textTheme.bodyText2Medium?.copyWith(color: AppColors.primaryMain),
      radius: Dimens.radius_20,
      onPressed: () {
        MRouter.pushNamed(MRouter.profileDetailsWidget);
      },
    );
  }

  Widget buildDreamApplicationNudgeBannerWidgets(UserData currentUser) {
    return DreamApplicationNudgeWidget(
      currentUser: currentUser,
      bottomWidget: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: ProfileCompletionPercentWidget(currentUser)),
          const SizedBox(width: Dimens.padding_16),
          MyInkWell(
            onTap: () {
              showDreamApplicationQuestionsBottomSheet(
                  context,
                  DreamApplicationCompletionStage.professionalDetails1,
                  _onBottomSheetClosed);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'complete'.tr,
                  style: Get.textTheme.bodyText2SemiBold
                      ?.copyWith(color: AppColors.primaryMain),
                ),
                const SizedBox(width: Dimens.padding_4),
                SvgPicture.asset(
                  'assets/images/ic_arrow_right.svg',
                  color: AppColors.primaryMain,
                  width: Dimens.iconSize_14,
                  height: Dimens.iconSize_14,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _onBottomSheetClosed() {
    _moreCubit.getUserProfile(_currentUser!);
  }

  // Row(
  // children: [
  // Text('complete'.tr),
  // const SizedBox(width: Dimens.padding_16),
  // SvgPicture.asset(
  // 'assets/images/ic_arrow_right.svg',
  // ),
  // ],
  // ),

  Widget buildMobileNumber() {
    String mobileNo =
        StringUtils.maskString(_currentUser?.userProfile?.mobileNumber, 3, 3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: CustomTextIconButton(Get.textTheme.bodyText2!,
          height: Dimens.btnHeight_32,
          iconData: Icons.call,
          iconColor: Get.theme.iconColorNormal,
          text: mobileNo),
    );
  }

  Widget buildEmail() {
    String email =
        StringUtils.maskString(_currentUser?.userProfile?.email, 4, 4);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
      child: CustomTextIconButton(Get.textTheme.bodyText2!,
          height: Dimens.btnHeight_32,
          iconData: Icons.email,
          iconColor: Get.theme.iconColorNormal,
          text: email),
    );
  }

  Widget buildMyProfileText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: CustomTextIconButton(
              Get.textTheme.bodyText1!,
              height: Dimens.btnHeight_40,
              svgIcon: 'assets/images/ic_my_profile.svg',
              iconColor: Get.theme.iconColorNormal,
              iconPadding: Dimens.padding_16,
              text: 'my_profile'.tr,
              onPressed: () {
                _openProfileWidget();
              },
            ),
          ),
          if (_currentUser?.userProfile?.profileCompletionPercentage != 100)
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: Dimens.margin_12),
                child: Container(
                  width: Dimens.radius_4,
                  height: Dimens.radius_4,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.error400),
                ),
              ),
            )
        ],
      ),
    );
  }

  _openProfileWidget() async {
    LoggingData loggingData =
        LoggingData(action: LoggingActions.completeProfile);
    CaptureEventHelper.captureEvent(loggingData: loggingData);

    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser);
    ClevertapHelper.instance()
        .addCleverTapEvent(ClevertapHelper.editProfile, properties);
    MRouter.pushNamed(MRouter.profileDetailsWidget, arguments: {}).then((value) => {
          setState(() {
            _currentUser = spUtil?.getUserData();
          })
        });
  }

  Widget buildCampusAmbassadorText() {
    bool hideCA = false;
    if ((_currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideCampusAmbassador) ??
        false)) {
      hideCA = true;
    } else if ((_currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.campusAmbassador) ??
        false)) {
      hideCA = true;
    }
    if (hideCA) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: CustomTextIconButton(
          Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_campus_ambassador.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'become_campus_ambassador'.tr,
          onPressed: () async {
            if (_moreCubit.campusAmbassadorResponse.hasError) {
              MRouter.pushNamed(MRouter.campusAmbassadorWidget);
            } else if (_moreCubit.campusAmbassadorResponse.hasValue) {
              Map<String, dynamic> properties =
                  await UserProperty.getUserProperty(_currentUser);
              ClevertapData clevertapData = ClevertapData(
                  eventName: ClevertapHelper.campusAmbassadorCta,
                  properties: properties);
              CaptureEventHelper.captureEvent(clevertapData: clevertapData);

              if (_moreCubit
                      .campusAmbassadorResponse.value.status!.isNotEmpty &&
                  _currentUser!.permissions!.awign!
                      .contains(AwignPermissionConstants.referral)) {
                MRouter.pushNamed(MRouter.openCaTaskWidget);
              } else {
                MRouter.pushNamed(MRouter.noAccessWidget);
              }
            }
          },
        ),
      );
    }
  }

  Widget buildShareText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: CustomTextIconButton(Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_share.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'share_app'.tr, onPressed: () {
        Helper.shareAwignAppLink(_currentUser);
      }),
    );
  }

  Widget buildResetPINText() {
    if (!(_currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideResetPIN) ??
        false)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: CustomTextIconButton(Get.textTheme.bodyText1!,
            height: Dimens.btnHeight_40,
            iconData: Icons.lock,
            iconColor: Get.theme.iconColorNormal,
            iconPadding: Dimens.padding_16,
            iconSize: Dimens.iconSize_16,
            text: 'reset_pin'.tr, onPressed: () {
          MRouter.pushNamed(MRouter.forgotPINWidget);
        }),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildApplicationHistoryText() {
    if ((_currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideApplicationHistory) ??
        false)) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: CustomTextIconButton(
          Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_application_history.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'application_history'.tr,
          onPressed: () async {
            MRouter.pushNamed(MRouter.applicationHistoryWidget);
            Map<String, dynamic> properties =
                await UserProperty.getUserProperty(_currentUser);
            ClevertapHelper.instance().addCleverTapEvent(
                ClevertapHelper.applicationHistory, properties);
          },
        ),
      );
    }
  }

  Widget buildFaqsAndSupport() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: CustomTextIconButton(
        Get.textTheme.bodyText1!,
        height: Dimens.btnHeight_40,
        svgIcon: 'assets/images/ic_faq_chat.svg',
        iconColor: Get.theme.iconColorNormal,
        iconPadding: Dimens.padding_16,
        text: 'faq_and_support'.tr,
        onPressed: () {
          MRouter.pushNamed(MRouter.faqAndSupportWidget, arguments: {});
        },
      ),
    );
  }

  Widget buildHowAppWorks() {
    if ((_currentUser?.permissions?.awign
                ?.contains(AwignPermissionConstants.hideHowTheAppWorks) ??
            false) &&
        RemoteConfigHelper.instance().isVideoConfigured) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: CustomTextIconButton(
          Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/info.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'how_the_app_works'.tr,
          onPressed: () {
            MRouter.pushNamed(MRouter.howAppWorksWidget, arguments: {});
          },
        ),
      );
    }
  }

  Widget buildDND() {
    FlavorCubit flavorCubit = context.read<FlavorCubit>();
    if ((_currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideDoNotDisturb) ??
        false)) {
      return const SizedBox();
    } else {
      return MyInkWell(
        onTap: () {
          if (flavorCubit.flavorConfig.appFlavor == AppFlavor.production) {
            BrowserHelper.customTab(
                context,
                "https://office.awign.com/projects/602d016b3ddaa1005f9d2d4e" +
                    "/project_roles/602d016b3ddaa1005f9d2d58/data_views/602d06af60a89c008896ed7e/leads/new");
          } else {
            BrowserHelper.customTab(
                context,
                "https://office.awigntest.com/" +
                    "projects/60ffdf7fc53e840080f6fba1/project_roles/60ffdf83c53e840080f6fbd7/data_views/60ffe123c53e840058f6fba6/leads/new");
          }
        },
        child: ListTile(
          visualDensity: const VisualDensity(
            horizontal: -4,
            vertical: -2,
          ),
          horizontalTitleGap: 0,
          leading: Image.asset(
            'assets/images/no_stopping.png',
            height: Dimens.iconSize_16,
          ),
          title: Text(
            "do_not_disturb".tr,
            style: Get.textTheme.bodyText1!,
          ),
          subtitle: Text(
            "unsubscribe_text".tr,
            style: Get.textTheme.bodySmall
                ?.copyWith(color: AppColors.backgroundGrey700),
          ),
        ),
      );
    }
  }

  Widget buildRateUs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: CustomTextIconButton(
        Get.textTheme.bodyText1!,
        height: Dimens.btnHeight_40,
        svgIcon: 'assets/images/ic_rate_us.svg',
        iconColor: Get.theme.iconColorNormal,
        iconPadding: Dimens.padding_16,
        text: 'rate_us'.tr,
        onPressed: () {
          LoggingData loggingData = LoggingData(
              action: LoggingActions.rateUsClicked,
              pageName: LoggingPageNames.profiles);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          showrateUsBottomSheet(context, MRouter.moreWidget);
        },
      ),
    );
  }

  Widget buildDeleteAccount() {
    return Visibility(
      visible: Platform.isIOS,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: CustomTextIconButton(
          Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_delete_user_account.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'delete_account'.tr,
          onPressed: () {
            _deleteUserAccount();
          },
        ),
      ),
    );
  }

  _deleteUserAccount() async {
    ConfirmAction? result = await Helper.asyncConfirmDialog(
        context, 'are_you_sure_want_to_delete_your_account'.tr,
        heading: 'delete_account'.tr,
        textOKBtn: 'yes'.tr,
        textCancelBtn: 'cancel'.tr);
    if (result == ConfirmAction.OK) {
      _moreCubit.deleteUserAccount(_currentUser?.id ?? -1);
    }
  }

  Widget buildLogout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: CustomTextIconButton(
        Get.textTheme.bodyText1!,
        height: Dimens.btnHeight_40,
        svgIcon: 'assets/images/ic_logout.svg',
        iconColor: Get.theme.iconColorNormal,
        iconPadding: Dimens.padding_16,
        text: 'logout'.tr,
        onPressed: () {
          Helper.doLogout();
        },
      ),
    );
  }

  Widget buildInspectApi() {
    FlavorCubit flavorCubit = context.read<FlavorCubit>();
    if (flavorCubit.flavorConfig.appFlavor != AppFlavor.production) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
        child: CustomTextIconButton(
          Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          text: "Inspect Api",
          onPressed: () {
            Alice _alice = Alice(
                navigatorKey: MRouter.globalNavigatorKey,
                showNotification: flavorCubit.flavorConfig.appFlavor != AppFlavor.production,
                showInspectorOnShake: flavorCubit.flavorConfig.appFlavor != AppFlavor.production,
                darkTheme: true
            );
            _alice.showInspector();
          },
        ),
      );
    } else {
     return const SizedBox();
    }
  }

  Widget buildNotificationHistoryText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
      child: CustomTextIconButton(Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_notification_history.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'notification_history'.tr),
    );
  }

  Widget buildHelpAndSupportText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
      child: CustomTextIconButton(Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_help_and_support.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'help_and_support'.tr),
    );
  }

  Widget buildKYCDetailsText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
      child: CustomTextIconButton(Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          svgIcon: 'assets/images/ic_kyc_details.svg',
          iconColor: Get.theme.iconColorNormal,
          iconPadding: Dimens.padding_16,
          text: 'kyc_details'.tr),
    );
  }

  Widget buildLanguageText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: CustomTextIconButton(Get.textTheme.bodyText1!,
          height: Dimens.btnHeight_40,
          iconData: Icons.logout,
          iconColor: Get.theme.iconColorNormal,
          iconSize: Dimens.iconSize_16,
          iconPadding: Dimens.padding_16,
          text: 'language'.tr, onPressed: () async {
        Map<String, dynamic> properties =
            await UserProperty.getUserProperty(_currentUser!);
        ClevertapData clevertapData = ClevertapData(
            eventName: ClevertapHelper.languageIcon, properties: properties);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
      }),
    );
  }

  Widget buildDarkModeContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
      child: Stack(
        children: [
          CustomTextIconButton(Get.textTheme.bodyText1!,
              height: Dimens.btnHeight_40,
              iconData: Icons.headphones,
              iconColor: Get.theme.iconColorNormal,
              iconSize: Dimens.iconSize_16,
              iconPadding: Dimens.padding_16,
              text: 'dark_mode'.tr),
          Positioned(
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: Dimens.padding_36),
              child: StreamBuilder<bool>(
                  stream: _moreCubit.isDarkMode,
                  builder: (context, isDarkMode) {
                    return Switch(
                      value: isDarkMode.data ?? false,
                      onChanged: (v) {
                        _moreCubit.changeIsDarkMode(v);
                        context.read<ThemeCubit>().changeTheme(v);
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, 0, Dimens.padding_16, Dimens.padding_8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0),
              title: Padding(
                padding: const EdgeInsets.only(bottom: Dimens.padding_12),
                child: Text(
                  'login_to_awign'.tr,
                  style: Get.context?.textTheme.labelLarge?.copyWith(
                      color: AppColors.black,
                      fontSize: Dimens.font_20,
                      fontWeight: FontWeight.w600),
                ),
              ),
              subtitle: Text(
                'Largest_gig_work_platform_to_earn_grow'.tr,
                style: Get.context?.textTheme.labelLarge?.copyWith(
                    color: AppColors.backgroundGrey900,
                    fontSize: Dimens.font_14,
                    fontWeight: FontWeight.w400),
              ),
              trailing: SizedBox(
                width: Dimens.btnWidth_100,
                height: Dimens.margin_40,
                child: RaisedRectButton(
                  text: 'login'.tr,
                  onPressed: () =>
                      {MRouter.pushNamed(MRouter.phoneVerificationWidget)},
                ),
              ),
            )),
      ),
    );
  }

  bool shouldShowNewUpdateOnLeaderBoard() {
    DateTime now = DateTime.now();
    int currentDay = now.day;
    int startDay = 5;
    int endDay = RemoteConfigHelper.instance().showNewUpdateForLeaderBoard + startDay;
    int lastShownMonth = (spUtil!.leaderBoardFlagShownLastMonth() ?? -1);
    return currentDay >= startDay && currentDay <= endDay && lastShownMonth != getCurrentMonth();
  }

  int getCurrentMonth() {
    return DateTime.now().month; // Subtract 1 because DateTime uses zero-based months
  }

  Widget buildLeaderBoardText() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_8, Dimens.padding_8, Dimens.padding_8, 0),
      child: CustomTextIconButton(
        Get.textTheme.bodyText1!,
        height: Dimens.btnHeight_48,
        svgIcon: 'assets/images/ranking.svg',
        rightSideGIF: shouldShowNewUpdateOnLeaderBoard()
            ? 'assets/images/new_update_bell.gif'
            : '',
        iconColor: Get.theme.iconColorNormal,
        iconPadding: Dimens.padding_16,
        text: 'leaderboard'.tr,
        onPressed: () {
          Future<bool>? aa = spUtil!.setLeaderBoardFlagShownLastMonth(getCurrentMonth());
          MRouter.pushNamed(MRouter.leaderBoardWidget, arguments: {});
          aa?.then((value) => setState(() {}));
          CaptureEventHelper.captureEvent(
              loggingData: LoggingData(
              event: LoggingEvents.accessedLeaderboard,
              action: LoggingActions.click,
              pageName: "Leaderboard",
              sectionName: "Profile")
          );
        },
      ),
    );
  }

  Widget buildAppVersionWidget() {
    return StreamBuilder<String>(
        stream: _moreCubit.versionReleaseStream,
        builder: (context, versionReleaseStream) {
          if (versionReleaseStream.hasData) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundGrey300,
              ),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: Dimens.padding_16),
              padding: const EdgeInsets.all(Dimens.padding_16),
              child: Text('${'app_version'.tr} ${versionReleaseStream.data}',
                  style: Get.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundBlack)),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
