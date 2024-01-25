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

part 'pin_verify_bottom_sheet_state.dart';

class PinVerifyBottomSheetCubit extends Cubit<PinVerifyBottomSheetState> {
  final PINRemoteRepository _pinRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _pin = BehaviorSubject<String?>();

  Stream<String?> get pin => _pin.stream;

  Function(String?) get changePIN => _pin.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  PinVerifyBottomSheetCubit(this._pinRemoteRepository)
      : super(PinVerifyBottomSheetInitial()) {
    _pin.listen((value) {
      if (Validator.checkPIN(value) == null) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    });
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _pin.close();
    buttonStatus.close();
    return super.close();
  }

  void verifyPIN(int userID) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      ApiResponse apiResponse =
          await _pinRemoteRepository.verifyPIN(userID, _pin.value!);
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: apiResponse.message));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.verified));
    } on ServerException catch (e) {
      if (e.data != null &&
          (e.data as Map<String, dynamic>)['pin_blocked_till'] != null) {
        SPUtil? spUtil = await SPUtil.getInstance();
        UserData? userData = spUtil?.getUserData();
        userData?.pinBlockedTill = e.data['pin_blocked_till'];
        spUtil?.putUserData(userData);
        changeButtonStatus(ButtonStatus(isLoading: false, isEnable: false));
        changeUIStatus(UIStatus(event: Event.updated));
      } else {
        changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
        changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('verifyPIN : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }
}
