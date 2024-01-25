import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/telephonic_interview/telephonic_interview_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/webinar_training/webinar_training_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'batches_state.dart';

class BatchesCubit extends Cubit<BatchesState> {
  final WebinarTrainingRemoteRepository _webinarTrainingRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _dayBatchEntityList = BehaviorSubject<List<DayBatchesEntity>>();
  Stream<List<DayBatchesEntity>> get dayBatchesEntityListStream => _dayBatchEntityList.stream;

  final _selectedDayBatchesEntity = BehaviorSubject<DayBatchesEntity>();
  Stream<DayBatchesEntity> get selectedDayBatchesEntityStream => _selectedDayBatchesEntity.stream;

  final _allBatches = BehaviorSubject<List<BatchEntity>>();
  Stream<List<BatchEntity>> get allBatchesStream => _allBatches.stream;

  // final _morningBatches = BehaviorSubject<List<SlotEntity>>();
  // Stream<List<SlotEntity>> get morningBatchesStream => _morningBatches.stream;
  //
  // final _noonBatches = BehaviorSubject<List<SlotEntity>>();
  // Stream<List<SlotEntity>> get noonBatchesStream => _noonBatches.stream;
  //
  // final _eveningBatches = BehaviorSubject<List<SlotEntity>>();
  // Stream<List<SlotEntity>> get eveningBatchesStream => _eveningBatches.stream;

  // final _isViewMoreMorningBatches = BehaviorSubject<bool>.seeded(false);
  // Stream<bool> get isViewMoreMorningBatchesStream => _isViewMoreMorningBatches.stream;
  // Function(bool) get changeIsViewMoreMorningBatches => _isViewMoreMorningBatches.sink.add;
  //
  // final _isViewMoreNoonBatches = BehaviorSubject<bool>.seeded(false);
  // Stream<bool> get isViewMoreNoonBatchesStream => _isViewMoreNoonBatches.stream;
  // Function(bool) get changeIsViewMoreNoonBatches => _isViewMoreNoonBatches.sink.add;
  //
  // final _isViewMoreEveningBatches = BehaviorSubject<bool>.seeded(false);
  // Stream<bool> get isViewMoreEveningBatchesStream => _isViewMoreEveningBatches.stream;
  // Function(bool) get changeIsViewMoreEveningBatches => _isViewMoreEveningBatches.sink.add;

  BatchEntity? selectedBatchEntity;

  BatchesCubit(this._webinarTrainingRemoteRepository) : super(BatchesInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _dayBatchEntityList.close();
    _selectedDayBatchesEntity.close();
    _allBatches.close();
    // _morningBatches.close();
    // _noonBatches.close();
    // _eveningBatches.close();
    // _isViewMoreMorningBatches.close();
    // _isViewMoreNoonBatches.close();
    // _isViewMoreEveningBatches.close();
    return super.close();
  }

  void fetchTrainingBatches(int userID, WorkApplicationEntity workApplicationEntity) async {
    try {
      BatchesResponse batchesResponse = await _webinarTrainingRemoteRepository.fetchTrainingBatches(userID, workApplicationEntity.id!);
      if(!batchesResponse.dayBatchesEntityList.isNullOrEmpty &&  !_dayBatchEntityList.isClosed) {
        _dayBatchEntityList.sink.add(batchesResponse.dayBatchesEntityList!);
        updateDayBatchesEntityList(0, batchesResponse.dayBatchesEntityList![0]);
      } else if(!_dayBatchEntityList.isClosed) {
        _dayBatchEntityList.sink.addError('Batches not available');
        changeUIStatus(UIStatus(failedWithoutAlertMessage: 'Batches not available'));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_dayBatchEntityList.isClosed) {
        _dayBatchEntityList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_dayBatchEntityList.isClosed) {
        _dayBatchEntityList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchInterviewBatches : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_dayBatchEntityList.isClosed) {
        _dayBatchEntityList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void updateDayBatchesEntityList(int index, DayBatchesEntity selectedDayBatchesEntity) {
    if(!_dayBatchEntityList.isClosed && !_selectedDayBatchesEntity.isClosed && !_allBatches.isClosed) {
      List<DayBatchesEntity> dayBatchesEntityList = _dayBatchEntityList.value;
      List<DayBatchesEntity> tempDayBatchesEntityList = _dayBatchEntityList.value;
      for(int i = 0; i < dayBatchesEntityList.length; i++) {
        DayBatchesEntity dayBatchesEntity = dayBatchesEntityList[i];
        dayBatchesEntity.isSelected = index == i ? true : false;
        tempDayBatchesEntityList[i] = dayBatchesEntity;
      }
      _dayBatchEntityList.sink.add(tempDayBatchesEntityList);
      selectedDayBatchesEntity.isSelected = true;
      _selectedDayBatchesEntity.sink.add(selectedDayBatchesEntity);
      _allBatches.sink.add(selectedDayBatchesEntity.allBatches);
      // _morningBatches.sink.add(selectedDayBatchesEntity.morningBatches);
      // _noonBatches.sink.add(selectedDayBatchesEntity.noonBatches);
      // _eveningBatches.sink.add(selectedDayBatchesEntity.eveningBatches);
      clearSelectedBatches();
    }
  }

  void updateAllSlotList(int index, BatchEntity batchEntity) {
    if(!_allBatches.isClosed) {
      clearSelectedBatches();
      batchEntity.isSelected = true;
      List<BatchEntity> allBatches = _allBatches.value;
      allBatches[index] = batchEntity;
      selectedBatchEntity = batchEntity;
      _allBatches.sink.add(allBatches);
    }
  }
  
  void updateMorningSlotList(int index, SlotEntity slotEntity) {
    // if(!_morningBatches.isClosed) {
    //   clearSelectedBatches();
    //   slotEntity.isSelected = true;
    //   List<SlotEntity> morningBatches = _morningBatches.value;
    //   morningBatches[index] = slotEntity;
    //   selectedBatchEntity = slotEntity;
    //   _morningBatches.sink.add(morningBatches);
    // }
  }

  void updateNoonSlotList(int index, SlotEntity slotEntity) {
    // if(!_noonBatches.isClosed) {
    //   clearSelectedBatches();
    //   slotEntity.isSelected = true;
    //   List<SlotEntity> noonBatches = _noonBatches.value;
    //   noonBatches[index] = slotEntity;
    //   selectedBatchEntity = slotEntity;
    //   _noonBatches.sink.add(noonBatches);
    // }
  }

  void updateEveningSlotList(int index, SlotEntity slotEntity) {
    // if(!_eveningBatches.isClosed) {
    //   clearSelectedBatches();
    //   slotEntity.isSelected = true;
    //   List<SlotEntity> eveningBatches = _eveningBatches.value;
    //   eveningBatches[index] = slotEntity;
    //   selectedBatchEntity = slotEntity;
    //   _eveningBatches.sink.add(eveningBatches);
    // }
  }

  void clearSelectedBatches() {
    selectedBatchEntity = null;
    // if(!_morningBatches.isClosed) {
    //   List<SlotEntity> morningBatches = _morningBatches.value;
    //   List<SlotEntity> tempMorningBatches = _morningBatches.value;
    //   for(int i = 0; i < morningBatches.length; i++) {
    //     SlotEntity slotEntity = morningBatches[i];
    //     if(slotEntity.isSelected) {
    //       slotEntity.isSelected = false;
    //       tempMorningBatches[i] = slotEntity;
    //       break;
    //     }
    //   }
    //   _morningBatches.sink.add(tempMorningBatches);
    // }
    // if(!_noonBatches.isClosed) {
    //   List<SlotEntity> noonBatches = _noonBatches.value;
    //   List<SlotEntity> tempNoonBatches = _noonBatches.value;
    //   for(int i = 0; i < noonBatches.length; i++) {
    //     SlotEntity slotEntity = noonBatches[i];
    //     if(slotEntity.isSelected) {
    //       slotEntity.isSelected = false;
    //       tempNoonBatches[i] = slotEntity;
    //       break;
    //     }
    //   }
    //   _noonBatches.sink.add(tempNoonBatches);
    // }
    // if(!_eveningBatches.isClosed) {
    //   List<SlotEntity> eveningBatches = _eveningBatches.value;
    //   List<SlotEntity> tempEveningBatches = _eveningBatches.value;
    //   for(int i = 0; i < eveningBatches.length; i++) {
    //     SlotEntity slotEntity = eveningBatches[i];
    //     if(slotEntity.isSelected) {
    //       slotEntity.isSelected = false;
    //       tempEveningBatches[i] = slotEntity;
    //       break;
    //     }
    //   }
    //   _eveningBatches.sink.add(tempEveningBatches);
    // }
  }

  void scheduleTrainingBatch(int userID, WorkApplicationEntity workApplicationEntity) async {
    try {
      if (selectedBatchEntity == null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_a_batch'.tr));
        return;
      }
      changeUIStatus(UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      WorkApplicationEntity lWorkApplicationEntity = await _webinarTrainingRemoteRepository.scheduleTrainingBatch(userID, workApplicationEntity.id!, selectedBatchEntity!.id!);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.scheduled));
    } on ServerException catch (e) {
      AppLog.e('scheduleTrainingBatch : ${e.toString()}');
      changeUIStatus(UIStatus(isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      AppLog.e('scheduleTrainingBatch : ${e.toString()}');
      changeUIStatus(UIStatus(isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('scheduleTrainingBatch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

}
