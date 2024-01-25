class Project {
  String? sAppConfig;
  String? id;
  String? name;
  String? description;
  Map<String, dynamic>? showWorklogConfig;
  List<FAQ>? faqs;
  String? leadLabel;
  List<ProjectRoles>? projectRoles;
  Workflow? workflow;
  String? updatedAt;
  Map<String, dynamic>? showFaqs;
  bool? archivedStatus;

  Project(
      {this.sAppConfig,
      this.description,
      this.faqs,
      this.leadLabel,
      this.name,
      this.showFaqs,
      this.showWorklogConfig,
      this.updatedAt,
      this.projectRoles,
      this.workflow});

  Project.fromJson(Map<String, dynamic> json) {
    sAppConfig = json['_app_config'];
    id = json['_id'];
    name = json['name'];
    showWorklogConfig = json['show_worklog_config'];
    description = json['description'];
    if (json['faqs'] != null) {
      faqs = <FAQ>[];
      json['faqs'].forEach((v) {
        faqs!.add(FAQ.fromJson(v));
      });
    }
    leadLabel = json['lead_label'];
    if (json['project_roles'] != null) {
      projectRoles = <ProjectRoles>[];
      json['project_roles'].forEach((v) {
        projectRoles!.add(ProjectRoles.fromJson(v));
      });
    }
    workflow =
        json['workflow'] != null ? Workflow.fromJson(json['workflow']) : null;
    updatedAt = json['updated_at'];
    showFaqs = json['show_faqs'];
    archivedStatus = json['archived_status'];
  }

  ProjectRoles? getProjectRole(String strSelectedRole) {
    ProjectRoles? projectRole;
    for (ProjectRoles pr in projectRoles ?? []) {
      if (pr.uid == strSelectedRole) {
        projectRole = pr;
        break;
      }
    }
    return projectRole;
  }
}

class FAQ {
  String? question;
  String? answer;

  FAQ({this.question, this.answer});

  FAQ.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    answer = json['answer'];
  }
}

class ProjectRoles {
  String? id;
  String? uid;
  String? name;
  bool? isManager;
  bool? availability;
  bool? workingStatus;
  late bool activeUsersVisible;
  int? activeWorkforceCount;
  PotentialEarning? potentialEarning;
  int? workAllocationDelay;

  ProjectRoles.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    uid = json['uid'];
    name = json['name'];
    isManager = json['is_manager'];
    availability = json['availability'];
    workingStatus = json['working_status'];
    activeUsersVisible = json['active_users_visible'] ?? false;
    activeWorkforceCount = json['active_workforce_count'];
    potentialEarning = json['potential_earning'] != null
        ? PotentialEarning.fromJson(json['potential_earning'])
        : null;
    workAllocationDelay = json['work_allocation_delay'];
  }
}

class PotentialEarning {
  String? earningType;
  String? from;
  String? to;
  String? earningDuration;

  PotentialEarning.fromJson(Map<String, dynamic> json) {
    earningType = json['earning_type'];
    from = json['from'];
    to = json['to'];
    earningDuration = json['earning_duration'];
  }
}

class Workflow {
  String? id;
  List<String>? statuses;
  Map<String, dynamic>? statusAliases;

  Workflow({this.id, this.statusAliases, this.statuses});

  Workflow.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    statuses = json['statuses'].cast<String>();
    statusAliases = json['status_aliases'];
  }
}
