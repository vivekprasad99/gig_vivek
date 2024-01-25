class CampusAmbassadorResponse {
  int? id;
  int? organisationId;
  int? userId;
  String? name;
  String? status;
  String? referralCode;
  String? createdAt;
  String? updatedAt;
  String? city;
  String? phoneNumber;
  int? totalReferralCount;
  String? approvedBy;
  List? campusAmbassadorTasks;

  CampusAmbassadorResponse(
      {this.id,
      this.organisationId,
      this.userId,
      this.name,
      this.status,
      this.referralCode,
      this.createdAt,
      this.updatedAt,
      this.city,
      this.phoneNumber,
      this.totalReferralCount,
      this.approvedBy,
      this.campusAmbassadorTasks});

  CampusAmbassadorResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    organisationId = json['organisation_id'];
    userId = json['user_id'];
    name = json['name'];
    status = json['status'];
    referralCode = json['referral_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    city = json['city'];
    phoneNumber = json['phone_number'];
    totalReferralCount = json['total_referral_count'];
    approvedBy = json['approved_by'];
    if (json['campus_ambassador_tasks'] != null) {
      campusAmbassadorTasks = [];
      json['campus_ambassador_tasks'].forEach((v) {
        campusAmbassadorTasks!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['organisation_id'] = this.organisationId;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['referral_code'] = this.referralCode;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['city'] = this.city;
    data['phone_number'] = this.phoneNumber;
    data['total_referral_count'] = this.totalReferralCount;
    data['approved_by'] = this.approvedBy;
    if (this.campusAmbassadorTasks != null) {
      data['campus_ambassador_tasks'] =
          this.campusAmbassadorTasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CampusAmbassadorTaskData {
  int? page;

  CampusAmbassadorTaskData({
    required this.page,
  });

  CampusAmbassadorTaskData.fromJson(Map<String, dynamic> json) {
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['page'] = page;
    return data;
  }
}

class CampusAmbassadorAnalyticsResponse {
  Map<String, dynamic>? analytics;

  CampusAmbassadorAnalyticsResponse(this.analytics);

  CampusAmbassadorAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    analytics = json['analytics'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['analytics'] = analytics;
    return data;
  }
}
