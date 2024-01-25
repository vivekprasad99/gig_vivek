import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'withdrawal_verification_state.dart';

class WithdrawalVerificationCubit extends Cubit<WithdrawalVerificationState> {
  final AuthRemoteRepository _authRemoteRepository;
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _kycDetails = BehaviorSubject<KycDetails>();

  Stream<KycDetails> get kycDetails => _kycDetails.stream;

  Function(KycDetails) get changeKycDetails => _kycDetails.sink.add;

  final _beneficiaryResponse = BehaviorSubject<BeneficiaryResponse>();

  Stream<BeneficiaryResponse> get beneficiaryResponse =>
      _beneficiaryResponse.stream;

  Function(BeneficiaryResponse) get changeBeneficiaryResponse =>
      _beneficiaryResponse.sink.add;

  final _unVerifiedBeneficiaryList = BehaviorSubject<List<Beneficiary>>();

  Stream<List<Beneficiary>> get unVerifiedBeneficiaryList =>
      _unVerifiedBeneficiaryList.stream;

  List<Beneficiary>? getUnVerifiedBeneficiaryList() {
    if (!_unVerifiedBeneficiaryList.isClosed &&
        _unVerifiedBeneficiaryList.hasValue) {
      return _unVerifiedBeneficiaryList.valueOrNull;
    } else {
      return null;
    }
  }

  Function(List<Beneficiary>) get changeUnVerifiedBeneficiaryList =>
      _unVerifiedBeneficiaryList.sink.add;

  int noOfBeneficiary = 0;

  WithdrawalVerificationCubit(
      this._authRemoteRepository, this._beneficiaryRemoteRepository)
      : super(WithdrawalVerificationInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _kycDetails.close();
    _beneficiaryResponse.close();
    _unVerifiedBeneficiaryList.close();
    return super.close();
  }

  void getPANDetails(int userID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      KycDetails kycDetails = await _authRemoteRepository.getPANDetails(userID);
      if (!_kycDetails.isClosed) {
        SPUtil? spUtil = await SPUtil.getInstance();
        UserData? currUser = spUtil?.getUserData();
        currUser?.userProfile?.kycDetails = kycDetails;
        spUtil?.putUserData(currUser);
        _kycDetails.sink.add(kycDetails);
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getPANDetails : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void getVerifiedBeneficiaries(int userID, KycDetails kycDetails) async {
    try {
      BeneficiaryRequestParam beneficiaryRequestParam =
          BeneficiaryRequestParam(userId: userID);
      BeneficiaryResponse beneficiaryResponse =
          await _beneficiaryRemoteRepository
              .getBeneficiaries(beneficiaryRequestParam);

      if (!_beneficiaryResponse.isClosed) {
        _beneficiaryResponse.sink.add(beneficiaryResponse);
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

  bool isVerifiedBeneficiaryFound(
      BeneficiaryResponse beneficiaryResponse, KycDetails kycDetails) {
    bool isPanNameMatched = false;
    List<Beneficiary> verifiedBeneficiaryList = [];
    List<Beneficiary> unVerifiedBeneficiaryList = [];
    noOfBeneficiary = beneficiaryResponse.beneficiaries?.length ?? 0;
    for (Beneficiary beneficiary in beneficiaryResponse.beneficiaries ?? []) {
      if (beneficiary.verificationStatus?.toLowerCase() ==
          BeneficiaryVerificationStatus.verified.value
              .toString()
              .toLowerCase()) {
        verifiedBeneficiaryList.add(beneficiary);
      } else if (beneficiary.verificationStatus?.toLowerCase() ==
          (BeneficiaryVerificationStatus.unverified.value
              .toString()
              .toLowerCase())) {
        unVerifiedBeneficiaryList.add(beneficiary);
      }
    }
    if (!_unVerifiedBeneficiaryList.isClosed) {
      if (unVerifiedBeneficiaryList.isNotEmpty) {
        Beneficiary beneficiary = unVerifiedBeneficiaryList[0];
        beneficiary.isSelected = true;
        unVerifiedBeneficiaryList[0] = beneficiary;
      }
      changeUnVerifiedBeneficiaryList(unVerifiedBeneficiaryList);
    }
    if (kycDetails.panVerificationStatus == PanStatus.verified) {
      if (verifiedBeneficiaryList.isNotEmpty) {
        isPanNameMatched = true;
      }
    }
    return isPanNameMatched;
  }

  void deleteBeneficiary(Beneficiary selectedBeneficiary) async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      ApiResponse apiResponse = await _beneficiaryRemoteRepository
          .deleteBeneficiary(selectedBeneficiary.beneId?.toString() ?? '');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('deleteBeneficiary : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
