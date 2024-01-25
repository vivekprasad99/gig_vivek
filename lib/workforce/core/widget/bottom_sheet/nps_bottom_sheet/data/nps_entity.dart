class NpsEntity {
  Nps? data;

  NpsEntity({this.data});

  NpsEntity.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Nps.fromJson(json['data']) : null;
  }
}

class Nps {
  List<Actions>? actions;

  Nps({this.actions});

  Nps.fromJson(Map<String, dynamic> json) {
    if (json['actions'] != null) {
      actions = <Actions>[];
      json['actions'].forEach((v) {
        actions!.add(Actions.fromJson(v));
      });
    }
  }
}

class Actions {
  int? id;
  int? userId;
  String? actionName;
  String? status;
  String? startDueDate;
  String? createdAt;
  String? updatedAt;

  Actions(
      {this.id,
        this.userId,
        this.actionName,
        this.status,
        this.startDueDate,
        this.createdAt,
        this.updatedAt});

  Actions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    actionName = json['action_name'];
    status = json['status'];
    startDueDate = json['start_due_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['action_name'] = this.actionName;
    data['status'] = this.status;
    data['start_due_date'] = this.startDueDate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
