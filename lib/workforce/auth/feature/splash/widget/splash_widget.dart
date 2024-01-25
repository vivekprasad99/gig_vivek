import 'dart:async';

import 'package:awign/workforce/auth/feature/splash/cubit/splash_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/deep_link/cubit/deep_link_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/animation/ripple_animation.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/cubit/theme_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/src/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../../../../core/data/remote/facebook/facebook_constant.dart';
import '../../../../core/data/remote/facebook/facebook_helper.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/utils/app_upgrade_dialog.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  final _splashCubit = sl<SplashCubit>();
  SPUtil? spUtil;
  late Future<bool> isUpdateDialogShowing;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    context.read<ThemeCubit>().updateAppTheme();
    Timer(const Duration(seconds: 3), () => launchAuthOrDashboardWidget());
    FaceBookEventHelper.addEvent(FacebookConstant.appOpen, null);
  }

  void subscribeUIStatus() {
    _splashCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
    _splashCubit.validTokenWithProfile.listen(
      (validateTokenResponse) async {
        if (sl<DeepLinkCubit>().initialURI != null &&
            sl<DeepLinkCubit>().initialURI!.path.isNotEmpty &&
            sl<DeepLinkCubit>().initialURI!.path != "/") {
          sl<DeepLinkCubit>()
              .launchWidgetFromDeepLink(sl<DeepLinkCubit>().initialURI!.path);
        } else {
          if (await isUpdateDialogShowing == false) {
            AuthHelper.checkOnboardingStages(validateTokenResponse.user!,
              isTrustBuildingWidgetShown:
                  spUtil?.getIsTrustBuildingWidgetShown());
          }
        }
        LoggingData loggingData = LoggingData(event: LoggingEvents.openApp);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
      },
      onError: (e) {
        MRouter.pushNamedAndRemoveUntil(MRouter.onboardingIntroWidget);
      },
    );
  }

  void launchAuthOrDashboardWidget() async {
    spUtil = await SPUtil.getInstance();
    UserData? userData = spUtil?.getUserData();
    _splashCubit.getLaunchConfig();
    _splashCubit.funAppLaunch(userData);
    if (userData != null) {
      _splashCubit.validateTokenAndGetUserProfile(userData.id);
    } else if (sl<DeepLinkCubit>().initialURI != null &&
        sl<DeepLinkCubit>().initialURI.toString().contains("waId=")) {
      _splashCubit.signInWhatsappLogin(
          sl<DeepLinkCubit>().initialURI!.toString().split('waId=')[1]);
    } else {
      if (await isUpdateDialogShowing == false) {
        MRouter.pushNamedAndRemoveUntil(MRouter.onboardingIntroWidget);
      }
      // MRouter.pushNamedAndRemoveUntil(MRouter.userEmailWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    isUpdateDialogShowing = AppUpgradeDialogHelper().checkVersionAndShowAppUpgradeDialog(context, true);
    return ScreenTypeLayout(
      mobile: buildSplashForMobile(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildSplashForMobile() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      topPadding: 0,
      bottomPadding: 0,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: RippleAnimation(
              repeat: true,
              color: AppColors.primary500,
              minRadius: 90,
              ripplesCount: 6,
              duration: const Duration(milliseconds: 5300),
              child: SvgPicture.asset(
                'assets/images/ic_awign_logo.svg',
                color: AppColors.backgroundWhite,
              ),
            ),
          ),
          buildBottomWaveWidget(),
        ],
      ),
    );
  }

  Widget buildBottomWaveWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 150,
        child: WaveWidget(
          config: CustomConfig(
            colors: [
              AppColors.link500,
              AppColors.link400,
              AppColors.link300,
              AppColors.link200,
            ],
            durations: [32000, 21000, 18000, 5000],
            heightPercentages: [0.25, 0.26, 0.28, 0.31],
          ),
          size: const Size(double.infinity, double.infinity),
          waveAmplitude: 0,
        ),
      ),
    );
  }
}
