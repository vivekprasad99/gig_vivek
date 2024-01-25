import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/mapper/event_mapper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_demo.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_event_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/pitch_demo/pitch_demo_remote_data_source.dart';
import 'package:dio/dio.dart';

import '../../model/work_application/work_application_section.dart';

abstract class PitchDemoRemoteRepository {
  Future<SlotsResponse> fetchPitchDemoSlot(int userID, int applicationID);

  Future<WorkApplicationEntity> schedulePitchDemo(
      int userID, int applicationID, int slotID);

  Future<WorkApplicationEntity> executePitchDemoEvent(
      int userID, int applicationID, ApplicationAction applicationAction);

  Future<WorkApplicationEntity> supplyConfirmPitchDemo(
      int userID, int applicationID, String reason);

  Future<WorkApplicationEntity> supplyUnConfirmPitchDemo(
      int userID, int applicationID, String reason);

  Future<ScreenResponse> fetchPitchDemoScreens(
      int userID, int applicationID);

  Future<List<AttachmentSection>> fetchResource(int userID, int applicationId);

  Future<Response> submitPitchDemoAnswer(
      int userID, int applicationID, int questionID, AnswerUnit answerUnit);
}


class PitchDemoRemoteRepositoryImpl implements PitchDemoRemoteRepository {
  final PitchDemoRemoteDataSource _dataSource;

  PitchDemoRemoteRepositoryImpl(this._dataSource);

  @override
  Future<SlotsResponse> fetchPitchDemoSlot(
      int userID, int applicationID) async {
    try {
      final SlotsResponse slotsResponse =
          await _dataSource.fetchPitchDemoSlot(userID, applicationID);
      return slotsResponse;
    } catch (e) {
      AppLog.e('fetchPitchDemoSlot : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> schedulePitchDemo(
      int userID, int applicationID, int slotID) async {
    try {
      PitchDemoRequest pitchDemoRequest = PitchDemoRequest(slotID: slotID);
      PitchDemoEntityRequest pitchDemoEntityRequest =
          PitchDemoEntityRequest(pitchDemoRequest: pitchDemoRequest);
      final WorkApplicationEntity workApplicationEntity = await _dataSource
          .schedulePitchDemo(userID, applicationID, pitchDemoEntityRequest);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('schedulePitchDemo : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> executePitchDemoEvent(int userID,
      int applicationID, ApplicationAction applicationAction) async {
    try {
      WorkApplicationEventEntity? workApplicationEventEntity =
          EventMapper.convertToEvent(applicationAction);
      final workApplicationEntity = await _dataSource.executePitchDemoEvent(
          userID, applicationID, workApplicationEventEntity?.value);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('executePitchDemoEvent : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyConfirmPitchDemo(
      int userID, int applicationID, String reason) async {
    try {
      ConfirmPitchDemoRequest confirmPitchDemoRequest = ConfirmPitchDemoRequest(
          confirmPitchDemo: ConfirmPitchDemo(confirmSupply: reason));
      final workApplicationEntity = await _dataSource.supplyConfirmPitchDemo(
          userID, applicationID, confirmPitchDemoRequest);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('supplyConfirmPitchDemo : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyUnConfirmPitchDemo(
      int userID, int applicationID, String reason) async {
    try {
      UnConfirmPitchDemoRequest unConfirmPitchDemoRequest =
          UnConfirmPitchDemoRequest(
              unConfirmPitchDemo: UnConfirmPitchDemo(unConfirmSupply: reason));
      final workApplicationEntity = await _dataSource.supplyUnConfirmPitchDemo(
          userID, applicationID, unConfirmPitchDemoRequest);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('supplyUnConfirmPitchDemo : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchPitchDemoScreens(
      int userID, int applicationID) async {
    try {
      final ScreenResponse screenResponse = await _dataSource
          .fetchPitchDemoScreens(userID, applicationID);
      return screenResponse;
    } catch (e, st) {
      AppLog.e('fetchPitchDemoScreens : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Response> submitPitchDemoAnswer(int userID, int applicationID,
      int questionID, AnswerUnit answerUnit) async {
    try {
      dynamic answerValue = AnswerUnitMapper.transformAnswerUnit(answerUnit);
      PitchDemoAnswerEntity answerEntity = PitchDemoAnswerEntity(
          pitchDemoQuestionId: questionID, answer: answerValue);
      PitchDemoAnswerRequestEntity requestEntity =
          PitchDemoAnswerRequestEntity(pitchDemoAnswerEntity: answerEntity);
      final Response response = await _dataSource.submitPitchDemoAnswer(
          userID, applicationID, requestEntity);
      return response;
    } catch (e, st) {
      AppLog.e('submitPitchDemoAnswer : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<AttachmentSection>> fetchResource(int userID, int applicationId) async {
    try {
      final List<AttachmentSection> attachmentsResponse =
          await _dataSource.fetchResource(userID, applicationId);
      return attachmentsResponse;
    } catch (e) {
      AppLog.e(
          'fResource: ${e.toString()} \n${e.toString()}');
      rethrow;
    }
  }
  }

