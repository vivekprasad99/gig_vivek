import 'dart:async';

import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:awign/workforce/onboarding/data/repository/in_app_interview/in_app_interview_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/in_app_training/in_app_training_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_demo/pitch_demo_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_test/pitch_test_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/data/model/button_status.dart';

part 'online_test_state.dart';

class OnlineTestCubit extends Cubit<OnlineTestState> {
  final InAppInterviewRemoteRepository _inAppInterviewRepository;
  final InAppTrainingRemoteRepository _inAppTrainingRemoteRepository;
  final PitchDemoRemoteRepository _pitchDemoRemoteRepository;
  final PitchTestRemoteRepository _pitchTestRemoteRepository;
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _resourceResponse = BehaviorSubject<AttachmentSection>();
  Stream<AttachmentSection> get resourceResponse => _resourceResponse.stream;

  AttachmentSection? get resourceValue => _resourceResponse.valueOrNull;

  Function(AttachmentSection) get changeResourceResponse => _resourceResponse.sink.add;

  final _screenResponse = BehaviorSubject<ScreenResponse>();

  Stream<ScreenResponse> get _screenResponseStream => _screenResponse.stream;

  ScreenResponse? get screenResponseValue => _screenResponse.valueOrNull;

  Function(ScreenResponse) get changeScreenResponse => _screenResponse.sink.add;

  final _timelineSectionEntity = BehaviorSubject<TimelineSectionEntity>();

  Stream<TimelineSectionEntity> get timelineSectionEntityStream =>
      _timelineSectionEntity.stream;

  Function(TimelineSectionEntity) get changeTimelineSectionEntity =>
      _timelineSectionEntity.sink.add;

  final _timerText = BehaviorSubject<String?>.seeded('00:10');

  Stream<String?> get timerText => _timerText.stream;

  Function(String?) get changeTimerText => _timerText.sink.add;

  int currentIndex = 0;
  Timer? timer;

  final buttonStatus =
  BehaviorSubject<ButtonStatus>.seeded(ButtonStatus(isEnable: false));
  Stream<ButtonStatus> get buttonStatusStream => buttonStatus.stream;
  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  OnlineTestCubit(
      this._inAppInterviewRepository,
      this._inAppTrainingRemoteRepository,
      this._pitchDemoRemoteRepository,
      this._pitchTestRemoteRepository)
      : super(OnlineTestInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _screenResponse.close();
    _timelineSectionEntity.close();
    timer?.cancel();
    buttonStatus.close();
    return super.close();
  }

  void fetchScreens(
      UserData curUser, WorkApplicationEntity workApplicationEntity) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      ScreenResponse? screenResponse;
      StepType? stepType = workApplicationEntity.pendingAction?.actionKey
          ?.getOnlineTestStepType();
      switch (stepType) {
        case StepType.interview:
          screenResponse =
              await _inAppInterviewRepository.fetchInAppInterviewScreens(
                  curUser.id!, workApplicationEntity.id!);
          break;
        case StepType.training:
          screenResponse =
              await _inAppTrainingRemoteRepository.fetchInAppTrainingScreens(
                  curUser.id!, workApplicationEntity.id!);
          break;
        case StepType.pitchDemo:
          screenResponse = await _pitchDemoRemoteRepository
              .fetchPitchDemoScreens(curUser.id!, workApplicationEntity.id!);
          break;
        case StepType.pitchTest:
          screenResponse = await _pitchTestRemoteRepository
              .fetchPitchTestScreens(curUser.id!, workApplicationEntity.id!);
          break;
      }
      if (screenResponse != null &&
          !screenResponse.screens.isNullOrEmpty &&
          !_screenResponse.isClosed) {
        currentIndex = -1;
        _screenResponse.sink.add(screenResponse);
        _awQuestionsCubit.changeScreenRowList(getScreenRows(screenResponse));
        changeUIStatus(UIStatus(
            isOnScreenLoading: false,
            data: screenResponse,
            event: Event.success));
      } else {
        _screenResponse.sink.addError('we_regret_the_technical_error'.tr);
        changeUIStatus(UIStatus(
            isOnScreenLoading: false,
            failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
        MRouter.popNamedWithResult(workApplicationEntity.fromRoute ?? MRouter.categoryApplicationDetailsWidget,
            Constants.doRefresh, false);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_screenResponse.isClosed) {
        _screenResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_screenResponse.isClosed) {
        _screenResponse.sink.addError(e.message!);
      }
    } catch (e) {
      AppLog.e('fetchScreens : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_screenResponse.isClosed) {
        _screenResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void fetchResource(
      int? userId, WorkApplicationEntity workApplicationEntity) async {
    List<AttachmentSection>? response;
    StepType? stepType =
        workApplicationEntity.pendingAction?.actionKey?.getOnlineTestStepType();
    switch (stepType) {
      case StepType.interview:
       response = await _inAppInterviewRepository.fetchResource(
            userId!, workApplicationEntity.id!);
        break;
      case StepType.pitchDemo:
        response = await _pitchDemoRemoteRepository.fetchResource(
            userId!, workApplicationEntity.id!);

        break;
      case StepType.training:
        response = await _inAppTrainingRemoteRepository.fetchResource(
            userId!, workApplicationEntity.id!);
        break;
      case StepType.pitchTest:
        response = await _pitchTestRemoteRepository.fetchResource(
            userId!, workApplicationEntity.id!);
        break;
    }
    for(AttachmentSection attachmentSection in response!){
      if(attachmentSection.attachments!.length > 0){
        changeResourceResponse(attachmentSection);
      }
    }
  }

  AttachmentSection? getResource() {
    if (!_resourceResponse.isClosed && _resourceResponse.hasValue) {
      return _resourceResponse.value;
    } else {
      return null;
    }
  }

  List<ScreenRow> getScreenRows(ScreenResponse screenResponse) {
    List<ScreenRow> screenRowList = [];
    if (!screenResponse.screens.isNullOrEmpty) {
      List<Question> questionList = [];
      for (int i = 0; i < screenResponse.screens!.length; i++) {
        Question? question = screenResponse
            .screens?[i].groupedQuestions?[questionUngrouped]?.first;
        if (question != null) {
          questionList.add(question);
        }
      }
      int count = 1;
      for (Question question in questionList) {
        question.screenRowIndex = count - 1;
        question.configuration?.questionIndex = count;
        ScreenRow screenRow = ScreenRow(
            rowType: ScreenRowType.question,
            screenData: null,
            groupData: null,
            question: question);
        screenRowList.add(screenRow);
        count++;
      }
    }
    return screenRowList;
  }

  bool hasMoreScreens() {
    return (screenResponseValue?.offset ?? 0) +
            (screenResponseValue?.screens?.length ?? 0) <
        (screenResponseValue?.total ?? 0);
  }

  bool isNextQuestionLoaded() {
    return currentIndex + 1 < (screenResponseValue?.screens?.length ?? 0);
  }

  int getCurrentPosition() {
    return (screenResponseValue?.offset ?? 0) + currentIndex;
  }

  void startTimeout() {
    var interval = const Duration(seconds: 1);
    int timerMaxSeconds = 10;
    int currentSeconds = 0;
    var duration = interval;
    timer = Timer.periodic(duration, (timer) {
      currentSeconds = timer.tick;
      String timerText =
          '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';
      changeTimerText(timerText);
      if (timer.tick >= timerMaxSeconds) timer.cancel();
    });
  }

  void submitAnswer(
      WorkApplicationEntity workApplicationEntity,
      UserData curUser,
      int questionID,
      AnswerUnit answerUnit,
      int answerTime) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      dio.Response? response;
      StepType? stepType = workApplicationEntity.pendingAction?.actionKey
          ?.getOnlineTestStepType();
      switch (stepType) {
        case StepType.interview:
          response = await _inAppInterviewRepository.submitInAppInterviewAnswer(
              curUser.id!,
              workApplicationEntity.id!,
              questionID,
              answerUnit,
              answerTime);
          break;
        case StepType.training:
          response =
              await _inAppTrainingRemoteRepository.submitInAppTrainingAnswer(
                  curUser.id!,
                  workApplicationEntity.id!,
                  questionID,
                  answerUnit,
                  answerTime);
          break;
        case StepType.pitchDemo:
          response = await _pitchDemoRemoteRepository.submitPitchDemoAnswer(
              curUser.id!, workApplicationEntity.id!, questionID, answerUnit);
          break;
        case StepType.pitchTest:
          response = await _pitchTestRemoteRepository.submitPitchTestAnswer(
              curUser.id!, workApplicationEntity.id!, questionID, answerUnit);
          break;
      }
      changeUIStatus(
          UIStatus(isDialogLoading: false, event: Event.answerSubmitSuccess));
      changeButtonStatus(ButtonStatus(isEnable: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('submitAnswer : ${e.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
