import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/webinar_training.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

abstract class WebinarTrainingRemoteDataSource {
  Future<BatchesResponse> fetchTrainingBatches(int userID, int applicationID);

  Future<WorkApplicationEntity> scheduleTrainingBatch(
      int userID, int applicationID, BatchRequestEntity batchRequestEntity);

  Future<WorkApplicationEntity> executeWebinarTrainingEvent(
      int userID, int applicationID, String event);

  Future<WorkApplicationEntity> supplyConfirmWebinarTraining(
      int userID,
      int applicationID,
      ConfirmWebinarTrainingRequest confirmWebinarTrainingRequest);

  Future<WorkApplicationEntity> supplyUnConfirmWebinarTraining(
      int userID,
      int applicationID,
      UnConfirmWebinarTrainingRequest unConfirmWebinarTrainingRequest);

  Future<WorkApplicationEntity> markAttendanceForWebinarTraining(
      int applicationID);
}

class WebinarTrainingRemoteDataSourceImpl extends WosAPI
    implements WebinarTrainingRemoteDataSource {
  @override
  Future<BatchesResponse> fetchTrainingBatches(
      int userID, int applicationID) async {
    try {
      Response response = await wosRestClient.post(fetchTrainingBatchAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString()));
      return BatchesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> scheduleTrainingBatch(int userID,
      int applicationID, BatchRequestEntity batchRequestEntity) async {
    try {
      Response response = await wosRestClient.put(
          scheduleTrainingBatchAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: batchRequestEntity.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> executeWebinarTrainingEvent(
      int userID, int applicationID, String event) async {
    try {
      Response response = await wosRestClient.put(executeWebinarTrainingEventAPI
          .replaceAll('userID', userID.toString())
          .replaceAll('applicationID', applicationID.toString())
          .replaceAll('event', event));
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyConfirmWebinarTraining(
      int userID,
      int applicationID,
      ConfirmWebinarTrainingRequest confirmWebinarTrainingRequest) async {
    try {
      Response response = await wosRestClient.put(
          supplyConfirmWebinarTrainingAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: confirmWebinarTrainingRequest.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> supplyUnConfirmWebinarTraining(int userID, int applicationID, UnConfirmWebinarTrainingRequest unConfirmWebinarTrainingRequest) async {
    try {
      Response response = await wosRestClient.put(
          supplyUnConfirmWebinarTrainingAPI
              .replaceAll('userID', userID.toString())
              .replaceAll('applicationID', applicationID.toString()),
          body: unConfirmWebinarTrainingRequest.toJson());
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationEntity> markAttendanceForWebinarTraining(
      int applicationID) async {
    try {
      Response response = await wosRestClient.put(
          markAttendanceForWebinarTrainingAPI(applicationID),
          body: {
            "webinar_training" : {}
          });
      return WorkApplicationEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
