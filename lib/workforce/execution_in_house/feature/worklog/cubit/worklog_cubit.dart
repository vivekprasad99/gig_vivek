import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/worklog_response.dart';
import 'package:awign/workforce/execution_in_house/data/repository/worklog/worklog_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'worklog_state.dart';

class WorklogCubit extends Cubit<WorklogState> {
  final WorklogRemoteRepository _worklogRemoteRepository;
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _screenRowList = BehaviorSubject<List<ScreenRow>>();
  Stream<List<ScreenRow>> get screenRowList => _screenRowList.stream;

  Function(List<ScreenRow>) get changeExecution => _screenRowList.sink.add;

  WorklogCubit(this._worklogRemoteRepository) : super(WorklogInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _screenRowList.close();
    return super.close();
  }

  void getWorklog(String projectId, String projectRoleUid) async {
    try {
      WorklogConfigs worklogs =
          await _worklogRemoteRepository.getWorkLog(projectId, projectRoleUid);
      List<ScreenRow> screenrows = [];
      int count = 1;
      for (var question in worklogs.questions!) {
        question.screenRowIndex = count - 1;
        question.configuration?.questionIndex = count;
        screenrows.add(
            ScreenRow(question: question, rowType: ScreenRowType.question));
        count++;
      }
      _awQuestionsCubit.changeScreenRowList(screenrows);
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.add(screenrows);
      } else {
        _screenRowList.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getWorklog : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void createWorklog(String executionId, String projectRoleUid) async {
    try {
      await _worklogRemoteRepository.createWorklog(
          executionId, projectRoleUid, _screenRowList.value);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('createWorklog : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
