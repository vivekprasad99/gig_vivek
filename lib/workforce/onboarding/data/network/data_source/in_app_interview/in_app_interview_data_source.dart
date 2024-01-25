import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/feature/online_test/helper/attachment_helper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_interview.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

import '../../../../../aw_questions/data/model/screen/attachment_response.dart';

abstract class InAppInterviewDataSource {
  Future<WorkApplicationEntity> executeInAppInterviewEvent(
      int userID, int applicationID, String event);

  Future<WorkApplicationEntity> executeApplicationEvent(
      int userID, int applicationID, String event);

  Future<ScreenResponse> fetchInAppInterviewScreens(
      int userID, int applicationID);

  Future<List<AttachmentSection>> fetchResource(int userID, int applicationID);

  Future<Response> submitInAppInterviewAnswer(int userID, int applicationID,
      InAppInterviewAnswerRequestEntity requestEntity);
}

class InAppInterviewDataSourceImpl extends WosAPI
    implements InAppInterviewDataSource {
  @override
  Future<WorkApplicationEntity> executeInAppInterviewEvent(
      int userID, int applicationID, String event) async {
    try {
      Response response = await wosRestClient.put(executeInAppInterviewEventAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString())
          .replaceAll('event', event));
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> executeApplicationEvent(
      int userID, int applicationID, String event) async {
    try {
      Response response = await wosRestClient.put(executeApplicationEventAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString())
          .replaceAll('event', event));
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchInAppInterviewScreens(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchInAppInterviewScreensAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return ScreenResponse.fromJson(response.data, userID, applicationID);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> submitInAppInterviewAnswer(int userID, int applicationID,
      InAppInterviewAnswerRequestEntity requestEntity) async {
    try {
      Response response = await wosRestClient.post(
          submitInAppInterviewAnswerAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: requestEntity.toJson());
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
