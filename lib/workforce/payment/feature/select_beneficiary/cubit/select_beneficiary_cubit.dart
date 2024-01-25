import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'select_beneficiary_state.dart';

class SelectBeneficiaryCubit extends Cubit<SelectBeneficiaryState> {
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _beneficiaryList = BehaviorSubject<List<Beneficiary>>();

  Stream<List<Beneficiary>> get beneficiaryList => _beneficiaryList.stream;

  Function(List<Beneficiary>) get changeBeneficiaryList =>
      _beneficiaryList.sink.add;

  int noOfBeneficiary = 0;
  int? lastSelectedIndex;
  Beneficiary? lastSelectedBeneficiary;

  SelectBeneficiaryCubit(this._beneficiaryRemoteRepository)
      : super(SelectBeneficiaryInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _beneficiaryList.close();
    return super.close();
  }

  void getBeneficiaries(int userID) async {
    try {
      BeneficiaryRequestParam beneficiaryRequestParam = BeneficiaryRequestParam(
          userId: userID, status: BeneficiaryVerificationStatus.verified);
      BeneficiaryResponse beneficiaryResponse =
          await _beneficiaryRemoteRepository
              .getBeneficiaries(beneficiaryRequestParam);
      if (!_beneficiaryList.isClosed &&
          !beneficiaryResponse.beneficiaries.isNullOrEmpty) {
        noOfBeneficiary = beneficiaryResponse.beneficiaries?.length ?? 0;
        _beneficiaryList.sink.add(beneficiaryResponse.beneficiaries!);
      } else {
        _beneficiaryList.sink.addError('no_beneficiary_added');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getVerifiedBeneficiaries : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  updateBeneficiaryList(int index, Beneficiary selectedBeneficiary) {
    if (!_beneficiaryList.isClosed && _beneficiaryList.hasValue) {
      List<Beneficiary> beneficiaryList = _beneficiaryList.value;
      if (lastSelectedIndex != null && lastSelectedBeneficiary != null) {
        lastSelectedBeneficiary?.isSelected = false;
        beneficiaryList[lastSelectedIndex!] = lastSelectedBeneficiary!;
      }
      selectedBeneficiary.isSelected = true;
      beneficiaryList[index] = selectedBeneficiary;
      lastSelectedIndex = index;
      lastSelectedBeneficiary = selectedBeneficiary;
      changeBeneficiaryList(beneficiaryList);
    }
  }
}
