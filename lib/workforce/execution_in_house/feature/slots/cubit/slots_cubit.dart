import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/telephonic_interview/telephonic_interview_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'slots_state.dart';

class SlotsCubit extends Cubit<SlotsState> {

  final TelephonicInterviewRemoteRepository _telephonicInterviewRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _daySlotsEntityList = BehaviorSubject<List<DaySlotsEntity>>();
  Stream<List<DaySlotsEntity>> get daySlotsEntityListStream => _daySlotsEntityList.stream;

  final _selectedDaySlotsEntity = BehaviorSubject<DaySlotsEntity>();
  Stream<DaySlotsEntity> get selectedDaySlotsEntityStream => _selectedDaySlotsEntity.stream;

  final _morningSlots = BehaviorSubject<List<SlotEntity>>();
  Stream<List<SlotEntity>> get morningSlotsStream => _morningSlots.stream;

  final _noonSlots = BehaviorSubject<List<SlotEntity>>();
  Stream<List<SlotEntity>> get noonSlotsStream => _noonSlots.stream;

  final _eveningSlots = BehaviorSubject<List<SlotEntity>>();
  Stream<List<SlotEntity>> get eveningSlotsStream => _eveningSlots.stream;

  final _isViewMoreMorningSlots = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isViewMoreMorningSlotsStream => _isViewMoreMorningSlots.stream;
  Function(bool) get changeIsViewMoreMorningSlots => _isViewMoreMorningSlots.sink.add;

  final _isViewMoreNoonSlots = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isViewMoreNoonSlotsStream => _isViewMoreNoonSlots.stream;
  Function(bool) get changeIsViewMoreNoonSlots => _isViewMoreNoonSlots.sink.add;

  final _isViewMoreEveningSlots = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isViewMoreEveningSlotsStream => _isViewMoreEveningSlots.stream;
  Function(bool) get changeIsViewMoreEveningSlots => _isViewMoreEveningSlots.sink.add;

  SlotEntity? selectedSlotEntity;

  SlotsCubit(this._telephonicInterviewRemoteRepository) : super(SlotsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _daySlotsEntityList.close();
    _selectedDaySlotsEntity.close();
    _morningSlots.close();
    _noonSlots.close();
    _eveningSlots.close();
    _isViewMoreMorningSlots.close();
    _isViewMoreNoonSlots.close();
    _isViewMoreEveningSlots.close();
    return super.close();
  }

  void fetchInterviewSlots(int userID, WorkApplicationEntity workApplicationEntity) async {
    try {
      SlotsResponse? slotsResponse;
      if((workApplicationEntity.pendingAction?.actionKey?.isTelephonicInterview() ?? false)) {
        slotsResponse = await _telephonicInterviewRemoteRepository.fetchInterviewSlots(userID, workApplicationEntity.id!);
      }
      if(slotsResponse != null && !slotsResponse.daySlotsEntityList.isNullOrEmpty &&  !_daySlotsEntityList.isClosed) {
        _daySlotsEntityList.sink.add(slotsResponse.daySlotsEntityList!);
        updateDaySlotsEntityList(0, slotsResponse.daySlotsEntityList![0]);
      } else if(!_daySlotsEntityList.isClosed) {
        _daySlotsEntityList.sink.addError('Slots not available');
        changeUIStatus(UIStatus(failedWithoutAlertMessage: 'Slots not available'));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_daySlotsEntityList.isClosed) {
        _daySlotsEntityList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_daySlotsEntityList.isClosed) {
        _daySlotsEntityList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchInterviewSlots : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_daySlotsEntityList.isClosed) {
        _daySlotsEntityList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void updateDaySlotsEntityList(int index, DaySlotsEntity selectedDaySlotsEntity) {
    if(!_daySlotsEntityList.isClosed && !_selectedDaySlotsEntity.isClosed && !_morningSlots.isClosed
    && !_noonSlots.isClosed && !_eveningSlots.isClosed) {
      List<DaySlotsEntity> daySlotsEntityList = _daySlotsEntityList.value;
      List<DaySlotsEntity> tempDaySlotsEntityList = _daySlotsEntityList.value;
      for(int i = 0; i < daySlotsEntityList.length; i++) {
        DaySlotsEntity daySlotsEntity = daySlotsEntityList[i];
        daySlotsEntity.isSelected = index == i ? true : false;
        tempDaySlotsEntityList[i] = daySlotsEntity;
      }
      _daySlotsEntityList.sink.add(tempDaySlotsEntityList);
      selectedDaySlotsEntity.isSelected = true;
      _selectedDaySlotsEntity.sink.add(selectedDaySlotsEntity);
      _morningSlots.sink.add(selectedDaySlotsEntity.morningSlots);
      _noonSlots.sink.add(selectedDaySlotsEntity.noonSlots);
      _eveningSlots.sink.add(selectedDaySlotsEntity.eveningSlots);
      clearSelectedSlots();
    }
  }

  void updateMorningSlotList(int index, SlotEntity slotEntity) {
    if(!_morningSlots.isClosed) {
      clearSelectedSlots();
      slotEntity.isSelected = true;
      List<SlotEntity> morningSlots = _morningSlots.value;
      morningSlots[index] = slotEntity;
      selectedSlotEntity = slotEntity;
      _morningSlots.sink.add(morningSlots);
    }
  }

  void updateNoonSlotList(int index, SlotEntity slotEntity) {
    if(!_noonSlots.isClosed) {
      clearSelectedSlots();
      slotEntity.isSelected = true;
      List<SlotEntity> noonSlots = _noonSlots.value;
      noonSlots[index] = slotEntity;
      selectedSlotEntity = slotEntity;
      _noonSlots.sink.add(noonSlots);
    }
  }

  void updateEveningSlotList(int index, SlotEntity slotEntity) {
    if(!_eveningSlots.isClosed) {
      clearSelectedSlots();
      slotEntity.isSelected = true;
      List<SlotEntity> eveningSlots = _eveningSlots.value;
      eveningSlots[index] = slotEntity;
      selectedSlotEntity = slotEntity;
      _eveningSlots.sink.add(eveningSlots);
    }
  }

  void clearSelectedSlots() {
    selectedSlotEntity = null;
    if(!_morningSlots.isClosed) {
      List<SlotEntity> morningSlots = _morningSlots.value;
      List<SlotEntity> tempMorningSlots = _morningSlots.value;
      for(int i = 0; i < morningSlots.length; i++) {
        SlotEntity slotEntity = morningSlots[i];
        if(slotEntity.isSelected) {
          slotEntity.isSelected = false;
          tempMorningSlots[i] = slotEntity;
          break;
        }
      }
      _morningSlots.sink.add(tempMorningSlots);
    }
    if(!_noonSlots.isClosed) {
      List<SlotEntity> noonSlots = _noonSlots.value;
      List<SlotEntity> tempNoonSlots = _noonSlots.value;
      for(int i = 0; i < noonSlots.length; i++) {
        SlotEntity slotEntity = noonSlots[i];
        if(slotEntity.isSelected) {
          slotEntity.isSelected = false;
          tempNoonSlots[i] = slotEntity;
          break;
        }
      }
      _noonSlots.sink.add(tempNoonSlots);
    }
    if(!_eveningSlots.isClosed) {
      List<SlotEntity> eveningSlots = _eveningSlots.value;
      List<SlotEntity> tempEveningSlots = _eveningSlots.value;
      for(int i = 0; i < eveningSlots.length; i++) {
        SlotEntity slotEntity = eveningSlots[i];
        if(slotEntity.isSelected) {
          slotEntity.isSelected = false;
          tempEveningSlots[i] = slotEntity;
          break;
        }
      }
      _eveningSlots.sink.add(tempEveningSlots);
    }
  }

  void scheduleTelephonicInterview(int userID, String mobileNo, WorkApplicationEntity workApplicationEntity) async {
    try {
      if (selectedSlotEntity == null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_a_time_slot'.tr));
        return;
      }
      changeUIStatus(UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      WorkApplicationEntity lWorkApplicationEntity = await _telephonicInterviewRemoteRepository.scheduleTelephonicInterview(userID, mobileNo, workApplicationEntity.id!, selectedSlotEntity!.id!);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.scheduled));
    } on ServerException catch (e) {
      AppLog.e('scheduleSlot : ${e.toString()}');
      changeUIStatus(UIStatus(isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      AppLog.e('scheduleSlot : ${e.toString()}');
      changeUIStatus(UIStatus(isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('scheduleSlot : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
