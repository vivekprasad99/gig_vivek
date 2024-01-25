import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/data/model/module_type.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';

const String questionUngrouped = 'ungrouped';

class ScreenType<String> extends Enum1<String> {
  const ScreenType(String val) : super(val);

  static const ScreenType start = ScreenType('start');
  static const ScreenType normal = ScreenType('normal');
  static const ScreenType end = ScreenType('end');

  static ScreenType? get(dynamic status) {
    switch (status) {
      case 'start':
        return ScreenType.start;
      case 'normal':
        return ScreenType.normal;
      case 'end':
        return ScreenType.end;
    }
    return null;
  }
}

class Screen {
  Screen({
    this.id,
    this.name,
    this.uID,
    this.isCheckPointScreen = false,
    this.screenType,
    this.next,
    this.endActions,
    this.instructions,
    this.applicationChannelId,
    this.inAppInterviewConfigId,
    this.sequence,
    this.createdAt,
    this.updatedAt,
    this.inAppInterviewQuestions,
    this.groupedQuestions,
    this.askConfirmation = false,
    this.previewEnabled = false,
    this.showPreview = false,
  });

  late String? id;
  late String? name;
  late String? uID;
  late bool isCheckPointScreen;
  late ScreenType? screenType;
  late NextScreenInformation? next;
  late List<EndAction>? endActions;
  late String? instructions;
  int? applicationChannelId;
  int? inAppInterviewConfigId;
  int? pitchTestConfigId;
  int? sequence;
  String? createdAt;
  String? updatedAt;
  List<ApplicationQuestionEntity>? inAppInterviewQuestions;
  List<ApplicationQuestionEntity>? inAppTrainingQuestions;
  List<ApplicationQuestionEntity>? automatedPitchDemoQuestions;
  List<ApplicationQuestionEntity>? pitchTestQuestions;
  Map<String, List<Question>>? groupedQuestions;

  // Lead screen's attributes
  late bool checkpoint;
  String? projectID;
  List<Group>? groups;
  List<Question>? questions;
  late bool askConfirmation;
  late bool previewEnabled;
  late bool showPreview;

  Screen.fromJson(Map<String, dynamic> json, int userID, int applicationID) {
    id = json['id']?.toString();
    uID = json['id']?.toString();
    applicationChannelId = json['application_channel_id'];
    inAppInterviewConfigId = json['in_app_interview_config_id'];
    pitchTestConfigId = json['pitch_test_config_id'];
    sequence = json['sequence'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['in_app_interview_questions'] != null) {
      inAppInterviewQuestions = <ApplicationQuestionEntity>[];
      json['in_app_interview_questions'].forEach((v) {
        inAppInterviewQuestions!.add(ApplicationQuestionEntity.fromJson(v));
      });
      groupedQuestions = <String, List<Question>>{};
      groupedQuestions?[questionUngrouped] =
          QuestionMapper.transformInAppInterviewQuestions(
              inAppInterviewQuestions,
              applicationID,
              applicationID,
              userID,
              ModuleType.application);
    }
    if (json['in_app_training_questions'] != null) {
      inAppTrainingQuestions = <ApplicationQuestionEntity>[];
      json['in_app_training_questions'].forEach((v) {
        inAppTrainingQuestions!.add(ApplicationQuestionEntity.fromJson(v));
      });
      groupedQuestions = <String, List<Question>>{};
      groupedQuestions?[questionUngrouped] =
          QuestionMapper.transformInAppTrainingQuestions(inAppTrainingQuestions,
              applicationID, applicationID, userID, ModuleType.application);
    }
    if (json['automated_pitch_demo_questions'] != null) {
      automatedPitchDemoQuestions = <ApplicationQuestionEntity>[];
      json['automated_pitch_demo_questions'].forEach((v) {
        automatedPitchDemoQuestions!.add(ApplicationQuestionEntity.fromJson(v));
      });
      groupedQuestions = <String, List<Question>>{};
      groupedQuestions?[questionUngrouped] =
          QuestionMapper.transformPitchDemoQuestions(
              automatedPitchDemoQuestions,
              applicationID,
              applicationID,
              userID,
              ModuleType.application);
    }
    if (json['pitch_test_questions'] != null) {
      pitchTestQuestions = <ApplicationQuestionEntity>[];
      json['pitch_test_questions'].forEach((v) {
        pitchTestQuestions!.add(ApplicationQuestionEntity.fromJson(v));
      });
      groupedQuestions = <String, List<Question>>{};
      groupedQuestions?[questionUngrouped] =
          QuestionMapper.transformPitchTestQuestions(pitchTestQuestions,
              applicationID, applicationID, userID, ModuleType.application);
    }
    // Lead screen's attributes
    id ??= json['_id']?.toString();
    name = json['name']?.toString();
    uID ??= json['uid']?.toString();
    if (json['_screen_type'] != null) {
      screenType = ScreenType.get(json['_screen_type']);
    } else {
      screenType = ScreenType.normal;
    }
    checkpoint = json['checkpoint'] ?? false;
    projectID = json['project_id'];
    if (json['groups'] != null) {
      groups = <Group>[];
      json['groups'].forEach((v) {
        groups!.add(Group.fromJson(v));
      });
    }
    if (json['grouped_questions'] != null) {
      Map<String, dynamic> lGroupedQuestions = json['grouped_questions'];
      Map<String, List<ScreenQuestion>> groupedScreenQuestions =
          <String, List<ScreenQuestion>>{};
      lGroupedQuestions.forEach((key, value) {
        List<dynamic> list = value;
        List<ScreenQuestion> screenQuestionList = [];
        for (var element in list) {
          screenQuestionList.add(ScreenQuestion.fromJson(element));
        }
        groupedScreenQuestions[key] = screenQuestionList;
      });
      groupedQuestions = <String, List<Question>>{};
      groupedScreenQuestions.forEach((key, value) {
        groupedQuestions?[key] = QuestionMapper.transformScreenQuestions(
            value, applicationID, applicationID, userID, ModuleType.execution);
      });
    }
    if (json['questions'] != null) {
      List<ApplicationQuestionEntity> applicationQuestionList = [];
      for (var element in (json['questions'] as List<dynamic>)) {
        applicationQuestionList
            .add(ApplicationQuestionEntity.fromJson(element));
      }
      questions = QuestionMapper.transformApplicationQuestions(
          applicationQuestionList,
          applicationID,
          applicationID,
          userID,
          ModuleType.application);
    }
    next = json['next'] != null
        ? NextScreenInformation.fromJson(json['next'])
        : null;
    next ??= NextScreenInformation(hasNextScreen: !isEmptyNextScreen(next));
    askConfirmation = json['ask_confirmation'] ?? false;
    if (json['end_actions'] != null) {
      endActions = <EndAction>[];
      json['end_actions'].forEach((v) {
        endActions!.add(EndAction.fromJson(v));
      });
    }
    previewEnabled = json['preview_enabled'] ?? false;
    showPreview = json['show_preview'] ?? false;
  }

  bool isEmptyNextScreen(NextScreenInformation? nextScreenInformation) {
    if (nextScreenInformation == null) {
      return true;
    } else {
      return isEmptyConditionOrScreenUID(nextScreenInformation.condition) &&
          isEmptyConditionOrScreenUID(nextScreenInformation.screenUid);
    }
  }

  bool isEmptyConditionOrScreenUID(dynamic any) {
    if (any == null) {
      return true;
    } else if (any is List<dynamic>) {
      return any.isEmpty;
    } else {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['application_channel_id'] = applicationChannelId;
    data['in_app_interview_config_id'] = inAppInterviewConfigId;
    data['sequence'] = sequence;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (inAppInterviewQuestions != null) {
      data['in_app_interview_questions'] =
          inAppInterviewQuestions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NextScreenInformation {
  String? type;
  dynamic condition;
  String? screenUid;
  late bool hasNextScreen;

  NextScreenInformation(
      {this.hasNextScreen = false, this.type, this.condition, this.screenUid});

  NextScreenInformation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    condition = json['condition'];
    screenUid = json['screen_uid'];
    hasNextScreen = true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['condition'] = condition;
    data['screen_uid'] = screenUid;
    return data;
  }
}

class EndAction {
  String? status;
  String? action;

  EndAction({this.status, this.action});

  EndAction.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    action = json['action'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['action'] = action;
    return data;
  }
}

class ScreenResponse {
  List<Screen>? screens;
  int? offset;
  int? total;

  ScreenResponse({this.screens, this.offset, this.total});

  ScreenResponse.fromJson(
      Map<String, dynamic> json, int userID, int applicationID) {
    if (json['screens'] != null) {
      screens = <Screen>[];
      json['screens'].forEach((v) {
        screens!.add(Screen.fromJson(v, userID, applicationID));
      });
    }
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (screens != null) {
      data['screens'] = screens!.map((v) => v.toJson()).toList();
    }
    data['offset'] = offset;
    data['total'] = total;
    return data;
  }
}

class Group {
  String? name;
  String? uid;

  Group({this.name, this.uid});

  Group.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['uid'] = uid;
    return data;
  }
}

class ScreenQuestion extends BaseQuestion {
  String? uid;
  String? questionText;
  String? attributeType;
  String? renderType;
  String? dataType;
  late bool editable;
  late bool required;
  String? group;
  List<ScreenQuestion>? nestedQuestions;
  String? id;
  String? status;
  String? dateValidation;
  String? strInputType;
  InputTypeEntity? inputType;
  bool? deleted;
  String? columnTitle;
  List<String>? inputOptions;
  bool? filterable;
  late bool blockAccess;
  bool? searchable;
  String? projectId;
  bool? bExtractable;
  bool? leadIdentifier;
  bool? uploadLater;
  bool? trackLocation;
  bool? trackTimestamp;
  bool? trackGeoLocation;
  String? updatedAt;
  String? createdAt;
  int? version;
  int? originalPosition;
  String? action;
  String? hintText;
  dynamic answerValue;
  Map<String, dynamic>? valueMetadata;
  late UploadFromOptionEntity? uploadFromOptionEntity;
  bool? isAsync;
  bool? showTimer;
  String? imageMetadataType;
  late List<String>? overWriteMetadata;
  late List<String>? superImposeMetadata;
  String? dateTimeFormat;
  late String? attributeName;
  late String? questionType;
  late String? characterFormat;
  late int? characterLimit;

  ScreenQuestion(
      {this.uid,
      this.questionText,
      this.attributeType,
      this.renderType,
      this.dataType,
      this.editable = true,
      this.required = false,
      this.group,
      this.nestedQuestions,
      this.id,
      this.status,
      this.dateValidation,
      this.strInputType,
      this.inputType,
      this.deleted,
      this.columnTitle,
      this.inputOptions,
      this.filterable,
      this.blockAccess = false,
      this.searchable,
      this.projectId,
      this.bExtractable,
      this.leadIdentifier,
      this.uploadLater,
      this.trackLocation,
      this.trackTimestamp,
      this.trackGeoLocation,
      this.updatedAt,
      this.createdAt,
      this.version,
      this.originalPosition,
      this.action,
      this.hintText,
      this.answerValue,
      this.valueMetadata,
      this.uploadFromOptionEntity,
      this.isAsync,
      this.imageMetadataType,
      this.overWriteMetadata,
      this.superImposeMetadata,
      this.dateTimeFormat,
      this.attributeName,
      this.characterFormat,
      this.characterLimit});

  ScreenQuestion.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    questionText = json['question_text'] ?? json['column_title'];
    attributeType = json['attribute_type'];
    renderType = json['render_type'];
    dataType = json['data_type'];
    editable = json['editable'] ?? true;
    required = json['required'] ?? false;
    group = json['group'];
    if (json['nested_questions'] != null) {
      nestedQuestions = <ScreenQuestion>[];
      json['nested_questions'].forEach((v) {
        nestedQuestions!.add(ScreenQuestion.fromJson(v));
      });
    }
    id = json['_id'];
    status = json['_status'];
    dateValidation = json['date_validation'];
    strInputType = json['input_type'];
    inputType = InputTypeEntity.get(json['render_type']);
    deleted = json['deleted'];
    columnTitle = json['column_title'];
    inputOptions = json['input_options']?.cast<String>();
    filterable = json['filterable'];
    blockAccess = json['block_access'] ?? false;
    searchable = json['searchable'];
    projectId = json['project_id'];
    bExtractable = json['_extractable'];
    leadIdentifier = json['lead_identifier'];
    uploadLater = json['upload_later'] ?? false;
    trackLocation = json['track_location'];
    trackTimestamp = json['track_timestamp'];
    trackGeoLocation = json['track_geo_location'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    version = json['version'];
    originalPosition = json['original_position'];
    action = json['action'];
    hintText = json['hint_text'];
    answerValue = json['value'];
    valueMetadata = json['value_metadata'];
    switch (json['upload_from']) {
      case 'camera':
        uploadFromOptionEntity = UploadFromOptionEntity.camera;
        break;
      case 'gallery':
        uploadFromOptionEntity = UploadFromOptionEntity.gallery;
        break;
      case 'both':
        uploadFromOptionEntity = UploadFromOptionEntity.both;
        break;
      default:
        uploadFromOptionEntity = null;
    }
    isAsync = json['is_async'] ?? false;
    imageMetadataType = json['image_metadata_type'];
    overWriteMetadata = json['overwrite_metadata'] != null
        ? List.castFrom<dynamic, String>(json['overwrite_metadata'])
        : null;
    superImposeMetadata = json['superimpose_metadata'] != null
        ? List.castFrom<dynamic, String>(json['superimpose_metadata'])
        : null;
    dateTimeFormat = json['date_time_format'];
    attributeName = json['attribute_name'];
    questionType = json['question_type'];
    characterFormat = json['character_format'];
    characterLimit = json['character_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['question_text'] = questionText;
    data['attribute_type'] = attributeType;
    data['render_type'] = renderType;
    data['data_type'] = dataType;
    data['editable'] = editable;
    data['required'] = required;
    data['group'] = group;
    data['_id'] = id;
    data['_status'] = status;
    data['date_validation'] = dateValidation;
    data['input_type'] = strInputType;
    // data['render_type'] = InputTypeEntity.getStringValue(inputType);
    data['deleted'] = deleted;
    data['column_title'] = columnTitle;
    data['input_options'] = inputOptions;
    data['filterable'] = filterable;
    data['block_access'] = blockAccess;
    data['searchable'] = searchable;
    data['project_id'] = projectId;
    data['_extractable'] = bExtractable;
    data['lead_identifier'] = leadIdentifier;
    data['upload_later'] = uploadLater;
    data['track_location'] = trackLocation;
    data['track_timestamp'] = trackTimestamp;
    data['track_geo_location'] = trackGeoLocation;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['version'] = version;
    data['original_position'] = originalPosition;
    data['action'] = action;
    data['question_type'] = questionType;
    data['character_format'] = characterFormat;
    data['character_limit'] = characterLimit;
    return data;
  }
}
