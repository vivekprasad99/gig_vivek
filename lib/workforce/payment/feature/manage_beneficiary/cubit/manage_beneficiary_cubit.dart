import 'package:awign/workforce/core/data/model/api_response.dart';
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
import 'package:tuple/tuple.dart';

part 'manage_beneficiary_state.dart';

class ManageBeneficiaryCubit extends Cubit<ManageBeneficiaryState> {
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _beneficiaryList = BehaviorSubject<List<Beneficiary>>();

  Stream<List<Beneficiary>> get beneficiaryList => _beneficiaryList.stream;

  Function(List<Beneficiary>) get changeBeneficiaryList =>
      _beneficiaryList.sink.add;
  int noOfBeneficiary = 0;

  ManageBeneficiaryCubit(this._beneficiaryRemoteRepository)
      : super(ManageBeneficiaryInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _beneficiaryList.close();
    return super.close();
  }

  void getBeneficiaries(int userID) async {
    try {
      if (!_beneficiaryList.isClosed && _beneficiaryList.hasValue) {
        changeBeneficiaryList([]);
      }
      BeneficiaryRequestParam beneficiaryRequestParam =
          BeneficiaryRequestParam(userId: userID);
      BeneficiaryResponse beneficiaryResponse =
          await _beneficiaryRemoteRepository
              .getBeneficiaries(beneficiaryRequestParam);
      if (!_beneficiaryList.isClosed &&
          !beneficiaryResponse.beneficiaries.isNullOrEmpty) {
        List<Beneficiary> beneficiaryList = [];
        List<Beneficiary> activeBeneficiaryList = [];
        List<Beneficiary> inActiveBeneficiaryList = [];
        beneficiaryResponse.beneficiaries?.forEach((beneficiary) {
          if (beneficiary.active) {
            activeBeneficiaryList.add(beneficiary);
          } else {
            inActiveBeneficiaryList.add(beneficiary);
          }
        });
        beneficiaryList.addAll(activeBeneficiaryList);
        beneficiaryList.addAll(inActiveBeneficiaryList);
        noOfBeneficiary = beneficiaryResponse.beneficiaries?.length ?? 0;
        _beneficiaryList.sink.add(beneficiaryList);
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
      AppLog.e('getBeneficiaries : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void verifyBeneficiary(int index, Beneficiary selectedBeneficiary) async {
    try {
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, true, false);
      AddBeneficiaryResponse addBeneficiaryResponse =
          await _beneficiaryRemoteRepository
              .verifyBeneficiary(selectedBeneficiary.beneId?.toString() ?? '');
      if (addBeneficiaryResponse.beneficiary != null) {
        if (addBeneficiaryResponse.beneficiary?.verificationStatus
                ?.toLowerCase() ==
            BeneficiaryVerificationStatus.verified.value
                .toString()
                .toLowerCase()) {
          _updateBeneficiaryLoadingAndActive(
              index, selectedBeneficiary, false, true);
          changeUIStatus(UIStatus(
              event: Event.verified, data: Tuple2(index, selectedBeneficiary)));
        } else {
          _updateBeneficiaryLoadingAndActive(
              index, selectedBeneficiary, false, false);
          changeUIStatus(UIStatus(
              event: Event.rejected,
              data: Tuple3(
                  index, selectedBeneficiary, addBeneficiaryResponse.message)));
        }
      } else {
        _updateBeneficiaryLoadingAndActive(
            index, selectedBeneficiary, false, false);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, false);
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, false);
    } catch (e, st) {
      AppLog.e('verifyBeneficiary : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, false);
    }
  }

  _updateBeneficiaryLoadingAndActive(int index, Beneficiary selectedBeneficiary,
      bool isVerifyLoading, bool isActive) {
    if (!_beneficiaryList.isClosed) {
      List<Beneficiary> beneficiaryList = _beneficiaryList.value;
      selectedBeneficiary.isVerifyLoading = isVerifyLoading;
      selectedBeneficiary.active = isActive;
      beneficiaryList[index] = selectedBeneficiary;
      changeBeneficiaryList(beneficiaryList);
    }
  }

  void deleteBeneficiary(int index, Beneficiary selectedBeneficiary) async {
    try {
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, true, false);
      ApiResponse apiResponse = await _beneficiaryRemoteRepository
          .deleteBeneficiary(selectedBeneficiary.beneId?.toString() ?? '');
      if (!_beneficiaryList.isClosed && _beneficiaryList.hasValue) {
        List<Beneficiary> beneficiaryList = _beneficiaryList.value;
        beneficiaryList.removeAt(index);
        changeBeneficiaryList(beneficiaryList);
      }
      changeUIStatus(
          UIStatus(successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, false);
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, false);
    } catch (e, st) {
      AppLog.e('deleteBeneficiary : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, false);
    }
  }

  void updateBeneficiaryActiveStatus(
      int index, Beneficiary selectedBeneficiary, bool isActive) async {
    try {
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, true, false);
      AddBeneficiaryResponse addBeneficiaryResponse =
          await _beneficiaryRemoteRepository.updateBeneficiaryActiveStatus(
              selectedBeneficiary.beneId?.toString() ?? '', isActive);
        _updateBeneficiaryLoadingAndActive(
            index, selectedBeneficiary, false, isActive);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, !isActive);
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, !isActive);
    } catch (e, st) {
      AppLog.e(
          'updateBeneficiaryActiveStatus : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      _updateBeneficiaryLoadingAndActive(
          index, selectedBeneficiary, false, !isActive);
    }
  }
}
