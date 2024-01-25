import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';

class WorklogResponse {
  List<WorklogConfigs>? worklogConfigs;

  WorklogResponse({this.worklogConfigs});

  WorklogResponse.fromJson(Map<String, dynamic> json) {
    if (json['worklog_configs'] != null) {
      worklogConfigs = <WorklogConfigs>[];
      json['worklog_configs'].forEach((v) {
        worklogConfigs!.add(WorklogConfigs.fromJson(v));
      });
    }
  }
}

class WorklogConfigs {
  String? id;
  String? projectId;
  String? projectRoleId;
  List<ScreenQuestion>? worklogQuestions;
  List<Question>? questions;

  WorklogConfigs(
      {this.id,
      this.projectId,
      this.projectRoleId,
      this.worklogQuestions,
      this.questions});

  WorklogConfigs.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    if (json['questions'] != null) {
      worklogQuestions = <ScreenQuestion>[];
      json['questions'].forEach((v) {
        worklogQuestions!.add(ScreenQuestion.fromJson(v));
      });
    }
    questions = QuestionMapper.transformWorklogQuestions(
        worklogQuestions, id, projectId ?? '');
  }
}

class WorklogRequest {
  Map<String, dynamic> worklog;

  WorklogRequest(this.worklog);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['worklog'] = worklog;
    return data;
  }
}
