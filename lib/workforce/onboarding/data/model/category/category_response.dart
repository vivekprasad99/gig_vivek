import 'dart:ui';

import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/module_type.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:flutter/material.dart';

class CategoryResponse {
  CategoryResponse({
    required this.categories,
    required this.page,
    required this.limit,
    required this.total,
  });

  late List<Category>? categories;
  late int? page;
  late int? limit;
  late int? total;

  CategoryResponse.fromJson(Map<String, dynamic> json) {
    categories = json['categories'] != null
        ? List.from(json['categories'])
        .map((e) => Category.fromJson(e))
        .toList()
        : null;
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['categories'] = categories?.map((e) => e.toJson()).toList();
    _data['page'] = page;
    _data['limit'] = limit;
    _data['total'] = total;
    return _data;
  }
}

class Category {
  Category({
    required this.id,
    required this.name,
    required this.potentialEarning,
    required this.categoryType,
    // this.potentialEarningPerDay,
    // this.workHours,
    // this.duration,
      // this.informationText,
      required this.description,
      required this.rolesAndResponsibilities,
      required this.whatYouGet,
      required this.whoCanApply,
      required this.listingsCount,
      // this.logo,
      required this.icon,
      required this.createdAt,
      required this.updatedAt,
      required this.requirements,
      required this.applicationQuestions,
      required this.categoryApplication,
      this.isProceedToNext = false});

  late int? id;
  late String? name;
  late PotentialEarning? potentialEarning;
  late String? categoryType;
  late HighlightTag? highlightTag;

  // late Null potentialEarningPerDay;
  // late Null workHours;
  // late Null duration;
  // late Null informationText;
  late String? description;
  late String? rolesAndResponsibilities;
  late String? whatYouGet;
  late String? whoCanApply;
  late int? listingsCount;

  // late Null logo;
  late String? icon;
  late String? createdAt;
  late String? updatedAt;
  late String? requirements;

  late List<ApplicationQuestionEntity>? applicationQuestions;
  CategoryApplication? categoryApplication;
  late bool? isProceedToNext;

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    potentialEarning = json['potential_earning'] != null
        ? PotentialEarning.fromJson(json['potential_earning'])
        : null;
    highlightTag = json['highlight_tag'] != null
        ? HighlightTag.fromJson(json['highlight_tag'])
        : null;
    categoryType = json['category_type'];
    // potentialEarningPerDay = null;
    // workHours = null;
    // duration = null;
    // informationText = null;
    description = json['description'];
    rolesAndResponsibilities = json['roles_and_responsibilities'];
    whatYouGet = json['what_you_get'];
    whoCanApply = json['who_can_apply'];
    listingsCount = json['listings_count'];
    // logo = null;
    icon = json['icon'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    requirements = json['requirements'];
    applicationQuestions = json['application_questions'] != null
        ? List.from(json['application_questions'])
            .map((e) => ApplicationQuestionEntity.fromJson(e))
            .toList()
        : null;
  }

  Color getTagColor() {
    String? colorString = highlightTag?.colorCode;

    if (colorString != null && colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }

    if (colorString != null) {
      return Color(int.parse('FF$colorString', radix: 16));
    }

    return Colors.grey;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['potential_earning'] = potentialEarning?.toJson();
    _data['category_type'] = categoryType;
    // _data['potential_earning_per_day'] = potentialEarningPerDay;
    // _data['work_hours'] = workHours;
    // _data['duration'] = duration;
    // _data['information_text'] = informationText;
    _data['description'] = description;
    _data['roles_and_responsibilities'] = rolesAndResponsibilities;
    _data['what_you_get'] = whatYouGet;
    _data['who_can_apply'] = whoCanApply;
    _data['listings_count'] = listingsCount;
    // _data['logo'] = logo;
    _data['icon'] = icon;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['requirements'] = requirements;
    _data['application_questions'] =
        applicationQuestions?.map((e) => e.toJson()).toList();
    return _data;
  }

  List<ScreenRow> getCategoryQuestions(int? userID) {
    List<Question> categoryApplicationQuestions =
    QuestionMapper.transformApplicationQuestions(
        applicationQuestions, id, null, userID, ModuleType.category);
    int count = 1;
    List<ScreenRow> screenRowList = [];
    for (Question question in categoryApplicationQuestions) {
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

class HighlightTag {
  HighlightTag(this.colorCode, this.name);

  late String? colorCode;
  late String? name;

  HighlightTag.fromJson(Map<String, dynamic> json) {
    colorCode = json['colour_code'];
    name = json['name'];

    Map<String, dynamic> toJson() {
      final _data = <String, dynamic>{};
      _data['colour_code'] = colorCode;
      _data['name'] = name;
      return _data;
    }
  }
}

class PotentialEarning {
  PotentialEarning({
    this.earningType,
    this.from,
    this.to,
    this.earningDuration,
  });

  String? earningType;
  String? from;
  String? to;
  String? earningDuration;

  PotentialEarning.fromJson(Map<String, dynamic> json) {
    earningType = json['earning_type'];
    if (json['from'] != null) {
      from = json['from'].toString();
    } else {
      from = null;
    }
    if (json['to'] != null) {
      to = json['to'].toString();
    } else {
      to = null;
    }
    earningDuration = json['earning_duration'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['earning_type'] = earningType;
    _data['from'] = from;
    _data['to'] = to;
    _data['earning_duration'] = earningDuration;
    return _data;
  }

  String getEarningText() {
    String earningText = '';
    String duration = earningDuration!.replaceFirst("per", "/");
    String earnType = '';
    if(earningType == 'earn_upto') {
      earnType = earningType!.replaceAll("_", " ").toCapitalized();
    }else{
      earnType = earningType!;
    }
    if (!from.isNullOrEmpty && !to.isNullOrEmpty) {
      if (from == Constants.upto) {
        earningText = '$from ${Constants.rs}$to';
      } else {
        earningText = '${Constants.rs}$from - ${Constants.rs}$to';
      }
    } else if (!from.isNullOrEmpty) {
      earningText = '${earnType.toCapitalized()} ${Constants.rs}$from';
    } else if (!to.isNullOrEmpty) {
      earningText = '${earnType.toCapitalized()} ${Constants.rs}$to';
    }
    return '$earningText $duration';
  }
}

class CreateCategoryRequest {
  CreateCategoryRequest({required this.createCategoryRequestData});

  late CreateCategoryRequestData createCategoryRequestData;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['category_application'] = createCategoryRequestData.toJson();
    return _data;
  }
}

class CreateCategoryRequestData {
  CreateCategoryRequestData(this.campaignId,
      this.referralCode,
      this.workListingIds,
      this.applicationAnswers,
      this.notifyEvent);

  late String? campaignId;
  late String? referralCode;
  late List<int>? workListingIds;
  late List<ApplicationAnswerEntity>? applicationAnswers;
  late bool? notifyEvent;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    if (campaignId != null) {
      _data['campaign_id'] = campaignId;
    }
    if (referralCode != null) {
      _data['referred_by'] = referralCode;
    }
    if (workListingIds != null) {
      _data['referred_worklisting_ids'] = workListingIds;
    }
    if (applicationAnswers != null) {
      _data['application_answers'] =
          applicationAnswers?.map((e) => e.toJson()).toList();
    }
    if (notifyEvent != null) {
      _data['notify_event'] = notifyEvent;
    }
    return _data;
  }
}

// class ApplicationQuestions {
//   ApplicationQuestions({
//     required this.id,
//     // this.worklistingId,
//     required this.questionType,
//     required this.questionText,
//     required this.inputType,
//     required this.inputOptions,
//     this.correctAnswer,
//     required this.required,
//     required this.mustBeCorrect,
//     required this.status,
//     required this.sequence,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.inputStructure,
//     // this.uploadFrom,
//     required this.async,
//     // this.attributeName,
//     required this.categoryId,
//   });
//   late int? id;
//   // late Null worklistingId;
//   late String? questionType;
//   late String? questionText;
//   late String? inputType;
//   late List<String>? inputOptions;
//   late String? correctAnswer;
//   late bool required;
//   late bool mustBeCorrect;
//   late String? status;
//   late int? sequence;
//   late String? createdAt;
//   late String? updatedAt;
//   late String? inputStructure;
//   // late Null uploadFrom;
//   late bool? async;
//   // late Null attributeName;
//   late int? categoryId;
//
//   ApplicationQuestions.fromJson(Map<String, dynamic> json){
//     id = json['id'];
//     // worklistingId = null;
//     questionType = json['question_type'];
//     questionText = json['question_text'];
//     inputType = json['input_type'];
//     inputOptions = json['input_options'] != null ? List.castFrom<dynamic, String>(json['input_options']) : null;
//     correctAnswer = null;
//     required = json['required'] ?? false;
//     mustBeCorrect = json['must_be_correct'] ?? false;
//     status = json['status'];
//     sequence = json['sequence'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     inputStructure = json['input_structure'];
//     // uploadFrom = null;
//     async = json['async'] ?? false;
//     // attributeName = null;
//     categoryId = json['category_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['id'] = id;
//     // _data['worklisting_id'] = worklistingId;
//     _data['question_type'] = questionType;
//     _data['question_text'] = questionText;
//     _data['input_type'] = inputType;
//     _data['input_options'] = inputOptions;
//     _data['correct_answer'] = correctAnswer;
//     _data['required'] = required;
//     _data['must_be_correct'] = mustBeCorrect;
//     _data['status'] = status;
//     _data['sequence'] = sequence;
//     _data['created_at'] = createdAt;
//     _data['updated_at'] = updatedAt;
//     _data['input_structure'] = inputStructure;
//     // _data['upload_from'] = uploadFrom;
//     _data['async'] = async;
//     // _data['attribute_name'] = attributeName;
//     _data['category_id'] = categoryId;
//     return _data;
//   }
// }
