import 'dart:async';
import 'dart:io';

import 'package:awign/workforce/auth/feature/otp_verification/cubit/otp_verification_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/data/remote/moengage/moengage_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/remote/facebook/facebook_constant.dart';
import '../../../../core/data/remote/facebook/facebook_helper.dart';
import '../../otp_less_login/cubit/otp_less_cubit.dart';

class PageType<String> extends Enum1<String> {
  const PageType(String val) : super(val);

  static const PageType forgotPIN = PageType('forgot_pin');
  static const PageType verifyPIN = PageType('verify_pin');
  static const PageType onboarding = PageType('onboarding');
  static const PageType verifyAadhar = PageType('verify_aadhar');
  static const PageType verifyWithdrawlPin = PageType('verify_withdrawl_pin');
}

class OTPVerificationWidget extends StatefulWidget {
  final String mobileNumber;
  final String fromRoute;
  final PageType pageType;

  const OTPVerificationWidget(this.mobileNumber, this.fromRoute, this.pageType,
      {Key? key})
      : super(key: key);

  @override
  _OTPVerificationWidgetState createState() => _OTPVerificationWidgetState();
}

class _OTPVerificationWidgetState extends State<OTPVerificationWidget> {
  final _otpVerificationCubit = sl<OtpVerificationCubit>();
  final TextEditingController _otpController = TextEditingController();
  UserData? _currentUser;
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  final _otplessFlutterPlugin = Otpless();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    initPlatformState();
    getUserData();
    listenForOTPCodeOnAndroid();
  }

  void listenForOTPCodeOnAndroid() async {
    if (Platform.isAndroid) {
      SmsAutoFill().code.listen((String code) {
        _otpController.text = code;
      });
    }
  }

  void getUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    switch (widget.pageType) {
      case PageType.verifyPIN:
        if (_currentUser != null) {
          _otpVerificationCubit.generatePINOTP(_currentUser!);
        }
        break;
      case PageType.forgotPIN:
        _otpVerificationCubit.startTimeout();
        break;
      case PageType.verifyWithdrawlPin:
        _otpVerificationCubit.generateOTP(_currentUser!.id!);
        break;
      case PageType.verifyAadhar:
        break;
      default:
        _otpVerificationCubit.startTimeout();
        _otpVerificationCubit.startTimeoutForWhatsApp();
        break;
    }
  }

  void subscribeUIStatus() {
    _otpVerificationCubit.uiStatus.listen(
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
          case Event.otpSent:
            LoggingData loggingData = LoggingData(
                event: LoggingEvents.mobileNumberContinueSuccessful,
                pageName: LoggingPageNames.phoneVerification);
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            _otpVerificationCubit.startTimeout();
            _otpVerificationCubit.startTimeoutForWhatsApp();
            break;
          case Event.verified:
            if (widget.fromRoute == MRouter.phoneVerificationWidget) {
              MoEngage.setUniqueId(uiStatus.data.toString());
              Map<String, dynamic> properties =
                  await UserProperty.getUserProperty(_currentUser!);
              ClevertapData clevertapData = ClevertapData(
                  eventName: ClevertapHelper.mobileNumberOtpVerify,
                  properties: properties);
              LoggingData loggingData = LoggingData(
                  event: LoggingEvents.otpEnterContinueSuccessful,
                  pageName: LoggingPageNames.otpVerification);
              CaptureEventHelper.captureEvent(
                  clevertapData: clevertapData, loggingData: loggingData);
              FaceBookEventHelper.addEvent(FacebookConstant.signIn, null);

              _otpVerificationCubit.validTokenWithProfile
                  .listen((validTokenWithProfile) {
                AuthHelper.checkOnboardingStages(validTokenWithProfile.user!, arguments: {
                  'from_route': MRouter.oTPVerificationWidget,
                });
              });
            } else {
              MRouter.pop(WidgetResult(event: Event.verified));
            }
            break;
          case Event.failed:
            if (widget.pageType == PageType.verifyAadhar) {
              MRouter.pop(WidgetResult(event: Event.failed));
            }
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _errorController.close();
    SmsAutoFill().unregisterListener();
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
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            const DefaultAppBar(
              isCollapsable: true,
              title: 'OTP Verification',
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                0, Dimens.padding_32, 0, Dimens.padding_16),
            child: StreamBuilder<bool?>(
              stream: _otpVerificationCubit.isLoaderTrue,
              builder: (context, snapshot) {
                if(snapshot.hasData && snapshot.data!)
                {
                  return showLottieLoader();
                }else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildDescriptionText(),
                      buildTitleText(),
                      buildOTPTextField(),
                      buildOTPMessageText(),
                      // Visibility(
                      //   visible: RemoteConfigHelper.instance().isOtplessEnabled,
                      //   child:
                      buildWhatsAppMessageText(),
                      // ),
                      buildSubmitButton(),
                    ],
                  );
                }
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitleText() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(Dimens.margin_16, 0, Dimens.margin_16, 0),
      child: TextFieldLabel(label: 'Enter OTP'),
    );
  }

  String getEmail() {
    String email = _currentUser?.email ?? "";
    int? indexOf = _currentUser?.email?.indexOf("@");
    if (indexOf == null || indexOf == -1) {
      return email;
    }
    if (indexOf < 2) {
      return "${email.substring(0, indexOf - 1)}***${email.substring(
          indexOf, email.length)}";
    }
    return "${email.substring(0, 3)}***${email.substring(
        indexOf, email.length)}";
  }

  List<TextSpan> getSpannableText() {
    var elements = <TextSpan>{};

    elements.add(TextSpan(
        text: 'OTP Sent to ',
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.w400)));

    elements.add(TextSpan(
        text: getPhoneNumber(),
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.primaryMain,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.bold)));
    if (getEmail().isNotEmpty) {
      elements.add(TextSpan(
          text: " and ",
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.backgroundGrey800,
              fontSize: Dimens.font_14,
              fontWeight: FontWeight.w400)));

      elements.add(TextSpan(
          text: getEmail(),
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.primaryMain,
              fontSize: Dimens.font_14,
              fontWeight: FontWeight.bold)));
    }

    return elements.toList();
  }

  List<TextSpan> getSpannableText2() {
    var elements = <TextSpan>{};
    elements.add(TextSpan(
        text: 'OTP has been sent on your mobile number & registered email address if it exists',
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.w400)));
    return elements.toList();
  }

String getPhoneNumber() {
  String phone = widget.mobileNumber;

  return "${phone.substring(0, 2)}xxx${phone.substring(6)}";
}

Widget buildDescriptionText() {

  if (_currentUser != null &&
      _currentUser!.email != null &&
      _currentUser!.email!.isNotEmpty) {
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
        Dimens.margin_16, Dimens.margin_16),
    child: RichText(
      text: TextSpan(
        children: (widget.pageType == PageType.verifyPIN) ?  getSpannableText() : getSpannableText2(),
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.w400),
      ),
    ),
    );
  }

  Widget buildWhatsAppMessageText() {
    if (widget.pageType == PageType.verifyAadhar) {
      return const SizedBox();
    } else {
      return StreamBuilder<String?>(
          stream: _otpVerificationCubit.timerTextForWhatsApp,
          builder: (context, timerText) {
            if (timerText.data == '00:00') {
              return MyInkWell(
                onTap: () async {
                  initiateWhatsappLogin(
                      "https://awign.authlink.me?redirectUri=awignotpless://otpless");
                  Helper.clearUserData();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
                  child: Row(
                    children: [
                      if (widget.pageType == PageType.onboarding) ...[
                        Text('login_via_whatsapp'.tr,
                            style: Get.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryMain)),
                        const SizedBox(width: Dimens.margin_8),
                        SvgPicture.asset(
                          'assets/images/org_whatsapp.svg',
                        )
                      ]
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          });
    }
  }

  Widget buildOTPTextField() {
    return StreamBuilder<String?>(
      stream: _otpVerificationCubit.otp,
      builder: (context, otp) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: PinCodeTextField(
            appContext: context,
            length: widget.pageType == PageType.verifyAadhar ? 6 : 5,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderWidth: Dimens.border_1,
                borderRadius: BorderRadius.circular(Dimens.radius_4),
                fieldHeight: Dimens.imageHeight_48,
                fieldWidth: Dimens.imageHeight_48,
                activeFillColor: AppColors.backgroundGrey400,
                activeColor: AppColors.backgroundGrey400,
                inactiveColor: AppColors.backgroundGrey400,
                inactiveFillColor: AppColors.backgroundGrey400,
                selectedColor: AppColors.primaryMain,
                selectedFillColor: AppColors.backgroundGrey400),
            keyboardType: TextInputType.number,
            cursorColor: AppColors.black,
            animationDuration: const Duration(milliseconds: 300),
            // backgroundColor: Colors.blue.shade50,
            enableActiveFill: true,
            errorAnimationController: _errorController,
            controller: _otpController,
            onCompleted: (v) {},
            onChanged: _otpVerificationCubit.changeOTP,
            beforeTextPaste: (text) {
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
          ),
        );
      },
    );
  }

  Widget buildOTPMessageText() {
    if (widget.pageType == PageType.verifyAadhar) {
      return const SizedBox();
    } else {
      return StreamBuilder<String?>(
        stream: _otpVerificationCubit.timerText,
        builder: (context, timerText) {
          if (timerText.data == '00:00') {
            return Column(
              children: [
                buildResendOTPText(),
              ],
            );
          } else {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
              child: Text('${"Resend OTP in"} ${timerText.data}',
                  style: Get.context?.textTheme.bodyText2),
            );
          }
        },
      );
    }
  }

  Widget buildResendOTPText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            switch (widget.pageType) {
              case PageType.verifyPIN:
                LoggingData loggingData = LoggingData(
                    action: LoggingEvents.resendOtpPinClicked,
                    pageName: 'Enter otp earnings'
                  );
                CaptureEventHelper.captureEvent(loggingData: loggingData);
                break;
              case PageType.forgotPIN:
                if (_currentUser != null) {
                  _otpVerificationCubit.generatePINOTP(_currentUser!);
                }
                break;
              default:
                _otpVerificationCubit.generateOTP(_currentUser!.id!);
                LoggingData loggingData = LoggingData(
                  action: LoggingEvents.resendOtpLoginClicked,
                  pageName: 'Enter otp login'
                );
                CaptureEventHelper.captureEvent(loggingData: loggingData);
                break;
            }
          },
          child: Text(
            'resend_otp'.tr,
            style: Get.context?.textTheme.bodyText1?.copyWith(
              color: AppColors.primaryMain,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_48, Dimens.padding_16, 0),
      child: RaisedRectButton(
        buttonStatus: _otpVerificationCubit.buttonStatus,
        text: 'verify'.tr,
        onPressed: () {
          if (_currentUser != null) {
            if (widget.pageType == PageType.onboarding) {
              _otpVerificationCubit.verifyOTP(_currentUser!.id!);
            } else if (widget.pageType == PageType.verifyAadhar) {
              _otpVerificationCubit.verifyAadharOTP(
                  _currentUser!.id!,
                  (_currentUser!.userProfile?.aadharDetails
                              ?.aadhaarVerificationCount ??
                          0) >=
                      2);
            } else if (widget.pageType == PageType.verifyPIN ||
                widget.pageType == PageType.forgotPIN || widget.pageType == PageType.verifyWithdrawlPin) {
              _otpVerificationCubit.verifyPINOTP(_currentUser!.id!);
            }
          }
        },
      ),
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
          textAlign: TextAlign.center,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.black),
        ),
      ],
    );
  }

  void initiateWhatsappLogin(String intentUrl) async {
    var result =
        await _otplessFlutterPlugin.loginUsingWhatsapp(intentUrl: intentUrl);
  }

  Future<void> initPlatformState() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    if(spUtil?.isOtpListnedForOtpVerification() == null || spUtil?.isOtpListnedForOtpVerification() == true) {
      spUtil?.putOtpListnerForOtpVerification(false);
      _otplessFlutterPlugin.authStream.listen((token) {
        if(spUtil?.isOtpListned() == null) {
          _otpVerificationCubit.changeIsLoaderTrue(true);
          sl<OtpLessCubit>().signInWhatsappLogin(token!);
        }
      });
    }
  }
}
