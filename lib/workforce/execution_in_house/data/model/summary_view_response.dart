class SummaryViewResponse {
  List<SummaryView>? summaryViews;
  int? limit;
  int? page;
  int? offset;
  int? total;

  SummaryViewResponse({this.summaryViews, this.limit, this.page, this.offset, this.total});

  SummaryViewResponse.fromJson(Map<String, dynamic> json) {
    if (json['summary_views'] != null) {
      summaryViews = <SummaryView>[];
      json['summary_views'].forEach((v) {
        summaryViews!.add(SummaryView.fromJson(v));
      });
    }
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summaryViews != null) {
      data['summary_views'] =
          summaryViews!.map((v) => v.toJson()).toList();
    }
    data['limit'] = limit;
    data['page'] = page;
    data['offset'] = offset;
    data['total'] = total;
    return data;
  }
}

class SummaryView {
  String? id;
  String? createdAt;
  String? projectId;
  String? projectRoleId;
  String? updatedAt;

  SummaryView(
      {this.id,
        this.createdAt,
        this.projectId,
        this.projectRoleId,
        this.updatedAt});

  SummaryView.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    createdAt = json['created_at'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['created_at'] = createdAt;
    data['project_id'] = projectId;
    data['project_role_id'] = projectRoleId;
    data['updated_at'] = updatedAt;
    return data;
  }
}