import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/ifsc_response.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'add_bank_account_state.dart';

class AddBankAccountCubit extends Cubit<AddBankAccountState> with Validator {
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _accountNumber = BehaviorSubject<String?>();

  Stream<String?> get accountNumber =>
      _accountNumber.stream.transform(validateAccountNumber);

  Function(String?) get changeAccountNumber => _accountNumber.sink.add;

  final _reEnterAccountNumber = BehaviorSubject<String?>();

  Stream<String?> get reEnterAccountNumber =>
      _reEnterAccountNumber.stream.transform(validateAccountNumber);

  Function(String?) get changeReEnterAccountNumber =>
      _reEnterAccountNumber.sink.add;

  final _isValidAccountNumber = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isValidAccountNumber => _isValidAccountNumber.stream;

  Function(bool) get changeIsValidAccountNumber =>
      _isValidAccountNumber.sink.add;

  final _ifscCode = BehaviorSubject<String?>();

  Stream<String?> get ifscCode => _ifscCode.stream.transform(validateIFSCCode);

  Function(String?) get changeIfscCode => _ifscCode.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _bankData = BehaviorSubject<BankData>();

  Stream<BankData> get bankData => _bankData.stream;

  Function(BankData) get changeBankData => _bankData.sink.add;

  AddBankAccountCubit(this._beneficiaryRemoteRepository)
      : super(AddBankAccountInitial()) {
    _accountNumber.listen((value) {
      _checkValidation();
    });
    _reEnterAccountNumber.listen((value) {
      _checkValidation();
    });
    _ifscCode.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_accountNumber.isClosed &&
        _accountNumber.hasValue &&
        !_reEnterAccountNumber.isClosed &&
        _reEnterAccountNumber.hasValue &&
        !_ifscCode.isClosed &&
        _ifscCode.hasValue) {
      if (Validator.checkAccountNumber(_accountNumber.value) == null &&
          Validator.checkAccountNumber(_reEnterAccountNumber.value) == null) {
        if (_accountNumber.value == _reEnterAccountNumber.value) {
          changeIsValidAccountNumber(true);
          if (Validator.checkIFSCCode(_ifscCode.value) == null) {
            validateIFSC();
          } else {
            if (!_bankData.isClosed) {
              _bankData.sink.addError('');
            }
            changeButtonStatus(ButtonStatus(isEnable: false));
          }
        } else {
          changeIsValidAccountNumber(false);
          _reEnterAccountNumber.sink.add('enter_valid_account_number');
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
    _accountNumber.close();
    _reEnterAccountNumber.close();
    _ifscCode.close();
    buttonStatus.close();
    _bankData.close();
    return super.close();
  }

  void validateIFSC() async {
    try {
      BankData bankData = await _beneficiaryRemoteRepository
          .validateIFSC(_ifscCode.value?.toUpperCase() ?? '');

      if (!_bankData.isClosed) {
        _bankData.sink.add(bankData);
        changeButtonStatus(ButtonStatus(isEnable: true));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isEnable: false));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isEnable: false));
    } catch (e, st) {
      AppLog.e('validateIFSC : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  void addBeneficiary(UserData currentUser) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      Beneficiary beneficiary = Beneficiary();
      if (currentUser.userProfile?.addresses != null &&
          currentUser.userProfile!.addresses!.isNotEmpty) {
        beneficiary.address1 =
            currentUser.userProfile!.addresses![0].toString();
      } else {
        beneficiary.address1 = 'Dummy Address';
      }
      beneficiary.phone = currentUser.userProfile?.mobileNumber;
      beneficiary.userId = currentUser.id.toString();
      beneficiary.email = currentUser.email;
      beneficiary.bankName = _bankData.value.bank;
      beneficiary.name = currentUser.name;
      beneficiary.bankAccount = _accountNumber.value;
      beneficiary.paymentMode = BeneficiaryType.payeeBank.value;
      beneficiary.ifsc = _ifscCode.value;
      beneficiary.verifyBeneficiary = RemoteConfigHelper.instance().isVerifyBeneficiaryConfigured;

      AddBeneficiaryResponse addBeneficiaryResponse =
          await _beneficiaryRemoteRepository.addBeneficiary(beneficiary);

      changeButtonStatus(ButtonStatus(isSuccess: true));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.created));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isEnable: true));
    } catch (e, st) {
      AppLog.e('addBeneficiary : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isEnable: true));
    }
  }
}
