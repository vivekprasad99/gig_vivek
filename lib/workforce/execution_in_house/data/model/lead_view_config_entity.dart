class ListViewsRequest {
  ListViewsRequest({this.limit, this.sortColumn, this.sortOrder});

  int? limit;
  String? sortColumn;
  String? sortOrder;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['limit'] = limit;
    _data['sort_column'] = sortColumn;
    _data['sort_order'] = sortOrder;
    return _data;
  }
}

class ListViewConfigData {
  List<ListViews>? listViews;
  List<Tabs>? tabs;
  Map<String, dynamic>? statusAliases;
  int? total;
  Map<String, int>? analyzeCounts;

  ListViewConfigData(
      {this.listViews, this.tabs, this.statusAliases, this.total});

  ListViewConfigData.fromJson(Map<String, dynamic> json) {
    if (json['list_views'] != null) {
      listViews = <ListViews>[];
      json['list_views'].forEach((v) {
        listViews!.add(ListViews.fromJson(v));
      });
    }
    if (json['tabs'] != null) {
      tabs = <Tabs>[];
      json['tabs'].forEach((v) {
        tabs!.add(Tabs.fromJson(v));
      });
    }
    statusAliases = json['status_aliases'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listViews != null) {
      data['list_views'] = listViews!.map((v) => v.toJson()).toList();
    }
    if (tabs != null) {
      data['tabs'] = tabs!.map((v) => v.toJson()).toList();
    }
    if (statusAliases != null) {
      data['status_aliases'] = statusAliases;
    }
    data['total'] = total;
    return data;
  }
}

class ListViews {
  String? id;
  bool? allowAddLead;
  bool? allowCloneLead;
  bool? allowDeleteLead;
  bool? allowWorkRequest;
  List<Columns>? columns;
  String? createdAt;
  bool? enableMapView;
  String? mapViewAttribute;
  String? projectId;
  String? projectRoleId;
  String? uid;
  String? updatedAt;
  int? version;
  String? workflowStatus;

  ListViews(
      {this.id,
      this.allowAddLead,
      this.allowCloneLead,
      this.allowDeleteLead,
      this.allowWorkRequest,
      this.columns,
      this.createdAt,
      this.enableMapView,
      this.mapViewAttribute,
      this.projectId,
      this.projectRoleId,
      this.uid,
      this.updatedAt,
      this.version,
      this.workflowStatus});

  ListViews.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    allowAddLead = json['allow_add_lead'];
    allowCloneLead = json['allow_clone_lead'];
    allowDeleteLead = json['allow_delete_lead'];
    allowWorkRequest = json['allow_work_request'];
    if (json['columns'] != null) {
      columns = <Columns>[];
      json['columns'].forEach((v) {
        columns!.add(Columns.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    enableMapView = json['enable_map_view'];
    mapViewAttribute = json['map_view_attribute'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    uid = json['uid'];
    updatedAt = json['updated_at'];
    version = json['version'];
    workflowStatus = json['workflow_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['allow_add_lead'] = allowAddLead;
    data['allow_clone_lead'] = allowCloneLead;
    data['allow_delete_lead'] = allowDeleteLead;
    data['allow_work_request'] = allowWorkRequest;
    if (columns != null) {
      data['columns'] = columns!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['enable_map_view'] = enableMapView;
    data['map_view_attribute'] = mapViewAttribute;
    data['project_id'] = projectId;
    data['project_role_id'] = projectRoleId;
    data['uid'] = uid;
    data['updated_at'] = updatedAt;
    data['version'] = version;
    data['workflow_status'] = workflowStatus;
    return data;
  }
}

class Columns {
  String? uid;
  String? columnTitle;
  bool? editable;
  bool? sortable;
  String? action;
  late bool primary;
  String? dataType;
  String? renderType;

  Columns(
      {this.uid,
      this.columnTitle,
      this.editable,
      this.sortable,
      this.action,
      this.primary = false,
      this.dataType,
      this.renderType});

  Columns.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    columnTitle = json['column_title'];
    editable = json['editable'];
    sortable = json['sortable'];
    action = json['action'];
    primary = json['primary'] ?? false;
    dataType = json['data_type'];
    renderType = json['render_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['column_title'] = columnTitle;
    data['editable'] = editable;
    data['sortable'] = sortable;
    data['action'] = action;
    data['primary'] = primary;
    data['data_type'] = dataType;
    data['render_type'] = renderType;
    return data;
  }
}

class Tabs {
  String? id;
  String? createdAt;
  String? name;
  int? priority;
  String? projectId;
  String? projectRoleId;
  List<String>? statuses;
  String? tabId;
  String? updatedAt;
  int? version;
  String? workflowId;

  Tabs(
      {this.id,
      this.createdAt,
      this.name,
      this.priority,
      this.projectId,
      this.projectRoleId,
      this.statuses,
      this.tabId,
      this.updatedAt,
      this.version,
      this.workflowId});

  Tabs.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    createdAt = json['created_at'];
    name = json['name'];
    priority = json['priority'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    statuses = json['statuses'].cast<String>();
    tabId = json['tab_id'];
    updatedAt = json['updated_at'];
    version = json['version'];
    workflowId = json['workflow_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['priority'] = priority;
    data['project_id'] = projectId;
    data['project_role_id'] = projectRoleId;
    data['statuses'] = statuses;
    data['tab_id'] = tabId;
    data['updated_at'] = updatedAt;
    data['version'] = version;
    data['workflow_id'] = workflowId;
    return data;
  }
}
