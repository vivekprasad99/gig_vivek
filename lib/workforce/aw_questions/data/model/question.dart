import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/parent_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/aw_questions/data/model/view_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class Question {
  String? questionID;
  late InputType? inputType;
  late DataType? dataType;
  late Configuration? configuration;
  late ParentReference? parentReference;
  late AnswerUnit? answerUnit;
  late List<Question>? nestedQuestionList;
  late ViewState? state;
  late String? currentRoute;
  int? screenRowIndex;
  int? groupQuestionIndex;
  UID? uid;
  DynamicModuleCategory? dynamicModuleCategory;
  String? attributeName;
  String? attributeUid;
  String? questionSubCategory;
  List<VisibilityCondition>? visibilityConditions;
  bool isVisible;
  late String uuid;
  String? leadID;
  String? screenID;
  String? projectID;
  String? executionID;
  String? selectedProjectRole;
  bool isDeleted;
  dynamic dynamicData;

  Question({
    this.questionID,
    this.uid,
    this.inputType,
    this.dataType,
    this.configuration,
    this.parentReference,
    this.answerUnit,
    this.nestedQuestionList,
    this.state,
    this.currentRoute,
    this.screenRowIndex,
    this.groupQuestionIndex,
    this.dynamicModuleCategory,
    this.attributeName,
    this.attributeUid,
    this.questionSubCategory,
    this.visibilityConditions,
    this.isVisible = true,
    this.leadID,
    this.screenID,
    this.projectID,
    this.executionID,
    this.selectedProjectRole,
    this.isDeleted = false,
    this.dynamicData,
  }) {
    answerUnit ??= AnswerUnit(inputType: inputType, dateType: dataType);
    uuid = DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool hasAnswered({bool isCheckImageDetails = false,Configuration? configuration}) {
    return answerUnit?.hasAnswered(isCheckImageDetails: isCheckImageDetails,configuration: configuration) ??
        false;
  }

  String? getPlaceHolderText() {
    switch (uid) {
      case UID.name:
        return 'enter_full_name'.tr;
      case UID.dateOfBirth:
        return 'enter_date_of_birth'.tr;
      case UID.languages:
        return 'select_languages'.tr;
      case UID.yearOfPassing:
        return 'select_your_passing_year'.tr;
      default:
        return null;
    }
  }

  String? getBottomSheetTitle() {
    switch (uid) {
      case UID.languages:
        return 'languages'.tr;
      default:
        return null;
    }
  }

  bool isUpperHintVisible() {
    switch (uid) {
      case UID.skillSets:
      case UID.devicesAndAssets:
      case UID.languages:
      case UID.panCard:
      case UID.drivingLicense:
        return true;
      default:
        return false;
    }
  }
}
