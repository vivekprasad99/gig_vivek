import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_demo.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

import '../../../../../aw_questions/data/model/screen/attachment_response.dart';
import '../../../../../execution_in_house/feature/online_test/helper/attachment_helper.dart';
import '../../../model/work_application/work_application_section.dart';

abstract class PitchDemoRemoteDataSource {
  Future<SlotsResponse> fetchPitchDemoSlot(int userID, int applicationID);

  Future<WorkApplicationEntity> schedulePitchDemo(int userID, int applicationID,
      PitchDemoEntityRequest pitchDemoEntityRequest);

  Future<WorkApplicationEntity> executePitchDemoEvent(
      int userID, int applicationID, String event);

  Future<WorkApplicationEntity> supplyConfirmPitchDemo(int userID,
      int applicationID, ConfirmPitchDemoRequest confirmPitchDemoRequest);

  Future<WorkApplicationEntity> supplyUnConfirmPitchDemo(int userID,
      int applicationID, UnConfirmPitchDemoRequest unConfirmPitchDemoRequest);

  Future<ScreenResponse> fetchPitchDemoScreens(
      int userID, int applicationID);

  Future<Response> submitPitchDemoAnswer(int userID, int applicationID,
      PitchDemoAnswerRequestEntity pitchDemoAnswerRequestEntity);
  Future<List<AttachmentSection>> fetchResource(int userID, int applicationID);
}

class PitchDemoRemoteDataSourceImpl extends WosAPI
    implements PitchDemoRemoteDataSource {
  @override
  Future<SlotsResponse> fetchPitchDemoSlot(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.post(fetchPitchDemoSlotAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return SlotsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> schedulePitchDemo(int userID, int applicationID,
      PitchDemoEntityRequest pitchDemoEntityRequest) async {
    try {
      Response response = await wosRestClient.put(
          schedulePitchDemoAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: pitchDemoEntityRequest.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> executePitchDemoEvent(
      int userID, int applicationID, String event) async {
    try {
      Response response = await wosRestClient.put(executePitchDemoEventAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString())
          .replaceAll('event', event));
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyConfirmPitchDemo(
      int userID,
      int applicationID,
      ConfirmPitchDemoRequest confirmPitchDemoRequest) async {
    try {
      Response response = await wosRestClient.put(
          supplyConfirmPitchDemoAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: confirmPitchDemoRequest.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyUnConfirmPitchDemo(
      int userID,
      int applicationID,
      UnConfirmPitchDemoRequest unConfirmPitchDemoRequest) async {
    try {
      Response response = await wosRestClient.put(
          supplyUnConfirmPitchDemoAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: unConfirmPitchDemoRequest.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchPitchDemoScreens(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.get(fetchPitchDemoScreensAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return ScreenResponse.fromJson(response.data, userID, applicationID);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> submitPitchDemoAnswer(int userID, int applicationID,
      PitchDemoAnswerRequestEntity pitchDemoAnswerRequestEntity) async {
    try {
      Response response = await wosRestClient.post(
          submitPitchDemoAnswerAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: pitchDemoAnswerRequestEntity.toJson());
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
