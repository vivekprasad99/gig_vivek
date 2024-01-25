import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
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

part 'user_location_state.dart';

class UserLocationCubit extends Cubit<UserLocationState> with Validator {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _formattedAddress = BehaviorSubject<String?>();

  Stream<String?> get formattedAddress =>
      _formattedAddress.stream.transform(validateAddress);

  Function(String?) get changeFormattedAddress => _formattedAddress.sink.add;

  final _pincode = BehaviorSubject<String?>();

  Stream<String?> get pincode => _pincode.stream.transform(validatePincode);

  Function(String?) get changePincode => _pincode.sink.add;

  final _address = BehaviorSubject<Address?>();

  Stream<Address?> get address => _address.stream;

  Function(Address?) get changeAddress => _address.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  UserLocationCubit(this._authRemoteRepository) : super(UserLocationInitial()) {
    _formattedAddress.listen((value) {
      _checkValidation();
    });
    _pincode.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_formattedAddress.isClosed &&
        _formattedAddress.hasValue &&
        !_pincode.isClosed &&
        _pincode.hasValue) {
      if (Validator.checkAddress(_formattedAddress.value) == null &&
          Validator.checkPincode(_pincode.value) == null) {
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
    _formattedAddress.close();
    _pincode.close();
    _address.close();
    buttonStatus.close();
    return super.close();
  }

  void createAddress(UserData currentUser) async {
    try {
      if (Validator.checkAddress(
              _formattedAddress.hasValue ? _formattedAddress.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkAddress(
                _formattedAddress.hasValue ? _formattedAddress.value : '')!));
        return;
      }
      if (Validator.checkPincode(_pincode.hasValue ? _pincode.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkPincode(
                _pincode.hasValue ? _pincode.value : '')!));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      ApiResponse apiResponse = await _authRemoteRepository.createAddress(
          currentUser.userProfile?.userId, _address.value!);
      SPUtil? spUtil = await SPUtil.getInstance();
      currentUser.userProfile?.profileCompletionStage =
          AuthHelper.professionDetails;
      spUtil?.putUserData(currentUser);
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
      AppLog.e('createAddress : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  void updateUserProfile(UserData currentUser) async {
    try {
      if (Validator.checkAddress(
              _formattedAddress.hasValue ? _formattedAddress.value : '') !=
          null) {
        return;
      }
      if (Validator.checkPincode(_pincode.hasValue ? _pincode.value : '') !=
          null) {
        return;
      }
      ApiResponse apiResponse = await _authRemoteRepository.updateUserProfile(
          currentUser.userProfile?.userId,
          currentUser.name,
          currentUser.email,
          currentUser.userProfile?.gender,
          currentUser.userProfile?.educationLevel,
          currentUser.userProfile?.dob,
          AuthHelper.professionDetails,
          null,
          null);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('updateUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
