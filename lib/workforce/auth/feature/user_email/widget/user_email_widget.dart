import 'package:awign/workforce/auth/feature/user_email/cubit/user_email_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
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
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class UserEmailWidget extends StatefulWidget {
  const UserEmailWidget({Key? key}) : super(key: key);

  @override
  State<UserEmailWidget> createState() => _UserEmailWidgetState();
}

class _UserEmailWidgetState extends State<UserEmailWidget> {
  final _userEmailCubit = sl<UserEmailCubit>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _userEmailCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.none:
            break;
          case Event.success:
            SPUtil? spUtil = await SPUtil.getInstance();
            _currentUser = spUtil?.getUserData();
            AuthHelper.checkOnboardingStages(_currentUser!);
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
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: 'create_account'.tr,
              isPopUpMenuVisible: true,
            ),
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
      child: InternetSensitive(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_32, 0, Dimens.padding_32, Dimens.padding_16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: Dimens.radius_32,
                      backgroundColor: AppColors.grey,
                      child: SvgPicture.asset(
                          'assets/images/ic_ellipse_yellow.svg'),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Text(Emoji.hi,
                            style: Get.textTheme.bodyText1
                                ?.copyWith(fontSize: Dimens.font_28))),
                  ],
                ),
                const SizedBox(
                  height: Dimens.margin_24,
                ),
                Text(
                  'we_see_you_are_new_here'.tr,
                  style: Get.textTheme.headline6
                      ?.copyWith(color: AppColors.backgroundBlack),
                ),
                const SizedBox(
                  height: Dimens.margin_12,
                ),
                Text(
                  'unlock_endless_opportunities_with_just_one_simple_step'.tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey800),
                ),
                const SizedBox(
                  height: Dimens.margin_40,
                ),
                buildGoogleLoginButton(),
                const SizedBox(
                  height: Dimens.margin_24,
                ),
                buildEmailLoginButton(),
                const Spacer(),
                const Spacer(),
                buildAlreadyAccount()
              ],
            )),
      ),
    );
  }

  Widget buildGoogleLoginButton() {
    return RaisedRectButton(
      backgroundColor: AppColors.primaryMain,
      svgIcon: 'assets/images/ic_google_g_logo.svg',
      text: "Continue With Google",
      textColor: AppColors.backgroundWhite,
      onPressed: () {
        _userEmailCubit.googleSignIn();
      },
    );
  }

  Widget buildEmailLoginButton() {
    return InkWell(
      child: Text('enter_email_manually'.tr,
          style: context.textTheme.bodyText2Medium
              ?.copyWith(color: AppColors.primaryMain)),
      onTap: () {
        MRouter.pushNamed(MRouter.enterEmailManuallyWidget);
      },
    );
  }

  Widget buildAlreadyAccount() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'already_have_an_account'.tr,
              style: Get.context?.textTheme.bodyText2
                  ?.copyWith(color: AppColors.backgroundGrey800),
            ),
            const SizedBox(
              width: Dimens.margin_8,
            ),
            buildLoginText(),
          ],
        ),
      ),
    );
  }

  Widget buildLoginText() {
    return MyInkWell(
      onTap: () {
        MRouter.pushNamed(MRouter.phoneVerificationWidget);
      },
      child: Text('login'.tr,
          style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.primaryMain, fontWeight: FontWeight.w600)),
    );
  }
}
