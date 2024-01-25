import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_update_response.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/attendance/attendance_data_source.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/attendance_answer_entity.dart';

abstract class AttendanceRemoteRepository {
  Future<AttendancePunchesResponse?> getAttendancePunchesSearch(String currentDate,{String memberId,String? projectRoleId,String? executionId});
  Future<AttendancePunchesUpdateResponse> getAttendancePunchesUpdate(String executionId,String id,String punchInTime,bool punchStatus,{List<AttendanceAnswerEntity>? attendanceAnswerEntityList});
}

class AttendanceRemoteRepositoryImpl implements AttendanceRemoteRepository {
  final AttendanceRemoteDataSource _dataSource;

  AttendanceRemoteRepositoryImpl(this._dataSource);

  @override
  Future<AttendancePunchesResponse?> getAttendancePunchesSearch(String currentDate,{String? memberId,String? projectRoleId,String? executionId}) async {
    try {
      AdvanceSearchRequestBuilder advancedSearchRequest = AdvanceSearchRequestBuilder();
      advancedSearchRequest.putPropertyToCondition(Constants.attendanceDate, Operator.equal, currentDate);
      if(memberId != null)
        {
          advancedSearchRequest.putPropertyToCondition(Constants.memberId, Operator.equal, memberId);
        }
      if(projectRoleId != null)
        {
          advancedSearchRequest.putPropertyToCondition(Constants.projectRoleId, Operator.equal, projectRoleId);
        }
      if(executionId != null)
        {
          advancedSearchRequest.putPropertyToCondition(Constants.executionId, Operator.equal, executionId);
        }
      advancedSearchRequest.setIncludeAttendanceConfig(true).setIncludeNextPunchCta(true).setSkipLimit(true);
      AttendancePunch attendancePunch = await _dataSource.getAttendancePunchesSearch(advancedSearchRequest.build());
      return attendancePunch.data;
    } catch (e, st) {
      AppLog.e('getAttendancePunchesSearch : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<AttendancePunchesUpdateResponse> getAttendancePunchesUpdate(String executionId,String id,String punchInTime,bool punchStatus,{List<AttendanceAnswerEntity>? attendanceAnswerEntityList}) async {
    try {
      AttendancePunchesUpdateResponse attendancePunchesUpdateResponse = await _dataSource.getAttendancePunchesUpdate(executionId,id,punchInTime,punchStatus,attendanceAnswerEntityList:attendanceAnswerEntityList);
      return attendancePunchesUpdateResponse;
    } catch (e, st) {
      AppLog.e('getAttendancePunchesUpdate : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}