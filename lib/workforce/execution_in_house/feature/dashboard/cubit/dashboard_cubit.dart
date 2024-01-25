import 'package:awign/workforce/auth/data/model/user_feedback_response.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_update_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/available_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_amount.dart';
import 'package:awign/workforce/execution_in_house/data/model/project.dart';
import 'package:awign/workforce/execution_in_house/data/repository/attendance/attendance_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/availablity/availablity_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/dashboaard_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../attendance/data/attendance_answer_entity.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRemoteRepository _dashboardRemoteRepository;
  final AuthRemoteRepository _authRemoteRepository;
  final AvailabilityRemoteRepository _availabilityRemoteRepository;
  final WosRemoteRepository _wosRemoteRepository;
  final AttendanceRemoteRepository _attendanceRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final tabsMap = BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get tabsMapStream => tabsMap.stream;

  final _currentUser = BehaviorSubject<UserData>();

  Stream<UserData> get currentUser => _currentUser.stream;

  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  final _execution = BehaviorSubject<Execution>();

  Stream<Execution> get execution => _execution.stream;

  Function(Execution) get changeExecution => _execution.sink.add;

  final _project = BehaviorSubject<Project>();

  Stream<Project> get project => _project.stream;

  final _leadPayoutAmount = BehaviorSubject<LeadPayoutAmount>();

  Stream<LeadPayoutAmount> get leadPayoutAmount => _leadPayoutAmount.stream;

  final _feedbackEventResponse = BehaviorSubject<FeedbackEventResponse>();
  Stream<FeedbackEventResponse> get feedbackEventResponse =>
      _feedbackEventResponse.stream;

  final _memberTimeSlotResponse =
      BehaviorSubject<MemberTimeSlotResponse>.seeded(MemberTimeSlotResponse());

  Stream<MemberTimeSlotResponse> get memberTimeSlotResponseStream =>
      _memberTimeSlotResponse.stream;

  MemberTimeSlotResponse? get memberTimeSlotResponseValue =>
      _memberTimeSlotResponse.valueOrNull;

  Function(MemberTimeSlotResponse) get changeMemberTimeSlotResponse =>
      _memberTimeSlotResponse.sink.add;

  final _workApplicationResponse = BehaviorSubject<WorkApplicationResponse>();

  Stream<WorkApplicationResponse> get workApplicationResponse =>
      _workApplicationResponse.stream;

  final _isStartWorkingVisible = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isStartWorkingVisibleStream => _isStartWorkingVisible.stream;

  Function(bool) get changeIsStartWorkingVisible =>
      _isStartWorkingVisible.sink.add;

  final _isProceedToWorkVisible = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isProceedToWorkVisibleStream =>
      _isProceedToWorkVisible.stream;

  Function(bool) get changeIsProceedToWorkVisible =>
      _isProceedToWorkVisible.sink.add;

  final _isRequestForWorkVisible = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isRequestForWorkVisibleStream =>
      _isRequestForWorkVisible.stream;

  Function(bool) get changeIsRequestForWorkVisible =>
      _isRequestForWorkVisible.sink.add;

  final _isTabRowRequested = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isTabRowRequestedStream => _isTabRowRequested.stream;

  Function(bool) get changeIsTabRowRequested => _isTabRowRequested.sink.add;

  final _executionResponse = BehaviorSubject<ExecutionsResponse>();

  Stream<ExecutionsResponse> get executionResponse => _executionResponse.stream;

  Function(ExecutionsResponse) get changeExecutionResponse =>
      _executionResponse.sink.add;

  final buttonStatus =
      BehaviorSubject<ButtonStatus>.seeded(ButtonStatus(isEnable: true));

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _attendancePunchesResponse = BehaviorSubject<AttendancePunches?>();
  Stream<AttendancePunches?> get attendancePunchesResponseStream => _attendancePunchesResponse.stream;
  Function(AttendancePunches?) get changeAttendancePunchesResponse => _attendancePunchesResponse.sink.add;
  // AttendancePunches? get attendancePunchesValue => _attendancePunchesResponse.value;
  AttendancePunches? get attendancePunchesValue {
    if(_attendancePunchesResponse.hasValue)
      {
        return _attendancePunchesResponse.value;
      }
    return null;
  }

  final _isPunchIn = BehaviorSubject<bool?>();
  Function(bool?) get changeIsPunchIn => _isPunchIn.sink.add;
  bool? get isPunchInValue => _isPunchIn.value;

  final _isComingFromBottomSheet = BehaviorSubject<bool?>();
  Function(bool?) get changeIsComingFromBottomSheet => _isComingFromBottomSheet.sink.add;
  bool? get isComingFromBottomSheet => _isComingFromBottomSheet.value;

  final _attendanceCount = BehaviorSubject<int?>.seeded(0);
  Function(int?) get changeAttendanceCount => _attendanceCount.sink.add;
  int? get attendanceCount => _attendanceCount.value;

  DashboardCubit(this._dashboardRemoteRepository, this._authRemoteRepository,
      this._availabilityRemoteRepository, this._wosRemoteRepository,this._attendanceRemoteRepository)
      : super(DashboardInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    tabsMap.close();
    _project.close();
    _leadPayoutAmount.close();
    _execution.close();
    _feedbackEventResponse.close();
    _memberTimeSlotResponse.close();
    _workApplicationResponse.close();
    _isStartWorkingVisible.close();
    _isProceedToWorkVisible.close();
    _isRequestForWorkVisible.close();
    _isTabRowRequested.close();
    _executionResponse.close();
    buttonStatus.close();
    _attendancePunchesResponse.close();
    return super.close();
  }

  void getProjectAndLeadPayoutAmount(Execution execution) async {
    Rx.combineLatest3(
      _project.stream,
      _leadPayoutAmount.stream,
      tabsMap.stream,
      (Project project, LeadPayoutAmount leadPayoutAmount,
          Map<String, dynamic> tabsMap) {
        return project;
      },
    ).listen((response) {
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    }).onError((e) {
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    });
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    getProject(execution.projectId ?? '');
    getLeadPayoutAmount(execution.id ?? '');
  }

  void getTabs(Execution execution) async {
    if (execution.archivedStatus == true) {
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } else {
      try {
        ApiResponse apiResponse = await _dashboardRemoteRepository.getTabs(
            execution.id ?? '',
            execution.selectedProjectRole?.toLowerCase().replaceAll(' ', '_') ??
                '');
        if (apiResponse.status == ApiResponse.success &&
            !tabsMap.isClosed &&
            apiResponse.data != null) {
          tabsMap.sink.add(apiResponse.data);
        } else {
          tabsMap.sink.addError('');
        }
      } on ServerException catch (e) {
        changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
        if (!tabsMap.isClosed) {
          tabsMap.sink.addError(e.message!);
        }
      } on FailureException catch (e) {
        changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
        if (!tabsMap.isClosed) {
          tabsMap.sink.addError(e.message!);
        }
      } catch (e, st) {
        AppLog.e('getTabs : ${e.toString()} \n${st.toString()}');
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
        if (!tabsMap.isClosed) {
          tabsMap.sink.addError('we_regret_the_technical_error'.tr);
        }
      }
    }
  }

  void getProject(String projectID) async {
    try {
      Project project = await _dashboardRemoteRepository.getProject(projectID);
      if (!_project.isClosed) {
        _project.sink.add(project);
      } else {
        _project.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_project.isClosed) {
        _project.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_project.isClosed) {
        _project.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getProject : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_project.isClosed) {
        _project.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getLeadPayoutAmount(String executionID) async {
    try {
      LeadPayoutAmount leadPayoutAmount =
          await _dashboardRemoteRepository.getLeadPayoutAmount(executionID);
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

  void getExecution(String executionID, String projectID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      Execution execution = await _dashboardRemoteRepository.getExecution(executionID, projectID);
      if (!_execution.isClosed) {
        changeExecution(execution);
      } else {
        _execution.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_execution.isClosed) {
        _execution.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_execution.isClosed) {
        _execution.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getExecution : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_execution.isClosed) {
        _execution.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void certificateStatusUpdate(Execution execution, String status) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      ApiResponse apiResponse =
          await _dashboardRemoteRepository.certificateStatusUpdate(
              execution.projectId ?? '', execution.id ?? '', '');
      if (!_execution.isClosed) {
        execution.status = ExecutionStatus.certificateRequested;
        _execution.sink.add(execution);
      }
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('certificateStatusUpdate : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void internalFeedbackEventSearch(int userId) async {
    try {
      FeedbackEventResponse data =
          await _authRemoteRepository.internalFeedbackEventSearch(userId);
      if (!_feedbackEventResponse.isClosed) {
        _feedbackEventResponse.sink.add(data);
      }
      changeUIStatus(UIStatus(event: Event.created));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'internalFeedbackEventSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void feedbackEvent() {
    if (_feedbackEventResponse.hasValue) {
      if (_feedbackEventResponse.value.events!.events!.isNotEmpty) {
        int? days = _feedbackEventResponse.value.events!.events![0].createdAt!
            .getNoOfDays(
                _feedbackEventResponse.value.events!.events![0].createdAt!);
        if (_feedbackEventResponse.value.events!.events![0].eventName ==
            FeedbackEvents.feedback_submitted.name) {
          if (days >= 28) {
            // 28 days as feedback submitted
            changeUIStatus(UIStatus(event: Event.rateus));
          }
        } else if (_feedbackEventResponse.value.events!.events![0].eventName ==
            FeedbackEvents.feedback_discarded.name) {
          if (days >= 7) {
            // 7 days as feedback discarded
            changeUIStatus(UIStatus(event: Event.rateus));
          }
        }
      } else {
        changeUIStatus(UIStatus(event: Event.rateus));
      }
    }
  }

  void getUpcomingSlots(String memberId, String date) async {
    try {
      MemberTimeSlotResponse data =
          await _availabilityRemoteRepository.getUpcomingSlots(memberId, date);
      if (data.memberTimeSlot != null) {
        _memberTimeSlotResponse.sink.add(data);
        changeUIStatus(UIStatus(event: Event.success));
      }
    } on ServerException catch (e) {
      if (e.data['member_time_slot'] == null) {
        changeUIStatus(UIStatus(event: Event.failed));
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getUpcomingSlots : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  bool isSlotAvailableCurrently() {
    if (!_memberTimeSlotResponse.isClosed &&
        _memberTimeSlotResponse.hasValue &&
        _memberTimeSlotResponse.value.memberTimeSlot != null &&
        _memberTimeSlotResponse.value.memberTimeSlot!.slots.isNotEmpty) {
      Slot slot = _memberTimeSlotResponse.value.memberTimeSlot!.slots[0];
      int startTime = DateTime.parse(slot.startTime!).millisecondsSinceEpoch;
      int endTime = DateTime.parse(slot.endTime!).millisecondsSinceEpoch;
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime > (startTime + 1) && currentTime < endTime) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void getCategoryApplicationDetails(String supplyID, String categoryID) async {
    try {
      WorkApplicationResponse workApplicationResponse =
          await _wosRemoteRepository.getCategoryApplicationDetails(
              supplyID, categoryID, null);
      if (!_workApplicationResponse.isClosed) {
        _workApplicationResponse.sink.add(workApplicationResponse);
      }
    } on ServerException catch (e) {
      if (!_workApplicationResponse.isClosed) {
        _workApplicationResponse.sink.addError('');
      }
    } on FailureException catch (e) {
      if (!_workApplicationResponse.isClosed) {
        _workApplicationResponse.sink.addError('');
      }
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationDetails : ${e.toString()} \n${st.toString()}');
      if (!_workApplicationResponse.isClosed) {
        _workApplicationResponse.sink.addError('');
      }
    }
  }

  List<WorkApplicationEntity>? getSimilarJobs() {
    if (!_workApplicationResponse.isClosed &&
        _workApplicationResponse.hasValue) {
      return _workApplicationResponse.value.workApplicationList;
    }
    return null;
  }

  void requestWork(String executionID) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      ExecutionsResponse executionsResponse =
          await _dashboardRemoteRepository.requestWork(executionID);
      changeButtonStatus(ButtonStatus(isSuccess: true));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_executionResponse.isClosed) {
        _executionResponse.sink.add(executionsResponse);
      }
    } on ServerException catch (e) {
      if (!_executionResponse.isClosed) {
        _executionResponse.sink.addError(e.message ?? '');
      }
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      if (!_executionResponse.isClosed) {
        _executionResponse.sink.addError(e.message ?? '');
      }
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('requestWork : ${e.toString()} \n${st.toString()}');
      if (!_executionResponse.isClosed) {
        _executionResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  Map<String, String> getLoggingEvents(
      Execution execution, bool availabilityInProject) {
    Map<String, String> map = {};
    map[LoggingEvents.projectID] = execution.projectId ?? '';
    map[LoggingEvents.available] = availabilityInProject.toString();
    map[LoggingEvents.roleName] =
        execution.selectedProjectRole?.toLowerCase().replaceAll(' ', '_') ?? '';
    return map;
  }

  void getAttendancePunchesSearch(String? projectRoleId,String currentDate,String? executionId) async {
    try {
      AttendancePunchesResponse? attendancePunchesResponse = await _attendanceRemoteRepository.getAttendancePunchesSearch(currentDate,projectRoleId: projectRoleId,executionId: executionId);
      if(!attendancePunchesResponse!.attendancePunches!.isNullOrEmpty)
        {
          _attendancePunchesResponse.sink.add(attendancePunchesResponse?.attendancePunches![0]);
        }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getAttendancePunchesSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void doPunchInPunchOut(String executionId,String attendanceId,String punchInTime,bool punchStatus,bool isComingFromBottomSheet,{List<AttendanceAnswerEntity>? attendanceAnswerEntityList}) async {
    try {
      AttendancePunchesUpdateResponse attendancePunchesUpdateResponse = await _attendanceRemoteRepository.getAttendancePunchesUpdate(executionId, attendanceId, punchInTime,punchStatus,attendanceAnswerEntityList: attendanceAnswerEntityList);
      if(isComingFromBottomSheet)
        {
          changeUIStatus(UIStatus(event: Event.scheduled,data: attendancePunchesUpdateResponse.data?.attendancePunch?.punchInTime));
        }else{
        changeUIStatus(UIStatus(event: Event.updated,data: attendancePunchesUpdateResponse.data?.attendancePunch?.punchInTime));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('doPunchInPunchOut : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
