import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_entity.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_response.dart';
import 'package:dio/dio.dart';
import '../../api/wos_api.dart';

abstract class CampusAmbassadorDataSource {
  Future<ApiResponse> createCampusAmbassador(
      int userId, CampusAmbassdor campusAmbassdor);

  Future<Response> getCampusAmbassador(int userId);

  Future<Response> getCATask(
      int userId, CampusAmbassadorTaskData campusAmbassadorTaskData);

  Future<Response> getCampusAmbassadorAnalyze(AdvancedSearchRequest body);

  Future<Response> caApplicationSearch(AdvancedSearchRequest builder);
}

class CampusAmbassadorDataSourceImpl extends WosAPI
    implements CampusAmbassadorDataSource {
  @override
  Future<ApiResponse> createCampusAmbassador(
      int userId, CampusAmbassdor campusAmbassdor) async {
    try {
      Response response = await wosRestClient.post(
          createCampusAmbassadorAPI.replaceAll('id', '$userId'),
          body: campusAmbassdor.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> getCampusAmbassador(int userId) async {
    try {
      Response response = await wosRestClient
          .get(createCampusAmbassadorAPI.replaceAll('id', '$userId'));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> getCATask(
      int userId, CampusAmbassadorTaskData campusAmbassadorTaskData) async {
    try {
      Response response = await wosRestClient.post(
          getCATaskAPI.replaceAll('user_id', '$userId'),
          body: campusAmbassadorTaskData.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> getCampusAmbassadorAnalyze(
      AdvancedSearchRequest body) async {
    try {
      Response response = await wosRestClient
          .post(getCampusAmbassadorAnalyzeAPI, body: body.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> caApplicationSearch(AdvancedSearchRequest builder) async {
    try {
      Response response = await wosRestClient.post(caApplicationSearchAPI,
          body: builder.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
