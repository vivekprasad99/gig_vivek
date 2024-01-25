import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/earning_breakup_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_amount.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_entity.dart';
import 'package:awign/workforce/execution_in_house/data/repository/leadpayout/leadpayout_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'leadpayout_state.dart';

class LeadpayoutCubit extends Cubit<LeadpayoutState> {
  final LeadPayoutRemoteRepository _leadPayoutRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _leadPayoutAmount = BehaviorSubject<LeadPayoutAmount>();
  Stream<LeadPayoutAmount> get leadPayoutAmount => _leadPayoutAmount.stream;

  final _leadPayout = BehaviorSubject<List<LeadPayoutEntity>>();
  Stream<List<LeadPayoutEntity>> get leadPayout => _leadPayout.stream;

  final _earningBreakupParams = BehaviorSubject<EarningBreakupParams>();
  Function(EarningBreakupParams) get changeEarningBreakupParams =>
      _earningBreakupParams.sink.add;

  EarningBreakupParams earningBreakupParams = EarningBreakupParams();

  LeadpayoutCubit(this._leadPayoutRemoteRepository)
      : super(LeadpayoutInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _leadPayoutAmount.close();
    return super.close();
  }

  void getLeadPayoutAmount(String executionID) async {
    try {
      LeadPayoutAmount leadPayoutAmount =
          await _leadPayoutRemoteRepository.getLeadPayoutAmount(executionID);
      if (!_leadPayoutAmount.isClosed) {
        _leadPayoutAmount.sink.add(leadPayoutAmount);
      } else {
        _leadPayoutAmount.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadPayoutAmount.isClosed) {
        _leadPayoutAmount.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadPayoutAmount.isClosed) {
        _leadPayoutAmount.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getLeadPayoutAmount : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_leadPayoutAmount.isClosed) {
        _leadPayoutAmount.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getPayoutDetails(String leadPayoutId, String executionID) async {
    try {
      List<LeadPayoutEntity>? leadPayout = await _leadPayoutRemoteRepository
          .getLeadPayoutDetails(leadPayoutId, executionID);
      if (!_leadPayout.isClosed) {
        _leadPayout.sink.add(leadPayout!);
      } else {
        _leadPayout.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadPayout.isClosed) {
        _leadPayout.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadPayout.isClosed) {
        _leadPayout.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getPayoutDetails : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_leadPayout.isClosed) {
        _leadPayout.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  Future<List<EarningBreakupEntity>?> getEarningsBreakup(
      int pageIndex, String? searchTerm) async {
    try {
      List<EarningBreakupEntity>? data = await _leadPayoutRemoteRepository
          .getEarningsBreakup(_earningBreakupParams.value, pageIndex);
      return data;
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getEarningsBreakup : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
