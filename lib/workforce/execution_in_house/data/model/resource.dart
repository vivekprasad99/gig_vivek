class ResourceResponse {
  List<Resource>? resources = [];

  ResourceResponse({this.resources});

  ResourceResponse.fromJson(Map<String, dynamic> json) {
    if (json['resources'] != null) {
      json['resources'].forEach((v) {
        resources!.add(Resource.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.resources != null) {
      data['resources'] = this.resources!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Resource {
  String? stepName;
  String? status;
  List<Material>? material = [];

  Resource({this.stepName, this.status, this.material});

  Resource.fromJson(Map<String, dynamic> json) {
    stepName = json['step_name'];
    status = json['status'];
    if (json['material'] != null) {
      // material = <Material>[];
      json['material'].forEach((v) {
        material!.add(Material.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['step_name'] = this.stepName;
    data['status'] = this.status;
    if (this.material != null) {
      data['material'] = this.material!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Material {
  int? id;
  int? inAppTrainingConfigId;
  Null? inAppTrainingQuestionId;
  String? title;
  String? fileType;
  String? filePath;
  String? createdAt;
  String? updatedAt;
  int? webinarTrainingConfigId;

  Material(
      {this.id,
      this.inAppTrainingConfigId,
      this.inAppTrainingQuestionId,
      this.title,
      this.fileType,
      this.filePath,
      this.createdAt,
      this.updatedAt,
      this.webinarTrainingConfigId});

  Material.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    inAppTrainingConfigId = json['in_app_training_config_id'];
    inAppTrainingQuestionId = json['in_app_training_question_id'];
    title = json['title'];
    fileType = json['file_type'];
    filePath = json['file_path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    webinarTrainingConfigId = json['webinar_training_config_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['in_app_training_config_id'] = this.inAppTrainingConfigId;
    data['in_app_training_question_id'] = this.inAppTrainingQuestionId;
    data['title'] = this.title;
    data['file_type'] = this.fileType;
    data['file_path'] = this.filePath;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['webinar_training_config_id'] = this.webinarTrainingConfigId;
    return data;
  }
}
