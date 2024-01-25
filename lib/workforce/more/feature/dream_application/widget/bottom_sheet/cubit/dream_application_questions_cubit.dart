import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/auth/data/repository/bff/bff_remote_repository.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'dream_application_questions_state.dart';

class DreamApplicationQuestionsCubit
    extends Cubit<DreamApplicationQuestionsState> with Validator {
  final BFFRemoteRepository _bffRemoteRepository;
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _questionAnswersResponse = BehaviorSubject<QuestionAnswersResponse>();

  Stream<QuestionAnswersResponse> get questionAnswersResponseStream =>
      _questionAnswersResponse.stream;

  Function(QuestionAnswersResponse) get changeQuestionAnswersResponse =>
      _questionAnswersResponse.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final _screenRowList = BehaviorSubject<List<ScreenRow>>();

  Stream<List<ScreenRow>> get screenRowListStream => _screenRowList.stream;

  List<ScreenRow> get screenRowListValue => _screenRowList.value;

  Function(List<ScreenRow>) get changeScreenRowList => _screenRowList.sink.add;

  DreamApplicationQuestionsCubit(this._bffRemoteRepository)
      : super(DreamApplicationQuestionsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _questionAnswersResponse.close();
    buttonStatus.close();
    _screenRowList.close();
    return super.close();
  }

  bool hasScreenRowListValue() {
    if (!_screenRowList.isClosed &&
        _screenRowList.hasValue &&
        !_screenRowList.value.isNullOrEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void getQuestionAnswers(UserData currentUser,
      DreamApplicationCompletionStage? dreamApplicationCompletionStage) async {
    try {
      QuestionAnswersResponse questionAnswersResponse =
          await _bffRemoteRepository.getQuestionAnswers(
              currentUser.id,
              DynamicModuleCategory.dreamApplication,
              dreamApplicationCompletionStage?.value ??
                  DreamApplicationCompletionStage.professionalDetails1.value);
      if (!_questionAnswersResponse.isClosed) {
        changeQuestionAnswersResponse(questionAnswersResponse);
      }
      _awQuestionsCubit.checkVisibilityAndUpdateQuestionList(
          questionAnswersResponse.getScreenQuestions(
              questionAnswersResponse.questions,
              DynamicModuleCategory.dreamApplication,
              null));
      checkValidation();
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getQuestionAnswers : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void checkValidation() {
    Result result = _awQuestionsCubit.validateRequiredAnswers();
    if (result.success) {
      changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  void submitAnswer(UserData currentUser,
      DreamApplicationCompletionStage dreamApplicationCompletionStage) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      SubmitAnswerResponse submitAnswerResponse =
          await _bffRemoteRepository.submitAnswer(
              _questionAnswersResponse.value.categoryDetails?.uid?.value ?? '',
              _questionAnswersResponse.value.screenDetails?.uid?.value ?? '',
              currentUser.userProfile?.userId,
              _awQuestionsCubit.getVisibleScreenRow(),
              null,
              dreamApplicationCompletionStage);
      if (_awQuestionsCubit.screenRowListValue != null) {
        changeScreenRowList(_awQuestionsCubit.screenRowListValue!);
      }
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? curUser = spUtil?.getUserData();
      curUser?.userProfile?.dreamApplicationCompletionStage =
          submitAnswerResponse.dreamApplicationCompletionStage;
      spUtil?.putUserData(curUser);
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: submitAnswerResponse.message));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.updated, data: curUser));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('submitAnswer : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }
}
