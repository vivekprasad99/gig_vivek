import 'package:awign/workforce/auth/data/repository/pin/pin_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'forgot_pin_state.dart';

class ForgotPINCubit extends Cubit<ForgotPinState> with Validator {
  final PINRemoteRepository _pinRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _currentUser = BehaviorSubject<UserData>();

  Stream<UserData> get currentUser => _currentUser.stream;

  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  final _email = BehaviorSubject<String?>();

  Stream<String?> get email => _email.stream.transform(validateEmail);

  Function(String?) get changeEmail => _email.sink.add;

  final _mobileNumber = BehaviorSubject<String?>();

  Stream<String?> get mobileNumber =>
      _mobileNumber.stream.transform(validateMobileNumber);

  Function(String?) get changeMobileNumber => _mobileNumber.sink.add;

  final _dateOfBirth = BehaviorSubject<String?>();

  Stream<String?> get dateOfBirth =>
      _dateOfBirth.stream.transform(validateDateOfBirth);

  Function(String?) get changeDateOfBirth => _dateOfBirth.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  ForgotPINCubit(this._pinRemoteRepository) : super(ForgotPinInitial()) {
    _email.listen((value) {
      _checkValidation();
    });
    _mobileNumber.listen((value) {
      _checkValidation();
    });
    _dateOfBirth.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_email.isClosed &&
        _email.hasValue &&
        !_mobileNumber.isClosed &&
        _mobileNumber.hasValue &&
        !_dateOfBirth.isClosed &&
        _dateOfBirth.hasValue) {
      if (Validator.checkEmail(_email.value) == null &&
          Validator.checkMobileNumber(_mobileNumber.value) == null &&
          Validator.checkDateOfBirthCombined(_dateOfBirth.value) == null) {
        if (!_currentUser.isClosed && _currentUser.hasValue) {
          if (_email.value == _currentUser.value.email &&
              _mobileNumber.value == _currentUser.value.mobileNumber) {
            changeButtonStatus(ButtonStatus(isEnable: true));
          } else {
            changeUIStatus(UIStatus(failedWithoutAlertMessage: ''));
          }
        }
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _currentUser.close();
    _email.close();
    _mobileNumber.close();
    _dateOfBirth.close();
    buttonStatus.close();
    return super.close();
  }

  void generatePINOTP(int userID) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      ApiResponse apiResponse = await _pinRemoteRepository.generatePINOTP(
          userID,
          _email.value ?? '',
          _mobileNumber.value ?? '',
          _dateOfBirth.value ?? '');
      changeButtonStatus(ButtonStatus(isSuccess: true));
      changeUIStatus(UIStatus(
          event: Event.otpSent,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeButtonStatus(ButtonStatus(isEnable: true));
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeButtonStatus(ButtonStatus(isEnable: true));
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('generatePINOTP : ${e.toString()} \n${st.toString()}');
      changeButtonStatus(ButtonStatus(isEnable: true));
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
