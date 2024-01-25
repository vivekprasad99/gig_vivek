import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ExecutionPageParameters {
  late final String memberID;
  late final bool isOffline;
  late final String uIDs;
  late final bool skipSaasOrgId;

  ExecutionPageParameters(
      {required this.memberID,
      this.isOffline = false,
      required this.uIDs,
      required this.skipSaasOrgId});
}

class ExecutionsResponse {
  List<Execution>? executions;
  int? total;
  int? limit;
  int? page;
  int? offset;
  Execution? execution;

  ExecutionsResponse(
      {this.executions,
      this.total,
      this.limit,
      this.page,
      this.offset,
      this.execution});

  ExecutionsResponse.fromJson(Map<String, dynamic> json, String uID) {
    if (json['executions'] != null) {
      executions = <Execution>[];
      json['executions'].forEach((v) {
        executions!.add(Execution.fromJson(v, uID));
      });
    }
    total = json['total'];
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    if (executions != null) {
      executions = sortExecutions(executions!);
    }
    execution = json['execution'] != null
        ? Execution.fromJson(json['execution'], uID)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (executions != null) {
      data['executions'] = executions!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['limit'] = limit;
    data['page'] = page;
    data['offset'] = offset;
    return data;
  }

  List<Execution> sortExecutions(List<Execution> remoteExecutionList) {
    List<Execution> executionList = [];
    List<Execution> activeExecutionList = [];
    List<Execution> approvedExecutionList = [];
    List<Execution> waitListedExecutionList = [];
    List<Execution> onHoldExecutionList = [];
    List<Execution> completedExecutionList = [];
    List<Execution> disqualifiedExecutionList = [];
    for (Execution execution in remoteExecutionList) {
      switch (execution.status) {
        case ExecutionStatus.approved:
          approvedExecutionList.add(execution);
          break;
        case ExecutionStatus.started:
          if ((execution.leadAllotmentType ==
                      ExecutionLeadAllotmentType.provided &&
                  execution.leadAssignedStatus == null) ||
              (execution.leadAllotmentType == null &&
                  execution.leadAssignedStatus == null)) {
            waitListedExecutionList.add(execution);
          } else if ((execution.leadAllotmentType ==
                      ExecutionLeadAllotmentType.selfCreated &&
                  execution.leadAssignedStatus == null) ||
              (execution.leadAssignedStatus ==
                  ExecutionLeadAssignedStatus.firstLeadAssigned)) {
            activeExecutionList.add(execution);
          } else {
            activeExecutionList.add(execution);
          }
          break;
        case ExecutionStatus.added:
          activeExecutionList.add(execution);
          break;
        case ExecutionStatus.durationExtended:
        case ExecutionStatus.halted:
          onHoldExecutionList.add(execution);
          break;
        case ExecutionStatus.certificateRequested:
        case ExecutionStatus.certificateIssued:
        case ExecutionStatus.backedOut:
        case ExecutionStatus.completed:
        case ExecutionStatus.submitted:
          completedExecutionList.add(execution);
          break;
        case ExecutionStatus.blacklisted:
        case ExecutionStatus.disqualified:
        case ExecutionStatus.rejected:
          disqualifiedExecutionList.add(execution);
          break;
      }
    }
    executionList.addAll(approvedExecutionList);
    executionList.addAll(activeExecutionList);
    executionList.addAll(waitListedExecutionList);
    executionList.addAll(completedExecutionList);
    executionList.addAll(onHoldExecutionList);
    executionList.addAll(disqualifiedExecutionList);
    return executionList;
  }
}

class ExecutionStatus<String> extends Enum1<String> {
  const ExecutionStatus(String val) : super(val);

  static const ExecutionStatus approved = ExecutionStatus('approved');
  static const ExecutionStatus started = ExecutionStatus('started');
  static const ExecutionStatus submitted = ExecutionStatus('submitted');
  static const ExecutionStatus extended = ExecutionStatus('extended');
  static const ExecutionStatus durationExtended =
      ExecutionStatus('duration_extended');
  static const ExecutionStatus halted = ExecutionStatus('halted');
  static const ExecutionStatus completed = ExecutionStatus('completed');
  static const ExecutionStatus certificateRequested =
      ExecutionStatus('certificate_requested');
  static const ExecutionStatus certificateIssued =
      ExecutionStatus('certificate_issued');
  static const ExecutionStatus backedOut = ExecutionStatus('backed_out');
  static const ExecutionStatus blacklisted = ExecutionStatus('blacklisted');
  static const ExecutionStatus disqualified = ExecutionStatus('disqualified');
  static const ExecutionStatus rejected = ExecutionStatus('rejected');
  static const ExecutionStatus added = ExecutionStatus('added');
}

class ExecutionLeadAllotmentType<String> extends Enum1<String> {
  const ExecutionLeadAllotmentType(String val) : super(val);

  static const ExecutionLeadAllotmentType provided =
      ExecutionLeadAllotmentType('provided');
  static const ExecutionLeadAllotmentType selfCreated =
      ExecutionLeadAllotmentType('self_created');
}

class ExecutionLeadAssignedStatus<String> extends Enum1<String> {
  const ExecutionLeadAssignedStatus(String val) : super(val);

  static const ExecutionLeadAssignedStatus firstLeadAssigned =
      ExecutionLeadAssignedStatus('first_lead_assigned');
}

class Execution {
  // AllocationGroups? aAllocationGroups;
  Map<String, dynamic>? earningsBreakupVisible;

  // AllocationGroups? aExecutionSource;
  String? id;
  ExecutionLeadAllotmentType? leadAllotmentType;
  ExecutionLeadAssignedStatus? leadAssignedStatus;

  // ManagerExecutions? mManagerExecutions;
  // EarningsBreakupVisible? offerLetterVisible;
  Map<String, dynamic>? offerLetterVisible;

  // AllocationGroups? aPayoutGroups;
  ExecutionStatus? status;

  // AllocationData? allocationData;
  bool? captureAadharCard;
  bool? captureDrivingLicence;

  // List<String>? categoryUids;
  // ManagerExecutions? certificate;
  // String? city;
  Map<String, dynamic>? certificate;
  String? createdAt;
  String? description;
  String? icon;

  // List<String>? languages;
  String? lastWorklogAt;

  // LatLon? latLon;
  // ManagerExecutions? leadAssignedStatusAt;
  String? memberId;
  String? name;

  // Null? nilId;
  // Null? offerLetterCity;
  Map<String, OfferLetterFiles>? offerLetterFiles;
  String? orgDisplayName;

  // Null? payoutGroupId;
  // String? pincode;
  // Null? proctorActivation;
  // Null? proctorAvailability;
  String? projectIcon;
  String? projectId;
  String? projectName;

  // String? projectPod;
  List<String>? projectRoles;

  // String? projectVertical;
  Null? saasOrgId;
  String? state;

  // String? street;
  // AllocationGroups? supplyCategories;
  Map<String, dynamic>? supplyCategories;
  String? updatedAt;

  // int? version;
  // bool? working;
  bool? availability;

  // List<String>? capacityStatuses;
  // bool? workingStatus;
  Map<String, dynamic>? applicationIds;
  String? selectedProjectRole;
  Map<String, dynamic>? tabsMap;
  String? selectedTab;
  Map<String, dynamic>? managerInformedStartDate;
  Map<String, dynamic>? startDate;
  Map<String, dynamic>? revisedStartDate;
  Map<String, dynamic>? managerInformedWorkStartInfoText;
  Map<String, dynamic>? workStartInfoText;
  Map<String, dynamic>? revisedWorkStartInfoText;
  bool? workRequested;
  String? lastWorkRequestedAt;
  String? strAvailability;
  Map<String, SharedInformationData>? sharedInformationData;
  bool? archivedStatus;

  Execution.fromJson(Map<String, dynamic> json, String uID) {
    // aAllocationGroups = json['_allocation_groups'] != null ? AllocationGroups.fromJson(json['_allocation_groups']) : null;
    earningsBreakupVisible = json['_earnings_breakup_visible'];
    // aExecutionSource = json['_execution_source'] != null ? AllocationGroups.fromJson(json['_execution_source']) : null;
    id = json['_id'];
    // leadAllotmentType = json['_lead_allotment_type'];
    switch (json['_lead_allotment_type']) {
      case 'provided':
        leadAllotmentType = ExecutionLeadAllotmentType.provided;
        break;
      case 'self_created':
        leadAllotmentType = ExecutionLeadAllotmentType.selfCreated;
        break;
    }
    // leadAssignedStatus = json['_lead_assigned_status'];
    switch (json['_lead_assigned_status']) {
      case 'first_lead_assigned':
        leadAssignedStatus = ExecutionLeadAssignedStatus.firstLeadAssigned;
        break;
    }
    // mManagerExecutions = json['_manager_executions'] != null ? ManagerExecutions.fromJson(json['_manager_executions']) : null;
    /*offerLetterVisible = json['_offer_letter_visible'] != null
        ? EarningsBreakupVisible.fromJson(json['_offer_letter_visible'])
        : null;*/
    offerLetterVisible = json['_offer_letter_visible'];
    // aPayoutGroups = json['_payout_groups'] != null ? AllocationGroups.fromJson(json['_payout_groups']) : null;
    // status = json['_status'];
    switch (json['_status']) {
      case 'approved':
        status = ExecutionStatus.approved;
        break;
      case 'started':
        status = ExecutionStatus.started;
        break;
      case 'submitted':
        status = ExecutionStatus.submitted;
        break;
      case 'extended':
        status = ExecutionStatus.extended;
        break;
      case 'duration_extended':
        status = ExecutionStatus.durationExtended;
        break;
      case 'halted':
        status = ExecutionStatus.halted;
        break;
      case 'completed':
        status = ExecutionStatus.completed;
        break;
      case 'certificate_requested':
        status = ExecutionStatus.certificateRequested;
        break;
      case 'certificate_issued':
        status = ExecutionStatus.certificateIssued;
        break;
      case 'backed_out':
        status = ExecutionStatus.backedOut;
        break;
      case 'blacklisted':
        status = ExecutionStatus.blacklisted;
        break;
      case 'disqualified':
        status = ExecutionStatus.disqualified;
        break;
      case 'rejected':
        status = ExecutionStatus.rejected;
        break;
      case 'added':
        status = ExecutionStatus.added;
        break;
    }
    // allocationData = json['allocation_data'] != null ? AllocationData.fromJson(json['allocation_data']) : null;
    captureAadharCard = json['capture_aadhar_card'];
    captureDrivingLicence = json['capture_driving_licence'];
    // categoryUids = json['category_uids'].cast<String>();
    // certificate = json['certificate'] != null ? ManagerExecutions.fromJson(json['certificate']) : null;
    certificate = json['certificate'];
    // city = json['city'];
    createdAt = json['created_at'];
    description = json['description'];
    icon = json['icon'];
    // languages = json['languages'].cast<String>();
    lastWorklogAt = json['last_worklog_at'];
    // latLon = json['lat_lon'] != null ? LatLon.fromJson(json['lat_lon']) : null;
    // leadAssignedStatusAt = json['lead_assigned_status_at'] != null ? ManagerExecutions.fromJson(json['lead_assigned_status_at']) : null;
    memberId = json['member_id'];
    name = json['name'];
    // nilId = json['nil_id'];
    // offerLetterCity = json['offer_letter_city'];
    // offerLetterFiles = json['offer_letter_files'] != null
    //     ? OfferLetterFiles.fromJson(json['offer_letter_files'])
    //     : null;
    if (json['offer_letter_files'] != null) {
      Map<String, dynamic> offerLetterFilesJson = json['offer_letter_files'];
      Map<String, OfferLetterFiles> offerLetterFilesMap = {};
      offerLetterFilesJson.forEach((k, v) {
        offerLetterFilesMap[k] = OfferLetterFiles.fromJson(v);
      });
      offerLetterFiles = offerLetterFilesMap;
    }

    orgDisplayName = json['org_display_name'];
    // payoutGroupId = json['payout_group_id'];
    // pincode = json['pincode'];
    // proctorActivation = json['proctor_activation'];
    // proctorAvailability = json['proctor_availability'];
    projectIcon = json['project_icon'];
    projectId = json['project_id'];
    projectName = json['project_name'] ?? 'Project';
    // projectPod = json['project_pod'];
    /*if (json['project_roles'] != null) {
      projectRoles = json['project_roles'].cast<String>();
    } else {
      projectRoles = null;
    }*/
    projectRoles = [];
    supplyCategories = json['supply_categories'];
    if (uID.isNotEmpty) {
      supplyCategories?.forEach((k, v) {
        if (v != null) {
          if (v.toString().toLowerCase().replaceAll(" ", "_") ==
              uID.toLowerCase().replaceAll(" ", "_")) {
            projectRoles?.add(k);
          }
        }
      });
    }
    // projectVertical = json['project_vertical'];
    // saasOrgId = json['saas_org_id'];
    state = json['state'];
    // street = json['street'];
    // supplyCategories = json['supply_categories'] != null
    //     ? AllocationGroups.fromJson(json['supply_categories'])
    //     : null;
    // supplyCategories = json['supply_categories'];
    updatedAt = json['updated_at'];
    // version = json['version'];
    // working = json['working'];
    availability = json['availability'];
    applicationIds = json['application_ids'];
    // capacityStatuses = json['capacity_statuses'].cast<String>();
    // workingStatus = json['working_status'];
    managerInformedStartDate = json['manager_informed_start_date'];
    startDate = json['start_date'];
    revisedStartDate = json['revised_start_date'];
    managerInformedWorkStartInfoText =
        json['manager_informed_work_start_info_text'];
    workStartInfoText = json['work_start_info_text'];
    revisedWorkStartInfoText = json['revised_work_start_info_text'];
    workRequested = json['work_requested'];
    lastWorkRequestedAt = json['last_work_requested_at'];
    if (json['shared_information_data'] != null) {
      Map<String, dynamic> sharedInformationDataJson =
          json['shared_information_data'];
      Map<String, SharedInformationData> sharedInformationDataMap = {};
      sharedInformationDataJson.forEach((k, v) {
        sharedInformationDataMap[k] = SharedInformationData.fromJson(v);
      });
      sharedInformationData = sharedInformationDataMap;
    }
    archivedStatus = json['archived_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (aAllocationGroups != null) {
    //   data['_allocation_groups'] = aAllocationGroups!.toJson();
    // }
    if (earningsBreakupVisible != null) {
      data['_earnings_breakup_visible'] = earningsBreakupVisible;
    }
    // if (aExecutionSource != null) {
    //   data['_execution_source'] = aExecutionSource!.toJson();
    // }
    data['_id'] = id;
    data['_lead_allotment_type'] = leadAllotmentType;
    data['_lead_assigned_status'] = leadAssignedStatus;
    // if (mManagerExecutions != null) {
    //   data['_manager_executions'] = mManagerExecutions!.toJson();
    // }
    if (offerLetterVisible != null) {
      data['_offer_letter_visible'] = offerLetterVisible;
    }
    // if (aPayoutGroups != null) {
    //   data['_payout_groups'] = aPayoutGroups!.toJson();
    // }
    data['_status'] = status;
    // if (allocationData != null) {
    //   data['allocation_data'] = allocationData!.toJson();
    // }
    data['capture_aadhar_card'] = captureAadharCard;
    data['capture_driving_licence'] = captureDrivingLicence;
    // data['category_uids'] = categoryUids;
    if (certificate != null) {
      data['certificate'] = certificate;
    }
    // data['city'] = city;
    data['created_at'] = createdAt;
    data['description'] = description;
    data['icon'] = icon;
    // data['languages'] = languages;
    data['last_worklog_at'] = lastWorklogAt;
    // if (latLon != null) {
    //   data['lat_lon'] = latLon!.toJson();
    // }
    // if (leadAssignedStatusAt != null) {
    //   data['lead_assigned_status_at'] = leadAssignedStatusAt!.toJson();
    // }
    data['member_id'] = memberId;
    data['name'] = name;
    // data['nil_id'] = nilId;
    // data['offer_letter_city'] = offerLetterCity;
    if (offerLetterFiles != null) {
      // data['offer_letter_files'] = offerLetterFiles!.toJson();
    }
    data['org_display_name'] = orgDisplayName;
    // data['payout_group_id'] = payoutGroupId;
    // data['pincode'] = pincode;
    // data['proctor_activation'] = proctorActivation;
    // data['proctor_availability'] = proctorAvailability;
    data['project_icon'] = projectIcon;
    data['project_id'] = projectId;
    data['project_name'] = projectName;
    // data['project_pod'] = projectPod;
    data['project_roles'] = projectRoles;
    // data['project_vertical'] = projectVertical;
    data['saas_org_id'] = saasOrgId;
    data['state'] = state;
    // data['street'] = street;
    if (supplyCategories != null) {
      // data['supply_categories'] = supplyCategories!.toJson();
      data['supply_categories'] = supplyCategories;
    }
    data['updated_at'] = updatedAt;
    // data['version'] = version;
    // data['working'] = working;
    data['availability'] = availability;
    // data['capacity_statuses'] = capacityStatuses;
    // data['working_status'] = workingStatus;
    data['manager_informed_start_date'] = managerInformedStartDate;
    data['start_date'] = startDate;
    data['revised_start_date'] = revisedStartDate;
    data['manager_informed_work_start_info_text'] =
        managerInformedWorkStartInfoText;
    data['work_start_info_text'] = workStartInfoText;
    data['revised_work_start_info_text'] = revisedWorkStartInfoText;
    data['work_requested'] = workRequested;
    data['last_work_requested_at'] = lastWorkRequestedAt;
    return data;
  }

  RequestWorkCardDetails getRequestWorkCardDetails(String? projectRole) {
    String? label, date, infoText, dateCardIcon;
    bool dateInfoVisibility = false;
    bool isExploreTextVisible = false;
    bool isExploreButtonVisible = false;
    if (projectRole != null &&
        leadAllotmentType == ExecutionLeadAllotmentType.provided &&
        leadAssignedStatus == null) {
      if (managerInformedStartDate != null &&
          managerInformedStartDate![projectRole] != null &&
          !StringUtils.compareWithCurrDate(
              managerInformedStartDate![projectRole]!)) {
        // Set manager inform date
        label = 'work_start_date'.tr;
        date = managerInformedStartDate![projectRole]!.toString()
            .getFormattedDateTime2(StringUtils.dateFormatDDMMMMYYYY);
        infoText = managerInformedWorkStartInfoText?[projectRole] ?? '';
      } else if (startDate != null &&
          startDate![projectRole] != null &&
          !StringUtils.compareWithCurrDate(startDate![projectRole]!)) {
        // Set start date
        label = 'work_start_date'.tr;
        date = startDate![projectRole]!.toString()
            .getFormattedDateTime2(StringUtils.dateFormatDDMMMMYYYY);
        infoText = workStartInfoText?[projectRole] ?? '';
      } else if (revisedStartDate != null &&
          revisedStartDate![projectRole] != null &&
          !StringUtils.compareWithCurrDate(revisedStartDate![projectRole]!)) {
        // Set revised due date
        label = 'revised_start_date'.tr;
        date = revisedStartDate![projectRole]!.toString()
            .getFormattedDateTime2(StringUtils.dateFormatDDMMMMYYYY);
        infoText = revisedWorkStartInfoText?[projectRole] ?? '';
        dateInfoVisibility = true;
        isExploreTextVisible = true;
      } else {
        dateCardIcon = 'assets/images/ic_sorry.svg';
        infoText = 'we_regret_to_inform_you_that'.tr;
        isExploreButtonVisible = true;
      }
    }
    return RequestWorkCardDetails(label, date, infoText, dateCardIcon,
        dateInfoVisibility, isExploreTextVisible, isExploreButtonVisible);
  }

  bool isRequestWorkVisibleCalc(
      FlavorCubit flavorCubit, int workAllocationDelay) {
    if (lastWorkRequestedAt == null) {
      return false;
    }
    try {
      DateTime dateTime = DateTime.parse(lastWorkRequestedAt!);
      DateTime newDateTime;
      if (flavorCubit.flavorConfig.appFlavor != AppFlavor.production) {
        newDateTime = DateTime(
            dateTime.year,
            dateTime.month,
            (dateTime.day + workAllocationDelay + 30),
            dateTime.hour,
            dateTime.minute,
            dateTime.second); //add N + 30 days
      } else {
        newDateTime = DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            (dateTime.minute + workAllocationDelay + 30),
            dateTime.second); //add N + 30 mins
      }
      return newDateTime.millisecondsSinceEpoch <
          DateTime.now().millisecondsSinceEpoch;
    } catch (e, st) {
      AppLog.e('isRequestWorkVisibleCalc : ${e.toString()} \n${st.toString()}');
      return false;
    }
  }

  bool isRegretMsgShown(FlavorCubit flavorCubit, int workAllocationDelay) {
    if (lastWorkRequestedAt == null) {
      return false;
    }
    try {
      DateTime dateTime = DateTime.parse(lastWorkRequestedAt!);
      DateTime newDateTime;
      if (flavorCubit.flavorConfig.appFlavor != AppFlavor.production) {
        newDateTime = DateTime(
            dateTime.year,
            dateTime.month,
            (dateTime.day + workAllocationDelay), //add N days
            dateTime.hour,
            dateTime.minute,
            dateTime.second); //add N + 30 days
      } else {
        newDateTime = DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            (dateTime.minute + workAllocationDelay),
            dateTime.second); //add N minutes
      }
      return newDateTime.millisecondsSinceEpoch <
          DateTime.now().millisecondsSinceEpoch;
    } catch (e, st) {
      AppLog.e('isRequestWorkVisibleCalc : ${e.toString()} \n${st.toString()}');
      return false;
    }
  }
}

class RequestWorkCardDetails {
  String? dateTitle, date, infoText, dateCardIcon;
  bool dateInfoVisibility;
  bool isExploreTextVisible;
  bool isExploreButtonVisible;

  RequestWorkCardDetails(
      this.dateTitle,
      this.date,
      this.infoText,
      this.dateCardIcon,
      this.dateInfoVisibility,
      this.isExploreTextVisible,
      this.isExploreButtonVisible);
}

class AllocationGroups {
  String? executive1;
  String? executive;
  String? qCExecutive;

  AllocationGroups({this.executive1, this.executive, this.qCExecutive});

  AllocationGroups.fromJson(Map<String, dynamic> json) {
    executive1 = json['executive1'];
    executive = json['Executive'];
    qCExecutive = json['QCExecutive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['executive1'] = executive1;
    data['Executive'] = executive;
    data['QCExecutive'] = qCExecutive;
    return data;
  }
}

class EarningsBreakupVisible {
  bool? executive1;
  bool? executive;
  bool? qCExecutive;

  EarningsBreakupVisible({this.executive1, this.executive, this.qCExecutive});

  EarningsBreakupVisible.fromJson(Map<String, dynamic> json) {
    executive1 = json['executive1'];
    executive = json['Executive'];
    qCExecutive = json['QCExecutive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['executive1'] = executive1;
    data['Executive'] = executive;
    data['QCExecutive'] = qCExecutive;
    return data;
  }
}

class SharedInformationData {
  dynamic value;
  String? title;

  SharedInformationData({this.value, this.title});

  SharedInformationData.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['title'] = title;
    return data;
  }
}

// class ManagerExecutions {
//
//
//   ManagerExecutions();
//
// ManagerExecutions.fromJson(Map<String, dynamic> json) {
// }
//
// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = <String, dynamic>{};
//   return data;
// }
// }

// class AllocationData {
//   Executive1? executive1;
//   Executive? executive;
//   Executive? qCExecutive;
//
//   AllocationData({this.executive1, this.executive, this.qCExecutive});
//
//   AllocationData.fromJson(Map<String, dynamic> json) {
//     executive1 = json['executive1'] != null ? Executive1.fromJson(json['executive1']) : null;
//     executive = json['Executive'] != null ? Executive.fromJson(json['Executive']) : null;
//     qCExecutive = json['QCExecutive'] != null ? Executive.fromJson(json['QCExecutive']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (executive1 != null) {
//       data['executive1'] = executive1!.toJson();
//     }
//     if (executive != null) {
//       data['Executive'] = executive!.toJson();
//     }
//     if (qCExecutive != null) {
//       data['QCExecutive'] = qCExecutive!.toJson();
//     }
//     return data;
//   }
// }

// class Executive1 {
//   Null? defaultRange;
//   Null? maximumRange;
//   Null? leadCapacity;
//   List<String>? capacityStatuses;
//
//   Executive1({this.defaultRange, this.maximumRange, this.leadCapacity, this.capacityStatuses});
//
//   Executive1.fromJson(Map<String, dynamic> json) {
//     defaultRange = json['default_range'];
//     maximumRange = json['maximum_range'];
//     leadCapacity = json['lead_capacity'];
//     capacityStatuses = json['capacity_statuses'].cast<String>();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['default_range'] = defaultRange;
//     data['maximum_range'] = maximumRange;
//     data['lead_capacity'] = leadCapacity;
//     data['capacity_statuses'] = capacityStatuses;
//     return data;
//   }
// }

// class Executive {
//   int? defaultRange;
//   int? maximumRange;
//   int? leadCapacity;
//   List<String>? capacityStatuses;
//
//   Executive({this.defaultRange, this.maximumRange, this.leadCapacity, this.capacityStatuses});
//
//   Executive.fromJson(Map<String, dynamic> json) {
//     defaultRange = json['default_range'];
//     maximumRange = json['maximum_range'];
//     leadCapacity = json['lead_capacity'];
//     capacityStatuses = json['capacity_statuses'].cast<String>();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['default_range'] = this.defaultRange;
//     data['maximum_range'] = this.maximumRange;
//     data['lead_capacity'] = this.leadCapacity;
//     data['capacity_statuses'] = this.capacityStatuses;
//     return data;
//   }
// }

// class QCExecutive {
//   Null? defaultRange;
//   Null? maximumRange;
//   Null? leadCapacity;
//   Null? capacityStatuses;
//
//   QCExecutive(
//       {this.defaultRange,
//       this.maximumRange,
//       this.leadCapacity,
//       this.capacityStatuses});
//
//   QCExecutive.fromJson(Map<String, dynamic> json) {
//     defaultRange = json['default_range'];
//     maximumRange = json['maximum_range'];
//     leadCapacity = json['lead_capacity'];
//     capacityStatuses = json['capacity_statuses'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['default_range'] = defaultRange;
//     data['maximum_range'] = maximumRange;
//     data['lead_capacity'] = leadCapacity;
//     data['capacity_statuses'] = capacityStatuses;
//     return data;
//   }
// }

// class LatLon {
//   double? longitude;
//   double? latitude;
//
//   LatLon({this.longitude, this.latitude});
//
//   LatLon.fromJson(Map<String, dynamic> json) {
//     longitude = json['longitude'];
//     latitude = json['latitude'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['longitude'] = longitude;
//     data['latitude'] = latitude;
//     return data;
//   }
// }

// class OfferLetterFiles {
//   Executive? executive;
//   Executive? qCExecutive;
//
//   OfferLetterFiles({this.executive, this.qCExecutive});
//
//   OfferLetterFiles.fromJson(Map<String, dynamic> json) {
//     executive = json['Executive'] != null
//         ? Executive.fromJson(json['Executive'])
//         : null;
//     qCExecutive = json['QCExecutive'] != null
//         ? Executive.fromJson(json['QCExecutive'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (executive != null) {
//       data['Executive'] = executive!.toJson();
//     }
//     if (qCExecutive != null) {
//       data['QCExecutive'] = qCExecutive!.toJson();
//     }
//     return data;
//   }
// }

class OfferLetterFiles {
  List<String>? pdf;
  List<String>? image;

  OfferLetterFiles({this.pdf, this.image});

  OfferLetterFiles.fromJson(Map<String, dynamic> json) {
    if (json['pdf'] != null) {
      pdf = json['pdf'].cast<String>();
    } else {
      pdf = null;
    }
    if (json['image'] != null) {
      image = json['image'].cast<String>();
    } else {
      image = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pdf'] = pdf;
    data['image'] = image;
    return data;
  }
}

class Executive {
  List<String>? pdf;
  List<String>? image;

  Executive({this.pdf, this.image});

  Executive.fromJson(Map<String, dynamic> json) {
    if (json['pdf'] != null) {
      pdf = json['pdf'].cast<String>();
    } else {
      pdf = null;
    }
    if (json['image'] != null) {
      image = json['image'].cast<String>();
    } else {
      image = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pdf'] = pdf;
    data['image'] = image;
    return data;
  }
}
