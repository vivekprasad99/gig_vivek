import 'dart:async';

import 'package:awign/workforce/auth/feature/otp_less_login/cubit/otp_less_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/firebase/remote_config/remote_config_helper.dart';
import '../../otp_verification/cubit/otp_verification_cubit.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({Key? key}) : super(key: key);

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  final _otpLessCubit = sl<OtpLessCubit>();
  final _otplessFlutterPlugin = Otpless();
  StreamSubscription<String?>? streamSubscription;
  bool value = true;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    subscribeUIStatus();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  void subscribeUIStatus() {
    _otpLessCubit.uiStatus.listen(
      (uiStatus) {
        switch (uiStatus.event) {
          case Event.failed:
            MRouter.pushNamedAndRemoveUntil(MRouter.userEmailWidget);
            break;
          case Event.none:
            break;
        }
      },
    );
    _otpLessCubit.validTokenWithProfile.listen(
      (validateTokenResponse) {
        AuthHelper.checkOnboardingStages(validateTokenResponse.user!);
      },
      onError: (e) {
        MRouter.pushNamedAndRemoveUntil(MRouter.onboardingIntroWidget);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(context),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            const DefaultAppBar(
              isCollapsable: true,
              title: 'Awign',
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
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_16,
          ),
          child:  StreamBuilder<bool?>(
            stream: _otpLessCubit.isLoaderTrue,
            builder: (context, snapshot) {
              if(snapshot.hasData && snapshot.data!)
                {
                  return showLottieLoader();
                }else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildTitleIcon(),
                            const SizedBox(height: Dimens.margin_40),
                            buildTitleWidget(),
                            const SizedBox(height: Dimens.margin_24),
                            MyInkWell(
                                onTap: () {
                                  Helper.clearUserData();
                                  MRouter.pushNamed(
                                      MRouter.phoneVerificationWidget);
                                },
                                child: buildLoginCard(
                                    'assets/images/mobile.svg',
                                    AppColors.link400, 'mobile_number'.tr)),
                            const SizedBox(height: Dimens.margin_24),
                            // if(RemoteConfigHelper.instance().isOtplessEnabled) ...[
                            MyInkWell(
                                onTap: () async {
                                  Helper.clearUserData();
                                  initiateWhatsappLogin(
                                      "https://awign.authlink.me?redirectUri=awignotpless://otpless");
                                },
                                child: buildLoginCard(
                                    'assets/images/whatsapp.svg',
                                    AppColors.success400, 'whatsapp'.tr)),
                            const SizedBox(height: Dimens.margin_8),
                            buildFasterLoginWidget(),
                            // ],
                          ],
                        ),
                      ),
                    ),
                    buildBottomTextContainer(),
                  ],
                );
              }
            }
          ),
        ),
      ),
    );
  }

  Widget buildLoginCard(String imgurl, Color color, String name) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryMain),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_12)),
        ),
        child: ListTile(
          leading: SvgPicture.asset(
            imgurl,
            color: color,
          ),
          title: Text(
            name,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: AppColors.primaryMain, size: Dimens.iconSize_20),
        ));
  }

  Widget buildTitleIcon() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: Dimens.padding_20,
        ),
        child: SvgPicture.asset(
          'assets/images/login.svg',
        ),
      ),
    );
  }

  Widget buildTitleWidget() {
    return Text(
      'login_singnup_with'.tr,
      textAlign: TextAlign.start,
      style: Get.context?.textTheme.labelLarge?.copyWith(
          color: AppColors.black,
          fontSize: Dimens.font_24,
          fontWeight: FontWeight.w600),
    );
  }

  Widget buildFasterLoginWidget() {
    return Row(
      children: [
        Text(
          'recommended_for_faster_login'.tr,
          textAlign: TextAlign.start,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.backgroundGrey800,
              fontSize: Dimens.font_12,
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: Dimens.margin_4),
        SvgPicture.asset(
          'assets/images/flash.svg',
        ),
      ],
    );
  }

  Widget buildBottomTextContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'by_continuing'.tr,
              style: context.textTheme.captionMedium?.copyWith(
                color: AppColors.primary700,
                fontSize: Dimens.font_12,
              ),
            ),
            buildPrivacyPolicyText(),
            Text(
              ' ${'and'.tr}',
              style: context.textTheme.captionMedium
                  ?.copyWith(color: AppColors.primary700,fontSize: Dimens.font_12,),
            ),
          ],
        ),
        const SizedBox(height: Dimens.margin_4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: Dimens.margin_4),
            buildTermsAndConditionsText(),
          ],
        ),
      ],
    );
  }


  Widget buildTermsAndConditionsText() {
    return MyInkWell(
      onTap: () {
        BrowserHelper.customTab(
            context, "https://www.awign.com/terms_and_conditions");
      },
      child: Text('terms_and_conditions'.tr,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: AppColors.primaryMain,fontSize: Dimens.font_12)),
    );
  }

  Widget buildPrivacyPolicyText() {
    return MyInkWell(
      onTap: () {
        BrowserHelper.customTab(
            context, "https://www.awign.com/privacy_policy");
      },
      child: Text(' ${'privacy_policy'.tr}',
          textAlign: TextAlign.start,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: AppColors.primaryMain,fontSize: Dimens.font_12)),
    );
  }

  Widget showLottieLoader()
  {
    return Column(
      children: [
        const SizedBox(height: Dimens.margin_80),
        Center(child: Lottie.asset("assets/images/loader.json")),
        Text(
          'thanks_for_chossing_awign'.tr,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.black),
        ),
      ],
    );
  }

  void initiateWhatsappLogin(String intentUrl) async {
    var result = await _otplessFlutterPlugin
        .loginUsingWhatsapp(intentUrl: intentUrl);
  }


  Future<void> initPlatformState() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    if((spUtil?.isOtpListned() == null || spUtil?.isOtpListned() == true))
      {
        spUtil?.putOtpListner(false);
        streamSubscription = _otplessFlutterPlugin.authStream.listen((token) {
          if(spUtil?.isOtpListnedForOtpVerification() == null)
            {
              _otpLessCubit.changeIsLoaderTrue(true);
              _otpLessCubit.signInWhatsappLogin(token!);
            }
        });
      }

  }
}
