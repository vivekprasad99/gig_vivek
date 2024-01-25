import 'dart:async';

import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/repository/execution_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/interector/application_event_interector.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/webinar_training/webinar_training_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'category_application_details_state.dart';

class CategoryApplicationDetailsCubit
    extends Cubit<CategoryApplicationDetailsState> {
  final ExecutionRemoteRepository _executionRemoteRepository;
  final WosRemoteRepository _wosRemoteRepository;
  final ApplicationEventInterector _applicationEventInterector;
  final WebinarTrainingRemoteRepository _webinarTrainingRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _executionList = BehaviorSubject<List<Execution>>();

  Stream<List<Execution>> get executionListStream => _executionList.stream;

  List<Execution> get executionList => _executionList.value;

  Function(List<Execution>) get changeExecutionList => _executionList.sink.add;

  final _applicationList = BehaviorSubject<List<WorkApplicationEntity>>();

  Stream<List<WorkApplicationEntity>> get applicationListStream =>
      _applicationList.stream;

  List<WorkApplicationEntity> get applicationList => _applicationList.value;

  Function(List<WorkApplicationEntity>) get changeApplicationList =>
      _applicationList.sink.add;

  final _workApplicationEntity = BehaviorSubject<WorkApplicationEntity>();

  Stream<WorkApplicationEntity> get workApplicationEntityStream =>
      _workApplicationEntity.stream;

  WorkApplicationEntity? get workApplicationEntityValue =>
      _workApplicationEntity.valueOrNull;

  Function(WorkApplicationEntity) get changeWorkApplicationEntity =>
      _workApplicationEntity.sink.add;

  CategoryApplicationDetailsCubit(this._executionRemoteRepository,
      this._wosRemoteRepository, this._applicationEventInterector,this._webinarTrainingRemoteRepository)
      : super(CategoryApplicationDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _executionList.close();
    _applicationList.close();
    _workApplicationEntity.close();
    return super.close();
  }

  void getApplicationAndExecution(UserData userData,
      CategoryApplication categoryApplication, bool isSkipSaasOrgID) async {
    Rx.combineLatest2(
      _executionList.stream,
      _applicationList.stream,
      (List<Execution> executions,
          List<WorkApplicationEntity> applicationResponse) {
        return executions;
      },
    ).listen((response) {
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    });
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    getExecutions(userData, categoryApplication, isSkipSaasOrgID);
    getApplication(userData, categoryApplication, isSkipSaasOrgID);
  }

  void getExecutions(UserData curUser, CategoryApplication categoryApplication,
      bool isSkipSaasOrgID) async {
    try {
      String? uids = categoryApplication.uids;
      uids ??= '${categoryApplication.name}';
      ExecutionPageParameters executionPageParameters = ExecutionPageParameters(
          memberID: curUser.ihOmsId!,
          uIDs: uids,
          skipSaasOrgId: isSkipSaasOrgID);
      Tuple2<ExecutionsResponse, String> tuple2 =
          await _executionRemoteRepository.getExecutions(
              1, executionPageParameters);
      if (tuple2.item1.executions != null && !_executionList.isClosed) {
        List<Execution> executionRemoteList = tuple2.item1.executions!;

        List<Execution> executionList = <Execution>[];
        List<Execution> activeExecutionList = <Execution>[];
        List<Execution> approvedExecutionList = <Execution>[];
        List<Execution> waitlistedExecutionList = <Execution>[];
        List<Execution> onHoldExecutionList = <Execution>[];
        List<Execution> completedExecutionList = <Execution>[];
        List<Execution> disqualifiedExecutionList = <Execution>[];
        List<Execution> archiveExecutionList = <Execution>[];

        for (Execution execution in executionRemoteList) {
          if (execution.archivedStatus == true) {
            archiveExecutionList.add(execution);
          } else {
            switch (execution.status) {
              case ExecutionStatus.approved:
                approvedExecutionList.add(execution);
                break;
              case ExecutionStatus.started:
                if ((execution.leadAllotmentType ==
                            ExecutionLeadAllotmentType.provided &&
                        execution.leadAssignedStatus == null) ||
                    (execution.leadAllotmentType == null &&
                        execution.leadAssignedStatus == null)) {
                  waitlistedExecutionList.add(execution);
                } else if ((execution.leadAllotmentType ==
                            ExecutionLeadAllotmentType.selfCreated &&
                        execution.leadAssignedStatus == null) ||
                    execution.leadAssignedStatus ==
                        ExecutionLeadAssignedStatus.firstLeadAssigned) {
                  activeExecutionList.add(execution);
                } else {
                  activeExecutionList.add(execution);
                }

                break;
              case ExecutionStatus.added:
                activeExecutionList.add(execution);
                break;
              case ExecutionStatus.durationExtended:
              case ExecutionStatus.halted:
                onHoldExecutionList.add(execution);
                break;
              case ExecutionStatus.certificateRequested:
              case ExecutionStatus.certificateIssued:
              case ExecutionStatus.backedOut:
              case ExecutionStatus.completed:
              case ExecutionStatus.submitted:
                completedExecutionList.add(execution);
                break;
              case ExecutionStatus.blacklisted:
              case ExecutionStatus.disqualified:
              case ExecutionStatus.rejected:
                disqualifiedExecutionList.add(execution);
            }
          }
        }
        executionList.addAll(approvedExecutionList);
        executionList.addAll(activeExecutionList);
        executionList.addAll(waitlistedExecutionList);
        executionList.addAll(completedExecutionList);
        executionList.addAll(onHoldExecutionList);
        executionList.addAll(disqualifiedExecutionList);
        executionList.addAll(archiveExecutionList);
        _executionList.sink.add(executionList);
      } else if (!_executionList.isClosed) {
        _executionList.sink.addError(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_executionList.isClosed) {
        _executionList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_executionList.isClosed) {
        _executionList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getExecutions : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_executionList.isClosed) {
        _executionList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getApplication(UserData userData,
      CategoryApplication categoryApplication, bool isSkipSaasOrgID) async {
    try {
      Tuple2<WorkApplicationResponse, String?> tuple2 =
          await _wosRemoteRepository.getCategoryApplicationSearch(
              categoryApplication.categoryId.toString(),
              userData.id.toString(),
              isSkipSaasOrgID);
      if ((userData.permissions?.awign
              ?.contains(AwignPermissionConstants.hidePendingJobs) ??
          false)) {
        _applicationList.sink.add([]);
      } else if (tuple2.item1.workApplicationList != null &&
          !_applicationList.isClosed) {
        _applicationList.sink.add(tuple2.item1.workApplicationList!);
      } else if (!_applicationList.isClosed) {
        _applicationList.sink.addError(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_applicationList.isClosed) {
        _applicationList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_applicationList.isClosed) {
        _applicationList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getApplication : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_applicationList.isClosed) {
        _applicationList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void executeApplicationEvent(int userID, int listingID, int applicationID,
      ApplicationAction applicationAction) async {
    try {
      WorkApplicationEntity? workApplicationEntity =
          await _applicationEventInterector.handleApplicationEvent(
              userID, applicationID, applicationAction);
      if (workApplicationEntity != null && !_workApplicationEntity.isClosed) {
        _workApplicationEntity.sink.add(workApplicationEntity);
        switch (workApplicationEntity.applicationStatus) {
          case ApplicationStatus.genericSelected:
            changeUIStatus(UIStatus(event: Event.selected));
            break;
          default:
            changeUIStatus(UIStatus(event: Event.success));
        }
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('executeApplicationEvent : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void markAttendance(int applicationID) async {
    try {
      WorkApplicationEntity? workApplicationEntity =
      await _webinarTrainingRemoteRepository.markAttendanceForWebinarTraining(applicationID);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('markAttendance : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
