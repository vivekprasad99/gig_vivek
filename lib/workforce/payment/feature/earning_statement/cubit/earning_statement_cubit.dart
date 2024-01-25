import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/earning_statement_entity.dart';
import 'package:awign/workforce/payment/data/repository/earning_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'earning_statement_state.dart';

class EarningStatementCubit extends Cubit<EarningStatementState> {
  final EarningRemoteRepository _earningRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _selectedMonth = BehaviorSubject<String>();

  Stream<String> get selectedMonth => _selectedMonth.stream;

  Function(String) get changeSelectedMonth => _selectedMonth.sink.add;

  final _withdrawalStatementList = BehaviorSubject<List<WithdrawalStatement>>();

  Stream<List<WithdrawalStatement>> get withdrawalStatementList =>
      _withdrawalStatementList.stream;

  Function(List<WithdrawalStatement>) get changeWithdrawalStatementList =>
      _withdrawalStatementList.sink.add;

  EarningStatementCubit(this._earningRemoteRepository)
      : super(EarningStatementInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _selectedMonth.close();
    return super.close();
  }

  void getEarningStatement(int userID) async {
    try {
      if (!_withdrawalStatementList.isClosed &&
          _withdrawalStatementList.hasValue) {
        changeWithdrawalStatementList([]);
      }
      WithdrawalStatementResponse withdrawalStatementResponse =
          await _earningRemoteRepository.getEarningStatement(
              userID, _selectedMonth.value);
      if (!_withdrawalStatementList.isClosed &&
          withdrawalStatementResponse.withdrawalStatements != null &&
          withdrawalStatementResponse.withdrawalStatements!.isNotEmpty) {
        changeWithdrawalStatementList(
            withdrawalStatementResponse.withdrawalStatements!);
      } else {
        _withdrawalStatementList.sink.addError('no_earnings'.tr);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _withdrawalStatementList.sink.addError('no_earnings'.tr);
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _withdrawalStatementList.sink.addError('no_earnings'.tr);
    } catch (e, st) {
      AppLog.e('getEarningStatement : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      _withdrawalStatementList.sink.addError('no_earnings'.tr);
    }
  }
}
