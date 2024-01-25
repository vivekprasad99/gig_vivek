import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/attachment_response.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/mapper/event_mapper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/in_app_interview.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_event_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/in_app_interview/in_app_interview_data_source.dart';
import 'package:dio/dio.dart';

abstract class InAppInterviewRemoteRepository {
  Future<WorkApplicationEntity> executeInAppInterviewEvent(
      int userID, int applicationID, ApplicationAction applicationAction);

  Future<WorkApplicationEntity> executeApplicationEvent(
      int userID, int applicationID, ApplicationAction applicationAction);

  Future<ScreenResponse> fetchInAppInterviewScreens(
      int userID, int applicationID);

  Future<List<AttachmentSection>> fetchResource(int userID, int applicationId);

  Future<Response> submitInAppInterviewAnswer(int userID, int applicationID,
      int questionID, AnswerUnit answerUnit, int answerTime);
}

class InAppInterviewRemoteRepositoryImpl
    implements InAppInterviewRemoteRepository {
  final InAppInterviewDataSource _dataSource;

  InAppInterviewRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkApplicationEntity> executeInAppInterviewEvent(int userID,
      int applicationID, ApplicationAction applicationAction) async {
    try {
      WorkApplicationEventEntity? workApplicationEventEntity =
          EventMapper.convertToEvent(applicationAction);
      final workApplicationEntity =
          await _dataSource.executeInAppInterviewEvent(
              userID, applicationID, workApplicationEventEntity?.value);
      return workApplicationEntity;
    } catch (e, st) {
      AppLog.e(
          'executeInAppInterviewEvent : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> executeApplicationEvent(int userID,
      int applicationID, ApplicationAction applicationAction) async {
    try {
      WorkApplicationEventEntity? workApplicationEventEntity =
          EventMapper.convertToEvent(applicationAction);
      final workApplicationEntity = await _dataSource.executeApplicationEvent(
          userID, applicationID, workApplicationEventEntity?.value);
      return workApplicationEntity;
    } catch (e, st) {
      AppLog.e('executeApplicationEvent : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ScreenResponse> fetchInAppInterviewScreens(
      int userID, int applicationID) async {
    try {
      final ScreenResponse screenResponse =
          await _dataSource.fetchInAppInterviewScreens(userID, applicationID);
      return screenResponse;
    } catch (e, st) {
      AppLog.e(
          'fetchInAppInterviewScreens : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Response> submitInAppInterviewAnswer(int userID, int applicationID,
      int questionID, AnswerUnit answerUnit, int answerTime) async {
    try {
      dynamic answerValue = AnswerUnitMapper.transformAnswerUnit(answerUnit);
      InAppInterviewAnswerEntity answerEntity = InAppInterviewAnswerEntity(
          inAppInterviewQuestionId: questionID,
          answer: answerValue,
          timeToAnswer: answerTime);
      InAppInterviewAnswerRequestEntity requestEntity =
          InAppInterviewAnswerRequestEntity(answerRequest: answerEntity);
      final Response response = await _dataSource.submitInAppInterviewAnswer(
          userID, applicationID, requestEntity);
      return response;
    } catch (e, st) {
      AppLog.e(
          'submitInAppInterviewAnswer : ${e.toString()} \n${st.toString()}');
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
