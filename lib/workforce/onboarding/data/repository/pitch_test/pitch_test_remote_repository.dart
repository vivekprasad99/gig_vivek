import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/mapper/event_mapper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_test.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_event_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/pitch_test/pitch_test_remote_data_source.dart';
import 'package:dio/dio.dart';

import '../../model/work_application/work_application_section.dart';

abstract class PitchTestRemoteRepository {
  Future<WorkApplicationEntity> executePitchTestEvent(
      int userID, int applicationID, ApplicationAction applicationAction);

  Future<ScreenResponse> fetchPitchTestScreens(
      int userID, int applicationID);

  Future<Response> submitPitchTestAnswer(
      int userID, int applicationID, int questionID, AnswerUnit answerUnit);

  Future<List<AttachmentSection>> fetchResource(int userID, int applicationId);
}

class PitchTestRemoteRepositoryImpl implements PitchTestRemoteRepository {
  final PitchTestRemoteDataSource _dataSource;

  PitchTestRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkApplicationEntity> executePitchTestEvent(int userID,
      int applicationID, ApplicationAction applicationAction) async {
    try {
      WorkApplicationEventEntity? workApplicationEventEntity =
          EventMapper.convertToEvent(applicationAction);
      final workApplicationEntity = await _dataSource.executePitchTestEvent(
          userID, applicationID, workApplicationEventEntity?.value);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('executePitchTestEvent : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchPitchTestScreens(
      int userID, int applicationID) async {
    try {
      final ScreenResponse screenResponse = await _dataSource
          .fetchPitchTestScreens(userID, applicationID);
      return screenResponse;
    } catch (e, st) {
      AppLog.e('fetchPitchTestScreens : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Response> submitPitchTestAnswer(int userID, int applicationID,
      int questionID, AnswerUnit answerUnit) async {
    try {
      dynamic answerValue = AnswerUnitMapper.transformAnswerUnit(answerUnit);
      PitchTestAnswerEntity answerEntity = PitchTestAnswerEntity(
          pitchTestQuestionId: questionID, answer: answerValue);
      PitchTestAnswerRequestEntity requestEntity =
          PitchTestAnswerRequestEntity(pitchTestAnswerEntity: answerEntity);
      final Response response = await _dataSource.submitPitchTestAnswer(
          userID, applicationID, requestEntity);
      return response;
    } catch (e, st) {
      AppLog.e('submitPitchTestAnswer : ${e.toString()} \n${st.toString()}');
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
