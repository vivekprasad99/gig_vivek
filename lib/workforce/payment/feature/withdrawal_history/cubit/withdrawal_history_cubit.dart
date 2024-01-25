import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/data/repository/payment_bff_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/pds_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'withdrawal_history_state.dart';

class WithdrawalHistoryCubit extends Cubit<WithdrawalHistoryState> {
  PDSRemoteRepository _pdsRemoteRepository;
  final PaymentBffRemoteRepository _paymentBffRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _currentUser = BehaviorSubject<UserData>();

  Stream<UserData> get currentUser => _currentUser.stream;

  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  WithdrawalHistoryCubit(this._pdsRemoteRepository,this._paymentBffRemoteRepository)
      : super(WithdrawalHistoryInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _currentUser.close();
    return super.close();
  }

  Future<List<Transfer>?> getWithdrawalHistory(
      int pageIndex, String? searchTerm) async {
    AppLog.e('Page index.....$pageIndex');
    try {
      int userID = -1;
      if (!_currentUser.isClosed && _currentUser.hasValue) {
        userID = _currentUser.value.id ?? -1;
      }
      TransferHistoryResponse transferHistoryResponse =
          await _paymentBffRemoteRepository.getWithdrawlHistory(userID, pageIndex);
      if (transferHistoryResponse.transfers != null) {
        return transferHistoryResponse.transfers;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } catch (e, st) {
      AppLog.e('getWithdrawalHistory : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
    return null;
  }

  void retryWithdraw(int index, Transfer transfer) async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      ApiResponse apiResponse =
          await _pdsRemoteRepository.updateBeneficiary(transfer);
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          successWithoutAlertMessage: apiResponse.message ?? '',
          event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('retryWithdraw : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
