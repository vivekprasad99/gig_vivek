import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/execution_in_house/data/model/signature_response.dart';
import 'package:awign/workforce/execution_in_house/data/repository/execution_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'sign_offer_letter_state.dart';

class SignOfferLetterCubit extends Cubit<SignOfferLetterState> with Validator {
  final ExecutionRemoteRepository _executionRemoteRepository;

  final _uiStatus =
      BehaviorSubject<UIStatus>.seeded(UIStatus(isOnScreenLoading: true));

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final signatureList = BehaviorSubject<List<Signature>?>();

  Function(List<Signature>?) get changeSignatureList => signatureList.sink.add;

  final _name = BehaviorSubject<String?>();

  Stream<String?> get nameStream => _name.stream.transform(validName);

  String? get nameValue => _name.value;

  Function(String?) get changeName => _name.sink.add;

  final _address = BehaviorSubject<String?>();

  Stream<String?> get address => _address.stream.transform(validateAddress);

  Function(String?) get changeAddress => _address.sink.add;

  final _pincode = BehaviorSubject<String?>();

  Stream<String?> get pincode => _pincode.stream.transform(validatePincode);

  Function(String?) get changePincode => _pincode.sink.add;

  final _city = BehaviorSubject<String?>();

  Stream<String?> get city => _city.stream.transform(validateCity);

  Function(String?) get changeCity => _city.sink.add;

  final _state = BehaviorSubject<String?>();

  Stream<String?> get stateStream => _state.stream.transform(validateState);

  Function(String?) get changeState => _state.sink.add;

  final _fontType = BehaviorSubject<String?>();

  Stream<String?> get fontType => _fontType.stream;

  Function(String?) get changeFontType => _fontType.sink.add;

  SignOfferLetterCubit(this._executionRemoteRepository)
      : super(SignOfferLetterInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _name.close();
    _address.close();
    _pincode.close();
    _city.close();
    _state.close();
    _fontType.close();
    signatureList.close();
    return super.close();
  }

  void getSignatures(String memberID, Map<String, dynamic> properties) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      SignatureResponse signatureResponse =
          await _executionRemoteRepository.getSignatures(memberID);
      if (!signatureList.isClosed &&
          signatureResponse.signatures != null &&
          signatureResponse.signatures!.isNotEmpty) {
        signatureList.sink.add(signatureResponse.signatures);
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
      ClevertapHelper.instance().addCleverTapEvent(
          ClevertapHelper.offerLetterSignInitiate, properties);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getSignatures : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void createSignature(String memberID, String mobileNumber, String projectID,
      String executionID) async {
    try {
      if (Validator.checkName(_name.hasValue ? _name.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkName(_name.hasValue ? _name.value : '')!));
        return;
      }
      if (Validator.checkAddress(_address.hasValue ? _address.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkAddress(
                _address.hasValue ? _address.value : '')!));
        return;
      }
      if (Validator.checkPincode(_pincode.hasValue ? _pincode.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkPincode(
                _pincode.hasValue ? _pincode.value : '')!));
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
      if (!_fontType.hasValue) {
        changeUIStatus(
            UIStatus(failedWithoutAlertMessage: 'please_select_signature'.tr));
        return;
      }
      if (_fontType.hasValue && _fontType.value.isNullOrEmpty) {
        changeUIStatus(
            UIStatus(failedWithoutAlertMessage: 'please_select_signature'.tr));
        return;
      }

      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      SignatureResponse signatureResponse =
          await _executionRemoteRepository.createSignature(
              memberID,
              _name.value!,
              mobileNumber,
              _address.value!,
              _pincode.value!,
              _city.value!,
              _state.value!,
              _fontType.value!);

      ApiResponse apiResponse =
          await _executionRemoteRepository.acceptOfferLetter(
              projectID, executionID, signatureResponse.signature?.id ?? '');

      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.accepted,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('createSignature : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
