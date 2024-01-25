import 'package:awign/workforce/auth/data/model/user_feedback_response.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/data/model/earning_item_data.dart';
import 'package:awign/workforce/payment/data/model/workforce_payout_response.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/payment_bff_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/pts_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart' as transfer_history;
import 'package:awign/workforce/payment/data/repository/pds_remote_repository.dart';
import '../../../../core/data/model/button_status.dart';
import '../../../data/model/withdrawal_response.dart';
import '../../../data/model/withdrawl_data.dart';
import '../widget/bottom_sheet/trasaction_status_bottom_sheet.dart';

part 'earnings_state.dart';

class EarningsCubit extends Cubit<EarningsState> {
  final PTSRemoteRepository _ptsRemoteRepository;
  final PDSRemoteRepository _pdsRemoteRepository;
  final AuthRemoteRepository _authRemoteRepository;
  final BeneficiaryRemoteRepository _beneficiaryRemoteRepository;
  final PaymentBffRemoteRepository _paymentBffRemoteRepository;
  final _uiStatus =
      BehaviorSubject<UIStatus>.seeded(UIStatus(isOnScreenLoading: true));

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _isExpanded = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isExpanded => _isExpanded.stream;

  final _isUpdateBankDetailsCTAVisible = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isUpdateBankDetailsCTAVisible =>
      _isUpdateBankDetailsCTAVisible;

  Function(bool) get changeIsExpanded => _isExpanded.sink.add;

  final _workforcePayoutResponse = BehaviorSubject<WorkforcePayoutResponse>();

  Stream<WorkforcePayoutResponse> get workforcePayoutResponse =>
      _workforcePayoutResponse.stream;

  Function(WorkforcePayoutResponse) get changeWorkforcePayoutResponse =>
      _workforcePayoutResponse.sink.add;

  final _kycDetails = BehaviorSubject<KycDetails>();

  Stream<KycDetails> get kycDetails => _kycDetails.stream;
  KycDetails get kycDetailsValue => _kycDetails.value;

  Function(KycDetails) get changeKycDetails => _kycDetails.sink.add;

  final _beneficiaryResponse = BehaviorSubject<BeneficiaryResponse>();

  Stream<BeneficiaryResponse> get beneficiaryResponse =>
      _beneficiaryResponse.stream;
  BeneficiaryResponse? get beneficiaryResponseValue => _beneficiaryResponse.valueOrNull;

  Function(BeneficiaryResponse) get changeBeneficiaryResponse =>
      _beneficiaryResponse.sink.add;

  final _feedbackEventResponse = BehaviorSubject<FeedbackEventResponse>();

  Stream<FeedbackEventResponse> get feedbackEventResponse =>
      _feedbackEventResponse.stream;

  final _currentUser = BehaviorSubject<UserData>();

  Stream<UserData> get currentUser => _currentUser.stream;

  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  final _earningDataList = BehaviorSubject<List<EarningItemData>>();

  Stream<List<EarningItemData>> get earningDataListStream =>
      _earningDataList.stream;

  List<EarningItemData> get earningDataList => _earningDataList.value;

  Function(List<EarningItemData>) get changeEarningDataList =>
      _earningDataList.sink.add;

  final _earningItem = BehaviorSubject<String>.seeded("Beneficiary");

  Stream<String> get earningItemStream => _earningItem.stream;

  String get earningItem => _earningItem.value;

  Function(String) get changeEarningItem => _earningItem.sink.add;

  final _isUpcomingEarningEnabled = BehaviorSubject<bool>();

  Stream<bool> get isUpcomingEarningEnabled => _isUpcomingEarningEnabled.stream;

  bool get isUpcomingEarningEnabledValue => _isUpcomingEarningEnabled.value;

  Function(bool) get changeIsUpcomingEarningEnabled =>
      _isUpcomingEarningEnabled.sink.add;

  final _totalWithdrawAfterCalculation = BehaviorSubject<double>();

  Stream<double> get totalWithdrawAfterCalculationStream =>
      _totalWithdrawAfterCalculation.stream;

  double get totalWithdrawAfterCalculation =>
      _totalWithdrawAfterCalculation.value;

  Function(double) get changeTotalWithdrawAfterCalculation =>
      _totalWithdrawAfterCalculation.sink.add;

  final _calculateDeductionResponse =
      BehaviorSubject<CalculateDeductionResponse>();

  Stream<CalculateDeductionResponse> get calculateDeductionResponseStream =>
      _calculateDeductionResponse.stream;

  Function(CalculateDeductionResponse) get changeCalculateDeductionResponse =>
      _calculateDeductionResponse.sink.add;

  final _withdrawlResponse = BehaviorSubject<WithdrawalResponse>();

  Stream<WithdrawalResponse> get withdrawlResponseStream =>
      _withdrawlResponse.stream;

  Function(WithdrawalResponse) get changeWithdrawlResponse =>
      _withdrawlResponse.sink.add;

  final _transactionsInFailedStatus =
      BehaviorSubject<transfer_history.TransferHistoryResponse>();

  Stream<transfer_history.TransferHistoryResponse> get transactionsInFailedStatus =>
      _transactionsInFailedStatus.stream;

  final _transactionsInProcessingStatus =
      BehaviorSubject<transfer_history.TransferHistoryResponse>();

  Stream<transfer_history.TransferHistoryResponse> get transactionsInProcessingStatus =>
      _transactionsInProcessingStatus.stream;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus(isEnable: true));
  Stream<ButtonStatus> get buttonStatusStream => buttonStatus.stream;
  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _failedTransactionSlider = BehaviorSubject<int>.seeded(0);
  Stream<int> get failedTransactionSlider => _failedTransactionSlider.stream;
  Function(int) get changeFailedTransactionSlider => _failedTransactionSlider.sink.add;

  final _processingTransactionSlider = BehaviorSubject<int>.seeded(0);
  Stream<int> get processingTransactionSlider => _processingTransactionSlider.stream;
  Function(int) get changeProcessingTransactionSlider => _processingTransactionSlider.sink.add;

  final _transactionStatus = BehaviorSubject<TransferStatus>.seeded(TransferStatus.processing);
  Stream<TransferStatus> get transactionStatus => _transactionStatus.stream;
  Function(TransferStatus) get changeTransactionStatus => _transactionStatus.sink.add;

  EarningsCubit(
      this._ptsRemoteRepository,
      this._pdsRemoteRepository,
      this._authRemoteRepository,
      this._beneficiaryRemoteRepository,
      this._paymentBffRemoteRepository)
      : super(EarningsInitial()) {
    loadEarningItemList();
  }

  void setUpdateBankDetailsCTAState(transfer_history.TransferHistoryResponse transfer){
      _isUpdateBankDetailsCTAVisible.sink.add(transfer.transfer?.statusReason == "INVALID_BENEFICIARY_DETAILS");
    }

  void loadEarningItemList() {
    var earningItem = ["Beneficiary", "History", "Earnings", "FAQ & Support"];

    var earningItemImages = [
      "assets/images/account_balance.svg",
      "assets/images/receipt_long.svg",
      "assets/images/account_balance_wallet.svg",
      "assets/images/faq_&_support.svg",
    ];

    var earningDataList = <EarningItemData>[];
    for (int i = 0; i < earningItem.length; i++) {
      if (i == 0) {
        var earningData = EarningItemData(
            isSelected: true,
            earningItem: earningItem[i],
            images: earningItemImages[i]);
        earningDataList.add(earningData);
      } else {
        var earningData = EarningItemData(
            earningItem: earningItem[i], images: earningItemImages[i]);
        earningDataList.add(earningData);
      }
    }
    if (!_earningDataList.isClosed) {
      _earningDataList.sink.add(earningDataList);
    }
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _isExpanded.close();
    _workforcePayoutResponse.close();
    _kycDetails.close();
    _beneficiaryResponse.close();
    _feedbackEventResponse.close();
    _currentUser.close();
    _earningDataList.close();
    _earningItem.close();
    _isUpcomingEarningEnabled.close();
    _totalWithdrawAfterCalculation.close();
    _calculateDeductionResponse.close();
    _withdrawlResponse.close();
    _transactionsInFailedStatus.close();
    _transactionsInProcessingStatus.close();
    _failedTransactionSlider.close();
    _processingTransactionSlider.close();
    _transactionStatus.close();
    return super.close();
  }

  void updateEarningList(int index, EarningItemData earningItemData) {
    var earningDataList = _earningDataList.value;
    var earningData = earningDataList[index];
    for (var name in earningDataList) {
      name.isSelected = false;
    }
    if (!earningDataList[index].isSelected) {
      earningDataList[index].earningItem = earningData.earningItem;
      earningDataList[index].images = earningData.images;
      earningDataList[index].isSelected = true;
      _earningDataList.sink.add(earningDataList);
      _earningItem.sink.add(earningData.earningItem!);
    }
    return;
  }

  void getPANDetails(int userID) async {
    try {
      KycDetails kycDetails = await _authRemoteRepository.getPANDetails(userID);
      if (!_kycDetails.isClosed) {
        SPUtil? spUtil = await SPUtil.getInstance();
        UserData? currUser = spUtil?.getUserData();
        currUser?.userProfile?.kycDetails = kycDetails;
        spUtil?.putUserData(currUser);
        _kycDetails.sink.add(kycDetails);
      }
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

  void getVerifiedBeneficiaries(int userID) async {
    try {
      BeneficiaryRequestParam beneficiaryRequestParam = BeneficiaryRequestParam(
          userId: userID, status: BeneficiaryVerificationStatus.verified);
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

  void initWithdraw(double requestedAmount, String beneficiaryId, int userID,
      String paymentChannelType, String requestAt) async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      ApiResponse apiResponse = await _ptsRemoteRepository.initWithdraw(
          requestedAmount,
          beneficiaryId,
          userID.toString(),
          userID.toString(),
          paymentChannelType,
          requestAt);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('initWithdraw : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void internalFeedbackEventSearch(int userId) async {
    try {
      FeedbackEventResponse data =
          await _authRemoteRepository.internalFeedbackEventSearch(userId);
      if (!_feedbackEventResponse.isClosed) {
        _feedbackEventResponse.sink.add(data);
      }
      changeUIStatus(
          UIStatus(event: Event.created, data: _workforcePayoutResponse.value));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'internalFeedbackEventSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void feedbackEvent() {
    if (_feedbackEventResponse.hasValue) {
      if (_feedbackEventResponse.value.events!.events!.isNotEmpty) {
        int? days = _feedbackEventResponse.value.events!.events![0].createdAt!
            .getNoOfDays(
                _feedbackEventResponse.value.events!.events![0].createdAt!);
        if (_feedbackEventResponse.value.events!.events![0].eventName ==
            FeedbackEvents.feedback_submitted.name) {
          if (days >= 28) {
            // 28 days as feedback submitted
            changeUIStatus(UIStatus(
                event: Event.rateus, data: _workforcePayoutResponse.value));
          }
        } else if (_feedbackEventResponse.value.events!.events![0].eventName ==
            FeedbackEvents.feedback_discarded.name) {
          if (days >= 7) {
            // 7 days as feedback discarded
            changeUIStatus(UIStatus(
                event: Event.rateus, data: _workforcePayoutResponse.value));
          }
        }
      } else {
        changeUIStatus(UIStatus(
            event: Event.rateus, data: _workforcePayoutResponse.value));
      }
    }
  }

  void getWorkForcePayout(int userID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      WorkforcePayoutResponse workforcePayoutResponse =
          await _paymentBffRemoteRepository.getWorkForcePayout(userID);
      if (!_workforcePayoutResponse.isClosed) {
        _workforcePayoutResponse.sink.add(workforcePayoutResponse);
      }
      if (workforcePayoutResponse.approved > 0) {
        calculateDeduction(
            workforcePayoutResponse.approved, workforcePayoutResponse);
      } else {
        changeUIStatus(
            UIStatus(isOnScreenLoading: false, data: workforcePayoutResponse));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getWorkForcePayouts : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void calculateDeduction(double approvedAmount,
      WorkforcePayoutResponse workforcePayoutResponse) async {
    try {
      CalculateDeductionResponse calculateDeductionResponse =
          await _paymentBffRemoteRepository.calculateDeduction(approvedAmount);
      if (!_calculateDeductionResponse.isClosed) {
        _calculateDeductionResponse.sink.add(calculateDeductionResponse);
      }
      changeUIStatus(
          UIStatus(isOnScreenLoading: false, data: workforcePayoutResponse));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getWorkForcePayouts : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void calculateWithDrawAmountOnToggle(
      bool isToggleOn,
      double redeemableEarning,
      double approvedEarning,
      double discount,
      double tds) {
    if (isToggleOn) {
      _totalWithdrawAfterCalculation.sink
          .add((redeemableEarning + approvedEarning) - tds - discount);
    } else {
      _totalWithdrawAfterCalculation.sink.add(redeemableEarning);
    }
    if (totalWithdrawAfterCalculation <= 100) {
      if (kycDetailsValue.panVerificationStatus != PanStatus.verified || beneficiaryResponseValue?.beneficiaries?.isNullOrEmpty == true) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    } else {
      changeButtonStatus(ButtonStatus(isEnable: true));
    }
  }

  void withdrawRequest(WithdrawlData withdrawlData) async {
    try {
      WithdrawalResponse withdrawalResponse =
          await _paymentBffRemoteRepository.withdrawRequest(withdrawlData);
      if (!_withdrawlResponse.isClosed) {
        _withdrawlResponse.sink.add(withdrawalResponse);
        changeUIStatus(UIStatus(event: Event.updated));
        changeTransactionStatus(TransferStatus.success);
      }
    } on ServerException catch (e) {
      _withdrawlResponse.sink.addError(e);
      changeTransactionStatus(TransferStatus.failure);
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      _withdrawlResponse.sink.addError(e);
      changeTransactionStatus(TransferStatus.failure);
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      _withdrawlResponse.sink.addError(e);
      changeTransactionStatus(TransferStatus.failure);
      AppLog.e('withdrawRequest : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  bool isWithdrawaleOrNot() {
    if (_workforcePayoutResponse.value.redeemable < 100 &&
        !_isUpcomingEarningEnabled.value) {
      return false;
    } else if ((_workforcePayoutResponse.value.redeemable +
                _workforcePayoutResponse.value.approved) <
            100 &&
        _isUpcomingEarningEnabled.value) {
      return false;
    }
    return true;
  }

  void showEmptyEarning(bool isToggleOn) {
    WorkforcePayoutResponse workforcePayoutResponse =
        _workforcePayoutResponse.value;
    if (isToggleOn) {
      workforcePayoutResponse.redeemable = 0;
      workforcePayoutResponse.approved = 0;
    } else {
      workforcePayoutResponse.redeemable = 0;
    }
    changeUIStatus(
        UIStatus(isOnScreenLoading: false, data: workforcePayoutResponse));
  }

  void getTransfersInFailedStatus(int userId) async {
    transfer_history.TransferHistoryResponse transferHistoryResponse =
        await _paymentBffRemoteRepository.getTransferInFailed(userId);
    _transactionsInFailedStatus.sink.add(transferHistoryResponse);
  }

  void getTransfersInProcessingStatus(int userId) async {
    transfer_history.TransferHistoryResponse transferHistoryResponse =
        await _paymentBffRemoteRepository.getTransferInProcessing(userId);
    _transactionsInProcessingStatus.sink.add(transferHistoryResponse);
  }

  void updateBeneficiary(UserData? currentUser, transfer_history.Transfer transfer) async {
    try {
      await _pdsRemoteRepository.updateBeneficiary(transfer);
      if(currentUser != null) {
        getTransfersInFailedStatus(currentUser.id ?? -1);
      }
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.updated));
    }
    on ServerException catch (e) {
      changeUIStatus(UIStatus(event: Event.updateError,
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(event: Event.updateError,
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      changeUIStatus(UIStatus(event: Event.updateError,
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void setButtonStatus(WorkforcePayoutResponse workforcePayoutResponse) {
    if (workforcePayoutResponse.redeemable <= 100) {
      if (kycDetailsValue.panVerificationStatus != PanStatus.verified || beneficiaryResponseValue?.beneficiaries?.isNullOrEmpty == true) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    } else {
      changeButtonStatus(ButtonStatus(isEnable: true));
    }
  }
}
