import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/model/location_item.dart';
import 'package:awign/workforce/execution_in_house/data/model/eligibility_entity_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/ineligible_question_answer_entity.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing_response.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

abstract class WosRemoteDataSource {
  Future<ApplicationQuestionResponse> getApplicationQuestions(
      AdvancedSearchRequest advancedSearchRequest);

  Future<CategoryResponse> getCategoryList(
      AdvancedSearchRequest advancedSearchRequest);

  Future<Category> getCategory(int categoryID);

  Future<CategoryApplicationResponse> getCategoryApplicationList(
      String? supplyId, AdvancedSearchRequest advancedSearchRequest);

  Future<CategoryApplication> createCategory(String? supplyID, int categoryID,
      CreateCategoryRequest createCategoryRequest);

  Future<WorkApplicationResponse> getCategoryApplicationDetails(
      String? supplyID,
      String categoryID,
      AdvancedSearchRequest advancedSearchRequest);

  Future<WorkApplicationResponse> getApplicationHistory(
      int? userId, AdvancedSearchRequest advancedSearchRequest);

  Future<LocationResponse> searchLocations(
      AdvancedSearchRequest advancedSearchRequest);

  Future<WorkApplicationResponse> getCategoryApplicationSearch(
      String categoryId,
      String supplyId,
      AdvancedSearchRequest advancedSearchRequest);

  Future<EligiblityEntityResponse> fetchEligiblity(
      AdvancedSearchRequest advancedSearchRequest);

  Future<InEligibleQuestionAnswerEntity> getQuestions(
      AdvancedSearchRequest advancedSearchRequest);

  Future<WorkListingResponse> getWorkListing(
      AdvancedSearchRequest advancedSearchRequest);
}

class WosRemoteDataSourceImpl extends WosAPI implements WosRemoteDataSource {
  @override
  Future<ApplicationQuestionResponse> getApplicationQuestions(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(applicationQuestionAPI,
          body: advancedSearchRequest.toJson());
      return ApplicationQuestionResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CategoryResponse> getCategoryList(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(categoryListAPI,
          body: advancedSearchRequest.toJson());
      return CategoryResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Category> getCategory(int categoryID) async {
    try {
      Response response = await wosRestClient
          .get(getCategoryAPI.replaceAll('id', '$categoryID'));
      return Category.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CategoryApplicationResponse> getCategoryApplicationList(
      String? supplyId, AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(
          categoryApplicationListAPI.replaceAll('SupplyID', '$supplyId'),
          body: advancedSearchRequest.toJson());
      return CategoryApplicationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CategoryApplication> createCategory(String? supplyID, int categoryID,
      CreateCategoryRequest createCategoryRequest) async {
    try {
      Response response = await wosRestClient.post(
          createCategoryAPI
              .replaceAll('categoryID', '$categoryID')
              .replaceAll('supplyID', '$supplyID'),
          body: createCategoryRequest.toJson());
      return CategoryApplication.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationResponse> getCategoryApplicationDetails(
      String? supplyID,
      String categoryID,
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(
          getCategoryApplicationDetailsAPI
              .replaceAll('categoryID', categoryID)
              .replaceAll('supplyID', '$supplyID'),
          body: advancedSearchRequest.toJson());
      return WorkApplicationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationResponse> getCategoryApplicationSearch(
      String categoryId,
      String supplyId,
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(
          getCategoryApplicationDetailsAPI
              .replaceAll('categoryID', categoryId.toString())
              .replaceAll('supplyID', supplyId),
          body: advancedSearchRequest.toJson());
      return WorkApplicationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkApplicationResponse> getApplicationHistory(
      int? userId, AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(
          searchWorkApplications.replaceAll('UserID', '$userId'),
          body: advancedSearchRequest.toJson());
      return WorkApplicationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LocationResponse> searchLocations(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(searchLocationsAPI,
          body: advancedSearchRequest.toJson());
      return LocationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WorkListingResponse> getWorkListing(AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(workListingSearchAPI,
          body: advancedSearchRequest.toJson());
      return WorkListingResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EligiblityEntityResponse> fetchEligiblity(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(fetchEligiblityAPI,
          body: advancedSearchRequest.toJson());
      return EligiblityEntityResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InEligibleQuestionAnswerEntity> getQuestions(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await wosRestClient.post(getQuestionsAPI,
          body: advancedSearchRequest.toJson());
      return InEligibleQuestionAnswerEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
