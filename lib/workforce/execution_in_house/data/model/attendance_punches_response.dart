import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/model/enum.dart';

import '../../../core/data/model/module_type.dart';

enum ScreenTitle {
  takeSelfie('Take a selfie'),
  yourLocation('Your location'),
  uploadImage('Upload Image'),
  inputFields('Input Fields');

  const ScreenTitle(this.value);
  final String value;

  static ScreenTitle get(status) {
    switch (status) {
      case 'Take a selfie':
        return ScreenTitle.takeSelfie;
      case 'Your location':
        return ScreenTitle.yourLocation;
      case 'Upload Image':
        return ScreenTitle.uploadImage;
      case 'Input Fields':
        return ScreenTitle.inputFields;
      default:
        return ScreenTitle.takeSelfie;
    }
  }
}

class AttendancePunch {
  AttendancePunchesResponse? data;

  AttendancePunch({this.data});

  AttendancePunch.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? AttendancePunchesResponse.fromJson(json['data'])
        : null;
  }
}

class AttendancePunchesResponse {
  List<AttendancePunches>? attendancePunches;
  int? limit;
  int? page;
  int? offset;

  AttendancePunchesResponse(
      {this.attendancePunches, this.limit, this.page, this.offset});

  AttendancePunchesResponse.fromJson(Map<String, dynamic> json) {
    if (json['attendance_punches'] != null) {
      attendancePunches = <AttendancePunches>[];
      json['attendance_punches'].forEach((v) {
        attendancePunches!.add(AttendancePunches.fromJson(v));
      });
    }
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
  }
}

class AttendancePunches {
  String? sId;
  String? approvalStatus;
  String? attendanceConfigurationId;
  String? attendanceDate;
  String? attendanceStatus;
  String? createdAt;
  String? executionId;
  String? memberId;
  String? name;
  String? projectId;
  String? projectRoleId;
  List<String>? punchInInputs;
  List<String>? punchInOutputs;
  String? punchInTime;
  String? punchOutTime;
  String? punchStatus;
  String? updatedAt;
  String? nextPunchCta;
  AttendanceConfiguration? attendanceConfiguration;

  AttendancePunches(
      {this.sId,
      this.approvalStatus,
      this.attendanceConfigurationId,
      this.attendanceDate,
      this.attendanceStatus,
      this.createdAt,
      this.executionId,
      this.memberId,
      this.name,
      this.projectId,
      this.projectRoleId,
      this.punchInInputs,
      this.punchInOutputs,
      this.punchInTime,
      this.punchOutTime,
      this.punchStatus,
      this.updatedAt,
      this.nextPunchCta,
      this.attendanceConfiguration});

  AttendancePunches.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    approvalStatus = json['approval_status'];
    attendanceConfigurationId = json['attendance_configuration_id'];
    attendanceDate = json['attendance_date'];
    attendanceStatus = json['attendance_status'];
    createdAt = json['created_at'];
    executionId = json['execution_id'];
    memberId = json['member_id'];
    name = json['name'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    if (json['punch_in_inputs'] != null) {
      punchInInputs = json['punch_in_inputs'].cast<String>();
    }
    if (json['punch_in_outputs'] != null) {
      punchInOutputs = json['punch_in_outputs'].cast<String>();
    }
    punchInTime = json['punch_in_time'];
    punchOutTime = json['punch_out_time'];
    punchStatus = json['punch_status'];
    updatedAt = json['updated_at'];
    nextPunchCta = json['next_punch_cta'];
    attendanceConfiguration = json['attendance_configuration'] != null
        ? AttendanceConfiguration.fromJson(json['attendance_configuration'])
        : null;
  }
}

class AttendanceConfiguration {
  String? sId;

  // AdditionalConditions? additionalConditions;
  bool? approvalNeeded;
  String? createdAt;
  String? endDate;
  bool? inputRequired;
  String? name;
  String? projectId;
  String? projectRoleId;
  List<PunchesConfiguration>? punchesConfiguration;
  String? startDate;
  String? status;
  String? updatedAt;
  String? projectName;
  List<int>? weeklyOff;
  AttendanceInputConfiguration? attendanceInputConfiguration;

  AttendanceConfiguration(
      {this.sId,
      this.approvalNeeded,
      this.createdAt,
      this.endDate,
      this.inputRequired,
      this.name,
      this.projectId,
      this.projectRoleId,
      this.punchesConfiguration,
      this.startDate,
      this.status,
      this.updatedAt,
      this.projectName,
      this.weeklyOff,
      this.attendanceInputConfiguration});

  AttendanceConfiguration.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    approvalNeeded = json['approval_needed'];
    createdAt = json['created_at'];
    endDate = json['end_date'];
    inputRequired = json['input_required'];
    name = json['name'];
    projectId = json['project_id'];
    projectRoleId = json['project_role_id'];
    if (json['punches_configuration'] != null) {
      punchesConfiguration = <PunchesConfiguration>[];
      json['punches_configuration'].forEach((v) {
        punchesConfiguration!.add(PunchesConfiguration.fromJson(v));
      });
    }
    startDate = json['start_date'];
    status = json['status'];
    updatedAt = json['updated_at'];
    projectName = json['project_name'];
    weeklyOff = json['weekly_off'].cast<int>();
    attendanceInputConfiguration =
        json['attendance_input_configuration'] != null
            ? AttendanceInputConfiguration.fromJson(
                json['attendance_input_configuration'])
            : null;
  }
}

class PunchesConfiguration {
  String? punchType;
  String? minTime;
  String? maxTime;
  bool? isMandatory;

  PunchesConfiguration(
      {this.punchType, this.minTime, this.maxTime, this.isMandatory});

  PunchesConfiguration.fromJson(Map<String, dynamic> json) {
    punchType = json['punch_type'];
    minTime = json['min_time'];
    maxTime = json['max_time'];
    isMandatory = json['is_mandatory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['punch_type'] = this.punchType;
    data['min_time'] = this.minTime;
    data['max_time'] = this.maxTime;
    data['is_mandatory'] = this.isMandatory;
    return data;
  }
}

class AttendanceInputConfiguration {
  String? sId;
  String? attendanceConfigurationId;
  String? createdAt;
  List<PunchInScreens>? punchInScreens;
  List<PunchInScreens>? punchOutScreens;
  String? updatedAt;

  AttendanceInputConfiguration(
      {this.sId,
      this.attendanceConfigurationId,
      this.createdAt,
      this.punchInScreens,
      this.punchOutScreens,
      this.updatedAt});

  AttendanceInputConfiguration.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    attendanceConfigurationId = json['attendance_configuration_id'];
    createdAt = json['created_at'];
    if (json['punch_in_screens'] != null) {
      punchInScreens = <PunchInScreens>[];
      json['punch_in_screens'].forEach((v) {
        punchInScreens!.add(PunchInScreens.fromJson(v));
      });
    }
    if (json['punch_out_screens'] != null) {
      punchOutScreens = <PunchInScreens>[];
      json['punch_out_screens'].forEach((v) {
        punchOutScreens!.add(PunchInScreens.fromJson(v));
      });
    }
    updatedAt = json['updated_at'];
  }
}

class PunchInScreens {
  String? screenTitle;
  List<ScreenQuestion>? screenQuestionList;
  List<Question>? questions;
  ScreenTitle? screenTitleEntity;

  PunchInScreens({this.screenTitle, this.questions, this.screenTitleEntity});

  PunchInScreens.fromJson(Map<String, dynamic> json) {
    screenTitle = json['screen_title'];
    if (json['questions'] != null) {
      screenQuestionList = <ScreenQuestion>[];
      json['questions'].forEach((v) {
        screenQuestionList!.add(ScreenQuestion.fromJson(v));
      });
    }
    questions = QuestionMapper.transformScreenQuestions(
      screenQuestionList,
      0,
      0,
      0,
      ModuleType.attendance,
      dynamicModuleCategory: DynamicModuleCategory.attendance,
    );
    screenTitleEntity = ScreenTitle.get(json['screen_title']);
  }
}

// class PunchOutScreens {
//   String? screenTitle;
//   List<ScreenQuestion>? screenQuestionList;
//   List<Question>? questions;
//   ScreenTitle? screenTitleEntity;
//
//   PunchOutScreens({this.screenTitle, this.questions});
//
//   PunchOutScreens.fromJson(Map<String, dynamic> json) {
//     screenTitle = json['screen_title'];
//     if (json['questions'] != null) {
//       screenQuestionList = <ScreenQuestion>[];
//       json['questions'].forEach((v) {
//         screenQuestionList!.add(ScreenQuestion.fromJson(v));
//       });
//     }
//     questions = QuestionMapper.transformScreenQuestions(
//       screenQuestionList,0,0,0,ModuleType.attendance,dynamicModuleCategory: DynamicModuleCategory.attendance,);
//     screenTitleEntity = ScreenTitle.get(json['screen_title']);
//   }
// }


