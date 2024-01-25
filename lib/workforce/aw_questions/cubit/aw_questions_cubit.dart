import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/location_helper.dart';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/data/local/repository/upload_entry/upload_entry_local_repository.dart';
import '../data/model/answer/trackable_data.dart';
import '../data/model/answer/trackable_data_holder.dart';
import '../data/model/sub_type.dart';
import '../helper/trackable_data_helper.dart';

part 'aw_questions_state.dart';

class AwQuestionsCubit extends Cubit<AwQuestionsState> {
  final UploadEntryLocalRepository _uploadEntryLocalRepository;

  AwQuestionsCubit(this._uploadEntryLocalRepository)
      : super(AwQuestionsInitial());

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _screenRowList = BehaviorSubject<List<ScreenRow>>();

  Stream<List<ScreenRow>> get screenRowListStream => _screenRowList.stream;

  List<ScreenRow>? get screenRowListValue => _screenRowList.valueOrNull;

  Function(List<ScreenRow>) get changeScreenRowList => _screenRowList.sink.add;

  @override
  Future<void> close() {
    _uiStatus.close();
    _screenRowList.close();
    return super.close();
  }

  void checkDBAndChangeScreenRowList(List<ScreenRow> screenRowList) {
    List<ScreenRow> tempScreenRowList = [];
    tempScreenRowList.addAll(screenRowList);
    for (int i = 0; i < screenRowList.length; i++) {
      ScreenRow screenRow = screenRowList[i];
      if(screenRow.question != null) {
        screenRow.question = checkAnswerInDB(screenRow.question!, true);
      } else if(screenRow.groupData != null && screenRow.groupData!.questions != null) {
        List<Question> tempGroupQuestionList = screenRow.groupData!.questions!;
        for(int j = 0; j < screenRow.groupData!.questions!.length; j++) {
          tempGroupQuestionList[j] = checkAnswerInDB(screenRow.groupData!.questions![j], true);
        }
        screenRow.groupData!.questions = tempGroupQuestionList;
      }
      tempScreenRowList[i] = screenRow;
    }
    changeScreenRowList(tempScreenRowList);
  }

  Future<void> updateScreenRowList(Question question,
      {DynamicModuleCategory? dynamicModuleCategory}) async {
    if (!_screenRowList.isClosed) {
      question = await checkAndSetTrackableData(question);
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
          /// Check answers in db and update question's AnswerUnit
          screenRow.groupData?.questions?[question.screenRowIndex!] = checkAnswerInDB(question, false);
          screenRowList[question.groupQuestionIndex!] = screenRow;
          _screenRowList.sink.add(screenRowList);
        }
      } else if (question.screenRowIndex != null) {
        if (screenRowList.length > question.screenRowIndex!) {
          ScreenRow screenRow = screenRowList[question.screenRowIndex!];

          /// Check answers in db and update question's AnswerUnit
          screenRow.question = checkAnswerInDB(question, false);
          screenRowList[question.screenRowIndex!] = screenRow;
          if (dynamicModuleCategory == DynamicModuleCategory.onboarding ||
              dynamicModuleCategory == DynamicModuleCategory.dreamApplication) {
            checkVisibilityAndUpdateQuestionList(screenRowList);
          } else {
            _screenRowList.sink.add(screenRowList);
          }
        }
      }
    }
  }

  checkVisibilityAndUpdateQuestionList(List<ScreenRow> screenRowList,
      {DynamicModuleCategory? dynamicModuleCategory}) {
    if (!_screenRowList.isClosed) {
      List<ScreenRow> tempScreenRowList = [];
      tempScreenRowList.addAll(screenRowList);
      for (int i = 0; i < screenRowList.length; i++) {
        ScreenRow screenRow = screenRowList[i];
        Question? question = screenRow.question;
        bool isVisible = true;
        if (question != null && !question.visibilityConditions.isNullOrEmpty) {
          for (int j = 0; j < question.visibilityConditions!.length; j++) {
            isVisible = checkVisibility(
                question.visibilityConditions![j], screenRowList,
                dynamicModuleCategory: dynamicModuleCategory);
            if (isVisible) {
              break;
            }
          }
          question.isVisible = isVisible;
          screenRow.question = question;
          tempScreenRowList[i] = screenRow;
        }
      }
      _screenRowList.sink.add(tempScreenRowList);
    }
  }

  Future<Question> checkAndSetTrackableData(Question question) async {
    if (question.configuration?.isAsync ?? false) {
      return question;
    } else if (question.inputType?.getValue2() == SubType.image) {
      return question;
    } else if(question.configuration?.isLocationTrackable ?? false) {
      Position? currentLocation = await LocationHelper.getCurrentLocation();
      TrackableData trackableData = TrackableDataHelper.getTrackableData(
          currentLocation, question.configuration?.isLocationTrackable ?? false, question.configuration?.isTimeTrackable ?? false);
      question.answerUnit?.trackableDataHolder = question.answerUnit?.trackableDataHolder != null
          ? question.answerUnit?.trackableDataHolder!
          : TrackableDataHolder();
      question.answerUnit?.trackableDataHolder?.trackableData = trackableData;
    }
    return question;
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>
      validateRequiredAnswers({DynamicModuleCategory? dynamicModuleCategory}) {
    if (!_screenRowList.isClosed && screenRowListValue != null) {
      List<ScreenRow> screenRowList = screenRowListValue!;
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

  Result<Map<String, AnswerUnit>, QuestionsValidationError>
      validateRequiredAnswer(Question question, int i) {
    Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
        questionValidation(question, i);
    if (result != null) return result;
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
    if ((isRequired && isVisible && !question.hasAnswered(configuration: question.configuration))) {
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

  bool checkVisibility(
      VisibilityCondition visibilityCondition, List<ScreenRow>? screenRowList,
      {DynamicModuleCategory? dynamicModuleCategory}) {
    bool isVisible = false;
    if (dynamicModuleCategory == DynamicModuleCategory.profileCompletion) {
      isVisible = true;
    } else if (!screenRowList.isNullOrEmpty) {
      for (ScreenRow screenRow in screenRowList!) {
        Question? question = screenRow.question;
        if (question?.attributeUid == visibilityCondition.questionUid &&
            (question?.hasAnswered() ?? false) &&
            visibilityCondition.answerUids != null) {
          bool isNestedQuestionVisible = true;
          if (question != null &&
              !question.visibilityConditions.isNullOrEmpty) {
            for (int j = 0; j < question.visibilityConditions!.length; j++) {
              isNestedQuestionVisible = checkVisibility(
                  question.visibilityConditions![j], screenRowList,
                  dynamicModuleCategory: dynamicModuleCategory);
              if (isNestedQuestionVisible) {
                break;
              }
            }
          }

          if (isNestedQuestionVisible) {
            switch (question?.answerUnit?.dateType) {
              case DataType.single:
                switch (question?.answerUnit?.inputType?.getValue1()) {
                  case ConfigurationType.singleSelect:
                    for (int i = 0;
                        i < visibilityCondition.answerUids!.length;
                        i++) {
                      if (question?.answerUnit?.optionValue?.uid ==
                          visibilityCondition.answerUids![i]) {
                        isVisible = true;
                        break;
                      }
                    }
                    break;
                }
                break;
            }
          } else {
            isVisible = false;
          }
        }
      }
    }
    return isVisible;
  }

  List<ScreenRow> getVisibleScreenRow(
      {DynamicModuleCategory? dynamicModuleCategory}) {
    List<ScreenRow> screenRowList = [];
    if (screenRowListValue != null) {
      for (var screenRow in screenRowListValue!) {
        bool isVisible = true;
        if (screenRow.question != null &&
            !screenRow.question!.visibilityConditions.isNullOrEmpty) {
          isVisible = screenRow.question!.isVisible;
        }
        if (isVisible) {
          screenRowList.add(screenRow);
        }
      }
    }
    return screenRowList;
  }

  Question checkAnswerInDB(Question question, bool isQuestionFromServer) {
    if (question.configuration?.isAsync ?? false) {
      List<UploadEntityHO> uploadEntityHOList =
          _uploadEntryLocalRepository.getUploadEntityHOList(
              questionID: question.questionID ?? '', leadID: question.leadID);
      if (question.answerUnit != null) {
        switch (question.dataType) {
          case DataType.single:
            if (!uploadEntityHOList.isNullOrEmpty) {
              for (int i = 0; i < uploadEntityHOList.length; i++) {
                question.answerUnit?.imageDetails =
                    uploadEntityHOList[i].getImageDetails();
                question.answerUnit?.stringValue =
                    uploadEntityHOList[i].uploadedFileUrl;
                break;
              }
            } else if (!isQuestionFromServer) {
              question.answerUnit?.imageDetails = null;
              question.answerUnit?.stringValue = null;
            }
            break;
          case DataType.array:
            List<AnswerUnit> answerUnitList =
                question.answerUnit?.arrayValue ?? [];
            if (!uploadEntityHOList.isNullOrEmpty) {
              for (int i = 0; i < uploadEntityHOList.length; i++) {
                bool isExist = false;
                for (int j = 0; j < answerUnitList.length; j++) {
                  AnswerUnit answerUnit = answerUnitList[j];
                  if (answerUnit.imageDetails?.uploadEntityHOKey ==
                      uploadEntityHOList[i].key) {
                    answerUnit.imageDetails =
                        uploadEntityHOList[i].getImageDetails();
                    answerUnit.stringValue =
                        uploadEntityHOList[i].uploadedFileUrl;
                    answerUnitList[j] = answerUnit;
                    isExist = true;
                    break;
                  } else if (answerUnit.stringValue ==
                      uploadEntityHOList[i].uploadedFileUrl) {
                    answerUnit.imageDetails =
                        uploadEntityHOList[i].getImageDetails();
                    answerUnit.stringValue =
                        uploadEntityHOList[i].uploadedFileUrl;
                    answerUnitList[j] = answerUnit;
                    isExist = true;
                    break;
                  }
                }
                if (!isExist) {
                  AnswerUnit answerUnit = AnswerUnit(
                      inputType: question.inputType, dateType: DataType.single);
                  answerUnit.imageDetails =
                      uploadEntityHOList[i].getImageDetails();
                  answerUnit.stringValue =
                      uploadEntityHOList[i].uploadedFileUrl;
                  answerUnitList.add(answerUnit);
                }
              }
              question.answerUnit?.arrayValue = answerUnitList;
            }
            break;
        }
      }
      return question;
    } else {
      return question;
    }
  }

  List<ScreenRow>? getScreenRowListByQuestionID(Question question) {
    List<ScreenRow>? resultScreenRowList;
    if (!_screenRowList.isClosed && _screenRowList.hasValue) {
      List<ScreenRow> screenRowList = _screenRowList.value;
      for (int i = 0; i < screenRowList.length; i++) {
        Question? lQuestion = screenRowList[i].question;
        if (lQuestion?.questionID == question.questionID) {
          resultScreenRowList = [];
          resultScreenRowList.add(screenRowList[i]);
          return resultScreenRowList;
        } else if (screenRowList[i].groupData != null
            && screenRowList[i].groupData?.questions.isNullOrEmpty == false) {
          for (final gQuestion in screenRowList[i].groupData!.questions!) {
            if (gQuestion.questionID == question.questionID) {
              resultScreenRowList = [];
              resultScreenRowList.add(screenRowList[i]);
              return resultScreenRowList;
            }
          }
        }
      }
    }
    return resultScreenRowList;
  }
}
