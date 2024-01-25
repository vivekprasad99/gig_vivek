import 'dart:convert';

import 'package:awign/workforce/auth/data/model/get_question_answers_request.dart';
import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/auth/data/network/api/bff_api.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:dio/dio.dart';

abstract class BFFRemoteDataSource {
  Future<QuestionAnswersResponse> getQuestionAnswers(
      int? userID, GetQuestionAnswerRequest getQuestionAnswerRequest);

  Future<ApiResponse> submitAnswer(String categoryUID, String screenUID,
      int? userID, SubmitAnswerRequest submitAnswerRequest);
}

class BFFRemoteDataSourceImpl extends BffAPI implements BFFRemoteDataSource {
  @override
  Future<QuestionAnswersResponse> getQuestionAnswers(
      int? userID, GetQuestionAnswerRequest getQuestionAnswerRequest) async {
    try {
      Response response = await bffRestClient.post(
          getQuestionAnswersAPI.replaceAll('userID', '$userID'),
          body: getQuestionAnswerRequest.toJson());
      return QuestionAnswersResponse.fromJson(response.data, userID);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> submitAnswer(String categoryUID, String screenUID,
      int? userID, SubmitAnswerRequest submitAnswerRequest) async {
    try {
      Response response = await bffRestClient.post(
          submitAnswerAPI
              .replaceAll('categoryUID', categoryUID)
              .replaceAll('screenUID', screenUID)
              .replaceAll('userID', '$userID'),
          body: json.encode(submitAnswerRequest.toJson()));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
