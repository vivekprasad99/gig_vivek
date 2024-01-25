import 'dart:async';

import 'package:awign/workforce/auth/data/model/user_mobile_verification_request.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/auth/data/repository/pin/pin_remote_repository.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_events.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/take_a_tour/tour_keys.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';

part 'otp_verification_state.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> with Validator {
  final AuthRemoteRepository _authRemoteRepository;
  final PINRemoteRepository _pinRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _otp = BehaviorSubject<String?>();

  Stream<String?> get otp => _otp.stream;

  Function(String?) get changeOTP => _otp.sink.add;

  final _timerText = BehaviorSubject<String?>.seeded('00:30');

  Stream<String?> get timerText => _timerText.stream;

  Function(String?) get changeTimerText => _timerText.sink.add;

  final _timerTextForWhatsApp = BehaviorSubject<String?>.seeded('00:10');

  Stream<String?> get timerTextForWhatsApp => _timerTextForWhatsApp.stream;

  Function(String?) get changeTimerTextForWhatsApp =>
      _timerTextForWhatsApp.sink.add;

  final _validateTokenResponse = BehaviorSubject<ValidateTokenResponse>();

  Stream<ValidateTokenResponse> get validateTokenResponse =>
      _validateTokenResponse.stream;

  Function(ValidateTokenResponse) get changeValidateTokenResponse =>
      _validateTokenResponse.sink.add;

  final _userProfileResponse = BehaviorSubject<UserProfileResponse>();

  Stream<UserProfileResponse> get userProfileResponse =>
      _userProfileResponse.stream;

  final _validTokenWithProfile = BehaviorSubject<ValidateTokenResponse>();

  Stream<ValidateTokenResponse> get validTokenWithProfile =>
      _validTokenWithProfile.stream;

  final _isLoaderTrue = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoaderTrue => _isLoaderTrue.stream;
  bool get isLoaderTrueValue => _isLoaderTrue.value;
  Function(bool) get changeIsLoaderTrue => _isLoaderTrue.sink.add;

  PageType? pageType;

  OtpVerificationCubit(this._authRemoteRepository, this._pinRemoteRepository)
      : super(OtpVerificationInitial()) {
    otp.listen((value) {
      if (pageType == PageType.verifyAadhar) {
        if (Validator.check6DigitOTP(value) == null) {
          changeButtonStatus(ButtonStatus(isEnable: true));
        } else {
          changeButtonStatus(ButtonStatus(isEnable: false));
        }
      } else {
        if (Validator.checkOTP(value) == null) {
          changeButtonStatus(ButtonStatus(isEnable: true));
        } else {
          changeButtonStatus(ButtonStatus(isEnable: false));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _otp.close();
    _timerText.close();
    _validateTokenResponse.close();
    _userProfileResponse.close();
    _validTokenWithProfile.close();
    return super.close();
  }

  void verifyOTP(int userID) async {
    try {
      if (Validator.checkOTP(_otp.hasValue ? _otp.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkOTP(_otp.hasValue ? _otp.value : '')!));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      UserNewMobileVerificationRequest userNewMobileVerificationRequest =
          UserNewMobileVerificationRequest(
              otp: _otp.value, mobileNumber: null, signInWithOtp: true);
      UserNewLoginRequest userNewLoginRequest = UserNewLoginRequest(
          userNewMobileVerificationRequest: userNewMobileVerificationRequest);

      Tuple2<LoginResponse, String?> tuple2 =
          await _authRemoteRepository.verifyOTP(userID, userNewLoginRequest);
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putUserData(tuple2.item1.user);
      spUtil?.putAccessToken(tuple2.item1.headers?.accessToken ?? '');
      spUtil?.putClient(tuple2.item1.headers?.client ?? '');
      spUtil?.putUID(tuple2.item1.headers?.uid ?? '');
      spUtil?.putSaasOrgID(tuple2.item1.headers?.saasOrgID != null
          ? tuple2.item1.headers!.saasOrgID!
          : 'nil');
      validateTokenAndGetUserProfile(tuple2.item1.user.id, tuple2.item2);
      TourKeys.loginCount++;
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: tuple2.item2 ?? ''));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(
          event: Event.verified,
          successWithoutAlertMessage: tuple2.item2 ?? '',
          data: tuple2.item1.user.id));
    } on ServerException catch (e) {
      _logOTPEnterUnSuccessfulEvent();
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      _logOTPEnterUnSuccessfulEvent();
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      _logOTPEnterUnSuccessfulEvent();
      AppLog.e('verifyOTP : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  _logOTPEnterUnSuccessfulEvent() {
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.otpEnterContinueUnSuccessful,
        pageName: LoggingPageNames.otpVerification);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  void verifyPINOTP(int userID) async {
    try {
      if (Validator.checkOTP(_otp.hasValue ? _otp.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkOTP(_otp.hasValue ? _otp.value : '')!));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      ApiResponse apiResponse =
          await _pinRemoteRepository.verifyPINOTP(userID, _otp.value ?? '');
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: apiResponse.message ?? ''));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(
          event: Event.verified,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('verifyPINOTP : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  void verifyAadharOTP(int userID, bool rejectIfFailed) async {
    try {
      if (Validator.check6DigitOTP(_otp.hasValue ? _otp.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.check6DigitOTP(_otp.hasValue ? _otp.value : '')!));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      KycDetails kycDetails = await _authRemoteRepository.verifyAadharOTP(
          userID, _otp.value ?? '', rejectIfFailed);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currUser = spUtil?.getUserData();
      currUser?.userProfile?.aadharDetails = kycDetails;
      spUtil?.putUserData(currUser);
      changeButtonStatus(ButtonStatus(isSuccess: true));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.verified));
    } on ServerException catch (e) {
      changeUIStatus(
          UIStatus(event: Event.failed, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(
          UIStatus(event: Event.failed, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('verifyPINOTP : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          event: Event.failed,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  void startTimeout() {
    var interval = const Duration(seconds: 1);
    int timerMaxSeconds = 30;
    int currentSeconds = 0;
    var duration = interval;
    Timer.periodic(duration, (timer) {
      currentSeconds = timer.tick;
      String timerText =
          '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';
      changeTimerText(timerText);
      if (timer.tick >= timerMaxSeconds) timer.cancel();
    });
  }

  void generateOTP(int userID) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      ApiResponse apiResponse = await _authRemoteRepository.generateOTP(userID);
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.otpSent,
          successWithoutAlertMessage: apiResponse.message!));
    } on ServerException catch (e) {
      _logMobileNumberUnSuccessfulEvent();
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      _logMobileNumberUnSuccessfulEvent();
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      _logMobileNumberUnSuccessfulEvent();
      AppLog.e('generateOTP : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  _logMobileNumberUnSuccessfulEvent() {
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.mobileNumberContinueUnSuccessful,
        pageName: LoggingPageNames.phoneVerification);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  void validateTokenAndGetUserProfile(int? userID, String? message) async {
    Rx.combineLatest2(
      _validateTokenResponse.stream,
      _userProfileResponse.stream,
      (ValidateTokenResponse validateTokenResponse,
          UserProfileResponse userProfileResponse) {
        validateTokenResponse.user?.userProfile =
            userProfileResponse.userProfile;
        return validateTokenResponse;
      },
    ).listen((validateTokenResponse) async {
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putUserData(validateTokenResponse.user);
      spUtil?.putAccessToken(validateTokenResponse.headers!.accessToken);
      spUtil?.putClient(validateTokenResponse.headers!.client);
      spUtil?.putUID(validateTokenResponse.headers!.uid);
      spUtil?.putSaasOrgID(validateTokenResponse.headers!.saasOrgID != null
          ? validateTokenResponse.headers!.saasOrgID!
          : '');
      changeUIStatus(UIStatus(
          isDialogLoading: false, successWithoutAlertMessage: message ?? ''));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.add(validateTokenResponse);
      }
    });
    validateToken();
    getUserProfile(userID);
  }

  void validateToken() async {
    try {
      Tuple2<ValidateTokenResponse, String?> tuple2 =
          await _authRemoteRepository.validateToken();
      if (!_validateTokenResponse.isClosed) {
        _validateTokenResponse.sink.add(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('validateToken : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getUserProfile(int? userID) async {
    try {
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(userID);
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.add(userProfileResponse);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void generatePINOTP(UserData currentUser) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));

      ApiResponse apiResponse = await _pinRemoteRepository.generatePINOTP(
          currentUser.id ?? -1,
          currentUser.email ?? '',
          currentUser.mobileNumber ?? '',
          currentUser.userProfile?.dob ?? '');
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.otpSent));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('generatePINOTP : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<String?> initiateOtpLess() async {
    try {
      ApiResponse apiResponse = await _authRemoteRepository.initiateOtpLess();
      return apiResponse.data['intent'];
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('initiateOtpLess : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void startTimeoutForWhatsApp() {
    var interval = const Duration(seconds: 1);
    int timerMaxSeconds = 10;
    int currentSeconds = 0;
    var duration = interval;
    Timer.periodic(duration, (timer) {
      currentSeconds = timer.tick;
      String timerText =
          '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';
      changeTimerTextForWhatsApp(timerText);
      if (timer.tick >= timerMaxSeconds) timer.cancel();
    });
  }
}
