import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/payment/data/model/amount_deduction_response.dart';
import 'package:awign/workforce/payment/data/repository/earning_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'withdrawal_bottom_sheet_state.dart';

class WithdrawalBottomSheetCubit extends Cubit<WithdrawalBottomSheetState> {
  final EarningRemoteRepository _earningRemoteRepository;
  final _uiStatus =
      BehaviorSubject<UIStatus>.seeded(UIStatus(isOnScreenLoading: true));

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;
  final _amountDeductionResponse = BehaviorSubject<AmountDeductionResponse>();

  Stream<AmountDeductionResponse> get amountDeductionResponse =>
      _amountDeductionResponse.stream;

  Function(AmountDeductionResponse) get changeAmountDeductionResponse =>
      _amountDeductionResponse.sink.add;

  WithdrawalBottomSheetCubit(this._earningRemoteRepository)
      : super(WithdrawalBottomSheetInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _amountDeductionResponse.close();
    return super.close();
  }

  void calculateTDS(double requestedAmount, int userID) async {
    try {
      AmountDeductionResponse amountDeductionResponse =
          await _earningRemoteRepository.calculateTDS(
              requestedAmount,
              userID.toString(),
              userID.toString(),
              StringUtils.getDateTimeInYYYYMMDDHHMMSSFormat(DateTime.now()) ?? '');
      if (!_amountDeductionResponse.isClosed) {
        changeAmountDeductionResponse(amountDeductionResponse);
      } else {
        _amountDeductionResponse.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _amountDeductionResponse.sink.addError(e.message!);
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _amountDeductionResponse.sink.addError(e.message!);
    } catch (e, st) {
      AppLog.e('calculateTDS : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      _amountDeductionResponse.sink
          .addError('we_regret_the_technical_error'.tr);
    }
  }
}
