import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/payment/data/model/earning_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/data/model/button_status.dart';
import '../../../data/repository/payment_bff_remote_repository.dart';

part 'confirm_amount_state.dart';

class ConfirmAmountCubit extends Cubit<ConfirmAmountState> {
  final PaymentBffRemoteRepository _paymentBffRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _isUpcomingEarningEnabled = BehaviorSubject<bool>();

  Stream<bool> get isUpcomingEarningEnabled => _isUpcomingEarningEnabled.stream;

  bool get isUpcomingEarningEnabledValue => _isUpcomingEarningEnabled.value;

  Function(bool) get changeIsUpcomingEarningEnabled =>
      _isUpcomingEarningEnabled.sink.add;

  final _isOverAllDeductionShown = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isOverAllDeductionShownStream =>
      _isOverAllDeductionShown.stream;

  bool get isOverAllDeductionShown => _isOverAllDeductionShown.value;

  Function(bool) get changeIsOverAllDeductionShown =>
      _isOverAllDeductionShown.sink.add;

  final _totalWithdrawAfterUpcomingEarning = BehaviorSubject<double>();

  Stream<double> get totalWithdrawAfterUpcomingEarningStream =>
      _totalWithdrawAfterUpcomingEarning.stream;

  double get totalWithdrawAfterUpcomingEarning =>
      _totalWithdrawAfterUpcomingEarning.value;

  Function(double) get changeTotalWithdrawAfterUpcomingEarning =>
      _totalWithdrawAfterUpcomingEarning.sink.add;

  final _totalWithdrawAfterCalculation = BehaviorSubject<double>();

  Stream<double> get totalWithdrawAfterCalculationStream =>
      _totalWithdrawAfterCalculation.stream;

  double get totalWithdrawAfterCalculation =>
      _totalWithdrawAfterCalculation.value;

  Function(double) get changeTotalWithdrawAfterCalculation =>
      _totalWithdrawAfterCalculation.sink.add;

  final _isChecked = BehaviorSubject<bool>.seeded(true);

  Stream<bool> get isChecked => _isChecked.stream;

  bool get isCheckedValue => _isChecked.value;

  Function(bool) get changeIsChecked => _isChecked.sink.add;

  final _expectedTransferTime = BehaviorSubject<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get expectedTransferTime =>
      _expectedTransferTime.stream;

  Map<String, dynamic>? get expectedTransferTimeValue =>
      _expectedTransferTime.valueOrNull;

  final buttonStatus =
      BehaviorSubject<ButtonStatus>.seeded(ButtonStatus(isEnable: true));

  Stream<ButtonStatus> get buttonStatusStream => buttonStatus.stream;

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  ConfirmAmountCubit(this._paymentBffRemoteRepository)
      : super(ConfirmAmountInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _isUpcomingEarningEnabled.close();
    _isOverAllDeductionShown.close();
    _totalWithdrawAfterUpcomingEarning.close();
    _totalWithdrawAfterCalculation.close();
    return super.close();
  }

  void calculateWithDrawAmountAfterUpcoming(
      bool isToggleOn, double redeemableEarning, double approvedEarning) {
    if (isToggleOn) {
      _totalWithdrawAfterUpcomingEarning.sink
          .add(redeemableEarning + approvedEarning);
    } else {
      _totalWithdrawAfterUpcomingEarning.sink.add(redeemableEarning);
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
      changeButtonStatus(ButtonStatus(isEnable: false));
    } else {
      changeButtonStatus(ButtonStatus(isEnable: true));
    }
  }

  void getExpectedTransferTime() async {
    Map<String, dynamic> expectedTransferTime =
        await _paymentBffRemoteRepository.getExpectedTransferTime();
    _expectedTransferTime.sink.add(expectedTransferTime);
  }

  void setButtonStatus(EarningData earningData) {
    if (earningData.isToggleOn) {
      if ((earningData.workforcePayoutResponse.redeemable +
                  earningData.workforcePayoutResponse.approved) -
              earningData.calculateDeductionResponse!.deductions![0].amount! -
              earningData.calculateDeductionResponse!.deductions![1].amount! <=
          100) {
        changeButtonStatus(ButtonStatus(isEnable: false));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: true));
      }
    } else {
      if (earningData.workforcePayoutResponse.redeemable <= 100) {
        changeButtonStatus(ButtonStatus(isEnable: false));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: true));
      }
    }
  }
}
