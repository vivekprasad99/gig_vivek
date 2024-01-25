import 'package:awign/workforce/auth/data/model/user_mobile_verification_request.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';

part 'phone_verification_state.dart';

class PhoneVerificationCubit extends Cubit<PhoneVerificationState>
    with Validator {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _isWhatsappSubscribed = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isWhatsappSubscribed => _isWhatsappSubscribed.stream;

  bool get isWhatsappSubscribedValue => _isWhatsappSubscribed.value;

  Function(bool) get changeIsWhatsappSubscribed =>
      _isWhatsappSubscribed.sink.add;

  final _mobileNumber = BehaviorSubject<String?>();

  Stream<String?> get mobileNumber =>
      _mobileNumber.stream.transform(validateMobileNumber);

  Function(String?) get changeMobileNumber => _mobileNumber.sink.add;

  PhoneVerificationCubit(this._authRemoteRepository)
      : super(PhoneVerificationInitial()) {
    mobileNumber.listen((value) {
      checkIfMobNumisSame(value);
      if (Validator.checkMobileNumber(value) == null) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      }
    }, onError: (error) {
      changeButtonStatus(ButtonStatus(isEnable: false));
    });
  }

  @override
  Future<void> close() {
    _isWhatsappSubscribed.close();
    _mobileNumber.close();
    return super.close();
  }

  void signInWithNumber() async {
    try {
      if (Validator.checkMobileNumber(
              _mobileNumber.hasValue ? _mobileNumber.value : '') !=
          null) {
        _mobileNumber.sink.addError(Validator.checkMobileNumber(
            _mobileNumber.hasValue ? _mobileNumber.value : '')!);
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      UserNewMobileVerificationRequest userNewMobileVerificationRequest =
          UserNewMobileVerificationRequest(
              otp: null,
              mobileNumber: _mobileNumber.value,
              signInWithOtp: null);
      UserNewLoginRequest userNewLoginRequest = UserNewLoginRequest(
          userNewMobileVerificationRequest: userNewMobileVerificationRequest);
      if (defaultTargetPlatform == TargetPlatform.android) {
        final signCode = await SmsAutoFill().getAppSignature;
        SmsAutoFill().listenForCode;
      }
      ApiResponse apiResponse =
          await _authRemoteRepository.signInWithNumber(userNewLoginRequest);
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: apiResponse.message));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.otpSent));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('generateOTP : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  Future<void> checkIfMobNumisSame(String? value) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? currentUser = spUtil?.getUserData();
    if (currentUser != null && value == currentUser.mobileNumber) {
        _mobileNumber.sink.addError('error_msg_for_same_mob_num'.tr);
    }
  }
}
