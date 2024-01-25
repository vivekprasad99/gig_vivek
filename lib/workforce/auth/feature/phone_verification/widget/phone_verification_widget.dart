import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/auth/feature/phone_verification/cubit/phone_verification_cubit.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PhoneVerificationWidget extends StatefulWidget {
  String? originRoute;

  PhoneVerificationWidget({Key? key, this.originRoute}) : super(key: key);

  @override
  _PhoneVerificationWidgetState createState() =>
      _PhoneVerificationWidgetState();
}

class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {
  final _phoneVerificationCubit = sl<PhoneVerificationCubit>();
  final TextEditingController _mobileNumberController = TextEditingController();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    setData();
    subscribeUIStatus();
  }

  void setData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _mobileNumberController.text =
        widget.originRoute != MRouter.editPersonalInfoWidget &&
                _currentUser?.email != null
            ? (_currentUser?.userProfile?.mobileNumber ?? '')
            : '';
    if ((_currentUser?.userProfile?.mobileNumber ?? '').isNotEmpty &&
        (_currentUser?.userProfile?.email ?? '').isNotEmpty &&
        widget.originRoute != MRouter.editPersonalInfoWidget) {
      _phoneVerificationCubit
          .changeMobileNumber(_currentUser?.userProfile?.mobileNumber);
    }
    _phoneVerificationCubit.changeIsWhatsappSubscribed(
        _currentUser?.subscribedToWhatsapp ?? false);
  }

  void subscribeUIStatus() {
    _phoneVerificationCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.otpSent:
            MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
              'mobile_number': _mobileNumberController.text,
              'from_route': MRouter.phoneVerificationWidget,
              'page_type': PageType.onboarding
            });
            _phoneVerificationCubit
                .changeButtonStatus(ButtonStatus(isEnable: true));
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
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
        Helper.hideKeyBoard(context);
        return Future.value(true);
      },
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        bottomPadding: 0,
        topPadding: 0,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              DefaultAppBar(
                isCollapsable: true,
                title: 'login_or_signup'.tr,
              ),
            ];
          },
          body: buildBody(),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, Dimens.padding_16, 0, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: Dimens.padding_20,
                          ),
                          child: SvgPicture.asset(
                            'assets/images/login.svg',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                            Dimens.padding_40, Dimens.margin_16, 0),
                        child: TextFieldLabel(label: 'mobile_number'.tr),
                      ),
                      buildPhoneNumberTextField(),
                      buildContinueButton(),
                      // const Spacer(),
                      // buildBottomTextContainer(),
                      buildBottomTextContainer(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimens.padding_16),
          ],
        ),
      ),
    );
  }

  Widget buildPhoneNumberTextField() {
    return StreamBuilder<String?>(
      stream: _phoneVerificationCubit.mobileNumber,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            controller: _mobileNumberController,
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 10,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textInputAction: TextInputAction.done,
            onChanged: _phoneVerificationCubit.changeMobileNumber,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: (_mobileNumberController.text.isEmpty)
                  ? context.theme.textFieldBackgroundColor
                  : AppColors.backgroundWhite,
              hintText: 'enter_10_digit_number'.tr,
              counterText: "",
              hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
              errorText: snapshot.error?.toString(),
              errorMaxLines: 3,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.primaryMain),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                    Dimens.margin_8, Dimens.margin_12, Dimens.margin_8),
                child: SvgPicture.asset('assets/images/mobile.svg'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
      child: RaisedRectButton(
        buttonStatus: _phoneVerificationCubit.buttonStatus,
        text: "Send OTP",
        onPressed: () async {
          _phoneVerificationCubit.signInWithNumber();

          Map<String, dynamic> properties = {
            CleverTapConstant.userPhone: _mobileNumberController.text
          };
          ClevertapData clevertapData = ClevertapData(
              eventName: ClevertapHelper.mobileNumberOtpSend,
              properties: properties);
          CaptureEventHelper.captureEvent(clevertapData: clevertapData);
        },
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
                const SizedBox(width: Dimens.margin_4),
                Text(
                  'and'.tr,
                  style: context.textTheme.captionMedium
                      ?.copyWith(color: AppColors.primary700),
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
        ),
      ),
    );
  }

  Widget buildPrivacyPolicyText() {
    return MyInkWell(
      onTap: () {
        BrowserHelper.customTab(
            context, "https://www.awign.com/privacy_policy");
      },
      child: Text(' ${'privacy_policy'.tr}',
          style: context.textTheme.bodyMedium
              ?.copyWith(color: AppColors.primaryMain)),
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
              ?.copyWith(color: AppColors.primaryMain)),
    );
  }

  // Widget buildTitleText() {
  //   return Text(
  //     "login_using_the_mobile_number".tr,
  //     style: Get.textTheme.bodyText2?.copyWith(
  //         color: AppColors.backgroundBlack,
  //         fontSize: Dimens.font_16,
  //         fontWeight: FontWeight.w500),
  //   );
  // }
}
