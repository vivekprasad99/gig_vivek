import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_demo/pitch_demo_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/telephonic_interview/telephonic_interview_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/webinar_training/webinar_training_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/work_application/work_application_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rxdart/rxdart.dart';

part 'application_section_details_state.dart';

class ApplicationSectionDetailsCubit extends Cubit<ApplicationSectionDetailsState> {
  final WorkApplicationRemoteRepository _workApplicationRemoteRepository;
  final TelephonicInterviewRemoteRepository _telephonicInterviewRemoteRepository;
  final WebinarTrainingRemoteRepository _webinarTrainingRemoteRepository;
  final PitchDemoRemoteRepository _pitchDemoRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _workApplicationEntity = BehaviorSubject<WorkApplicationEntity>();
  Stream<WorkApplicationEntity> get workApplicationEntityStream => _workApplicationEntity.stream;
  Function(WorkApplicationEntity) get changeWorkApplicationEntity => _workApplicationEntity.sink.add;

  final _timelineSectionEntity = BehaviorSubject<TimelineSectionEntity>();
  Stream<TimelineSectionEntity> get timelineSectionEntityStream => _timelineSectionEntity.stream;
  Function(TimelineSectionEntity) get changeTimelineSectionEntity => _timelineSectionEntity.sink.add;

  ApplicationSectionDetailsCubit(this._workApplicationRemoteRepository, this._telephonicInterviewRemoteRepository,
      this._webinarTrainingRemoteRepository, this._pitchDemoRemoteRepository) : super(ApplicationSectionDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _workApplicationEntity.close();
    _timelineSectionEntity.close();
    return super.close();
  }

  void fetchWorkApplicationForDetailsSection(int userID, int applicationID) async {
    Rx.combineLatest2(
      _workApplicationEntity.stream,
      _timelineSectionEntity.stream, (WorkApplicationEntity workApplicationEntity, TimelineSectionEntity timelineSectionEntity) {
        if(workApplicationEntity.detailsData?.detailSections![0] is TimelineSectionEntity) {
          return workApplicationEntity;
        }
        workApplicationEntity.detailsData?.detailSections?.insert(0, timelineSectionEntity);
      return workApplicationEntity;
    },
    ).listen((workApplicationEntity) {
      changeUIStatus(UIStatus(isOnScreenLoading: false, event: Event.success, data: workApplicationEntity));
    });
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    fetchWorkApplication(userID, applicationID);
    fetchTimeline(userID, applicationID);
  }

  void fetchWorkApplication(int userID, int applicationID) async {
    try {
      WorkApplicationEntity workApplicationEntity = await _workApplicationRemoteRepository.fetchWorkApplication(userID, applicationID);
      if(!_workApplicationEntity.isClosed) {
        _workApplicationEntity.sink.add(workApplicationEntity);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_workApplicationEntity.isClosed) {
        _workApplicationEntity.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_workApplicationEntity.isClosed) {
        _workApplicationEntity.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchWorkApplication : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_workApplicationEntity.isClosed) {
        _workApplicationEntity.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void fetchTimeline(int userID, int applicationID) async {
    try {
      TimelineSectionEntity timelineSectionEntity = await _workApplicationRemoteRepository
          .fetchTimeline(userID, applicationID);
      if(!_timelineSectionEntity.isClosed) {
        _timelineSectionEntity.sink.add(timelineSectionEntity);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_timelineSectionEntity.isClosed) {
        _timelineSectionEntity.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_timelineSectionEntity.isClosed) {
        _timelineSectionEntity.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchTimeline : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_timelineSectionEntity.isClosed) {
        _timelineSectionEntity.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void scheduleTelephonicInterview(int userID, String mobileNo, WorkApplicationEntity workApplicationEntity, SlotEntity? selectedSlotEntity) async {
    try {
      if (selectedSlotEntity == null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_a_time_slot'.tr));
        return;
      }
      changeUIStatus(UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      WorkApplicationEntity lWorkApplicationEntity = await _telephonicInterviewRemoteRepository.scheduleTelephonicInterview(userID, mobileNo, workApplicationEntity.id!, selectedSlotEntity.id!);
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

  void scheduleTrainingBatch(int userID, WorkApplicationEntity workApplicationEntity, BatchEntity? selectedBatchEntity) async {
    try {
      if (selectedBatchEntity == null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_a_batch'.tr));
        return;
      }
      WorkApplicationEntity lWorkApplicationEntity = await _webinarTrainingRemoteRepository.scheduleTrainingBatch(userID, workApplicationEntity.id!, selectedBatchEntity.id!);
      changeUIStatus(UIStatus(event: Event.batchScheduled,isOnScreenLoading: false,data: lWorkApplicationEntity));
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

  void schedulePitchDemo(int userID, WorkApplicationEntity workApplicationEntity, SlotEntity? selectedSlotEntity) async {
    try {
      if (selectedSlotEntity == null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_a_time_slot'.tr));
        return;
      }
      changeUIStatus(UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      WorkApplicationEntity lWorkApplicationEntity = await _pitchDemoRemoteRepository.schedulePitchDemo(userID, workApplicationEntity.id!, selectedSlotEntity.id!);
      // changeUIStatus(UIStatus(isDialogLoading: false, event: Event.scheduled));
      changeUIStatus(UIStatus(isOnScreenLoading: false, event: Event.success, data: lWorkApplicationEntity));
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
