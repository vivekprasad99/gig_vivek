class CategoryApplicationResponse {
  static const String status = 'status';
  static const String supplyPendingAction = 'supply_pending_action';

  CategoryApplicationResponse({
    required this.categoryApplications,
    required this.total,
  });
  late List<CategoryApplication>? categoryApplications;
  late int? total;

  CategoryApplicationResponse.fromJson(Map<String, dynamic> json) {
    categoryApplications = json['category_applications'] != null
        ? List.from(json['category_applications'])
            .map((e) => CategoryApplication.fromJson(e))
            .toList()
        : null;
    total = json['total'];
  }
}

class CategoryApplication {
  CategoryApplication({
    required this.id,
    required this.categoryId,
    required this.uids,
    required this.name,
    required this.categoryType,
    required this.icon,
    required this.status,
    required this.myJobsCount,
    required this.listingCount,
    required this.pendingJobCount,
    required this.updatedAt,
  });

  late int? id;
  late int? categoryId;
  late String? uids;
  late String? name;
  late String? categoryType;
  late String? icon;
  late String? status;
  late int? myJobsCount;
  late int? listingCount;
  late int? pendingJobCount;
  late String? updatedAt;

  CategoryApplication.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    uids = json['category_uid'];
    name = json['category_title'];
    categoryType = json['category_type'];
    icon = json['icon'];
    status = json['status'];
    myJobsCount = json['executions_started_count'];
    listingCount = json['listing_count'];
    pendingJobCount = json['applications_count'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['category_id'] = categoryId;
    _data['category_uids'] = uids;
    _data['category_title'] = name;
    _data['category_type'] = categoryType;
    _data['icon'] = icon;
    _data['status'] = status;
    _data['executions_started_count'] = myJobsCount;
    _data['listing_count'] = listingCount;
    _data['applications_count'] = pendingJobCount;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}
