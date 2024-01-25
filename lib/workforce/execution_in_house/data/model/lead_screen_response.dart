import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';

class LeadScreenResponse {
  List<DataView>? dataViews;
  int? limit;
  int? page;
  int? offset;
  int? total;
  Screen? screen;

  LeadScreenResponse({this.dataViews, this.limit, this.page, this.offset, this.total});

  LeadScreenResponse.fromJson(Map<String, dynamic> json, int userID, int applicationID) {
    if (json['data_views'] != null) {
      dataViews = <DataView>[];
      json['data_views'].forEach((v) {
        dataViews!.add(DataView.fromJson(v, userID, applicationID));
      });
    }
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
    screen = json['screen'] != null
        ? Screen.fromJson(json['screen'], userID, applicationID)
        : null;
    if(screen == null && !dataViews.isNullOrEmpty && dataViews![0].startScreen != null) {
      screen = dataViews![0].startScreen;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dataViews != null) {
      data['data_views'] = dataViews!.map((v) => v.toJson()).toList();
    }
    data['limit'] = limit;
    data['page'] = page;
    data['offset'] = offset;
    data['total'] = total;
    return data;
  }
}

class DataView {
  String? id;
  bool? active;
  String? createdAt;
  String? projectId;
  String? projectRoleId;
  String? sampleLeadScenarioId;
  String? updatedAt;
  String? url;
  String? viewType;
  String? workflowStatus;
  Screen? startScreen;

  DataView(
      {this.id,
        this.active,
        this.createdAt,
        this.projectId,
        this.projectRoleId,
        this.sampleLeadScenarioId,
        this.updatedAt,
        this.url,
        this.viewType,
        this.workflowStatus,
        this.startScreen});

  DataView.fromJson(Map<String, dynamic> json, int userID, int applicationID) {
    id = json['_id'];
    active = json['active'];
    createdAt = json['created_at'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    sampleLeadScenarioId = json['sample_lead_scenario_id'];
    updatedAt = json['updated_at'];
    url = json['url'];
    viewType = json['view_type'];
    workflowStatus = json['workflow_status'];
    startScreen = json['start_screen'] != null
        ? Screen.fromJson(json['start_screen'], userID, applicationID)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['active'] = active;
    data['created_at'] = createdAt;
    data['project_id'] = projectId;
    data['project_role_id'] = projectRoleId;
    data['sample_lead_scenario_id'] = sampleLeadScenarioId;
    data['updated_at'] = updatedAt;
    data['url'] = url;
    data['view_type'] = viewType;
    data['workflow_status'] = workflowStatus;
    if (startScreen != null) {
      data['start_screen'] = startScreen!.toJson();
    }
    return data;
  }
}