import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_interview.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/telephonic_interview_request_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

abstract class TelephonicInterviewRemoteDataSource {
  Future<SlotsResponse> fetchInterviewSlots(int userID, int applicationID);
  Future<WorkApplicationEntity> scheduleTelephonicInterview(int userID, int applicationID, TelephonicInterviewRequestEntity telephonicInterviewRequestEntity);
}

class TelephonicInterviewRemoteDataSourceImpl extends WosAPI
    implements TelephonicInterviewRemoteDataSource {
  @override
  Future<SlotsResponse> fetchInterviewSlots(int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.post(
          fetchInterviewSlotsAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()));
      return SlotsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> scheduleTelephonicInterview(int userID, int applicationID, TelephonicInterviewRequestEntity telephonicInterviewRequestEntity) async {
    try {
      Response response = await wosRestClient.put(
          scheduleTelephonicInterviewAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
      body: telephonicInterviewRequestEntity.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
