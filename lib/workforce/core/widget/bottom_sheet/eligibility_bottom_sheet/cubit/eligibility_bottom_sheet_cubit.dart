import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/repository/work_listing/work_listing_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../execution_in_house/data/model/eligibility_entity_response.dart';

part 'eligibility_bottom_sheet_state.dart';

class EligibilityBottomSheetCubit extends Cubit<EligibilityBottomSheetState> {
  final WosRemoteRepository _wosRemoteRepository;
  EligibilityBottomSheetCubit(this._wosRemoteRepository) : super(EligibilityBottomSheetInitial());

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _eligiblityEntityResponse = BehaviorSubject<EligiblityEntityResponse>();
  Stream<EligiblityEntityResponse> get eligiblityEntityResponseStream =>
      _eligiblityEntityResponse.stream;
  EligiblityEntityResponse get eligiblityEntityResponse => _eligiblityEntityResponse.value;
  Function(EligiblityEntityResponse) get changeEligiblityEntityResponse =>
      _eligiblityEntityResponse.sink.add;

  @override
  Future<void> close() {
    _uiStatus.close();
    _eligiblityEntityResponse.close();
    return super.close();
  }



  Future getEligiblity(
      int? categoryApplicationId, int? workListingId) async {
    try {
      EligiblityEntityResponse eligiblityEntityResponse = await _wosRemoteRepository.fetchEligiblity(categoryApplicationId!,workListingId!);
      if (!_eligiblityEntityResponse.isClosed) {
        _eligiblityEntityResponse.sink.add(eligiblityEntityResponse);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getEligiblity : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
