import 'dart:convert';

import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_update_response.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/attendance_answer_entity.dart';
import 'package:dio/dio.dart';
import '../../../../../core/data/model/advance_search/advance_search_request.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendancePunch> getAttendancePunchesSearch(
      AdvancedSearchRequest advancedSearchRequest);
  Future<AttendancePunchesUpdateResponse> getAttendancePunchesUpdate(
      String executionId, String id, String punchInTime, bool punchStatus,{List<AttendanceAnswerEntity>? attendanceAnswerEntityList});
}

class AttendanceRemoteDataSourceImpl extends InHouseOMSAPI
    implements AttendanceRemoteDataSource {
  @override
  Future<AttendancePunch> getAttendancePunchesSearch(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          attendancePunchesSearchAPI,
          body: advancedSearchRequest.toJson());
      return AttendancePunch.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AttendancePunchesUpdateResponse> getAttendancePunchesUpdate(
      String executionId,
      String id,
      String punchInTime,
      bool punchStatus,{List<AttendanceAnswerEntity>? attendanceAnswerEntityList}) async {
    try {
      List<Map<String, dynamic>>? attendanceAnswerList = attendanceAnswerEntityList?.map((attendanceAnswer) => attendanceAnswer.toJson()).toList();
      Map<String, dynamic> map = {};
      if(attendanceAnswerEntityList != null)
        {
          map = {
            punchStatus  ? "punch_in_time" : "punch_out_time": punchInTime,
            punchStatus ? "punch_in_inputs" : "punch_out_inputs" : attendanceAnswerList,
          };
        }else {
        map = {
          punchStatus  ? "punch_in_time" : "punch_out_time": punchInTime,
        };
      }

      Map<String, Map<String, dynamic>> hashmap = {"attendance_punches": map};
      Response response = await inHouseOMSRestClient.patch(
          attendancePunchesUpdateAPI
              .replaceAll('execution_id', executionId)
              .replaceAll('id', id),
          body: hashmap);
      return AttendancePunchesUpdateResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
