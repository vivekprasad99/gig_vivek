import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/hash_answer.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'nested_question_state.dart';

class NestedQuestionCubit extends Cubit<NestedQuestionState> {
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _screenRowList = BehaviorSubject<List<ScreenRow>>();

  Stream<List<ScreenRow>> get screenRowListStream => _screenRowList.stream;

  List<ScreenRow> get screenRowListValue => _screenRowList.value;

  Function(List<ScreenRow>) get changeScreenRowList => _screenRowList.sink.add;

  NestedQuestionCubit() : super(NestedQuestionInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _screenRowList.close();
    return super.close();
  }

  void setNestedQuestionList(Question question) {
    changeScreenRowList(getScreenRows(question));
  }

  List<ScreenRow> getScreenRows(Question question) {
    List<ScreenRow> screenRowList = [];
    int count = 1;
    for (Question nestedQuestion in question.nestedQuestionList ?? []) {
      nestedQuestion.screenRowIndex = count - 1;
      nestedQuestion.configuration?.questionIndex = count;
      ScreenRow screenRow = ScreenRow(
          rowType: ScreenRowType.question,
          screenData: null,
          groupData: null,
          question: nestedQuestion);
      screenRowList.add(screenRow);
      count++;
    }
    return screenRowList;
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
      validateRequiredAnswers() {
    if (!_screenRowList.isClosed) {
      List<ScreenRow> screenRowList = _screenRowList.value;
      for (int i = 0; i < screenRowList.length; i++) {
        if (screenRowList[i].rowType == ScreenRowType.category) {
          List<Question> questionList =
              screenRowList[i].groupData?.questions ?? [];
          for (int j = 0; j < questionList.length; j++) {
            Question question = questionList[j];
            Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
                questionValidation(question, j);
            if (result != null) return result;
          }
        }
        Question? question = screenRowList[i].question;
        Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
            questionValidation(question!, i);
        if (result != null) return result;
      }
    }
    return Result.success();
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>
      validateRequiredAnswer(Question question, int i) {
    Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
        questionValidation(question, i);
    if (result != null) return result;
    return Result.success();
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>? questionValidation(
      Question question, int i) {
    bool isRequired = question.configuration?.isRequired ?? false;
    if ((isRequired && !question.hasAnswered())) {
      String questionText =
          question.configuration?.questionText ?? 'required_questions'.tr;
      return Result.error(
          QuestionsValidationError(i, '${'please_answer'.tr} $questionText'));
    }
    return null;
  }

  void reloadScreenRowList() {
    if (!_screenRowList.isClosed && _screenRowList.hasValue) {
      List<ScreenRow> screenRowList = _screenRowList.value;
      _screenRowList.sink.add(screenRowList);
    }
  }

  AnswerUnit? getAnswerUnit(Question question) {
    List<HashAnswer> answerUnitList = getAnswerUnits();
    if (answerUnitList.isNotEmpty) {
      AnswerUnit answerUnit = AnswerUnit(
          inputType: question.inputType, dateType: question.dataType);
      answerUnit.hashValue = answerUnitList;
      return answerUnit;
    } else {
      return null;
    }
  }

  List<HashAnswer> getAnswerUnits() {
    List<HashAnswer> answerUnitList = [];
    if (!_screenRowList.isClosed && _screenRowList.hasValue) {
      for (ScreenRow screenRow in screenRowListValue) {
        if (screenRow.rowType == ScreenRowType.category &&
            screenRow.groupData != null &&
            !screenRow.groupData!.questions.isNullOrEmpty) {
          for (Question question in screenRow.groupData!.questions!) {
            if (question.hasAnswered() &&
                question.configuration?.uid != null &&
                question.answerUnit != null) {
              HashAnswer hashAnswer = HashAnswer(
                  kay: question.configuration!.uid!,
                  value: question.answerUnit!);
              answerUnitList.add(hashAnswer);
            }
          }
        } else if (screenRow.question != null &&
            screenRow.question!.hasAnswered() &&
            screenRow.question!.configuration?.uid != null &&
            screenRow.question!.answerUnit != null) {
          HashAnswer hashAnswer = HashAnswer(
              kay: screenRow.question!.configuration!.uid!,
              value: screenRow.question!.answerUnit!);
          answerUnitList.add(hashAnswer);
        }
      }
    }
    return answerUnitList;
  }
}
