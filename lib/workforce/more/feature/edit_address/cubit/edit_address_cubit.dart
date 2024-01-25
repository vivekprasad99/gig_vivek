import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'edit_address_state.dart';

class EditAddressCubit extends Cubit<EditAddressState> with Validator {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _area = BehaviorSubject<String?>();
  Stream<String?> get area => _area.stream.transform(validArea);
  Function(String?) get changeArea => _area.sink.add;

  final _city = BehaviorSubject<String?>();
  Stream<String?> get city => _city.stream.transform(validArea);
  Function(String?) get changeCity => _city.sink.add;

  final _state = BehaviorSubject<String?>();
  Stream<String?> get stateName => _state.stream.transform(validateState);
  Function(String?) get changeState => _state.sink.add;

  final _pincode = BehaviorSubject<String?>();
  Stream<String?> get pincode => _pincode.stream.transform(validatePincode);
  Function(String?) get changePincode => _pincode.sink.add;

  final _address = BehaviorSubject<Address?>();
  Stream<Address?> get address => _address.stream;
  Function(Address?) get changeAddress => _address.sink.add;

  EditAddressCubit(this._authRemoteRepository) : super(EditAddressInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _area.close();
    _city.close();
    _state.close();
    _pincode.close();
    _address.close();
    return super.close();
  }

  void updateAddress(int? userID) async {
    try {
      if (Validator.checkAddress(_area.hasValue ? _area.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkAddress(_area.hasValue ? _area.value : '')!));
        return;
      }
      if (Validator.checkCity(_city.hasValue ? _city.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkCity(_city.hasValue ? _city.value : '')!));
        return;
      }
      if (Validator.checkState(_state.hasValue ? _state.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkState(_state.hasValue ? _state.value : '')!));
        return;
      }
      if (Validator.checkPincode(_pincode.hasValue ? _pincode.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkPincode(
                _pincode.hasValue ? _pincode.value : '')!));
        return;
      }
      Address? address = _address.value;
      address?.area = _area.value;
      address?.city = _city.value;
      address?.state = _state.value;
      address?.pincode = _pincode.value;
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      ApiResponse apiResponse = await _authRemoteRepository.updateAddress(
          userID, address?.id, _address.value!);
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.success,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('updateAddress : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
