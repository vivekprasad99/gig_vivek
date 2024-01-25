import 'package:awign/workforce/auth/feature/welcome/cubit/welcome_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
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

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({Key? key}) : super(key: key);

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  final _welcomeCubit = sl<WelcomeCubit>();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _welcomeCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
    _welcomeCubit.validTokenWithProfile.listen((validTokenWithProfile) {
      AuthHelper.checkOnboardingStages(validTokenWithProfile.user!);
    });
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: Dimens.padding_24, top: Dimens.padding_200),
              child: SvgPicture.asset(
                'assets/images/ic_awign_logo.svg',
                color: AppColors.backgroundWhite,
              ),
            ),
          ),
          buildCenterWidgets(),
          buildBottomTextContainer(),
        ],
      ),
    );
  }

  Widget buildCenterWidgets() {
    return InternetSensitive(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_32, Dimens.padding_48, Dimens.padding_32, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildWelcomeText(),
              const SizedBox(height: Dimens.margin_32),
              buildGoogleLoginButton(),
              const SizedBox(height: Dimens.margin_24),
              buildEmailLoginText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWelcomeText() {
    return Text(
      'welcome_text'.tr,
      textAlign: TextAlign.center,
      style: Get.context?.textTheme.headline3
          ?.copyWith(color: AppColors.backgroundWhite),
    );
  }

  Widget buildGoogleLoginButton() {
    return RaisedRectButton(
      backgroundColor: AppColors.backgroundWhite,
      svgIcon: 'assets/images/ic_google_g_logo.svg',
      text: 'continue_with_google'.tr,
      textColor: AppColors.black,
      onPressed: () async {
        LoggingData loggingData = LoggingData(
            action: LoggingActions.continueWithGoogle,
            pageName: LoggingPageNames.createAccount);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        _welcomeCubit.googleSignIn();
      },
    );
  }

  Widget buildEmailLoginText() {
    return Align(
      alignment: Alignment.centerRight,
      child: MyInkWell(
        onTap: () {
          LoggingData loggingData = LoggingData(
              action: LoggingActions.continueWithEmail,
              pageName: LoggingPageNames.createAccount);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          MRouter.pushNamed(MRouter.emailSignInWidget);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
          child: Text(
            'login_using_email'.tr,
            style: Get.context?.textTheme.bodyText1?.copyWith(
              color: AppColors.backgroundWhite,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottomTextContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'by_continuing'.tr,
              style: Get.context?.textTheme.bodyText2
                  ?.copyWith(color: AppColors.backgroundWhite),
            ),
            const SizedBox(height: Dimens.margin_4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPrivacyPolicyText(),
                const SizedBox(width: Dimens.margin_4),
                Text(
                  'and'.tr,
                  style: Get.context?.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundWhite),
                ),
                const SizedBox(width: Dimens.margin_4),
                buildTermsAndConditionsText(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrivacyPolicyText() {
    return MyInkWell(
      onTap: () {},
      child: Text(
        'privacy_policy'.tr,
        style: Get.context?.textTheme.bodyText2?.copyWith(
          color: AppColors.backgroundWhite,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget buildTermsAndConditionsText() {
    return MyInkWell(
      onTap: () {},
      child: Text(
        'terms_and_conditions'.tr,
        style: Get.context?.textTheme.bodyText2?.copyWith(
          color: AppColors.backgroundWhite,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
