import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_screen.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type_entity_new.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_as.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class QuestionAnswersResponse {
  CategoryDetails? categoryDetails;
  ScreenDetails? screenDetails;
  List<QuestionEntity>? questions;
  List<SectionDetails>? sectionDetailsList;
  SectionDetailsQuestions? personalDetails;
  SectionDetailsQuestions? professionalDetails;
  SectionDetailsQuestions? educationalDetails;
  SectionDetailsQuestions? preference;
  SectionDetailsQuestions? skills;
  SectionDetailsQuestions? documents;
  List<SectionDetailsQuestions>? sectionDetailsQuestionsList;

  QuestionAnswersResponse(
      {this.categoryDetails, this.screenDetails, this.questions});

  QuestionAnswersResponse.fromJson(Map<String, dynamic> json, int? userID) {
    categoryDetails = json['category_details'] != null
        ? CategoryDetails.fromJson(json['category_details'])
        : null;
    screenDetails = json['screen_details'] != null
        ? ScreenDetails.fromJson(json['screen_details'])
        : null;
    if (json['questions'] != null) {
      questions = <QuestionEntity>[];
      json['questions'].forEach((v) {
        questions!.add(QuestionEntity.fromJson(v));
      });
    }
    if (json['section_details'] != null) {
      sectionDetailsList = <SectionDetails>[];
      json['section_details'].forEach((v) {
        sectionDetailsList!.add(SectionDetails.fromJson(v));
      });
    }
    personalDetails = json['personal_details'] != null
        ? SectionDetailsQuestions.fromJson(json['personal_details'],
            getSectionTitle('personal_details'), this, userID)
        : null;
    sectionDetailsQuestionsList ??= [];
    if (personalDetails != null && !personalDetails!.questions.isNullOrEmpty) {
      sectionDetailsQuestionsList!.add(personalDetails!);
      updateRequiredQuestionAvailableInSectionDetailsList(personalDetails!);
    }
    professionalDetails = json['professional_details'] != null
        ? SectionDetailsQuestions.fromJson(json['professional_details'],
            getSectionTitle('professional_details'), this, userID,
            isProfessionalDetailsSection: true)
        : null;
    if (professionalDetails != null &&
        !professionalDetails!.questions.isNullOrEmpty) {
      sectionDetailsQuestionsList!.add(professionalDetails!);
      updateRequiredQuestionAvailableInSectionDetailsList(professionalDetails!);
    }
    educationalDetails = json['educational_details'] != null
        ? SectionDetailsQuestions.fromJson(json['educational_details'],
            getSectionTitle('educational_details'), this, userID)
        : null;
    if (educationalDetails != null &&
        !educationalDetails!.questions.isNullOrEmpty) {
      sectionDetailsQuestionsList!.add(educationalDetails!);
      updateRequiredQuestionAvailableInSectionDetailsList(educationalDetails!);
    }
    preference = json['preference'] != null
        ? SectionDetailsQuestions.fromJson(
            json['preference'], getSectionTitle('preference'), this, userID)
        : null;
    if (preference != null && !preference!.questions.isNullOrEmpty) {
      sectionDetailsQuestionsList!.add(preference!);
      updateRequiredQuestionAvailableInSectionDetailsList(preference!);
    }
    skills = json['skills'] != null
        ? SectionDetailsQuestions.fromJson(
            json['skills'], getSectionTitle('skills'), this, userID)
        : null;
    if (skills != null && !skills!.questions.isNullOrEmpty) {
      sectionDetailsQuestionsList!.add(skills!);
      updateRequiredQuestionAvailableInSectionDetailsList(skills!);
    }
    documents = json['documents'] != null
        ? SectionDetailsQuestions.fromJson(
            json['documents'], getSectionTitle('documents'), this, userID)
        : null;
    if (documents != null && !documents!.questions.isNullOrEmpty) {
      sectionDetailsQuestionsList!.add(documents!);
      updateRequiredQuestionAvailableInSectionDetailsList(documents!);
    }
  }

  String? getSectionTitle(String uid) {
    String? title;
    if (!sectionDetailsList.isNullOrEmpty) {
      for (int i = 0; i < sectionDetailsList!.length; i++) {
        if (sectionDetailsList![i].uid == uid) {
          title = sectionDetailsList![i].title;
          break;
        }
      }
    }
    return title;
  }

  void updateRequiredQuestionAvailableInSectionDetailsList(
      SectionDetailsQuestions sectionDetailsQuestions) {
    if (!sectionDetailsList.isNullOrEmpty) {
      List<SectionDetails> tempList = [];
      tempList.addAll(sectionDetailsList!);
      for (int i = 0; i < sectionDetailsList!.length; i++) {
        if (sectionDetailsList![i].title == sectionDetailsQuestions.title) {
          tempList[i].isRequired =
              sectionDetailsQuestions.isRequiredQuestionAvailable();
          break;
        }
      }
      sectionDetailsList = tempList;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (categoryDetails != null) {
      data['category_details'] = categoryDetails!.toJson();
    }
    if (screenDetails != null) {
      data['screen_details'] = screenDetails!.toJson();
    }
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    if (sectionDetailsList != null) {
      data['section_details'] =
          sectionDetailsList!.map((v) => v.toJson()).toList();
    }
    if (personalDetails != null) {
      data['personal_details'] = personalDetails!.toJson();
    }
    if (professionalDetails != null) {
      data['professional_details'] = professionalDetails!.toJson();
    }
    if (educationalDetails != null) {
      data['educational_details'] = educationalDetails!.toJson();
    }
    if (preference != null) {
      data['preference'] = preference!.toJson();
    }
    if (skills != null) {
      data['skills'] = skills!.toJson();
    }
    if (documents != null) {
      data['documents'] = documents!.toJson();
    }
    return data;
  }

  List<ScreenRow> getScreenQuestions(List<QuestionEntity>? questions,
      DynamicModuleCategory dynamicModuleCategory, int? userID) {
    List<Question> questionList = QuestionMapper.transformQuestionsNew(
        questions, dynamicModuleCategory, userID);
    int count = 1;
    List<ScreenRow> screenRowList = [];
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
    return screenRowList;
  }
}

class CategoryDetails {
  String? title;
  DynamicModuleCategory? uid;
  int? screenCount;

  CategoryDetails({this.title, this.uid, this.screenCount});

  CategoryDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    uid = DynamicModuleCategory.get(json['uid']);
    screenCount = json['screen_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['uid'] = uid?.value;
    data['screen_count'] = screenCount;
    return data;
  }
}

class ScreenDetails {
  String? title;
  DynamicScreen? uid;
  int? screenOrder;
  String? description;
  int? sectionCount;

  ScreenDetails(
      {this.title,
      this.uid,
      this.screenOrder,
      this.description,
      this.sectionCount});

  ScreenDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    uid = DynamicScreen.get(json['uid']);
    screenOrder = json['screen_order'];
    description = json['description'];
    sectionCount = json['section_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['uid'] = uid?.value;
    data['screen_order'] = screenOrder;
    data['description'] = description;
    data['section_count'] = sectionCount;
    return data;
  }
}

class QuestionEntity extends BaseQuestion {
  String? title;
  String? uid;
  String? name;
  String? questionId;
  String? questionSubCategory;
  late bool editable;
  late bool required;
  String? hint;
  InputTypeEntityNew? inputType;
  String? questionType;
  RenderAs? renderAs;
  String? sequence;
  InputOption? inputOptions;
  dynamic answer;
  List<VisibilityCondition>? visibilityConditions;

  QuestionEntity(
      {this.title,
      this.uid,
      this.name,
      this.questionId,
      this.questionSubCategory,
      this.editable = true,
      this.required = false,
      this.hint,
      this.inputType,
      this.questionType,
      this.renderAs,
      this.sequence,
      this.inputOptions,
      this.answer,
      this.visibilityConditions});

  QuestionEntity.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    uid = json['uid'];
    name = json['name'];
    questionId = json['question_id'];
    questionSubCategory = json['question_sub_category'];
    editable = json['editable'] ?? true;
    required = json['required'] ?? false;
    hint = json['hint'];
    inputType = InputTypeEntityNew.get(json['input_type']);
    questionType = json['question_type'];
    renderAs = RenderAs.get(json['render_as']);
    sequence = json['sequence'];
    inputOptions = json['input_options'] != null
        ? InputOption.fromJson(json['input_options'])
        : null;
    answer = json['answer'];
    if (json['visibility_conditions'] != null) {
      visibilityConditions = <VisibilityCondition>[];
      json['visibility_conditions'].forEach((v) {
        visibilityConditions!.add(VisibilityCondition.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['uid'] = uid;
    data['name'] = name;
    data['question_id'] = questionId;
    data['question_sub_category'] = questionSubCategory;
    data['editable'] = editable;
    data['required'] = required;
    data['hint'] = hint;
    data['input_type'] = inputType?.value;
    data['question_type'] = questionType;
    data['render_as'] = renderAs?.value;
    data['sequence'] = sequence;
    if (inputOptions != null) {
      data['input_options'] = inputOptions!.toJson();
    }
    data['answer'] = answer;
    if (visibilityConditions != null) {
      data['visibility_conditions'] =
          visibilityConditions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InputOption {
  List<Option>? options;
  List<ImageInputOption>? imageInputOption;
  InputOption({this.options});

  InputOption.fromJson(Map<String, dynamic> json) {
    if (json['options'] != null) {
      options = <Option>[];
      int index = 0;
      json['options'].forEach((v) {
        options!.add(Option.fromJson(v, index));
        index++;
      });
    }
    if (json['image_input_option'] != null) {
      imageInputOption = <ImageInputOption>[];
      json['image_input_option'].forEach((v) {
        imageInputOption!.add(ImageInputOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageInputOption {
  UploadFromOptionEntity? uploadFromOptionEntity;

  ImageInputOption({this.uploadFromOptionEntity});

  ImageInputOption.fromJson(Map<String, dynamic> json) {
    uploadFromOptionEntity = UploadFromOptionEntity.get(json['upload_from']);
  }
}

class VisibilityCondition {
  String? questionUid;
  List<String>? answerUids;

  VisibilityCondition({this.questionUid, this.answerUids});

  VisibilityCondition.fromJson(Map<String, dynamic> json) {
    questionUid = json['question_uid'];
    answerUids = json['answer_uids'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question_uid'] = questionUid;
    data['answer_uids'] = answerUids;
    return data;
  }
}

class SectionDetails {
  String? title;
  String? uid;
  int? sectionOrder;
  late bool isSelected;
  late bool isRequired;

  SectionDetails(
      {this.title,
      this.uid,
      this.sectionOrder,
      this.isSelected = false,
      this.isRequired = false});

  SectionDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    uid = json['uid'];
    sectionOrder = json['section_order'];
    isSelected = false;
    isRequired = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['uid'] = uid;
    data['section_order'] = sectionOrder;
    return data;
  }
}

class SectionDetailsQuestions {
  List<QuestionEntity>? questions;
  String? title;
  List<ScreenRow>? screenRowList;

  SectionDetailsQuestions({this.questions});

  SectionDetailsQuestions.fromJson(
      Map<String, dynamic> json,
      String? sectionTitle,
      QuestionAnswersResponse questionAnswersResponse,
      int? userID,
      {bool isProfessionalDetailsSection = false}) {
    if (json['questions'] != null) {
      questions = <QuestionEntity>[];
      json['questions'].forEach((v) {
        questions!.add(QuestionEntity.fromJson(v));
      });
    }
    if (questions != null) {
      if (isProfessionalDetailsSection) {
        questions?.add(QuestionEntity(
            title: 'whats_app_notification'.tr,
            uid: UID.whatsapp.value,
            name: 'whats_app_notification'.tr,
            questionSubCategory: 'profile_data',
            inputType: InputTypeEntityNew.whatsApp,
            editable: false));
      }
      screenRowList = questionAnswersResponse.getScreenQuestions(
          questions, DynamicModuleCategory.profileCompletion, userID);
    }
    title = sectionTitle;
  }

  bool isRequiredQuestionAvailable() {
    bool isRequired = false;
    for (int i = 0; i < (screenRowList?.length ?? 0); i++) {
      Question? question = screenRowList![i].question;
      bool isVisible = true;
      if (question != null && !question.visibilityConditions.isNullOrEmpty) {
        isVisible = question.isVisible;
      }
      if ((question?.configuration?.isRequired ?? false) &&
          !(question?.hasAnswered() ?? false) &&
          isVisible) {
        isRequired = true;
        break;
      }
    }
    return isRequired;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
