import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'verify_existing_bank_account_state.dart';

class VerifyExistingBankAccountCubit
    extends Cubit<VerifyExistingBankAccountState> {
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _beneficiaryList = BehaviorSubject<List<Beneficiary>>();

  Stream<List<Beneficiary>> get beneficiaryList => _beneficiaryList.stream;

  Function(List<Beneficiary>) get changeBeneficiaryList =>
      _beneficiaryList.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  Beneficiary? selectedBeneficiary;

  VerifyExistingBankAccountCubit(this._beneficiaryRemoteRepository)
      : super(VerifyExistingBankAccountInitial()) {
    _beneficiaryList.listen((beneficiaryList) {
      bool isSelected = false;
      for (Beneficiary beneficiary in beneficiaryList) {
        if (beneficiary.isSelected) {
          isSelected = true;
          break;
        }
      }
      changeButtonStatus(ButtonStatus(isEnable: isSelected));
    });
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _beneficiaryList.close();
    buttonStatus.close();
    return super.close();
  }

  updateBeneficiaryList(int index, Beneficiary selectedBeneficiary) {
    if (!_beneficiaryList.isClosed && _beneficiaryList.hasValue) {
      List<Beneficiary> beneficiaryList = _beneficiaryList.value;
      List<Beneficiary> tempBeneficiaryList = _beneficiaryList.value;
      for (int i = 0; i < beneficiaryList.length; i++) {
        Beneficiary beneficiary = beneficiaryList[i];
        if (beneficiary.isSelected) {
          beneficiary.isSelected = false;
          tempBeneficiaryList[i] = beneficiary;
          break;
        }
      }
      selectedBeneficiary.isSelected = true;
      tempBeneficiaryList[index] = selectedBeneficiary;
      this.selectedBeneficiary = selectedBeneficiary;
      changeBeneficiaryList(tempBeneficiaryList);
    }
  }

  void verifyBeneficiary() async {
    try {
      if (selectedBeneficiary == null) {
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      AddBeneficiaryResponse addBeneficiaryResponse =
          await _beneficiaryRemoteRepository
              .verifyBeneficiary(selectedBeneficiary?.beneId?.toString() ?? '');
      if (addBeneficiaryResponse.beneficiary != null &&
          addBeneficiaryResponse.beneficiary?.verificationStatus
                  ?.toLowerCase() !=
              BeneficiaryVerificationStatus.verified.value
                  .toString()
                  .toLowerCase()) {
        changeButtonStatus(ButtonStatus(isSuccess: true));
        await Future.delayed(const Duration(milliseconds: 500));
        changeUIStatus(UIStatus(event: Event.verified));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: true));
        await Future.delayed(const Duration(milliseconds: 500));
        changeUIStatus(UIStatus(
            event: Event.failed,
            failedWithAlertMessage: addBeneficiaryResponse.message));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isEnable: true));
    } catch (e, st) {
      AppLog.e('verifyBeneficiary : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isEnable: true));
    }
  }
}
