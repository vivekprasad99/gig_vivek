import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_test.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

import '../../../../aw_questions/data/model/screen/attachment_response.dart';
import '../../../../execution_in_house/feature/online_test/helper/attachment_helper.dart';
import '../../model/work_application/work_application_section.dart';

abstract class PitchTestRemoteDataSource {
  Future<WorkApplicationEntity> executePitchTestEvent(
      int userID, int applicationID, String event);

  Future<ScreenResponse> fetchPitchTestScreens(
      int userID, int applicationID);

  Future<Response> submitPitchTestAnswer(int userID, int applicationID,
      PitchTestAnswerRequestEntity pitchTestAnswerRequestEntity);

  Future<List<AttachmentSection>> fetchResource(int userID, int applicationID);
}

class PitchTestRemoteDataSourceImpl extends WosAPI
    implements PitchTestRemoteDataSource {
  @override
  Future<WorkApplicationEntity> executePitchTestEvent(
      int userID, int applicationID, String event) async {
    try {
      Response response = await wosRestClient.put(executePitchTestEventAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString())
          .replaceAll('event', event));
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchPitchTestScreens(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchPitchTestScreensAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return ScreenResponse.fromJson(response.data, userID, applicationID);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> submitPitchTestAnswer(int userID, int applicationID,
      PitchTestAnswerRequestEntity pitchTestAnswerRequestEntity) async {
    try {
      Response response = await wosRestClient.post(
          submitPitchTestAnswerAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: pitchTestAnswerRequestEntity.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AttachmentSection>> fetchResource(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchResourceAPI
          .replaceAll('{user_id}', userID.toString())
          .replaceAll('{id}', applicationID.toString()));
      AttachmentsResponse attachmentsResponse =
      AttachmentsResponse.fromJson(response.data);
      return AttachmentMapper.transformAttachmentsResponse(
          attachmentsResponse.attachmentSections);
    } catch (e) {
      rethrow;
    }
  }
}
