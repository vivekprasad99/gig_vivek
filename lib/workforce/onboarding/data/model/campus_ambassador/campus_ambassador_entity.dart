class CampusAmbassdor {
  CampusAmbassador? campusAmbassador;

  CampusAmbassdor({this.campusAmbassador});

  CampusAmbassdor.fromJson(Map<String, dynamic> json) {
    campusAmbassador = json['campus_ambassador'] != null
        ? CampusAmbassador.fromJson(json['campus_ambassador'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (campusAmbassador != null) {
      data['campus_ambassador'] = campusAmbassador!.toJson();
    }
    return data;
  }
}

class CampusAmbassador {
  int? organisationId;
  String? phoneNumber;
  String? referralCode;
  int? userId;

  CampusAmbassador(
      {this.organisationId, this.phoneNumber, this.referralCode, this.userId});

  CampusAmbassador.fromJson(Map<String, dynamic> json) {
    organisationId = json['organisation_id'];
    phoneNumber = json['phone_number'];
    referralCode = json['referral_code'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['organisation_id'] = organisationId;
    data['phone_number'] = phoneNumber;
    data['referral_code'] = referralCode;
    data['user_id'] = userId;
    return data;
  }
}

class CampusAmbassdorTaskRespons {
  List<CampusAmbassadorTasks>? campusAmbassadorTasks;
  int? page;
  int? limit;
  int? offset;
  int? total;

  CampusAmbassdorTaskRespons(
      {this.campusAmbassadorTasks,
      this.page,
      this.limit,
      this.offset,
      this.total});

  CampusAmbassdorTaskRespons.fromJson(Map<String, dynamic> json) {
    if (json['campus_ambassador_tasks'] != null) {
      campusAmbassadorTasks = <CampusAmbassadorTasks>[];
      json['campus_ambassador_tasks'].forEach((v) {
        campusAmbassadorTasks!.add(new CampusAmbassadorTasks.fromJson(v));
      });
    }
    page = json['page'];
    limit = json['limit'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.campusAmbassadorTasks != null) {
      data['campus_ambassador_tasks'] =
          this.campusAmbassadorTasks!.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    data['total'] = this.total;
    return data;
  }
}

class CampusAmbassadorTasks {
  int? id;
  int? campusAmbassadorId;
  String? campusAmbassadorName;
  String? status;
  int? worklistingId;
  String? comments;
  String? createdAt;
  String? updatedAt;
  String? referralCode;
  int? referralCount;
  String? worklistingName;
  String? executionProjectId;

  CampusAmbassadorTasks(
      {this.id,
      this.campusAmbassadorId,
      this.campusAmbassadorName,
      this.status,
      this.worklistingId,
      this.comments,
      this.createdAt,
      this.updatedAt,
      this.referralCode,
      this.referralCount,
      this.worklistingName,
      this.executionProjectId});

  CampusAmbassadorTasks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    campusAmbassadorId = json['campus_ambassador_id'];
    campusAmbassadorName = json['campus_ambassador_name'];
    status = json['status'];
    worklistingId = json['worklisting_id'];
    comments = json['comments'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    referralCode = json['referral_code'];
    referralCount = json['referral_count'];
    worklistingName = json['worklisting_name'];
    executionProjectId = json['execution_project_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['campus_ambassador_id'] = this.campusAmbassadorId;
    data['campus_ambassador_name'] = this.campusAmbassadorName;
    data['status'] = this.status;
    data['worklisting_id'] = this.worklistingId;
    data['comments'] = this.comments;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['referral_code'] = this.referralCode;
    data['referral_count'] = this.referralCount;
    data['worklisting_name'] = this.worklistingName;
    data['execution_project_id'] = this.executionProjectId;
    return data;
  }
}
