import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/data/model/ui_status.dart';
import '../../../../core/exception/exception.dart';
import '../../../../core/utils/app_log.dart';
import '../../../data/model/call_bridge_entity.dart';
import '../../../data/repository/lead/lead_remote_repository.dart';

part 'call_bridge_bottom_sheet_state.dart';

class CallBridgeBottomSheetCubit extends Cubit<CallBridgeBottomSheetState> {
  final LeadRemoteRepository _leadRemoteRepository;

  CallBridgeBottomSheetCubit(this._leadRemoteRepository)
      : super(CallBridgeBottomSheetInitial());

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  Future<void> callBridge(String uid, String mobileNumber, String leadId,
      String executionId) async {
    try {
      await _leadRemoteRepository.callBridge(
          leadId, executionId, CallBridgeRequest(CallBridgeDataRequest(mobileNumber, uid)));
      changeUIStatus(UIStatus(event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('callBridge : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
