import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/eligibility_entity_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/ineligible_question_answer_entity.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../aw_questions/data/model/row/screen_row.dart';
import '../../../../core/exception/exception.dart';
import '../../../../onboarding/data/model/category/category_application_response.dart';

part 'application_result_state.dart';

class ApplicationResultCubit extends Cubit<ApplicationResultState> {
  final WosRemoteRepository _wosRemoteRepository;
  ApplicationResultCubit(this._wosRemoteRepository) : super(ApplicationResultInitial());

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _questionList = BehaviorSubject<List<Question>>();
  Stream<List<Question>> get questionList => _questionList.stream;

  final _screenRowList = BehaviorSubject<List<ScreenRow>>();
  Stream<List<ScreenRow>> get screenRowListStream => _screenRowList.stream;
  List<ScreenRow> get screenRowListValue => _screenRowList.value;
  Function(List<ScreenRow>) get changeScreenRowList => _screenRowList.sink.add;

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  Future getQuestions(List<ApplicationAnswers>? applicationAnswerList,int? userID) async {
    try {
      List<Question> questions  = await _wosRemoteRepository.getQuestions(applicationAnswerList,userID);
      getApplicationQuestions(questions,applicationAnswerList);
      if (!_questionList.isClosed) {
        _questionList.sink.add(questions);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getQuestions : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void getApplicationQuestions(List<Question> questionsList,List<ApplicationAnswers>? applicationAnswerList) {
    int count = 1;
    List<ScreenRow> screenRowList = [];
    for (Question question in questionsList) {
      question.screenRowIndex = count - 1;
      question.configuration?.questionIndex = count;
      dynamic value = getEligibilityAnswer(question,applicationAnswerList);
      question.answerUnit = AnswerUnitMapper.getAnswerUnit(question.inputType,
          question.dataType, value, question.nestedQuestionList);
      ScreenRow screenRow = ScreenRow(
          rowType: ScreenRowType.question,
          screenData: null,
          groupData: null,
          question: question);
      screenRowList.add(screenRow);
      count++;
    }
    _screenRowList.sink.add(screenRowList);
  }

  dynamic getEligibilityAnswer(Question question,List<ApplicationAnswers>? applicationAnswerList)
  {
    for (ApplicationAnswers applicationAnswers in applicationAnswerList!) {
      if(applicationAnswers.applicationQuestionId.toString() == question.configuration?.uid)
        {
          return applicationAnswers.answer;
        }
    }
    return null;
  }

  void updateScreenRowList(Question question) {
    if (!_screenRowList.isClosed) {
      List<ScreenRow> screenRowList = _screenRowList.value;
      if (question.groupQuestionIndex != null &&
          question.screenRowIndex != null) {
        if (screenRowList.length > question.groupQuestionIndex!) {
          ScreenRow screenRow = screenRowList[question.groupQuestionIndex!];
          GroupData? groupData = screenRow.groupData;
          if (groupData != null &&
              groupData.questions != null &&
              groupData.questions!.length > question.screenRowIndex!) {
            groupData.questions![question.screenRowIndex!] = question;
            int answerQuestionCount = 0;
            for (Question lQuestion in groupData.questions!) {
              if (lQuestion.hasAnswered()) {
                answerQuestionCount++;
              }
            }
            groupData.answerQuestionCount = answerQuestionCount;
          }
          screenRow.groupData = groupData;
          screenRowList[question.groupQuestionIndex!] = screenRow;
          _screenRowList.sink.add(screenRowList);
        }
      } else if (question.screenRowIndex != null) {
        if (screenRowList.length > question.screenRowIndex!) {
          ScreenRow screenRow = screenRowList[question.screenRowIndex!];
          screenRow.question = question;
          screenRowList[question.screenRowIndex!] = screenRow;
            _screenRowList.sink.add(screenRowList);
        }
      }
    }
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>
  validateRequiredAnswers({DynamicModuleCategory? dynamicModuleCategory}) {
    if (!_screenRowList.isClosed) {
      List<ScreenRow> screenRowList = _screenRowList.value;
      for (int i = 0; i < screenRowList.length; i++) {
        if (screenRowList[i].rowType == ScreenRowType.category) {
          List<Question> questionList =
              screenRowList[i].groupData?.questions ?? [];
          for (int j = 0; j < questionList.length; j++) {
            Question question = questionList[j];

            Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
            questionValidation(question, j,
                dynamicModuleCategory: dynamicModuleCategory);
            if (result != null) return result;
          }
        }
        Question? question = screenRowList[i].question;
        if (question == null) {
          continue;
        }
        Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
        questionValidation(question, i,
            dynamicModuleCategory: dynamicModuleCategory);
        if (result != null) return result;
      }
    }
    return Result.success();
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>? questionValidation(
      Question question, int i,
      {DynamicModuleCategory? dynamicModuleCategory}) {
    bool isRequired = question.configuration?.isRequired ?? false;
    bool isVisible = true;
    if (!question.visibilityConditions.isNullOrEmpty) {
      isVisible = question.isVisible;
    }
    if ((isRequired && isVisible && !question.hasAnswered())) {
      String questionText =
          question.configuration?.questionText ?? 'required_questions'.tr;
      return Result.error(
          QuestionsValidationError(i, '${'please_answer'.tr} $questionText'));
    }
    return null;
  }

  void onConfirmTap(
      String supplyID, int categoryID, List<ScreenRow> screenRowList) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      CategoryApplication categoryApplication = await _wosRemoteRepository
          .createCategory(supplyID, categoryID, null, screenRowList);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: e.message!,
          event: Event.failed));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: e.message!,
          event: Event.failed));
    } catch (e, st) {
      AppLog.e('getCategory : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr,
          event: Event.failed));
    }
  }
}
