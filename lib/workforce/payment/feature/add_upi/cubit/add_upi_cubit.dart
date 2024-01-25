import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'add_upi_state.dart';

class AddUpiCubit extends Cubit<AddUpiState> with Validator {
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _upi = BehaviorSubject<String?>();

  Stream<String?> get upi => _upi.stream.transform(validateUPI);

  Function(String?) get changeUPI => _upi.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  AddUpiCubit(this._beneficiaryRemoteRepository) : super(AddUpiInitial()) {
    _upi.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_upi.isClosed &&
        _upi.hasValue &&
        Validator.checkUPI(_upi.value) == null) {
      changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _upi.close();
    buttonStatus.close();
    return super.close();
  }

  void addUPI(UserData currentUser) async {
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
      beneficiary.name = currentUser.name;
      beneficiary.phone = currentUser.userProfile?.mobileNumber;
      beneficiary.userId = currentUser.id.toString();
      beneficiary.email = currentUser.email;
      beneficiary.vpa = _upi.value;
      beneficiary.paymentMode = BeneficiaryType.upi.value;
      beneficiary.verifyBeneficiary =
          RemoteConfigHelper.instance().isVerifyBeneficiaryConfigured;

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
      AppLog.e('addUPI : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isEnable: true));
    }
  }
}
