import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/mapper/event_mapper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/webinar_training.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_event_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/webinar_training/webinar_training_remote_data_source.dart';

abstract class WebinarTrainingRemoteRepository {
  Future<BatchesResponse> fetchTrainingBatches(int userID, int applicationID);

  Future<WorkApplicationEntity> scheduleTrainingBatch(
      int userID, int applicationID, int batchID);

  Future<WorkApplicationEntity> executeWebinarTrainingEvent(
      int userID, int applicationID, ApplicationAction applicationAction);

  Future<WorkApplicationEntity> supplyConfirmWebinarTraining(
      int userID, int applicationID, String reason);

  Future<WorkApplicationEntity> supplyUnConfirmWebinarTraining(
      int userID, int applicationID, String reason);

  Future<WorkApplicationEntity> markAttendanceForWebinarTraining(int applicationID);
}

class WebinarTrainingRemoteRepositoryImpl
    implements WebinarTrainingRemoteRepository {
  final WebinarTrainingRemoteDataSource _dataSource;

  WebinarTrainingRemoteRepositoryImpl(this._dataSource);

  @override
  Future<BatchesResponse> fetchTrainingBatches(
      int userID, int applicationID) async {
    try {
      final BatchesResponse batchesResponse =
          await _dataSource.fetchTrainingBatches(userID, applicationID);
      return batchesResponse;
    } catch (e) {
      AppLog.e('fetchTrainingBatches : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> scheduleTrainingBatch(
      int userID, int applicationID, int batchID) async {
    try {
      WebinarTrainingRequest webinarTrainingRequest =
          WebinarTrainingRequest(batchID: batchID);
      BatchRequestEntity batchRequestEntity =
          BatchRequestEntity(webinarTrainingRequest: webinarTrainingRequest);
      final WorkApplicationEntity workApplicationEntity = await _dataSource
          .scheduleTrainingBatch(userID, applicationID, batchRequestEntity);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('scheduleTrainingBatch : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> executeWebinarTrainingEvent(int userID,
      int applicationID, ApplicationAction applicationAction) async {
    try {
      WorkApplicationEventEntity? workApplicationEventEntity =
          EventMapper.convertToEvent(applicationAction);
      final workApplicationEntity =
          await _dataSource.executeWebinarTrainingEvent(
              userID, applicationID, workApplicationEventEntity?.value);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('executeWebinarTrainingEvent : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyConfirmWebinarTraining(
      int userID, int applicationID, String reason) async {
    try {
      ConfirmWebinarTrainingRequest confirmWebinarTrainingRequest =
          ConfirmWebinarTrainingRequest(
              trainingConfirmReason:
                  TrainingConfirmReason(trainingConfirmationSupply: reason));
      final workApplicationEntity =
          await _dataSource.supplyConfirmWebinarTraining(
              userID, applicationID, confirmWebinarTrainingRequest);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('supplyConfirmWebinarTraining : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyUnConfirmWebinarTraining(
      int userID, int applicationID, String reason) async {
    try {
      UnConfirmWebinarTrainingRequest unConfirmWebinarTrainingRequest =
          UnConfirmWebinarTrainingRequest(
              trainingUnConfirmReason:
                  TrainingUnConfirmReason(nonConfirmationReasonSupply: reason));
      final workApplicationEntity =
          await _dataSource.supplyUnConfirmWebinarTraining(
              userID, applicationID, unConfirmWebinarTrainingRequest);
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('supplyUnConfirmWebinarTraining : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> markAttendanceForWebinarTraining(int applicationID) async {
    try {
      final workApplicationEntity =
      await _dataSource.markAttendanceForWebinarTraining(applicationID, );
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('markAttendanceForWebinarTraining : ${e.toString()}');
      rethrow;
    }
  }
}
