import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/worklog/worklog_remote_data_source.dart';

import '../../model/worklog_response.dart';

abstract class WorklogRemoteRepository {
  Future<WorklogConfigs> getWorkLog(String projectId, String projectRoleUid);

  Future createWorklog(String executionId, String projectRoleUid,
      List<ScreenRow> screenRowListt);
}

class WorklogRemoteRepositoryImpl implements WorklogRemoteRepository {
  final WorklogRemoteDataSource _dataSource;

  WorklogRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorklogConfigs> getWorkLog(String projectId, String projectRoleUid) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getWorkLog(projectId, projectRoleUid);
      if (apiResponse.status == ApiResponse.success) {
        WorklogResponse worklogResponse = WorklogResponse.fromJson(apiResponse.data);
        return worklogResponse.worklogConfigs![0];
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getWorkLog : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future createWorklog(String executionId, String projectRoleUid,
      List<ScreenRow> screenRowList) async {
    try {
      var request = WorklogRequest(
          AnswerUnitMapper.transformScreenRowForUpdateLead(screenRowList));
      ApiResponse apiResponse =
          await _dataSource.createWorkLog(executionId, projectRoleUid, request);
    } catch (e, st) {
      AppLog.e('getWorkLog : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
