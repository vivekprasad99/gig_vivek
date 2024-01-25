import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/attachment/file_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/audio/audio_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/date/date_time_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/text/text_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type_entity_new.dart';
import 'package:awign/workforce/aw_questions/data/model/media_file.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/application_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/category_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/lead_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/pan_details_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/parent_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_as.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/data/image_sync_state.dart';
import 'package:awign/workforce/core/data/model/module_type.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';

class QuestionMapper {
  static List<Question> transformApplicationQuestions(
      List<ApplicationQuestionEntity>? applicationQuestionLibraries,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType) {
    List<Question> questions = [];
    if (applicationQuestionLibraries != null) {
      for (int i = 0; i < applicationQuestionLibraries.length; i++) {
        ApplicationQuestionEntity applicationQuestionEntity =
            applicationQuestionLibraries[i];
        if (applicationQuestionEntity.status == 'enabled') {
          questions.add(_transformQuestion(i, applicationQuestionEntity,
              listingId, applicationId, userID, moduleType));
        }
      }
    }
    return questions;
  }

  static List<Question> transformInAppInterviewQuestions(
      List<ApplicationQuestionEntity>? applicationQuestionLibraries,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType) {
    List<Question> questions = [];
    if (applicationQuestionLibraries != null) {
      for (int i = 0; i < applicationQuestionLibraries.length; i++) {
        ApplicationQuestionEntity applicationQuestionEntity =
            applicationQuestionLibraries[i];
        questions.add(_transformQuestion(i, applicationQuestionEntity,
            listingId, applicationId, userID, moduleType));
      }
    }
    return questions;
  }

  static List<Question> transformInAppTrainingQuestions(
      List<ApplicationQuestionEntity>? applicationQuestionLibraries,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType) {
    List<Question> questions = [];
    if (applicationQuestionLibraries != null) {
      for (int i = 0; i < applicationQuestionLibraries.length; i++) {
        ApplicationQuestionEntity applicationQuestionEntity =
            applicationQuestionLibraries[i];
        questions.add(_transformQuestion(i, applicationQuestionEntity,
            listingId, applicationId, userID, moduleType));
      }
    }
    return questions;
  }

  static List<Question> transformPitchDemoQuestions(
      List<ApplicationQuestionEntity>? applicationQuestionLibraries,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType) {
    List<Question> questions = [];
    if (applicationQuestionLibraries != null) {
      for (int i = 0; i < applicationQuestionLibraries.length; i++) {
        ApplicationQuestionEntity applicationQuestionEntity =
            applicationQuestionLibraries[i];
        questions.add(_transformQuestion(i, applicationQuestionEntity,
            listingId, applicationId, userID, moduleType));
      }
    }
    return questions;
  }

  static List<Question> transformPitchTestQuestions(
      List<ApplicationQuestionEntity>? applicationQuestionLibraries,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType) {
    List<Question> questions = [];
    if (applicationQuestionLibraries != null) {
      for (int i = 0; i < applicationQuestionLibraries.length; i++) {
        ApplicationQuestionEntity applicationQuestionEntity =
            applicationQuestionLibraries[i];
        questions.add(_transformQuestion(i, applicationQuestionEntity,
            listingId, applicationId, userID, moduleType));
      }
    }
    return questions;
  }

  static List<Question> transformScreenQuestions(
      List<ScreenQuestion>? screenQuestions,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType,{DynamicModuleCategory? dynamicModuleCategory}) {
    List<Question> questions = [];
    if (screenQuestions != null) {
      for (int i = 0; i < screenQuestions.length; i++) {
        ScreenQuestion screenQuestion = screenQuestions[i];
        questions.add(_transformScreenQuestion(
            i, screenQuestion, listingId, applicationId, userID, moduleType,dynamicModuleCategory: dynamicModuleCategory));
      }
    }
    return questions;
  }

  static List<Question> transformWorklogQuestions(
      List<ScreenQuestion>? screenQuestions, String? id, String projectId) {
    List<Question> questions = [];
    if (screenQuestions != null) {
      for (int i = 0; i < screenQuestions.length; i++) {
        ScreenQuestion lScreenQuestion = screenQuestions[i];
        questions
            .add(_transformWorklogQuestion(i, lScreenQuestion, id, projectId));
      }
    }
    return questions;
  }

  static List<Question> transformQuestionsNew(
      List<QuestionEntity>? questionEntities,
      DynamicModuleCategory? dynamicModuleCategory,
      int? userID) {
    List<Question> questions = [];
    if (questionEntities != null) {
      for (int i = 0; i < questionEntities.length; i++) {
        QuestionEntity lQuestionEntity = questionEntities[i];
        questions.add(_transformQuestionNew(
            i, lQuestionEntity, dynamicModuleCategory, userID));
      }
    }
    return questions;
  }

  static Question _transformQuestion(
      int screenRowIndex,
      ApplicationQuestionEntity applicationQuestionLibraries,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType) {
    String questionID = applicationQuestionLibraries.id != null
        ? applicationQuestionLibraries.id.toString()
        : '';

    DataType dataType =
        _transformDataType(applicationQuestionLibraries.dataType);
    return Question(
      screenRowIndex: screenRowIndex,
      inputType: _transformInputType(applicationQuestionLibraries.inputType),
      configuration: _getConfiguration(applicationQuestionLibraries,dataType,moduleType: moduleType),
      dataType: dataType,
      parentReference: _transformParentReference(
          applicationId, questionID, userID!, null, moduleType),
    );
  }

  static Question _transformQuestionNew(
      int screenRowIndex,
      QuestionEntity questionEntity,
      DynamicModuleCategory? dynamicModuleCategory,
      int? userID) {
    String questionID = questionEntity.questionId ?? '';
    InputType inputType = _transformInputTypeNew(
        questionEntity.inputType, questionEntity.renderAs);
    UID? uid = UID.get(questionEntity.uid);
    if (uid == UID.resume) {
      inputType = InputType.file;
    }
    Configuration configuration =
        _getConfigurationNew(questionEntity, inputType, DataType.single, uid);
    return Question(
        screenRowIndex: screenRowIndex,
        uid: uid,
        inputType: inputType,
        dataType: DataType.single,
        configuration: configuration,
        parentReference: _transformParentReference(
            null, questionID, userID, null, ModuleType.profileCompletion),
        dynamicModuleCategory: dynamicModuleCategory,
        attributeName: questionEntity.name,
        attributeUid: questionEntity.uid,
        questionSubCategory: questionEntity.questionSubCategory,
        visibilityConditions: questionEntity.visibilityConditions,
        answerUnit: AnswerUnitMapper.getAnswerUnit(
            inputType, DataType.single, questionEntity.answer, null,
            configuration: configuration, uid: uid));
  }

  static Question _transformScreenQuestion(
      int screenRowIndex,
      ScreenQuestion screenQuestion,
      int? listingId,
      int? applicationId,
      int? userID,
      ModuleType moduleType,{DynamicModuleCategory? dynamicModuleCategory}) {
    String questionID =
        screenQuestion.id != null ? screenQuestion.id.toString() : '';
    List<Question>? nestedQuestionList;
    if (screenQuestion.nestedQuestions != null) {
      nestedQuestionList = [];
      for (int i = 0; i < screenQuestion.nestedQuestions!.length; i++) {
        ScreenQuestion lScreenQuestion = screenQuestion.nestedQuestions![i];
        nestedQuestionList.add(_transformScreenQuestion(
            i, lScreenQuestion, listingId, applicationId, userID, moduleType));
      }
    }
    DataType dataType = _transformDataType(screenQuestion.dataType);
    return Question(
      questionID: screenQuestion.id,
      screenRowIndex: screenRowIndex,
      inputType: _transformInputType(screenQuestion.inputType),
      dataType: dataType,
      configuration: _getConfiguration(screenQuestion, dataType),
      parentReference: _transformParentReference(applicationId, questionID,
          userID!, screenQuestion.projectId, moduleType),
      nestedQuestionList: nestedQuestionList,
      dynamicModuleCategory: dynamicModuleCategory,
    );
  }

  static Question _transformWorklogQuestion(int screenRowIndex,
      ScreenQuestion screenQuestion, String? id, String projectId) {
    List<Question>? nestedQuestionList;
    if (screenQuestion.nestedQuestions != null) {
      nestedQuestionList = [];
      for (int i = 0; i < screenQuestion.nestedQuestions!.length; i++) {
        ScreenQuestion lScreenQuestion = screenQuestion.nestedQuestions![i];
        nestedQuestionList
            .add(_transformWorklogQuestion(i, lScreenQuestion, id, projectId));
      }
    }
    DataType dataType = _transformDataType(screenQuestion.dataType);
    return Question(
      screenRowIndex: screenRowIndex,
      inputType: _transformInputType(screenQuestion.inputType),
      dataType: dataType,
      configuration: _getConfiguration(screenQuestion, dataType),
      parentReference: LeadReference(projectId),
      nestedQuestionList: nestedQuestionList,
    );
  }

  static DataType _transformDataType(String? dataType) {
    switch (dataType) {
      case QuestionDataType.single:
        return DataType.single;
      case QuestionDataType.array:
        return DataType.array;
      case QuestionDataType.hash:
        return DataType.hash;
      default:
        return DataType.single;
    }
  }

  static InputType _transformInputType(InputTypeEntity? inputType) {
    switch (inputType) {
      case InputTypeEntity.shortText:
        return InputType.shortText;
      case InputTypeEntity.longText:
        return InputType.longText;
      case InputTypeEntity.integer:
        return InputType.number;
      case InputTypeEntity.email:
        return InputType.email;
      case InputTypeEntity.float:
        return InputType.float;
      case InputTypeEntity.url:
        return InputType.url;
      case InputTypeEntity.singleSelectDropdown:
        return InputType.singleSelectDropDown;
      case InputTypeEntity.radioButton:
      case InputTypeEntity.singleSelect:
        return InputType.singleSelect;
      case InputTypeEntity.multiSelectCheckbox:
        return InputType.multiSelect;
      case InputTypeEntity.multiSelectDropdown:
        return InputType.multiSelectDropDown;
      case InputTypeEntity.multipleSelect:
        return InputType.multiSelect;
      case InputTypeEntity.singleSelectImage:
        return InputType.singleSelectImage;
      case InputTypeEntity.multiSelectImage:
        return InputType.multiSelectImage;
      case InputTypeEntity.singleSelectDecisionButton:
        return InputType.singleSelectDecisionButton;
      case InputTypeEntity.date:
        return InputType.date;
      case InputTypeEntity.dateTime:
        return InputType.dateTime;
      case InputTypeEntity.time:
        return InputType.time;
      case InputTypeEntity.timeRange:
        return InputType.timeRange;
      case InputTypeEntity.dateRange:
        return InputType.dateRange;
      case InputTypeEntity.datetimeRange:
        return InputType.dateTimeRange;
      case InputTypeEntity.audioRecording:
        return InputType.audioRecording;
      case InputTypeEntity.image:
        return InputType.image;
      case InputTypeEntity.audio:
        return InputType.audio;
      case InputTypeEntity.video:
        return InputType.video;
      case InputTypeEntity.pdf:
        return InputType.pdf;
      case InputTypeEntity.file:
        return InputType.file;
      case InputTypeEntity.signature:
        return InputType.signature;
      case InputTypeEntity.currentLocation:
        return InputType.currentLocation;
      case InputTypeEntity.geoAddress:
        return InputType.geoAddress;
      case InputTypeEntity.nested:
        return InputType.nested;
      case InputTypeEntity.phone:
        return InputType.phone;
      case InputTypeEntity.pinCode:
        return InputType.pinCode;
      case InputTypeEntity.codeScanner:
        return InputType.codeScanner;
      default:
        return InputType.shortText;
    }
  }

  static InputType _transformInputTypeNew(
      InputTypeEntityNew? inputType, RenderAs? renderAs) {
    switch (inputType) {
      case InputTypeEntityNew.text:
        return InputType.shortText;
      case InputTypeEntityNew.singleSelect:
        switch (renderAs) {
          case RenderAs.dropDown:
            return InputType.singleSelectDropDown;
          case RenderAs.box:
            return InputType.singleSelectBox;
          case RenderAs.slider:
            return InputType.singleSelectSlider;
          default:
            return InputType.singleSelect;
        }
      case InputTypeEntityNew.multiSelect:
        switch (renderAs) {
          case RenderAs.dropDown:
            return InputType.multiSelectDropDown;
          case RenderAs.box:
            return InputType.multiSelectBox;
          case RenderAs.checkboxRight:
            return InputType.multiSelectCheckBoxRight;
          default:
            return InputType.multiSelect;
        }
      case InputTypeEntityNew.date:
        switch (renderAs) {
          case RenderAs.dateTime:
            return InputType.dateTime;
          default:
            return InputType.date;
        }
      case InputTypeEntityNew.geoAddress:
        return InputType.geoAddress;
      case InputTypeEntityNew.attachment:
        return InputType.image;
      case InputTypeEntityNew.whatsApp:
        return InputType.whatsApp;
      default:
        return InputType.shortText;
    }
  }

  /// Whenever this method will be modified, please modify getConfigurationForArrayQuestion method
  static Configuration _getConfiguration(BaseQuestion baseQuestion,DataType dataType,{ModuleType? moduleType}) {
    var questionEntity;
    if (baseQuestion is ApplicationQuestionEntity) {
      questionEntity = baseQuestion;
    } else if (baseQuestion is ScreenQuestion) {
      questionEntity = baseQuestion;
    }
    Configuration configuration = Configuration();
    InputType inputType = _transformInputType(questionEntity.inputType);
    switch (inputType.getValue1()) {
      case ConfigurationType.singleSelect:
      case ConfigurationType.multiSelect:
        configuration = SelectConfiguration(
            type: inputType.getValue1(), options: questionEntity.inputOptions);
        break;
      case ConfigurationType.text:
        configuration = TextConfiguration();
        break;
      case ConfigurationType.dateTimeRange:
      case ConfigurationType.dateTime:
        SubType? subType = _getSubType(questionEntity.inputType);
        if (subType != null) {
          configuration = DateTimeConfiguration();
          (configuration as DateTimeConfiguration).subType = subType;
        }
        break;
      case ConfigurationType.file:
        configuration = FileConfiguration();
        if (inputType == InputType.image) {
          (configuration as FileConfiguration).imageMetaData =
              questionEntity.imageMetadataType;
          configuration.overWriteMetadata = questionEntity.overWriteMetadata;
          configuration.supperImposeMetadata =
              questionEntity.superImposeMetadata;
          configuration.uploadFrom =
              _transformUploadFrom(questionEntity.uploadFromOptionEntity);
          configuration.imageSyncStatus = ImageSyncStatus();
          if (baseQuestion is ScreenQuestion) {
            configuration.isAsync = questionEntity.isAsync;
          }
        } else {
          configuration.uploadFrom = UploadFromOption.gallery;
        }
        (configuration as FileConfiguration).blockAccess =
            questionEntity.blockAccess;
        configuration.uploadLater = questionEntity.uploadLater;
        break;
      case ConfigurationType.audioRecording:
        SubType? subType = _getSubType(questionEntity.inputType);
        if (subType != null) {
          configuration = AudioConfiguration();
          (configuration as AudioConfiguration).subType = subType;
          configuration.recordingLength =
              questionEntity.maxPitchDemoLength ?? 0;
          configuration.mediaFiles =
              _transformMediaFiles(questionEntity.pitchTestMediaFiles);
        }
        break;
    }
    if(moduleType == ModuleType.eligiblityCriteria) {
        configuration.isRequired = true;
    } else {
      configuration.isRequired = questionEntity.required;
    }
    configuration.isEditable = questionEntity.editable;
    configuration.uid = questionEntity.id.toString();
    configuration.showTimer = questionEntity.showTimer ?? false;
    if (baseQuestion is ScreenQuestion) {
      configuration.uid = questionEntity.uid;
      configuration.isTimeTrackable = questionEntity.trackTimestamp ?? false;
      configuration.isLocationTrackable = questionEntity.trackLocation ?? false;
      configuration.characterFormat = questionEntity.characterFormat;
      configuration.characterLimit = questionEntity.characterLimit;
      configuration.uploadFrom =
          _transformUploadFrom(questionEntity.uploadFromOptionEntity);
    }
    configuration.questionText = questionEntity.questionText;
    configuration.attributeName = questionEntity.attributeName;
    configuration.isProfileQuestion =
        questionEntity.questionType == Constants.profileQuestion;

    if (baseQuestion is ScreenQuestion) {
      configuration.isLocationTrackable =
          questionEntity.trackGeoLocation ?? false;
      configuration.imageMetaData = questionEntity.imageMetadataType;
      configuration.isTimeTrackable = questionEntity.trackTimestamp ?? false;
    }
    configuration.questionResources = _transformQuestionResources(baseQuestion);
    return configuration;
  }

  static Configuration getConfigurationForArrayQuestion(Question question) {
    Configuration configuration = Configuration();
    InputType? inputType = question.inputType;
    switch (inputType?.getValue1()) {
      case ConfigurationType.singleSelect:
      case ConfigurationType.multiSelect:
        SelectConfiguration? selectConfiguration =
            question.configuration as SelectConfiguration?;
        configuration = SelectConfiguration(
            type: inputType?.getValue1(),
            options: selectConfiguration?.options);
        break;
      case ConfigurationType.text:
        configuration = TextConfiguration();
        break;
      case ConfigurationType.dateTimeRange:
      case ConfigurationType.dateTime:
        DateTimeConfiguration? dateTimeConfiguration =
            question.configuration as DateTimeConfiguration?;
        SubType? subType = dateTimeConfiguration?.subType;
        if (subType != null) {
          configuration = DateTimeConfiguration();
          (configuration as DateTimeConfiguration).subType = subType;
        }
        break;
      case ConfigurationType.file:
        FileConfiguration? fileConfiguration =
            question.configuration as FileConfiguration?;
        configuration = FileConfiguration();
        if (inputType == InputType.image) {
          (configuration as FileConfiguration).imageMetaData =
              fileConfiguration?.imageMetaData;
          configuration.overWriteMetadata =
              fileConfiguration?.overWriteMetadata;
          configuration.supperImposeMetadata =
              fileConfiguration?.supperImposeMetadata;
          configuration.uploadFrom = fileConfiguration?.uploadFrom;
          configuration.isAsync = fileConfiguration?.isAsync ?? false;
          configuration.imageSyncStatus = ImageSyncStatus();
        } else {
          configuration.uploadFrom = UploadFromOption.gallery;
        }
        (configuration as FileConfiguration).blockAccess =
            fileConfiguration?.blockAccess ?? false;
        configuration.uploadLater = fileConfiguration?.uploadLater ?? false;
        break;
      case ConfigurationType.audioRecording:
        AudioConfiguration? audioConfiguration =
            question.configuration as AudioConfiguration?;
        SubType? subType = audioConfiguration?.subType;
        if (subType != null) {
          configuration = AudioConfiguration();
          (configuration as AudioConfiguration).subType = subType;
          configuration.recordingLength =
              audioConfiguration?.recordingLength ?? 0;
          configuration.mediaFiles = audioConfiguration?.mediaFiles;
        }
        break;
    }
    configuration.isRequired = question.configuration?.isRequired ?? false;
    configuration.isEditable = question.configuration?.isEditable ?? true;
    configuration.uid = question.configuration?.uid;
    configuration.showTimer = question.configuration?.showTimer ?? false;
    configuration.questionText = question.configuration?.questionText;
    configuration.attributeName = question.configuration?.attributeName;
    configuration.isProfileQuestion = question.configuration?.isProfileQuestion ?? false;
    configuration.questionResources = question.configuration?.questionResources;
    return configuration;
  }

  static Configuration _getConfigurationNew(QuestionEntity questionEntity,
      InputType inputType, DataType dataType, UID? uid) {
    Configuration configuration = Configuration();
    switch (inputType.getValue1()) {
      case ConfigurationType.singleSelect:
      case ConfigurationType.multiSelect:
        configuration = SelectConfiguration(
            type: inputType.getValue1(),
            options: _getOptions(uid),
            optionEntities: questionEntity.inputOptions?.options);
        break;
      case ConfigurationType.text:
        configuration = TextConfiguration();
        break;
      case ConfigurationType.dateTimeRange:
      case ConfigurationType.dateTime:
        SubType? subType = _getSubTypeNew(questionEntity.inputType);
        if (subType != null) {
          configuration = DateTimeConfiguration();
          (configuration as DateTimeConfiguration).subType = subType;
          (configuration).dateTimeFormat = StringUtils.dateFormatYMD;
        }
        break;
      case ConfigurationType.file:
        configuration = FileConfiguration();
        if (inputType == InputType.image) {
          // (configuration as FileConfiguration).imageMetaData = questionEntity.imageMetadataType;
          // configuration.overWriteMetadata = questionEntity.overWriteMetadata;
          // configuration.supperImposeMetadata = questionEntity.superImposeMetadata;
          if (questionEntity.inputOptions != null &&
              !questionEntity.inputOptions!.imageInputOption.isNullOrEmpty) {
            configuration.uploadFrom = _transformUploadFrom(questionEntity
                .inputOptions!.imageInputOption![0].uploadFromOptionEntity);
          }
          configuration.isAsync = false;
          (configuration as FileConfiguration).imageSyncStatus =
              ImageSyncStatus();
        } else {
          configuration.uploadFrom = UploadFromOption.gallery;
        }
        // (configuration as FileConfiguration).blockAccess = questionEntity.blockAccess;
        // configuration.uploadLater = questionEntity.uploadLater;
        break;
    }
    configuration.isRequired = questionEntity.required;
    configuration.isEditable = questionEntity.editable;
    configuration.uid = questionEntity.questionId;
    configuration.questionText = questionEntity.title;
    configuration.questionNameText = questionEntity.name;
    configuration.hintText = questionEntity.hint;
    // configuration.attributeName = questionEntity.attributeName;
    // configuration.isProfileQuestion = questionEntity.questionType == Constants.profileQuestion;
    return configuration;
  }

  static dynamic _getOptions(UID? uid) {
    switch (uid) {
      case UID.yearOfPassing:
        List<String> optionList = [];
        for (int i = 1990; i <= DateTime.now().year; i++) {
          optionList.add(i.toString());
        }
        return optionList.reversed.toList();
      default:
        return null;
    }
  }

  static SubType? _getSubType(InputTypeEntity? inputTypeEntity) {
    switch (inputTypeEntity) {
      case InputTypeEntity.integer:
        return SubType.number;
      case InputTypeEntity.email:
        return SubType.email;
      case InputTypeEntity.float:
        return SubType.float;
      case InputTypeEntity.date:
      case InputTypeEntity.dateRange:
        return SubType.date;
      case InputTypeEntity.timeRange:
      case InputTypeEntity.time:
        return SubType.time;
      case InputTypeEntity.datetimeRange:
      case InputTypeEntity.dateTime:
        return SubType.dateTime;
      case InputTypeEntity.audioRecording:
        return SubType.audioRecording;
      case InputTypeEntity.singleSelectImage:
      case InputTypeEntity.multiSelectImage:
        return SubType.image;
      default:
        return null;
    }
  }

  static SubType? _getSubTypeNew(InputTypeEntityNew? inputTypeEntity) {
    switch (inputTypeEntity) {
      // case InputTypeEntityNew.text:
      //   return SubType.number;
      // case InputTypeEntityNew.email:
      //   return SubType.email;
      // case InputTypeEntityNew.float:
      //   return SubType.float;
      case InputTypeEntityNew.date:
        return SubType.date;
      // case InputTypeEntityNew.timeRange:
      // case InputTypeEntityNew.time:
      //   return SubType.time;
      // case InputTypeEntityNew.datetimeRange:
      // case InputTypeEntityNew.dateTime:
      //   return SubType.dateTime;
      // case InputTypeEntityNew.audioRecording:
      //   return SubType.audioRecording;
      // case InputTypeEntityNew.singleSelectImage:
      // case InputTypeEntityNew.multiSelectImage:
      //   return SubType.image;
      default:
        return null;
    }
  }

  static UploadFromOption _transformUploadFrom(
      UploadFromOptionEntity? uploadFromOptionEntity) {
    switch (uploadFromOptionEntity) {
      case UploadFromOptionEntity.camera:
        return UploadFromOption.camera;
      case UploadFromOptionEntity.gallery:
        return UploadFromOption.gallery;
      case UploadFromOptionEntity.both:
        return UploadFromOption.cameraAndGallery;
      default:
        return UploadFromOption.gallery;
    }
  }

  static List<MediaFile>? _transformMediaFiles(
      List<Attachment>? mediaFileEntities) {
    if (mediaFileEntities == null) {
      return null;
    }
    List<MediaFile> mediaFileList = [];
    for (Attachment attachment in mediaFileEntities) {
      mediaFileList.add(_transformMediaFile(attachment));
    }
  }

  static MediaFile _transformMediaFile(Attachment attachment) {
    return MediaFile(
        id: attachment.id,
        title: attachment.title,
        fileType: _transformMediaType(attachment.fileType),
        filePath: attachment.filePath);
  }

  static MediaFileRenderType _transformMediaType(FileType? fileType) {
    switch (fileType) {
      case FileType.image:
      case FileType.jpeg:
      case FileType.jpg:
      case FileType.png:
      case FileType.svg:
        return MediaFileRenderType.image;
      case FileType.video:
      case FileType.mp4:
      case FileType.webm:
        return MediaFileRenderType.video;
      case FileType.mp3:
      case FileType.ogg:
      case FileType.audio:
        return MediaFileRenderType.audio;
      default:
        return MediaFileRenderType.file;
    }
  }

  static ParentReference _transformParentReference(
      int? applicationID,
      String questionID,
      int? userID,
      String? projectID,
      ModuleType moduleType) {
    switch (moduleType) {
      case ModuleType.category:
        return CategoryReference(questionID, userID);
      case ModuleType.application:
        return ApplicationReference(applicationID, questionID, applicationID);
      case ModuleType.execution:
        return LeadReference(projectID);
      case ModuleType.profileCompletion:
        return PANDetailsReference(userID);
      default:
        return ApplicationReference(applicationID, questionID, applicationID);
    }
  }

  static List<Attachment>? _transformQuestionResources(BaseQuestion baseQuestion) {
    if (baseQuestion is ApplicationQuestionEntity) {
      ApplicationQuestionEntity questionEntity = baseQuestion;
      if(!questionEntity.inAppInterviewSupportMedia.isNullOrEmpty) {
        return questionEntity.inAppInterviewSupportMedia;
      } else if(!questionEntity.inAppTrainingSupportMedia.isNullOrEmpty) {
        return questionEntity.inAppTrainingSupportMedia;
      } else if(!questionEntity.pitchTestMediaFiles.isNullOrEmpty) {
        return questionEntity.pitchTestMediaFiles;
      }
    } else if (baseQuestion is ScreenQuestion) {
      return null;
    }
    return null;
  }

  static List<Question>? getNestedQuestionOfArrayQuestion(
      List<Question>? nestedQuestionList, AnswerUnit? answerUnit) {
    List<Question>? lNestedQuestionList;
    if (!nestedQuestionList.isNullOrEmpty) {
      lNestedQuestionList = [];
      for (int i = 0; i < nestedQuestionList!.length; i++) {
        // Configuration configuration =
        //     Configuration.from(nestedQuestionList[i].configuration);
        Configuration configuration =
            getConfigurationForArrayQuestion(nestedQuestionList[i]);
        configuration.questionIndex = i + 1;
        AnswerUnit? lAnswerUnit;
        if (answerUnit != null &&
            answerUnit.hashValue != null &&
            answerUnit.hashValue!.length > i) {
          lAnswerUnit = answerUnit.hashValue![i].value;
        } else {
          lAnswerUnit = AnswerUnit(
              inputType: nestedQuestionList[i].inputType,
              dateType: nestedQuestionList[i].dataType);
        }
        Question lQuestion = Question(
          screenRowIndex: i,
          inputType: nestedQuestionList[i].inputType,
          dataType: nestedQuestionList[i].dataType,
          configuration: configuration,
          parentReference: nestedQuestionList[i].parentReference,
          answerUnit: lAnswerUnit,
          nestedQuestionList: getNestedQuestionOfArrayQuestion(
              nestedQuestionList[i].nestedQuestionList, lAnswerUnit),
        );
        lNestedQuestionList.add(lQuestion);
      }
    }
    return lNestedQuestionList;
  }
}

class QuestionDataType {
  static const single = 'single';
  static const array = 'array';
  static const hash = 'hash';
}
