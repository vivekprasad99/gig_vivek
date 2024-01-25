import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/upload_or_sync/upload_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../core/data/local/database/upload_entity_ho/upload_entity_ho.dart';
import '../../../../core/data/local/repository/upload_entry/upload_entry_local_repository.dart';
import '../../../../core/di/app_injection_container.dart';
import '../../../../core/exception/exception.dart';
import '../../../../core/utils/app_log.dart';
import '../../../../execution_in_house/data/model/lead_entity.dart';
import '../../../../execution_in_house/data/repository/lead/lead_remote_repository.dart';
import '../../../cubit/aw_questions_cubit.dart';
import '../../../cubit/upload_or_sync_process_cubit/upload_or_sync_process_cubit.dart';
import '../../../data/model/configuration/configuration_type.dart';
import '../../../data/model/questions_validation_error.dart';
import '../../../data/model/result.dart';
import '../../../data/model/row/screen_row.dart';
import '../../../data/model/sub_type.dart';

part 'array_question_state.dart';

class ArrayQuestionCubit extends Cubit<ArrayQuestionState> {
  final UploadEntryLocalRepository _uploadEntryLocalRepository;
  final LeadRemoteRepository _leadRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  ArrayQuestionCubit(
      this._uploadEntryLocalRepository, this._leadRemoteRepository)
      : super(ArrayQuestionInitial());

  final _questionList = BehaviorSubject<List<Question>>();

  Stream<List<Question>> get questionListStream => _questionList.stream;

  List<Question> get questionListValue => _questionList.value;

  Function(List<Question>) get changeQuestionRowList => _questionList.sink.add;

  @override
  Future<void> close() {
    _uiStatus.close();
    _questionList.close();
    return super.close();
  }

  addFirstQuestion(Question question) {
    if (!_questionList.isClosed) {
      List<Question>? questionList = [];
      if (question.answerUnit?.arrayValue != null &&
          question.answerUnit!.arrayValue!.isNotEmpty) {
        for (int i = 0; i < question.answerUnit!.arrayValue!.length; i++) {
          Configuration configuration =
              QuestionMapper.getConfigurationForArrayQuestion(question);
          configuration.questionIndex = i + 1;
          Question lQuestion = Question(
            questionID: question.questionID,
            leadID: question.leadID,
            screenID: question.leadID,
            projectID: question.projectID,
            executionID: question.executionID,
            selectedProjectRole: question.selectedProjectRole,
            screenRowIndex: questionList.length,
            inputType: question.inputType,
            dataType: DataType.single,
            configuration: configuration,
            parentReference: question.parentReference,
            answerUnit: question.answerUnit!.arrayValue![i],
            nestedQuestionList: QuestionMapper.getNestedQuestionOfArrayQuestion(
                question.nestedQuestionList,
                question.answerUnit!.arrayValue![i]),
            currentRoute: MRouter.arrayQuestionWidget,
          );
          questionList.add(lQuestion);
        }
      } else {
        AnswerUnit answerUnit = AnswerUnit(
            inputType: question.inputType, dateType: DataType.single);
        Configuration configuration =
            QuestionMapper.getConfigurationForArrayQuestion(question);
        configuration.questionIndex = questionList.length + 1;
        Question lQuestion = Question(
          questionID: question.questionID,
          leadID: question.leadID,
          screenID: question.leadID,
          projectID: question.projectID,
          executionID: question.executionID,
          selectedProjectRole: question.selectedProjectRole,
          screenRowIndex: questionList.length,
          inputType: question.inputType,
          dataType: DataType.single,
          configuration: configuration,
          parentReference: question.parentReference,
          answerUnit: answerUnit,
          nestedQuestionList: question.nestedQuestionList,
          currentRoute: MRouter.arrayQuestionWidget,
        );
        questionList.add(lQuestion);
      }
      changeQuestionRowList(questionList);
    }
  }

  addQuestion(Question question,
      {ImageDetails? imageDetails,
      AnswerUnit? answerUnit,
      bool isUpdateQuestionList = true,
      List<Question>? existingQuestionList}) {
    if (!_questionList.isClosed) {
      List<Question>? questionList = [];
      if (existingQuestionList != null) {
        questionList = existingQuestionList;
      } else if (_questionList.hasValue) {
        questionList = _questionList.value;
      }

      questionList ??= [];
      answerUnit ??= AnswerUnit(
          inputType: question.inputType,
          dateType: DataType.single,
          imageDetails: imageDetails);
      Configuration configuration =
          QuestionMapper.getConfigurationForArrayQuestion(question);
      configuration.questionIndex = questionList.length + 1;
      List<Question>? nestedQuestionList =
          QuestionMapper.getNestedQuestionOfArrayQuestion(
              question.nestedQuestionList, null);
      Question lQuestion = Question(
        questionID: question.questionID,
        leadID: question.leadID,
        screenID: question.leadID,
        projectID: question.projectID,
        executionID: question.executionID,
        selectedProjectRole: question.selectedProjectRole,
        screenRowIndex: questionList.length,
        inputType: question.inputType,
        dataType: DataType.single,
        configuration: configuration,
        parentReference: question.parentReference,
        answerUnit: answerUnit,
        nestedQuestionList: nestedQuestionList,
        currentRoute: MRouter.arrayQuestionWidget,
      );
      questionList.add(lQuestion);
      if (isUpdateQuestionList) {
        changeQuestionRowList(questionList);
      }
    }
  }

  getNewQuestion(Question question) {
    if (!_questionList.isClosed) {
      List<Question>? questionList = [];
      if (_questionList.hasValue) {
        questionList = _questionList.value;
      }
      AnswerUnit answerUnit =
          AnswerUnit(inputType: question.inputType, dateType: DataType.single);
      Configuration configuration =
          QuestionMapper.getConfigurationForArrayQuestion(question);
      configuration.questionIndex = questionList.length + 1;
      Question lQuestion = Question(
        questionID: question.questionID,
        leadID: question.leadID,
        screenID: question.leadID,
        projectID: question.projectID,
        executionID: question.executionID,
        selectedProjectRole: question.selectedProjectRole,
        screenRowIndex: questionList.length,
        inputType: question.inputType,
        dataType: (question.configuration?.isAsync ?? false)
            ? DataType.array
            : DataType.single,
        configuration: configuration,
        parentReference: question.parentReference,
        answerUnit: answerUnit,
        nestedQuestionList: question.nestedQuestionList,
        currentRoute: MRouter.arrayQuestionWidget,
      );
      return lQuestion;
    }
  }

  deleteQuestion(Question question) {
    if (!_questionList.isClosed && _questionList.hasValue) {
      List<Question>? questionList = _questionList.value;
      if (question.groupQuestionIndex != null) {
      } else if (question.screenRowIndex != null) {
        questionList.removeAt(question.screenRowIndex!);
        for (int i = question.screenRowIndex!; i < questionList.length; i++) {
          questionList[i].configuration?.questionIndex =
              questionList[i].configuration!.questionIndex! - 1;
        }
      }

      // TODO NEED TO DELETE FROM DB
      changeQuestionRowList(questionList);
    }
  }

  updateQuestionList(Question question, Question parentQuestion) {
    if (!_questionList.isClosed) {
      List<Question>? questionList = _questionList.value;
      if (question.groupQuestionIndex != null) {
      } else if (question.screenRowIndex != null) {
        if (question.isDeleted) {
          List<Question> tempQuestionList = [];
          tempQuestionList.addAll(questionList);
          for (int i = 0; i < questionList.length; i++) {
            if (questionList[i].answerUnit?.imageDetails?.uploadEntityHOKey ==
                question.answerUnit?.imageDetails?.uploadEntityHOKey) {
              tempQuestionList.removeAt(i);
              break;
            }
          }
          for (int i = 0; i < tempQuestionList.length; i++) {
            Question question = tempQuestionList[i];
            if(question.inputType?.getValue1() != ConfigurationType.text) {
              question.uuid = DateTime.now().millisecondsSinceEpoch.toString();
            }
            tempQuestionList[i] = question;
          }
          questionList.clear();
          questionList.addAll(tempQuestionList);
        } else {
          if(question.inputType?.getValue1() != ConfigurationType.text) {
            question.uuid = DateTime.now().millisecondsSinceEpoch.toString();
          }
          questionList[question.screenRowIndex!] = question;
        }
      }
      changeQuestionRowList(questionList);
      if (question.isDeleted) {
        AnswerUnit? answerUnit = getAnswerUnit(parentQuestion);
        parentQuestion.answerUnit = answerUnit;
        updateLead(parentQuestion);
      }
    }
  }

  addQuestionList(Question question,
      {List<ImageDetails>? imageDetailsList,
      List<AnswerUnit>? answerUnitList,
      bool isStartUploading = false,
      bool isRefreshList = false,
      bool isUpsertEntity = false}) async {
    /// Inserting image from gallery
    if (isUpsertEntity &&
        imageDetailsList != null &&
        imageDetailsList.length == 1) {
      ImageDetails imageDetails = imageDetailsList[0];
      int key =
          await _uploadEntryLocalRepository.upsertEntity(imageDetailsList[0]);
      imageDetails.uploadEntityHOKey = key;
      imageDetailsList[0] = imageDetails;
    }

    if (!_questionList.isClosed) {
      List<Question>? questionList = [];
      if (_questionList.hasValue) {
        questionList = _questionList.value;
      }
      if (isRefreshList) {
        questionList.clear();
      }

      if (imageDetailsList != null) {
        for (int i = 0; i < imageDetailsList.length; i++) {
          addQuestion(question,
              imageDetails: imageDetailsList[i],
              isUpdateQuestionList: !(i < imageDetailsList.length - 1),
              existingQuestionList: questionList);
        }
      }

      if (answerUnitList != null) {
        for (int i = 0; i < answerUnitList.length; i++) {
          addQuestion(question,
              answerUnit: answerUnitList[i],
              isUpdateQuestionList: !(i < answerUnitList.length - 1),
              existingQuestionList: questionList);
        }
      }
    }

    if (isStartUploading) {
      /// Start image uploading
      sl<UploadOrSyncProcessCubit>().start();
    }
  }

  void updateUploadEntriesAndStartSyncing(Question question) {
    List<UploadEntityHO> uploadEntityHOList =
        _uploadEntryLocalRepository.getUploadEntityHOList(
            questionID: question.questionID ?? '', leadID: question.leadID);
    for (int i = 0; i < uploadEntityHOList.length; i++) {
      UploadEntityHO uploadEntityHO = uploadEntityHOList[i];
      if (uploadEntityHO.uploadStatus == UploadStatus.uploadNotStarted.value &&
          (uploadEntityHO.isPaused ?? false)) {
        uploadEntityHO.isPaused = false;
        uploadEntityHO.save();
      }
    }
    sl<UploadOrSyncProcessCubit>().start();
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>
      validateRequiredAnswers({bool isCheckImageDetails = false}) {
    if (!_questionList.isClosed) {
      List<Question>? questionList = _questionList.value;
      for (int i = 0; i < questionList.length; i++) {
        Question question = questionList[i];
        Result<Map<String, AnswerUnit>, QuestionsValidationError>? result =
            questionValidation(question, i,
                isCheckImageDetails: isCheckImageDetails);
        if (result != null) return result;
      }
    }
    return Result.success();
  }

  Result<Map<String, AnswerUnit>, QuestionsValidationError>? questionValidation(
      Question question, int i,
      {bool isCheckImageDetails = false}) {
    bool isRequired = question.configuration?.isRequired ?? false;
    if ((isRequired &&
        !question.hasAnswered(isCheckImageDetails: isCheckImageDetails))) {
      String questionText =
          question.configuration?.questionText ?? 'required_questions'.tr;
      return Result.error(QuestionsValidationError(
          i, '${'please_fill_already_input_first'.tr} '));
    }
    return null;
  }

  AnswerUnit? getAnswerUnit(Question question) {
    List<AnswerUnit> answerUnitList = getAnswerUnits();

    if (answerUnitList.isNotEmpty) {
      AnswerUnit answerUnit = AnswerUnit(
          inputType: question.inputType, dateType: question.dataType);
      answerUnit.arrayValue = answerUnitList;
      return answerUnit;
    } else if (question.configuration?.isAsync ?? false) {
      AnswerUnit answerUnit = AnswerUnit(
          inputType: question.inputType, dateType: question.dataType);
      answerUnit.arrayValue = answerUnitList;
      return answerUnit;
    } else {
      return null;
    }
  }

  List<AnswerUnit> getAnswerUnits() {
    List<AnswerUnit> answerUnitList = [];
    if (_questionList.hasValue) {
      for (Question question in _questionList.value ?? []) {
        if (question.dataType == DataType.single &&
            question.inputType?.getValue2() == SubType.image &&
            (question.hasAnswered() ||
                question.hasAnswered(isCheckImageDetails: true))) {
          answerUnitList.add(question.answerUnit!);
        } else if (question.hasAnswered()) {
          answerUnitList.add(question.answerUnit!);
        }
      }
    }
    return answerUnitList;
  }

  void updateLead(Question question) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      List<ScreenRow>? screenRowList =
          sl<AwQuestionsCubit>().getScreenRowListByQuestionID(question);
      if (screenRowList != null && screenRowList.length == 1) {
        ScreenRow screenRow = screenRowList[0];
        screenRow.question = question;
        screenRowList[0] = screenRow;
      }
      Lead lead = await _leadRemoteRepository.updateLead(
          question.executionID ?? '',
          question.screenID ?? '',
          question.leadID ?? '',
          screenRowList);
    } on ServerException catch (e) {
      AppLog.e('updateLead : ${e.toString()} \n${e.message!}');
    } on FailureException catch (e) {
      AppLog.e('updateLead : ${e.toString()} \n${e.message!}');
    } catch (e, st) {
      AppLog.e('updateLead : ${e.toString()} \n${st.toString()}');
    }
  }
}
