class AttendancePunchesUpdateResponse {
  Data? data;

  AttendancePunchesUpdateResponse({this.data});

  AttendancePunchesUpdateResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  AttendancePunchesUpdate? attendancePunch;

  Data({this.attendancePunch});

  Data.fromJson(Map<String, dynamic> json) {
    attendancePunch = json['attendance_punches'] != null
        ? AttendancePunchesUpdate.fromJson(json['attendance_punches'])
        : null;
  }
}

class AttendancePunchesUpdate {
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
  String? punchInTime;
  String? punchOutTime;
  String? updatedAt;

  AttendancePunchesUpdate(
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
        this.punchInTime,
        this.punchOutTime,
        this.updatedAt});

  AttendancePunchesUpdate.fromJson(Map<String, dynamic> json) {
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
    punchInTime = json['punch_in_time'];
    punchOutTime = json['punch_out_time'];
    updatedAt = json['updated_at'];
  }
}
