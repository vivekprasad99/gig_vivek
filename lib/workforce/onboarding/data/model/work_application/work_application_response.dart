import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/onboarding/data/mapper/application_details_section_provider.dart';
import 'package:awign/workforce/onboarding/data/mapper/application_tile_section_provider.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_interview.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_training.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_demo.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_test.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/section_type.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/telephonic_interview_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/webinar_training.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_pending_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

class WorkApplicationResponse {
  WorkApplicationResponse({
    required this.workApplicationList,
    required this.total,
  });

  late List<WorkApplicationEntity>? workApplicationList;
  late int? total;

  WorkApplicationResponse.fromJson(Map<String, dynamic> json) {
    workApplicationList = json['applications'] != null
        ? List.from(json['applications'])
            .map((e) => WorkApplicationEntity.fromJson(e))
            .toList()
        : null;
    total = json['total'];
  }
}

class WorkApplicationEntity {
  int? id;
  int? workListingId;
  int? supplyId;
  int? userId;
  int? applicationChannelId;
  WorkApplicationStatusEntity? status;
  WorkApplicationPendingAction? supplyPendingAction;
  String? awignPendingAction;
  String? workListingTitle;
  PotentialEarning? potentialEarning;
  String? campaignId;
  String? startDate;
  String? workListingType;
  String? createdAt;
  String? updatedAt;
  String? referredBy;
  String? supplyName;
  String? appliedCity;
  String? backOutReason;
  String? executionId;
  String? projectExecutionSourceId;
  String? supplyEmail;
  String? supplyMobileNumber;
  int? trainerId;
  String? trainerName;
  int? interviewerId;
  String? interviewerName;
  String? pitchDemoerId;
  String? pitchDemoerName;
  String? subStatus;
  String? appliedState;
  String? appliedPincode;
  String? appliedAt;
  String? selectedAt;
  String? rejectedAt;
  String? backedOutAt;
  String? approvedToWorkAt;
  String? executionStartedAt;
  String? executionCompletedAt;
  String? inAppInterviewPendingAt;
  String? inAppInterviewStartedAt;
  String? inAppInterviewPassedAt;
  String? inAppInterviewFailedAt;
  String? telephonicInterviewPendingAt;
  String? telephonicInterviewScheduledAt;
  String? telephonicInterviewStartedAt;
  String? telephonicInterviewInterviewCompletedAt;
  String? telephonicInterviewSelectedAt;
  String? telephonicInterviewRejectedAt;
  String? telephonicInterviewPassedAt;
  String? telephonicInterviewFailedAt;
  String? telephonicInterviewIncompleteAt;
  String? inAppTrainingPendingAt;
  String? inAppTrainingStartedAt;
  String? inAppTrainingPassedAt;
  String? inAppTrainingFailedAt;
  String? webinarTrainingPendingAt;
  String? webinarTrainingScheduledAt;
  String? webinarTrainingStartedAt;
  String? webinarTrainingTrainingCompletedAt;
  String? webinarTrainingIncompleteAt;
  String? webinarTrainingSupplyReattendAt;
  String? pitchTestPendingAt;
  String? pitchTestStartedAt;
  String? pitchTestPassedAt;
  String? pitchTestFailedAt;
  String? sampleLeadTestPendingAt;
  String? sampleLeadTestStartedAt;
  String? sampleLeadTestCompletedAt;
  String? pitchDemoPendingAt;
  String? pitchDemoScheduledAt;
  String? pitchDemoStartedAt;
  String? pitchDemoDemoCompletedAt;
  String? pitchDemoSelectedAt;
  String? pitchDemoRejectedAt;
  String? pitchDemoPassedAt;
  String? pitchDemoFailedAt;
  String? pitchDemoIncompleteAt;
  String? supplyType;
  String? waitlistedStep;
  String? waitlistMessage;
  String? whitelistedStep;
  String? followUpStatus;
  String? logo;
  String? icon;
  String? projectVertical;
  String? supplyCategory;
  int? version;
  String? lastAppliedAt;
  String? telephonicInterviewNotInterestedAt;
  String? workingStatus;
  String? executionStatus;
  String? saasOrgId;
  int? categoryId;
  String? orgDisplayName;
  WorkApplicationStatusEntity? currentStepName;
  String? cta;
  String? displayMessage;
  int? progress;
  bool? isEligible;
  int? categoryApplicationId;

  // Vacancy? vacancy;
  WorkListing? worklisting;
  InAppInterview? inAppInterview;
  InAppTraining? inAppTraining;
  TelephonicInterviewEntity? telephonicInterview;
  WebinarTraining? webinarTraining;
  PitchDemo? pitchDemo;
  PitchTest? pitchTest;
  ApplicationStatus? applicationStatus;
  ActionData? pendingAction;
  WorkApplicationDetailsData? detailsData;
  SlotEntity? suggestedSlot;
  BatchEntity? suggestedBatch;
  BaseSection? tileActionSection;
  String? fromRoute;
  bool? archivedStatus;

  WorkApplicationEntity({
    this.id,
    this.workListingId,
    this.supplyId,
    this.userId,
    this.applicationChannelId,
    this.status,
    this.supplyPendingAction,
    this.awignPendingAction,
    this.workListingTitle,
    this.potentialEarning,
    this.campaignId,
    this.startDate,
    this.workListingType,
    this.createdAt,
    this.updatedAt,
    this.referredBy,
    this.supplyName,
    this.appliedCity,
    this.backOutReason,
    this.executionId,
    this.projectExecutionSourceId,
    this.supplyEmail,
    this.supplyMobileNumber,
    this.trainerId,
    this.trainerName,
    this.interviewerId,
    this.interviewerName,
    this.pitchDemoerId,
    this.pitchDemoerName,
    this.subStatus,
    this.appliedState,
    this.appliedPincode,
    this.appliedAt,
    this.selectedAt,
    this.rejectedAt,
    this.backedOutAt,
    this.approvedToWorkAt,
    this.executionStartedAt,
    this.executionCompletedAt,
    this.inAppInterviewPendingAt,
    this.inAppInterviewStartedAt,
    this.inAppInterviewPassedAt,
    this.inAppInterviewFailedAt,
    this.telephonicInterviewPendingAt,
    this.telephonicInterviewScheduledAt,
    this.telephonicInterviewStartedAt,
    this.telephonicInterviewInterviewCompletedAt,
    this.telephonicInterviewSelectedAt,
    this.telephonicInterviewRejectedAt,
    this.telephonicInterviewPassedAt,
    this.telephonicInterviewFailedAt,
    this.telephonicInterviewIncompleteAt,
    this.inAppTrainingPendingAt,
    this.inAppTrainingStartedAt,
    this.inAppTrainingPassedAt,
    this.inAppTrainingFailedAt,
    this.webinarTrainingPendingAt,
    this.webinarTrainingScheduledAt,
    this.webinarTrainingStartedAt,
    this.webinarTrainingTrainingCompletedAt,
    this.webinarTrainingIncompleteAt,
    this.webinarTrainingSupplyReattendAt,
    this.pitchTestPendingAt,
    this.pitchTestStartedAt,
    this.pitchTestPassedAt,
    this.pitchTestFailedAt,
    this.sampleLeadTestPendingAt,
    this.sampleLeadTestStartedAt,
    this.sampleLeadTestCompletedAt,
    this.pitchDemoPendingAt,
    this.pitchDemoScheduledAt,
    this.pitchDemoStartedAt,
    this.pitchDemoDemoCompletedAt,
    this.pitchDemoSelectedAt,
    this.pitchDemoRejectedAt,
    this.pitchDemoPassedAt,
    this.pitchDemoFailedAt,
    this.pitchDemoIncompleteAt,
    this.supplyType,
    this.waitlistedStep,
    this.waitlistMessage,
    this.whitelistedStep,
    this.followUpStatus,
    this.logo,
    this.icon,
    this.projectVertical,
    this.supplyCategory,
    this.version,
    this.lastAppliedAt,
    this.telephonicInterviewNotInterestedAt,
    this.workingStatus,
    this.executionStatus,
    this.saasOrgId,
    this.categoryId,
    this.orgDisplayName,
    this.currentStepName,
    this.cta,
    this.displayMessage,
    this.progress,
    // this.vacancy,
    this.worklisting,
    this.inAppInterview,
    this.inAppTraining,
    this.applicationStatus,
    this.pendingAction,
    this.detailsData,
    this.suggestedSlot,
    this.suggestedBatch,
    this.tileActionSection,
    this.archivedStatus,
    this.isEligible,
    this.categoryApplicationId
  });

  WorkApplicationEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workListingId = json['worklisting_id'];
    supplyId = json['supply_id'];
    userId = json['user_id'];
    applicationChannelId = json['application_channel_id'];
    status = WorkApplicationStatusEntity.getStatus(json['status']);
    supplyPendingAction =
        WorkApplicationPendingAction.getAction(json['supply_pending_action']);
    awignPendingAction = json['awign_pending_action'];
    workListingTitle = json['worklisting_title'];
    potentialEarning = json['potential_earning'] != null
        ? PotentialEarning.fromJson(json['potential_earning'])
        : null;
    campaignId = json['campaign_id'];
    startDate = json['start_date'];
    workListingType = json['worklisting_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    referredBy = json['referred_by'];
    supplyName = json['supply_name'];
    appliedCity = json['applied_city'];
    backOutReason = json['back_out_reason'];
    executionId = json['execution_id'];
    projectExecutionSourceId = json['project_execution_source_id'];
    supplyEmail = json['supply_email'];
    supplyMobileNumber = json['supply_mobile_number'];
    trainerId = json['trainer_id'];
    trainerName = json['trainer_name'];
    interviewerId = json['interviewer_id'];
    interviewerName = json['interviewer_name'];
    pitchDemoerId = json['pitch_demoer_id'];
    pitchDemoerName = json['pitch_demoer_name'];
    subStatus = json['sub_status'];
    appliedState = json['applied_state'];
    appliedPincode = json['applied_pincode'];
    appliedAt = json['applied_at'];
    selectedAt = json['selected_at'];
    rejectedAt = json['rejected_at'];
    backedOutAt = json['backed_out_at'];
    approvedToWorkAt = json['approved_to_work_at'];
    executionStartedAt = json['execution_started_at'];
    executionCompletedAt = json['execution_completed_at'];
    inAppInterviewPendingAt = json['in_app_interview_pending_at'];
    inAppInterviewStartedAt = json['in_app_interview_started_at'];
    inAppInterviewPassedAt = json['in_app_interview_passed_at'];
    inAppInterviewFailedAt = json['in_app_interview_failed_at'];
    telephonicInterviewPendingAt = json['telephonic_interview_pending_at'];
    telephonicInterviewScheduledAt = json['telephonic_interview_scheduled_at'];
    telephonicInterviewStartedAt = json['telephonic_interview_started_at'];
    telephonicInterviewInterviewCompletedAt =
        json['telephonic_interview_interview_completed_at'];
    telephonicInterviewSelectedAt = json['telephonic_interview_selected_at'];
    telephonicInterviewRejectedAt = json['telephonic_interview_rejected_at'];
    telephonicInterviewPassedAt = json['telephonic_interview_passed_at'];
    telephonicInterviewFailedAt = json['telephonic_interview_failed_at'];
    telephonicInterviewIncompleteAt =
        json['telephonic_interview_incomplete_at'];
    inAppTrainingPendingAt = json['in_app_training_pending_at'];
    inAppTrainingStartedAt = json['in_app_training_started_at'];
    inAppTrainingPassedAt = json['in_app_training_passed_at'];
    inAppTrainingFailedAt = json['in_app_training_failed_at'];
    webinarTrainingPendingAt = json['webinar_training_pending_at'];
    webinarTrainingScheduledAt = json['webinar_training_scheduled_at'];
    webinarTrainingStartedAt = json['webinar_training_started_at'];
    webinarTrainingTrainingCompletedAt =
        json['webinar_training_training_completed_at'];
    webinarTrainingIncompleteAt = json['webinar_training_incomplete_at'];
    webinarTrainingSupplyReattendAt =
        json['webinar_training_supply_reattend_at'];
    pitchTestPendingAt = json['pitch_test_pending_at'];
    pitchTestStartedAt = json['pitch_test_started_at'];
    pitchTestPassedAt = json['pitch_test_passed_at'];
    pitchTestFailedAt = json['pitch_test_failed_at'];
    sampleLeadTestPendingAt = json['sample_lead_test_pending_at'];
    sampleLeadTestStartedAt = json['sample_lead_test_started_at'];
    sampleLeadTestCompletedAt = json['sample_lead_test_completed_at'];
    pitchDemoPendingAt = json['pitch_demo_pending_at'];
    pitchDemoScheduledAt = json['pitch_demo_scheduled_at'];
    pitchDemoStartedAt = json['pitch_demo_started_at'];
    pitchDemoDemoCompletedAt = json['pitch_demo_demo_completed_at'];
    pitchDemoSelectedAt = json['pitch_demo_selected_at'];
    pitchDemoRejectedAt = json['pitch_demo_rejected_at'];
    pitchDemoPassedAt = json['pitch_demo_passed_at'];
    pitchDemoFailedAt = json['pitch_demo_failed_at'];
    pitchDemoIncompleteAt = json['pitch_demo_incomplete_at'];
    supplyType = json['supply_type'];
    waitlistedStep = json['waitlisted_step'];
    waitlistMessage = json['waitlist_message'];
    whitelistedStep = json['whitelisted_step'];
    followUpStatus = json['follow_up_status'];
    isEligible = json['is_eligible'];
    logo = json['logo'];
    icon = json['icon'];
    projectVertical = json['project_vertical'];
    supplyCategory = json['supply_category'];
    version = json['version'];
    lastAppliedAt = json['last_applied_at'];
    telephonicInterviewNotInterestedAt =
        json['telephonic_interview_not_interested_at'];
    workingStatus = json['working_status'];
    executionStatus = json['execution_status'];
    saasOrgId = json['saas_org_id'];
    categoryId = json['category_id'];
    orgDisplayName = json['org_display_name'];
    categoryApplicationId = json['category_application_id'];
    // currentStepName = json['current_step_name'];
    suggestedSlot = json['suggested_slot'] != null
        ? SlotEntity.fromJson(json['suggested_slot'])
        : null;
    suggestedBatch = json['suggested_batch'] != null
        ? BatchEntity.fromJson(json['suggested_batch'])
        : null;
    currentStepName =
        WorkApplicationStatusEntity.getStatus(json['current_step_name']);
    cta = json['cta'];
    displayMessage = json['display_message'];
    progress = json['progress'];
    // vacancy = json['vacancy'] != null ? Vacancy.fromJson(json['vacancy']) : null;
    worklisting = json['worklisting'] != null
        ? WorkListing.fromJson(json['worklisting'])
        : null;
    inAppInterview = json['in_app_interview'] != null
        ? InAppInterview.fromJson(json['in_app_interview'])
        : null;
    inAppTraining = json['in_app_training'] != null
        ? InAppTraining.fromJson(json['in_app_training'])
        : null;
    telephonicInterview = json['telephonic_interview'] != null
        ? TelephonicInterviewEntity.fromJson(json['telephonic_interview'])
        : null;
    webinarTraining = json['webinar_training'] != null
        ? WebinarTraining.fromJson(json['webinar_training'])
        : null;
    pitchDemo = json['pitch_demo'] != null
        ? PitchDemo.fromJson(json['pitch_demo'])
        : null;
    pitchTest = json['pitch_test'] != null
        ? PitchTest.fromJson(json['pitch_test'])
        : null;
    pendingAction = ActionData.getActionData(supplyPendingAction,
        executionID: executionId,
        projectExecutionSourceID: projectExecutionSourceId,
        cta: cta);
    applicationStatus = ApplicationStatus.getStatus(this);
    detailsData = WorkApplicationDetailsData(
        detailSections:
            ApplicationDetailsSectionProvider.getDetailsSectionList(this));
    tileActionSection =
        ApplicationTileSectionProvider.getTileActionSection(this);
    archivedStatus = json['archived_status'];
  }

// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = <String, dynamic>{};
//   data['id'] = id;
//   data['worklisting_id'] = workListingId;
//   data['supply_id'] = supplyId;
//   data['user_id'] = userId;
//   data['application_channel_id'] = applicationChannelId;
//   data['status'] = status;
//   data['supply_pending_action'] = supplyPendingAction;
//   data['awign_pending_action'] = awignPendingAction;
//   data['worklisting_title'] = workListingTitle;
//   if (potentialEarning != null) {
//     data['potential_earning'] = potentialEarning!.toJson();
//   }
//   data['campaign_id'] = campaignId;
//   data['start_date'] = startDate;
//   data['worklisting_type'] = workListingType;
//   data['created_at'] = createdAt;
//   data['updated_at'] = updatedAt;
//   data['referred_by'] = referredBy;
//   data['supply_name'] = supplyName;
//   data['applied_city'] = appliedCity;
//   data['back_out_reason'] = backOutReason;
//   data['execution_id'] = executionId;
//   data['project_execution_source_id'] = projectExecutionSourceId;
//   data['supply_email'] = supplyEmail;
//   data['supply_mobile_number'] = supplyMobileNumber;
//   data['trainer_id'] = trainerId;
//   data['trainer_name'] = trainerName;
//   data['interviewer_id'] = interviewerId;
//   data['interviewer_name'] = interviewerName;
//   data['pitch_demoer_id'] = pitchDemoerId;
//   data['pitch_demoer_name'] = pitchDemoerName;
//   data['sub_status'] = subStatus;
//   data['applied_state'] = appliedState;
//   data['applied_pincode'] = appliedPincode;
//   data['applied_at'] = appliedAt;
//   data['selected_at'] = selectedAt;
//   data['rejected_at'] = rejectedAt;
//   data['backed_out_at'] = backedOutAt;
//   data['approved_to_work_at'] = approvedToWorkAt;
//   data['execution_started_at'] = executionStartedAt;
//   data['execution_completed_at'] = executionCompletedAt;
//   data['in_app_interview_pending_at'] = inAppInterviewPendingAt;
//   data['in_app_interview_started_at'] = inAppInterviewStartedAt;
//   data['in_app_interview_passed_at'] = inAppInterviewPassedAt;
//   data['in_app_interview_failed_at'] = inAppInterviewFailedAt;
//   data['telephonic_interview_pending_at'] = telephonicInterviewPendingAt;
//   data['telephonic_interview_scheduled_at'] = telephonicInterviewScheduledAt;
//   data['telephonic_interview_started_at'] = telephonicInterviewStartedAt;
//   data['telephonic_interview_interview_completed_at'] = telephonicInterviewInterviewCompletedAt;
//   data['telephonic_interview_selected_at'] = telephonicInterviewSelectedAt;
//   data['telephonic_interview_rejected_at'] = telephonicInterviewRejectedAt;
//   data['telephonic_interview_passed_at'] = telephonicInterviewPassedAt;
//   data['telephonic_interview_failed_at'] = telephonicInterviewFailedAt;
//   data['telephonic_interview_incomplete_at'] = telephonicInterviewIncompleteAt;
//   data['in_app_training_pending_at'] = inAppTrainingPendingAt;
//   data['in_app_training_started_at'] = inAppTrainingStartedAt;
//   data['in_app_training_passed_at'] = inAppTrainingPassedAt;
//   data['in_app_training_failed_at'] = inAppTrainingFailedAt;
//   data['webinar_training_pending_at'] = webinarTrainingPendingAt;
//   data['webinar_training_scheduled_at'] = webinarTrainingScheduledAt;
//   data['webinar_training_started_at'] = webinarTrainingStartedAt;
//   data['webinar_training_training_completed_at'] = webinarTrainingTrainingCompletedAt;
//   data['webinar_training_incomplete_at'] = webinarTrainingIncompleteAt;
//   data['webinar_training_supply_reattend_at'] = webinarTrainingSupplyReattendAt;
//   data['pitch_test_pending_at'] = pitchTestPendingAt;
//   data['pitch_test_started_at'] = pitchTestStartedAt;
//   data['pitch_test_passed_at'] = pitchTestPassedAt;
//   data['pitch_test_failed_at'] = pitchTestFailedAt;
//   data['sample_lead_test_pending_at'] = sampleLeadTestPendingAt;
//   data['sample_lead_test_started_at'] = sampleLeadTestStartedAt;
//   data['sample_lead_test_completed_at'] = sampleLeadTestCompletedAt;
//   data['pitch_demo_pending_at'] = pitchDemoPendingAt;
//   data['pitch_demo_scheduled_at'] = pitchDemoScheduledAt;
//   data['pitch_demo_started_at'] = pitchDemoStartedAt;
//   data['pitch_demo_demo_completed_at'] = pitchDemoDemoCompletedAt;
//   data['pitch_demo_selected_at'] = pitchDemoSelectedAt;
//   data['pitch_demo_rejected_at'] = pitchDemoRejectedAt;
//   data['pitch_demo_passed_at'] = pitchDemoPassedAt;
//   data['pitch_demo_failed_at'] = pitchDemoFailedAt;
//   data['pitch_demo_incomplete_at'] = pitchDemoIncompleteAt;
//   data['supply_type'] = supplyType;
//   data['waitlisted_step'] = waitlistedStep;
//   data['waitlist_message'] = waitlistMessage;
//   data['whitelisted_step'] = whitelistedStep;
//   data['follow_up_status'] = followUpStatus;
//   data['logo'] = logo;
//   data['icon'] = icon;
//   data['project_vertical'] = projectVertical;
//   data['supply_category'] = supplyCategory;
//   data['version'] = version;
//   data['last_applied_at'] = lastAppliedAt;
//   data['telephonic_interview_not_interested_at'] = telephonicInterviewNotInterestedAt;
//   data['working_status'] = workingStatus;
//   data['execution_status'] = executionStatus;
//   data['saas_org_id'] = saasOrgId;
//   data['category_id'] = categoryId;
//   data['org_display_name'] = orgDisplayName;
//   data['current_step_name'] = currentStepName;
//   data['cta'] = cta;
//   data['display_message'] = displayMessage;
//   data['progress'] = progress;
//   // if (vacancy != null) {
//   //   data['vacancy'] = vacancy!.toJson();
//   // }
//   if (worklisting != null) {
//     data['worklisting'] = worklisting?.toJson();
//   }
//   // if (inAppInterview != null) {
//   //   data['in_app_interview'] = inAppInterview!.toJson();
//   // }
//   return data;
// }
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['earning_type'] = earningType;
    data['from'] = from;
    data['to'] = to;
    data['earning_duration'] = earningDuration;
    return data;
  }

  String getEarningText() {
    String earningText = '';
    if (!from.isNullOrEmpty && !to.isNullOrEmpty) {
      if (from == Constants.upto) {
        earningText = '$from ${Constants.rs} $to';
      } else {
        earningText = '${Constants.rs} $from - ${Constants.rs} $to';
      }
    } else if (!from.isNullOrEmpty) {
      earningText = '${Constants.rs} $from';
    } else if (!to.isNullOrEmpty) {
      earningText = '${Constants.rs} $to';
    }
    return '${earningType?.replaceAll('_', ' ')} $earningText ${earningDuration?.replaceAll('_', ' ')}'
        .toCapitalized();
  }
}

class ActionData {
  ApplicationAction? actionKey;
  String? ctaText;
  dynamic data;

  ActionData({this.actionKey, this.ctaText, this.data}) {
    ctaText ??= actionKey!.getValue1();
  }

  ActionData.getActionData(
      WorkApplicationPendingAction? workApplicationPendingAction,
      {String? executionID = '',
      String? projectExecutionSourceID = '',
      String? cta}) {
    ctaText = cta;
    switch (workApplicationPendingAction) {
      case WorkApplicationPendingAction.inAppInterviewPending:
        actionKey = ApplicationAction.startInAppInterview;
        break;
      case WorkApplicationPendingAction.retakeInAppInterview:
        actionKey = ApplicationAction.redoInAppInterview;
        break;
      case WorkApplicationPendingAction.completeInAppInterview:
        actionKey = ApplicationAction.completeInAppInterview;
        break;

      case WorkApplicationPendingAction.scheduleTelephonicInterview:
        actionKey = ApplicationAction.scheduleTelephonicInterview;
        break;
      case WorkApplicationPendingAction.askSupplyInterviewConfirmation:
        actionKey = ApplicationAction.telephonicInterviewAskConfirmation;
        break;
      case WorkApplicationPendingAction
          .rescheduleTelephonicInterviewOrContactSupport:
        actionKey = ApplicationAction.reTakeTelephonicInterview;
        break;
      case WorkApplicationPendingAction.rescheduleTelephonicInterview:
        actionKey = ApplicationAction.reTakeTelephonicInterview;
        break;
      case WorkApplicationPendingAction.retakeTelephonicInterview:
        actionKey = ApplicationAction.reTakeTelephonicInterview;
        break;
      case WorkApplicationPendingAction.prepareInterview:
        actionKey = ApplicationAction.prepareInterview;
        break;

      case WorkApplicationPendingAction.startInAppTraining:
        actionKey = ApplicationAction.startInAppTraining;
        break;
      case WorkApplicationPendingAction.retakeInAppTraining:
        actionKey = ApplicationAction.redoInAppTraining;
        break;
      case WorkApplicationPendingAction.completeInAppTraining:
        actionKey = ApplicationAction.completeInAppTraining;
        break;

      case WorkApplicationPendingAction.scheduleWebinarTraining:
        actionKey = ApplicationAction.scheduleWebinarTraining;
        break;
      case WorkApplicationPendingAction.askSupplyTrainingConfirmation:
        actionKey = ApplicationAction.webinarTrainingAskConfirmation;
        break;
      case WorkApplicationPendingAction.reScheduleWebinarTrainingOrSupport:
        actionKey = ApplicationAction.retakeWebinarTraining;
        break;
      case WorkApplicationPendingAction.reScheduleWebinarTraining:
        actionKey = ApplicationAction.retakeWebinarTraining;
        break;
      case WorkApplicationPendingAction.retakeWebinarTraining:
        actionKey = ApplicationAction.retakeWebinarTraining;
        break;
      case WorkApplicationPendingAction.prepareTraining:
        actionKey = ApplicationAction.prepareTraining;
        break;
      case WorkApplicationPendingAction.prepareTrainingNoResource:
        actionKey = ApplicationAction.prepareTrainingNoResource;
        break;
      case WorkApplicationPendingAction.joinTraining:
        actionKey = ApplicationAction.joinTraining;
        break;
      case WorkApplicationPendingAction.joinTrainingNoResource:
        actionKey = ApplicationAction.joinTrainingNoResource;
        break;
      case WorkApplicationPendingAction.missedTraining:
        actionKey = ApplicationAction.reScheduleWebinarTraining;
        break;

      case WorkApplicationPendingAction.startPitchDemo:
        actionKey = ApplicationAction.startPitchDemo;
        break;
      case WorkApplicationPendingAction.completePitchDemo:
        actionKey = ApplicationAction.completePitchDemo;
        break;
      case WorkApplicationPendingAction.schedulePitchDemo:
        actionKey = ApplicationAction.schedulePitchDemo;
        break;
      case WorkApplicationPendingAction.askSupplyPitchDemoConfirmation:
        actionKey = ApplicationAction.pitchDemoAskConfirmation;
        break;
      case WorkApplicationPendingAction.preparePitchDemo:
        actionKey = ApplicationAction.preparePitchDemo;
        break;
      case WorkApplicationPendingAction.reschedulePitchDemoOrSupport:
        actionKey = ApplicationAction.redoPitchDemo;
        break;
      case WorkApplicationPendingAction.reschedulePitchDemo:
        actionKey = ApplicationAction.redoPitchDemo;
        break;
      case WorkApplicationPendingAction.retakePitchDemo:
        actionKey = ApplicationAction.redoPitchDemo;
        break;

      case WorkApplicationPendingAction.startPitchTest:
        actionKey = ApplicationAction.startPitchTest;
        break;
      case WorkApplicationPendingAction.retakePitchTest:
        actionKey = ApplicationAction.redoPitchTest;
        break;
      case WorkApplicationPendingAction.completePitchTest:
        actionKey = ApplicationAction.completePitchTest;
        break;
      case WorkApplicationPendingAction.reapply:
        actionKey = ApplicationAction.reApply;
        break;

      case WorkApplicationPendingAction.contactSupport:
        actionKey = ApplicationAction.customerSupport;
        break;
    }
  }
}

class TimelineSectionEntity extends BaseSection {
  List<TimelineStepEntity>? timelineSteps;

  TimelineSectionEntity({this.timelineSteps}) : super(SectionType.timeline);

  TimelineSectionEntity.fromJson(Map<String, dynamic> json)
      : super(SectionType.timeline) {
    if (json['process_flow'] != null) {
      timelineSteps = <TimelineStepEntity>[];
      json['process_flow'].forEach((v) {
        timelineSteps!.add(TimelineStepEntity.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (timelineSteps != null) {
      data['process_flow'] = timelineSteps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimelineStepEntity {
  String? stepName;
  SectionStatusEntity? status;
  List<TimelineStepEntity>? subSteps;

  TimelineStepEntity(
      {this.stepName, this.status = SectionStatusEntity.locked, this.subSteps});

  TimelineStepEntity.fromJson(Map<String, dynamic> json) {
    stepName = json['step_name'];
    status = SectionStatusEntity.getStatus(json['status']);
    if (json['sub_steps'] != null) {
      subSteps = <TimelineStepEntity>[];
      json['sub_steps'].forEach((v) {
        subSteps!.add(TimelineStepEntity.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['step_name'] = stepName;
    data['status'] = status;
    if (subSteps != null) {
      data['sub_steps'] = subSteps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SectionStatusEntity<String> extends Enum1<String> {
  const SectionStatusEntity(String val) : super(val);

  static const SectionStatusEntity inProgress =
      SectionStatusEntity('in_progress');
  static const SectionStatusEntity completed = SectionStatusEntity('completed');
  static const SectionStatusEntity locked = SectionStatusEntity('locked');
  static const SectionStatusEntity empty = SectionStatusEntity('empty');
  static const SectionStatusEntity unLocked = SectionStatusEntity('unLocked');

  static SectionStatusEntity? getStatus(dynamic status) {
    switch (status) {
      case 'in_progress':
        return SectionStatusEntity.inProgress;
      case 'completed':
        return SectionStatusEntity.completed;
      case 'locked':
        return SectionStatusEntity.locked;
      case 'empty':
        return SectionStatusEntity.empty;
      case 'unLocked':
        return SectionStatusEntity.unLocked;
    }
    return null;
  }
}

class WorkApplicationDetailsData {
  List<BaseSection>? detailSections;

  WorkApplicationDetailsData({this.detailSections});
}

class StepType<String> extends Enum1<String> {
  const StepType(String val) : super(val);

  static const StepType interview = StepType('interview');
  static const StepType training = StepType('training');
  static const StepType pitchTest = StepType('pitchTest');
  static const StepType pitchDemo = StepType('pitchDemo');

  static StepType? getStatus(dynamic status) {
    switch (status) {
      case 'interview':
        return StepType.interview;
      case 'training':
        return StepType.training;
      case 'pitchTest':
        return StepType.pitchTest;
      case 'pitchDemo':
        return StepType.pitchDemo;
    }
    return null;
  }
}

class WorkApplicationCreateRequest {
  CreateRequestData createRequestData;

  WorkApplicationCreateRequest(this.createRequestData);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['application'] = createRequestData.toJson();
    return data;
  }
}

class CreateRequestData {
  String? workListingID;
  String? referredBY;

  CreateRequestData({this.workListingID, this.referredBY});

  CreateRequestData.fromJson(Map<String, dynamic> json) {
    workListingID = json['worklisting_id'];
    referredBY = json['referred_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(workListingID != null) {
      data['worklisting_id'] = workListingID;
    }
    if(referredBY != null) {
      data['referred_by'] = referredBY;
    }
    return data;
  }
}
