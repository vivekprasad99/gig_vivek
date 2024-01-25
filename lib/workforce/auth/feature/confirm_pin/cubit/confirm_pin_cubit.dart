import 'package:awign/workforce/auth/data/repository/pin/pin_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
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

part 'confirm_pin_state.dart';

class ConfirmPinCubit extends Cubit<ConfirmPinState> {
  final PINRemoteRepository _pinRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _pin = BehaviorSubject<String?>();

  Stream<String?> get pin => _pin.stream;

  Function(String?) get changePIN => _pin.sink.add;

  final _confirmPIN = BehaviorSubject<String?>();

  Stream<String?> get confirmPIN => _confirmPIN.stream;

  Function(String?) get changeConfirmPIN => _confirmPIN.sink.add;

  ConfirmPinCubit(this._pinRemoteRepository) : super(ConfirmPinInitial()) {
    _pin.listen((value) {
      _checkValidation();
    });
    _confirmPIN.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_pin.isClosed &&
        _pin.hasValue &&
        !_confirmPIN.isClosed &&
        _confirmPIN.hasValue) {
      if (Validator.checkPIN(_pin.value) == null &&
          Validator.checkPIN(_confirmPIN.value) == null &&
          _pin.value == _confirmPIN.value) {
        changeButtonStatus(ButtonStatus(isEnable: true));
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
    buttonStatus.close();
    _pin.close();
    _confirmPIN.close();
    return super.close();
  }

  void updatePIN(int userID) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      ApiResponse apiResponse =
          await _pinRemoteRepository.updatePIN(userID, _pin.value!);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? userData = spUtil?.getUserData();
      userData?.pinSet = true;
      userData?.pinBlockedTill = null;
      spUtil?.putUserData(userData);
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: apiResponse.message));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.updated));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('updatePIN : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }
}
