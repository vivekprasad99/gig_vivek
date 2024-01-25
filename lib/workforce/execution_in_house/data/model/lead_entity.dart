import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';
import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/exception/exception.dart';

enum LeadOption { Duplicate, Delete }

class LeadsAnalysis {
  Map<String, dynamic>? status;

  LeadsAnalysis({this.status});

  LeadsAnalysis.fromJson(Map<String, dynamic> json) {
    status = json['_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (status != null) {
      data['_status'] = status;
    }
    return data;
  }
}

class LeadRemoteRequest {
  String? searchTerm;
  String? listViewID;
  String? blockID;
  List<Map<String, QueryCondition>>? filters;
  late LeadDataSourceParams leadDataSourceParams;

  LeadRemoteRequest(
      {this.searchTerm,
      this.listViewID,
      this.blockID,
      this.filters,
      required this.leadDataSourceParams});
}

class LeadDataSourceParams {
  String? executionID;
  String? projectID;
  String? projectRoleUID;
  String? executionSourceID;
  String? projectRoleName;
  String? scenarioID;
  String? currentStatus;
  String? status;
  ScreenViewType? screenViewType;
  Map<String, dynamic>? statusAliases;
  String? projectIcon;

  LeadDataSourceParams(
      {this.executionID,
      this.projectID,
      this.projectRoleUID,
      this.executionSourceID,
      this.projectRoleName,
      this.scenarioID,
      this.currentStatus,
      this.status,
      this.screenViewType = ScreenViewType.updateLead,
      this.statusAliases,
      this.projectIcon});
}

class ScreenViewType<String> extends Enum1<String> {
  const ScreenViewType(String val) : super(val);

  static const ScreenViewType addLead = ScreenViewType('addLead');
  static const ScreenViewType updateLead = ScreenViewType('updateLead');
  static const ScreenViewType sampleLead = ScreenViewType('sampleLead');
  static const ScreenViewType duplicateLead = ScreenViewType('duplicateLead');
}

class LeadSearchResponse {
  List<Map<String, dynamic>>? leadMapList;
  int? limit;
  int? page;
  int? offset;
  int? total;
  bool? misspellings;
  List<Lead>? leads;

  LeadSearchResponse(
      {this.leadMapList,
      this.limit,
      this.page,
      this.offset,
      this.total,
      this.misspellings});

  LeadSearchResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic>? leadsJsonList = json['leads'];
    leadMapList = [];
    leadsJsonList?.forEach((element) {
      leadMapList?.add(element);
    });
    // leadMapList = json['leads'];
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
    misspellings = json['misspellings'];
    leads = [];
    leadMapList?.forEach((element) {
      leads?.add(Lead(element));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['leads'] = leadMapList;
    data['limit'] = limit;
    data['page'] = page;
    data['offset'] = offset;
    data['total'] = total;
    data['misspellings'] = misspellings;
    return data;
  }
}

class Lead {
  static const id = '_id';
  static const status = 'status';
  static const sstatus = '_status';
  static const updatedAt = 'updated_at';
  static const visibility = '_visibility';
  static const deadline = '_deadline';
  static const payoutSurgeFactor = '_payout_surge_factor';
  static const payoutSurgeReason = '_payout_surge_reason';
  static const payoutSurge = '_payout_surge';
  static const priorityData = '_priority_data';
  static const priorityReason = '_priority_reason';

  late Map<String, dynamic> leadMap;
  int? version;

  Lead(this.leadMap);

  Object? get(String key) {
    return leadMap[key];
  }

  String getLeadID() {
    String? leadID = leadMap[id];
    if (leadID != null) {
      return leadID;
    } else {
      throw FailureException(0, 'Lead id cannot be null');
    }
  }

  String getUpdatedAt() {
    String? updatedAt = leadMap[Lead.updatedAt];
    if (updatedAt != null) {
      return updatedAt;
    } else {
      throw FailureException(0, 'Lead updated at cannot be null');
    }
  }

  String? getStatus() {
    String? status = leadMap[Lead.status];
    if (status != null) {
      return status;
    } else {
      status = leadMap[Lead.sstatus];
      return status;
    }
  }

  Map<String, bool>? getVisibility() {
    Map<String, bool>? visibility = leadMap[Lead.visibility];
    return visibility;
  }

  dynamic getLeadAnswerValue(String? questionUID) {
    return leadMap[questionUID];
  }

  Lead.fromJson(Map<String, dynamic> json) {
    leadMap = json['lead'] ?? {};
    version = json['version'];
  }
}

class LeadUpdateRequest {
  Map<String, dynamic> lead;
  int? version;

  LeadUpdateRequest(this.lead, this.version);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lead'] = lead;
    data['version'] = version;
    return data;
  }
}
