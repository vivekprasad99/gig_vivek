import 'dart:ui';

import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';

import '../work_application/location_type.dart';

class WorkListingResponse {
  List<Worklistings>? worklistings;
  int? total;
  int? page;
  int? limit;
  int? offset;

  WorkListingResponse(
      {this.worklistings, this.total, this.page, this.limit, this.offset});

  WorkListingResponse.fromJson(Map<String, dynamic> json) {
    if (json['worklistings'] != null) {
      worklistings = <Worklistings>[];
      json['worklistings'].forEach((v) {
        worklistings!.add(Worklistings.fromJson(v));
      });
    }
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (worklistings != null) {
      data['worklistings'] = worklistings!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['offset'] = offset;
    return data;
  }
}

class Worklistings {
  int? id;
  String? uid;
  String? name;
  String? listingType;
  String? executionType;
  String? configurationStatus;
  String? publishingStatus;
  String? urlStatus;
  String? clientName;
  PotentialEarning? potentialEarning;
  int? potentialEarningPerDay;
  // Null? startDate;
  // Null? workHours;
  Duration? duration;
  String? informationText;
  String? description;
  String? rolesAndResponsibilities;
  String? whatYouGet;
  String? whoCanApply;
  // Null? infographics;
  // Null? postApplicationMessage;
  // Null? supplyRequirementId;
  String? executionProjectId;
  String? executionProjectName;
  int? defaultApplicationChannelId;
  String? logo;
  String? icon;
  String? facebookSharingText;
  String? createdAt;
  String? updatedAt;
  List<String>? pincodes;
  List<String>? cities;
  List<String>? states;
  LocationType? locationType;
  int? monthlyVacancy;
  String? publishedAt;
  StatusMapping? statusMapping;
  String? projectExecutionSourceId;
  bool? basicDetailsConfigured;
  bool? locationConfigured;
  bool? earningsConfigured;
  bool? descriptionConfigured;
  bool? offerLetterConfigured;
  bool? basicDetailsReviewed;
  bool? locationReviewed;
  bool? earningsReviewed;
  bool? descriptionReviewed;
  bool? offerLetterReviewed;
  String? projectVertical;
  String? supplyCategory;
  List<String>? profileTags;
  String? requirements;
  String? saasOrgId;
  int? categoryId;
  String? categoryUid;
  String? orgDisplayName;
  bool? earningsVisible;
  bool? activeUsersVisible;
  bool? archivedStatus;
  DefaultApplicationChannel? defaultApplicationChannel;
  WorkApplicationEntity? workApplicationEntity;
  HighlightTag? highlightTag;

  Worklistings(
      {this.id,
      this.uid,
      this.name,
      this.listingType,
      this.executionType,
      this.configurationStatus,
      this.publishingStatus,
      this.urlStatus,
      this.clientName,
      this.potentialEarning,
      this.potentialEarningPerDay,
      // this.startDate,
      // this.workHours,
      this.duration,
      this.informationText,
      this.description,
      this.rolesAndResponsibilities,
      this.whatYouGet,
      this.whoCanApply,
      // this.infographics,
      //   this.postApplicationMessage,
      //   this.supplyRequirementId,
        this.executionProjectId,
        this.executionProjectName,
        this.defaultApplicationChannelId,
        this.logo,
        this.icon,
        this.facebookSharingText,
        this.createdAt,
        this.updatedAt,
        this.pincodes,
        this.cities,
        this.states,
        this.locationType,
        this.monthlyVacancy,
        this.publishedAt,
        this.statusMapping,
        this.projectExecutionSourceId,
        this.basicDetailsConfigured,
        this.locationConfigured,
        this.earningsConfigured,
        this.descriptionConfigured,
        this.offerLetterConfigured,
        this.basicDetailsReviewed,
        this.locationReviewed,
        this.earningsReviewed,
        this.descriptionReviewed,
        this.offerLetterReviewed,
        this.projectVertical,
        this.supplyCategory,
      this.profileTags,
      this.requirements,
      this.saasOrgId,
      this.categoryId,
      this.categoryUid,
      this.orgDisplayName,
      this.earningsVisible,
      this.activeUsersVisible,
      this.archivedStatus,
      this.defaultApplicationChannel,
      this.workApplicationEntity,
      this.highlightTag});

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


  Worklistings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    name = json['name'];
    listingType = json['listing_type'];
    executionType = json['execution_type'];
    configurationStatus = json['configuration_status'];
    publishingStatus = json['publishing_status'];
    urlStatus = json['url_status'];
    clientName = json['client_name'];
    potentialEarning = json['potential_earning'] != null
        ? PotentialEarning.fromJson(json['potential_earning'])
        : null;
    potentialEarningPerDay = json['potential_earning_per_day'];
    // startDate = json['start_date'];
    // workHours = json['work_hours'];
    duration = json['duration'] != null
        ? Duration.fromJson(json['duration'])
        : null;
    informationText = json['information_text'];
    description = json['description'];
    rolesAndResponsibilities = json['roles_and_responsibilities'];
    whatYouGet = json['what_you_get'];
    whoCanApply = json['who_can_apply'];
    // infographics = json['infographics'];
    // postApplicationMessage = json['post_application_message'];
    // supplyRequirementId = json['supply_requirement_id'];
    executionProjectId = json['execution_project_id'];
    executionProjectName = json['execution_project_name'];
    defaultApplicationChannelId = json['default_application_channel_id'];
    logo = json['logo'];
    icon = json['icon'];
    facebookSharingText = json['facebook_sharing_text'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['pincodes'] != null) {
      pincodes = <String>[];
      json['pincodes'].forEach((v) {
        pincodes!.add(v.toString());
      });
    }
    if (json['cities'] != null) {
      cities = <String>[];
      json['cities'].forEach((v) {
        cities!.add(v);
      });
    }
    if (json['states'] != null) {
      states = <String>[];
      json['states'].forEach((v) {
        states!.add(v);
      });
    }
    locationType = LocationType.getType(json['location_type']);
    monthlyVacancy = json['monthly_vacancy'];
    publishedAt = json['published_at'];
    statusMapping = json['status_mapping'] != null
        ? StatusMapping.fromJson(json['status_mapping'])
        : null;
    projectExecutionSourceId = json['project_execution_source_id'];
    basicDetailsConfigured = json['basic_details_configured'];
    locationConfigured = json['location_configured'];
    earningsConfigured = json['earnings_configured'];
    descriptionConfigured = json['description_configured'];
    offerLetterConfigured = json['offer_letter_configured'];
    basicDetailsReviewed = json['basic_details_reviewed'];
    locationReviewed = json['location_reviewed'];
    earningsReviewed = json['earnings_reviewed'];
    descriptionReviewed = json['description_reviewed'];
    offerLetterReviewed = json['offer_letter_reviewed'];
    projectVertical = json['project_vertical'];
    supplyCategory = json['supply_category'];
    if (json['profile_tags'] != null) {
      profileTags = <String>[];
      json['profile_tags'].forEach((v) {
        profileTags!.add(v);
      });
    }
    if(json['highlight_tag'] != null){
      highlightTag = json['highlight_tag'] != null
          ? HighlightTag.fromJson(json['highlight_tag'])
          : null;
    }
    requirements = json['requirements'];
    saasOrgId = json['saas_org_id'];
    categoryId = json['category_id'];
    categoryUid = json['category_uid'];
    orgDisplayName = json['org_display_name'];
    earningsVisible = json['earnings_visible'];
    activeUsersVisible = json['active_users_visible'];
    archivedStatus = json['archived_status'];
    defaultApplicationChannel = json['default_application_channel'] != null
        ?  DefaultApplicationChannel.fromJson(
        json['default_application_channel'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['uid'] = uid;
    data['name'] = name;
    data['listing_type'] = listingType;
    data['execution_type'] = executionType;
    data['configuration_status'] = configurationStatus;
    data['publishing_status'] = publishingStatus;
    data['url_status'] = urlStatus;
    data['client_name'] = clientName;
    if (potentialEarning != null) {
      data['potential_earning'] = potentialEarning!.toJson();
    }
    data['potential_earning_per_day'] = potentialEarningPerDay;
    // data['start_date'] = this.startDate;
    // data['work_hours'] = this.workHours;
    if (duration != null) {
      data['duration'] = duration!.toJson();
    }
    data['information_text'] = informationText;
    data['description'] = description;
    data['roles_and_responsibilities'] = rolesAndResponsibilities;
    data['what_you_get'] = whatYouGet;
    data['who_can_apply'] = whoCanApply;
    // data['infographics'] = this.infographics;
    // data['post_application_message'] = this.postApplicationMessage;
    // data['supply_requirement_id'] = this.supplyRequirementId;
    data['execution_project_id'] = executionProjectId;
    data['execution_project_name'] = executionProjectName;
    data['default_application_channel_id'] = defaultApplicationChannelId;
    data['logo'] = logo;
    data['icon'] = icon;
    data['facebook_sharing_text'] = facebookSharingText;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pincodes != null) {
      data['pincodes'] = pincodes!.map((v) => v).toList();
    }
    if (cities != null) {
      data['cities'] = cities!.map((v) => v).toList();
    }
    if (states != null) {
      data['states'] = states!.map((v) => v).toList();
    }
    data['location_type'] = locationType;
    data['monthly_vacancy'] = monthlyVacancy;
    data['published_at'] = publishedAt;
    if (statusMapping != null) {
      data['status_mapping'] = statusMapping!.toJson();
    }
    data['project_execution_source_id'] = projectExecutionSourceId;
    data['basic_details_configured'] = basicDetailsConfigured;
    data['location_configured'] = locationConfigured;
    data['earnings_configured'] = earningsConfigured;
    data['description_configured'] = descriptionConfigured;
    data['offer_letter_configured'] = offerLetterConfigured;
    data['basic_details_reviewed'] = basicDetailsReviewed;
    data['location_reviewed'] = locationReviewed;
    data['earnings_reviewed'] = earningsReviewed;
    data['description_reviewed'] = descriptionReviewed;
    data['offer_letter_reviewed'] = offerLetterReviewed;
    data['project_vertical'] = projectVertical;
    data['supply_category'] = supplyCategory;
    data['profile_tags'] = profileTags;
    data['requirements'] = requirements;
    data['saas_org_id'] = saasOrgId;
    data['category_id'] = categoryId;
    data['category_uid'] = categoryUid;
    data['org_display_name'] = orgDisplayName;
    data['earnings_visible'] = earningsVisible;
    data['active_users_visible'] = activeUsersVisible;
    data['archived_status'] = archivedStatus;
    if (defaultApplicationChannel != null) {
      data['default_application_channel'] =
          defaultApplicationChannel!.toJson();
    }
    if(highlightTag != null){
      data['highlight_tag'] = highlightTag!.toJson();
    }
    return data;
  }
}

class HighlightTag {
  HighlightTag(this.colorCode, this.name);

  late String? colorCode;
  late String? name;

  HighlightTag.fromJson(Map<String, dynamic> json) {
    colorCode = json['colour_code'];
    name = json['name'];
  }
    Map<String, dynamic> toJson() {
      final _data = <String, dynamic>{};
      _data['colour_code'] = colorCode;
      _data['name'] = name;
      return _data;
    }
}

class PotentialEarning {
  String? earningType;
  String? from;
  String? to;
  String? earningDuration;

  PotentialEarning(
      {this.earningType, this.from, this.to, this.earningDuration});

  PotentialEarning.fromJson(Map<String, dynamic> json) {
    earningType = json['earning_type'];
    from = json['from'];
    to = json['to'];
    earningDuration = json['earning_duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['earning_type'] = earningType;
    data['from'] = from;
    data['to'] = to;
    data['earning_duration'] = earningDuration;
    return data;
  }

  String getEarningText() {
    String earningText = '';
    String duration = earningDuration!.replaceFirst("per", "/");
    String earnType = '';
    if(earningType == 'earn_upto')
    {
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

class Duration {
  String? from;
  String? to;
  String? type;

  Duration({this.from, this.to, this.type});

  Duration.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['from'] = from;
    data['to'] = to;
    data['type'] = type;
    return data;
  }
}

class StatusMapping {
  InAppInterview? inAppInterview;

  StatusMapping({this.inAppInterview});

  StatusMapping.fromJson(Map<String, dynamic> json) {
    inAppInterview = json['in_app_interview'] != null
        ? InAppInterview.fromJson(json['in_app_interview'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (inAppInterview != null) {
      data['in_app_interview'] = inAppInterview!.toJson();
    }
    return data;
  }
}

class InAppInterview {
  List<String>? pending;
  List<String>? started;
  List<String>? passed;
  List<String>? failed;

  InAppInterview({this.pending, this.started, this.passed, this.failed});

  InAppInterview.fromJson(Map<String, dynamic> json) {
    pending = json['pending'].cast<String>();
    started = json['started'].cast<String>();
    passed = json['passed'].cast<String>();
    failed = json['failed']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['pending'] = pending;
    data['started'] = started;
    data['passed'] = passed;
    data['failed'] = failed;
    return data;
  }
}

class DefaultApplicationChannel {
  int? id;
  int? worklistingId;
  String? name;
  bool? inAppInterviewRequired;
  bool? inAppInterviewMandatory;
  bool? telephonicInterviewRequired;
  bool? telephonicInterviewMandatory;
  bool? inAppTrainingRequired;
  bool? inAppTrainingMandatory;
  bool? webinarTrainingRequired;
  bool? webinarTrainingMandatory;
  bool? pitchDemoRequired;
  bool? pitchDemoMandatory;
  String? pitchDemoType;
  bool? pitchTestRequired;
  bool? pitchTestMandatory;
  bool? sampleLeadTestRequired;
  bool? sampleLeadTestMandatory;
  String? status;
  String? jdAttachmentPath;
  String? loiAttachmentPath;
  String? cities;
  String? waitlistSteps;
  String? waitlistConditions;
  String? waitlistMessage;
  String? createdAt;
  String? updatedAt;
  bool? inAppInterviewConfigured;
  bool? inAppInterviewReviewed;
  bool? telephonicInterviewConfigured;
  bool? telephonicInterviewReviewed;
  bool? inAppTrainingConfigured;
  bool? inAppTrainingReviewed;
  bool? webinarTrainingConfigured;
  bool? webinarTrainingReviewed;
  bool? pitchDemoConfigured;
  bool? pitchDemoReviewed;
  bool? pitchTestConfigured;
  bool? pitchTestReviewed;
  bool? sampleLeadTestConfigured;
  bool? sampleLeadTestReviewed;
  bool? applicationQuestionConfigured;
  bool? applicationQuestionReviewed;
  bool? locationDependent;
  int? allowedReapplyCount;

  DefaultApplicationChannel(
      {this.id,
        this.worklistingId,
        this.name,
        this.inAppInterviewRequired,
        this.inAppInterviewMandatory,
        this.telephonicInterviewRequired,
        this.telephonicInterviewMandatory,
        this.inAppTrainingRequired,
        this.inAppTrainingMandatory,
        this.webinarTrainingRequired,
        this.webinarTrainingMandatory,
        this.pitchDemoRequired,
        this.pitchDemoMandatory,
        this.pitchDemoType,
        this.pitchTestRequired,
        this.pitchTestMandatory,
        this.sampleLeadTestRequired,
        this.sampleLeadTestMandatory,
        this.status,
        this.jdAttachmentPath,
        this.loiAttachmentPath,
        this.cities,
        this.waitlistSteps,
        this.waitlistConditions,
        this.waitlistMessage,
        this.createdAt,
        this.updatedAt,
        this.inAppInterviewConfigured,
        this.inAppInterviewReviewed,
        this.telephonicInterviewConfigured,
        this.telephonicInterviewReviewed,
        this.inAppTrainingConfigured,
        this.inAppTrainingReviewed,
        this.webinarTrainingConfigured,
        this.webinarTrainingReviewed,
        this.pitchDemoConfigured,
        this.pitchDemoReviewed,
        this.pitchTestConfigured,
        this.pitchTestReviewed,
        this.sampleLeadTestConfigured,
        this.sampleLeadTestReviewed,
        this.applicationQuestionConfigured,
        this.applicationQuestionReviewed,
        this.locationDependent,
        this.allowedReapplyCount});

  DefaultApplicationChannel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    worklistingId = json['worklisting_id'];
    name = json['name'];
    inAppInterviewRequired = json['in_app_interview_required'];
    inAppInterviewMandatory = json['in_app_interview_mandatory'];
    telephonicInterviewRequired = json['telephonic_interview_required'];
    telephonicInterviewMandatory = json['telephonic_interview_mandatory'];
    inAppTrainingRequired = json['in_app_training_required'];
    inAppTrainingMandatory = json['in_app_training_mandatory'];
    webinarTrainingRequired = json['webinar_training_required'];
    webinarTrainingMandatory = json['webinar_training_mandatory'];
    pitchDemoRequired = json['pitch_demo_required'];
    pitchDemoMandatory = json['pitch_demo_mandatory'];
    pitchDemoType = json['pitch_demo_type'] ?? '';
    pitchTestRequired = json['pitch_test_required'];
    pitchTestMandatory = json['pitch_test_mandatory'];
    sampleLeadTestRequired = json['sample_lead_test_required'];
    sampleLeadTestMandatory = json['sample_lead_test_mandatory'];
    status = json['status'];
    jdAttachmentPath = json['jd_attachment_path'];
    loiAttachmentPath = json['loi_attachment_path'];
    cities = json['cities'];
    waitlistSteps = json['waitlist_steps'];
    waitlistConditions = json['waitlist_conditions'];
    waitlistMessage = json['waitlist_message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    inAppInterviewConfigured = json['in_app_interview_configured'];
    inAppInterviewReviewed = json['in_app_interview_reviewed'];
    telephonicInterviewConfigured = json['telephonic_interview_configured'];
    telephonicInterviewReviewed = json['telephonic_interview_reviewed'];
    inAppTrainingConfigured = json['in_app_training_configured'];
    inAppTrainingReviewed = json['in_app_training_reviewed'];
    webinarTrainingConfigured = json['webinar_training_configured'];
    webinarTrainingReviewed = json['webinar_training_reviewed'];
    pitchDemoConfigured = json['pitch_demo_configured'];
    pitchDemoReviewed = json['pitch_demo_reviewed'];
    pitchTestConfigured = json['pitch_test_configured'];
    pitchTestReviewed = json['pitch_test_reviewed'];
    sampleLeadTestConfigured = json['sample_lead_test_configured'];
    sampleLeadTestReviewed = json['sample_lead_test_reviewed'];
    applicationQuestionConfigured = json['application_question_configured'];
    applicationQuestionReviewed = json['application_question_reviewed'];
    locationDependent = json['location_dependent'];
    allowedReapplyCount = json['allowed_reapply_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['worklisting_id'] = worklistingId;
    data['name'] = name;
    data['in_app_interview_required'] = inAppInterviewRequired;
    data['in_app_interview_mandatory'] = inAppInterviewMandatory;
    data['telephonic_interview_required'] = telephonicInterviewRequired;
    data['telephonic_interview_mandatory'] = telephonicInterviewMandatory;
    data['in_app_training_required'] = inAppTrainingRequired;
    data['in_app_training_mandatory'] = inAppTrainingMandatory;
    data['webinar_training_required'] = webinarTrainingRequired;
    data['webinar_training_mandatory'] = webinarTrainingMandatory;
    data['pitch_demo_required'] = pitchDemoRequired;
    data['pitch_demo_mandatory'] = pitchDemoMandatory;
    data['pitch_demo_type'] = pitchDemoType;
    data['pitch_test_required'] = pitchTestRequired;
    data['pitch_test_mandatory'] = pitchTestMandatory;
    data['sample_lead_test_required'] = sampleLeadTestRequired;
    data['sample_lead_test_mandatory'] = sampleLeadTestMandatory;
    data['status'] = status;
    data['jd_attachment_path'] = jdAttachmentPath;
    data['loi_attachment_path'] = loiAttachmentPath;
    data['cities'] = cities;
    data['waitlist_steps'] = waitlistSteps;
    data['waitlist_conditions'] = waitlistConditions;
    data['waitlist_message'] = waitlistMessage;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['in_app_interview_configured'] = inAppInterviewConfigured;
    data['in_app_interview_reviewed'] = inAppInterviewReviewed;
    data['telephonic_interview_configured'] =
        telephonicInterviewConfigured;
    data['telephonic_interview_reviewed'] = telephonicInterviewReviewed;
    data['in_app_training_configured'] = inAppTrainingConfigured;
    data['in_app_training_reviewed'] = inAppTrainingReviewed;
    data['webinar_training_configured'] = webinarTrainingConfigured;
    data['webinar_training_reviewed'] = webinarTrainingReviewed;
    data['pitch_demo_configured'] = pitchDemoConfigured;
    data['pitch_demo_reviewed'] = pitchDemoReviewed;
    data['pitch_test_configured'] = pitchTestConfigured;
    data['pitch_test_reviewed'] = pitchTestReviewed;
    data['sample_lead_test_configured'] = sampleLeadTestConfigured;
    data['sample_lead_test_reviewed'] = sampleLeadTestReviewed;
    data['application_question_configured'] =
        applicationQuestionConfigured;
    data['application_question_reviewed'] = applicationQuestionReviewed;
    data['location_dependent'] = locationDependent;
    data['allowed_reapply_count'] = allowedReapplyCount;
    return data;
  }
}
