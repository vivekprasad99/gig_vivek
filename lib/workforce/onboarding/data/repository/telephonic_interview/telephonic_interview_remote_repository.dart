import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/telephonic_interview_request_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/telephonic_interview/telephonic_interview_remote_data_source.dart';

abstract class TelephonicInterviewRemoteRepository {
  Future<SlotsResponse> fetchInterviewSlots(int userID, int applicationID);

  Future<WorkApplicationEntity> scheduleTelephonicInterview(
      int userID, String mobileNumber, int applicationID, int slotID);
}

class TelephonicInterviewRemoteRepositoryImpl
    implements TelephonicInterviewRemoteRepository {
  final TelephonicInterviewRemoteDataSource _dataSource;

  TelephonicInterviewRemoteRepositoryImpl(this._dataSource);

  @override
  Future<SlotsResponse> fetchInterviewSlots(
      int userID, int applicationID) async {
    try {
      final SlotsResponse slotsResponse =
          await _dataSource.fetchInterviewSlots(userID, applicationID);
      return slotsResponse;
    } catch (e) {
      AppLog.e('fetchInterviewSlots : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> scheduleTelephonicInterview(
      int userID, String mobileNumber, int applicationID, int slotID) async {
    try {
      TelephonicInterviewRequestDataEntity
          telephonicInterviewRequestDataEntity =
          TelephonicInterviewRequestDataEntity(
              slotID: slotID, mobileNumber: mobileNumber);
      TelephonicInterviewRequestEntity telephonicInterviewRequestEntity =
          TelephonicInterviewRequestEntity(
              telephonicInterviewRequestDataEntity:
                  telephonicInterviewRequestDataEntity);
      final WorkApplicationEntity workApplicationEntity =
          await _dataSource.scheduleTelephonicInterview(
              userID, applicationID, telephonicInterviewRequestEntity);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('scheduleTelephonicInterview : ${e.toString()}');
      rethrow;
    }
  }
}
