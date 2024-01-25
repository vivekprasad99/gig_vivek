import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/mapper/event_mapper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_interview.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_training.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_event_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/in_app_interview/in_app_interview_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/in_app_training/in_app_training_remote_data_source.dart';
import 'package:dio/dio.dart';

import '../../model/work_application/work_application_section.dart';

abstract class InAppTrainingRemoteRepository {

  Future<WorkApplicationEntity> executeInAppTrainingEvent(int userID, int applicationID, ApplicationAction applicationAction);

  Future<ScreenResponse> fetchInAppTrainingScreens(int userID, int applicationID);

  Future<Response> submitInAppTrainingAnswer(int userID, int applicationID, int questionID, AnswerUnit answerUnit, int answerTime);
  Future<List<AttachmentSection>> fetchResource(int userID, int applicationId);
}

class InAppTrainingRemoteRepositoryImpl implements InAppTrainingRemoteRepository {
  final InAppTrainingRemoteDataSource _dataSource;

  InAppTrainingRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkApplicationEntity> executeInAppTrainingEvent(
      int userID,
      int applicationID,
      ApplicationAction applicationAction) async {
    try {
      WorkApplicationEventEntity? workApplicationEventEntity = EventMapper.convertToEvent(applicationAction);
      final workApplicationEntity = await _dataSource
          .executeInAppTrainingEvent(userID, applicationID, workApplicationEventEntity?.value);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('executeInAppTrainingEvent : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchInAppTrainingScreens(int userID, int applicationID) async {
    try {
      final ScreenResponse screenResponse = await _dataSource
          .fetchInAppTrainingScreens(userID, applicationID);
      return screenResponse;
    } catch (e) {
      AppLog.e('fetchInAppTrainingScreens : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Response> submitInAppTrainingAnswer(int userID, int applicationID, int questionID, AnswerUnit answerUnit, int answerTime) async {
    try {
      dynamic answerValue = AnswerUnitMapper.transformAnswerUnit(answerUnit);
      InAppTrainingAnswerEntity answerEntity = InAppTrainingAnswerEntity(inAppTrainingQuestionId: questionID, answer: answerValue, timeToAnswer: answerTime);
      InAppTrainingAnswerRequestEntity requestEntity = InAppTrainingAnswerRequestEntity(answerRequest: answerEntity);
      final Response response = await _dataSource
          .submitInAppTrainingAnswer(userID, applicationID, requestEntity);
      return response;
    } catch (e) {
      AppLog.e('submitInAppTrainingAnswer : ${e.toString()}');
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
