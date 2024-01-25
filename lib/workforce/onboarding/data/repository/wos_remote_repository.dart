import 'dart:ffi';

import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/mapper/question_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/module_type.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/model/location_item.dart';
import 'package:awign/workforce/execution_in_house/data/model/eligibility_entity_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/ineligible_question_answer_entity.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/wos_remote_data_source.dart';
import 'package:tuple/tuple.dart';

import '../../../core/data/model/advance_search/query_condition.dart';
import '../model/work_listing/work_listing.dart';

const profileQuestion = 'profile_question';
const questionType = 'question_type';
const categoryApplicationid = 'category_application_id';
const ineligibleWorklistings = 'ineligible_worklistings';

abstract class WosRemoteRepository {
  Future<List<Question>> getApplicationQuestions(int? userID);

  Future<Tuple2<CategoryResponse, String?>> getCategoryList(int pageIndex);

  Future<Category> getCategory(int categoryID);

  Future<Tuple2<CategoryApplicationResponse, String?>>
      getCategoryApplicationList(int pageIndex, String supplyId,
          {String categoryID, List<int?>? listOfCategoryId});

  Future<CategoryApplication> createCategory(String supplyId, int categoryID,
      int? workListingId, List<ScreenRow> screenRowList);

  Future<WorkApplicationResponse> getCategoryApplicationDetails(
      String supplyId, String categoryID, int? workListingId);

  Future<Tuple2<WorkApplicationResponse, String?>> getApplicationHistory(
      int pageIndex, int? userId);

  Future<LocationResponse> searchLocations(
      String searchTerm, LocationType locationType, int page);

  Future<Tuple2<WorkApplicationResponse, String?>> getCategoryApplicationSearch(
      String categoryId, String supplyId, bool isSkipSaasOrgID,
      {String? workListingID, bool isCreateApplication = false});

  Future<WorkListingResponse> getWorkListing(int categoryID);

  Future<CategoryApplication> createCategoryInNotifyStatus(
      int userId, int categoryID);

  Future<EligiblityEntityResponse> fetchEligiblity(int categoryApplicationId, int workListingId);

  Future<List<Question>> getQuestions(List<ApplicationAnswers>? applicationAnswerList,int? userID);
}

class WosRemoteRepositoryImpl implements WosRemoteRepository {
  final WosRemoteDataSource _dataSource;

  WosRemoteRepositoryImpl(this._dataSource);

  @override
  Future<List<Question>> getApplicationQuestions(int? userID) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(questionType, Operator.equal, profileQuestion)
          .setSearchTerm('*')
          .setLimit(100)
          .build();
      final applicationQuestionResponse =
          await _dataSource.getApplicationQuestions(advancedSearchRequest);
      List<Question> questions = QuestionMapper.transformApplicationQuestions(
          applicationQuestionResponse.applicationQuestionLibraries,
          0,
          0,
          userID,
          ModuleType.application);
      return questions;
    } catch (e, st) {
      AppLog.e('getApplicationQuestions : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<CategoryResponse, String?>> getCategoryList(
      int pageIndex) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(
              Constants.status, Operator.equal, Constants.published)
          .setSortOrder("desc")
          .setSortColumn("listings_count")
          .setPage(pageIndex)
          .setLimit(50)
          .setSkipSaasOrgId(true)
          .build();
      CategoryResponse categoryResponse =
          await _dataSource.getCategoryList(advancedSearchRequest);
      return Tuple2(categoryResponse, null);
    } catch (e, st) {
      AppLog.e('getCategoryList : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Category> getCategory(int categoryID) async {
    try {
      Category category = await _dataSource.getCategory(categoryID);
      return category;
    } catch (e, st) {
      AppLog.e('getCategory : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<CategoryApplicationResponse, String?>>
      getCategoryApplicationList(int pageIndex, String supplyId,
          {String? categoryID, List<int?>? listOfCategoryId}) async {
    try {
      AdvanceSearchRequestBuilder advancedSearchRequest =
          AdvanceSearchRequestBuilder();
      if (listOfCategoryId?.isNotEmpty ?? false) {
        advancedSearchRequest
            .setPage(pageIndex)
            .setLimit(listOfCategoryId?.length)
            .setSkipSaasOrgId(true);
        for (int? categoryId in listOfCategoryId!) {
          advancedSearchRequest.putPropertyToConditionList(
              AdvancedSearchRequest.categoryID, Operator.equal, categoryId!);
        }
      } else {
        advancedSearchRequest
            .setPage(pageIndex)
            .setLimit(10)
            .setSkipSaasOrgId(true);
        if (categoryID != null) {
          advancedSearchRequest.putPropertyToCondition(
              AdvancedSearchRequest.categoryID, Operator.equal, categoryID);
        } else {
          advancedSearchRequest.putPropertyToCondition(
              AdvancedSearchRequest.status, Operator.IN, ["created", "applied"]);
        }
      }
      CategoryApplicationResponse categoryApplicationResponse =
          await _dataSource.getCategoryApplicationList(
              supplyId, advancedSearchRequest.build());
      return Tuple2(categoryApplicationResponse, null);
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationList: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CategoryApplication> createCategoryInNotifyStatus(
      int userId, int categoryID) async {
    try {
      CreateCategoryRequestData createCategoryRequestData =
          CreateCategoryRequestData(null, null, null, null, true);
      CreateCategoryRequest createCategoryRequest = CreateCategoryRequest(
          createCategoryRequestData: createCategoryRequestData);
      CategoryApplication categoryApplication = await _dataSource
          .createCategory(userId.toString(), categoryID, createCategoryRequest);
      return categoryApplication;
    } catch (e, st) {
      AppLog.e(
          'createCategoryInNotifyStatus: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CategoryApplication> createCategory(String supplyId, int categoryID,
      int? workListingId, List<ScreenRow> screenRowList) async {
    try {
      List<ApplicationAnswerEntity> answerEntities = [];
      for (ScreenRow screenRow in screenRowList) {
        dynamic answerValue = AnswerUnitMapper.transformAnswerUnit(
            screenRow.question?.answerUnit);
        if (answerValue != null) {
          answerEntities.add(ApplicationAnswerEntity(
              screenRow.question?.configuration?.uid, answerValue));
        }
      }
      List<int> workListingIDs = [];
      if (workListingId != null) {
        workListingIDs.add(workListingId);
      }
      CreateCategoryRequestData createCategoryRequestData =
          CreateCategoryRequestData('', null, workListingIDs, answerEntities, null);
      CreateCategoryRequest createCategoryRequest = CreateCategoryRequest(
          createCategoryRequestData: createCategoryRequestData);
      CategoryApplication categoryApplication = await _dataSource
          .createCategory(supplyId, categoryID, createCategoryRequest);
      return categoryApplication;
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationList: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationResponse> getCategoryApplicationDetails(
      String supplyId, String categoryID, int? workListingId) async {
    try {
      var advancedSearchRequest =
          AdvanceSearchRequestBuilder().setPage(1).setLimit(100);
      // .setSkipSaasOrgId(true)

      List<String> statuses = [];
      statuses.add(
          WorkApplicationStatusEntity.created.value.toString().toLowerCase());
      statuses.add(
          WorkApplicationStatusEntity.selected.value.toString().toLowerCase());
      statuses.add(
          WorkApplicationStatusEntity.backedOut.value.toString().toLowerCase());
      statuses.add(WorkApplicationStatusEntity.executionCompleted.value
          .toString()
          .toLowerCase());
      statuses.add(WorkApplicationStatusEntity.executionStarted.value
          .toString()
          .toLowerCase());
      statuses.add(WorkApplicationStatusEntity.approvedToWork.value
          .toString()
          .toLowerCase());

      if (workListingId == null) {
        advancedSearchRequest
            .putPropertyToCondition(
                CategoryApplicationResponse.status, Operator.notIn, statuses)
            .putPropertyToCondition(
                CategoryApplicationResponse.supplyPendingAction,
                Operator.notEqual,
                "explore_other_jobs");
      }

      if (workListingId != null) {
        advancedSearchRequest.setConditions([]);
      }
      advancedSearchRequest.setCreateApplication(true);
      WorkApplicationResponse workApplicationResponse =
          await _dataSource.getCategoryApplicationDetails(
              supplyId, categoryID, advancedSearchRequest.build());
      return workApplicationResponse;
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationDetails: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<WorkApplicationResponse, String?>> getApplicationHistory(
      int pageIndex, int? userId) async {
    try {
      List<Map<String, QueryCondition>>? applicationHistoryQueryCondition = [];
      Map<String, QueryCondition> statusMap = {};
      Map<String, QueryCondition> pendingActionMap = {};
      Map<String, QueryCondition> archivedStatus = {};
      var queryCondition = QueryCondition();
      var queryCondition1 = QueryCondition();
      var queryCondition2 = QueryCondition();
      queryCondition.operator = Operator.equal.name();
      queryCondition.value = WorkApplicationStatusEntity.backedOut.value;
      statusMap = {
        AdvancedSearchRequest.status: queryCondition,
      };
      queryCondition1.operator = Operator.equal.name();
      queryCondition1.value = AdvancedSearchRequest.exploreOtherJobs;
      pendingActionMap = {
        AdvancedSearchRequest.supplyPendingAction: queryCondition1,
      };
      queryCondition2.operator = Operator.boolean.name();
      queryCondition2.value = true;
      archivedStatus = {"archived_status": queryCondition2};
      applicationHistoryQueryCondition.add(statusMap);
      applicationHistoryQueryCondition.add(pendingActionMap);
      applicationHistoryQueryCondition.add(archivedStatus);
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .setConditions(applicationHistoryQueryCondition)
          .setPage(pageIndex)
          .setLimit(10)
          .setSkipSaasOrgId(true);

      WorkApplicationResponse workApplicationResponse = await _dataSource
          .getApplicationHistory(userId, advancedSearchRequest.build());
      return Tuple2(workApplicationResponse, null);
    } catch (e, st) {
      AppLog.e('getApplicationHistory: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<LocationResponse> searchLocations(
      String searchTerm, LocationType locationType, int page) async {
    try {
      String strLocationType = 'city';
      switch (locationType) {
        case LocationType.allIndia:
        case LocationType.city:
          strLocationType = 'city';
          break;
        case LocationType.pincode:
          strLocationType = 'pincode';
          break;
        case LocationType.state:
          strLocationType = 'state';
          break;
      }
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .setSearchColumn(strLocationType)
          .setSearchTerm(searchTerm)
          .setPage(page)
          .setLimit(AdvanceSearchRequestBuilder.defaultLimit)
          .build();
      LocationResponse locationResponse =
          await _dataSource.searchLocations(advancedSearchRequest);
      return locationResponse;
    } catch (e, st) {
      AppLog.e('searchLocations: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<WorkApplicationResponse, String?>> getCategoryApplicationSearch(
      String categoryId, String supplyId, bool isSkipSaasOrgID,
      {String? workListingID, bool isCreateApplication = false}) async {
    try {
      List<String> status = [];
      status.add(WorkApplicationStatusEntity.created.value);
      status.add(WorkApplicationStatusEntity.selected.value);
      status.add(WorkApplicationStatusEntity.backedOut.value);
      status.add(WorkApplicationStatusEntity.executionCompleted.value);
      status.add(WorkApplicationStatusEntity.executionStarted.value);
      status.add(WorkApplicationStatusEntity.approvedToWork.value);
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .setLimit(100)
          .setPage(1)
          .setCreateApplication(true)
          .setIncludeApplicationEligibilities(true)
          .setSkipSaasOrgId(isSkipSaasOrgID);
      if (workListingID == null) {
        advancedSearchRequest.putPropertyToCondition(
            AdvancedSearchRequest.status, Operator.notIn, status);
        advancedSearchRequest.putPropertyToCondition(
            AdvancedSearchRequest.supplyPendingAction,
            Operator.notEqual,
            AdvancedSearchRequest.exploreOtherJobs);
      } else {
        advancedSearchRequest.putPropertyToCondition(
            AdvancedSearchRequest.worklistingID, Operator.equal, workListingID);
      }
      if (isCreateApplication) {
        advancedSearchRequest.setCreateApplication(isCreateApplication);
      }
      advancedSearchRequest.putPropertyToCondition(
          "archived_status", Operator.boolean, false);
      advancedSearchRequest.setCreateApplication(true);
      WorkApplicationResponse applicationResponse =
          await _dataSource.getCategoryApplicationSearch(
              categoryId, supplyId, advancedSearchRequest.build());
      return Tuple2(applicationResponse, null);
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationSearch: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkListingResponse> getWorkListing(int categoryID) async {
    try {
      const publishingStatus = "publishing_status";
      const categoryId = "category_id";
      var advancedSearchRequest =
      AdvanceSearchRequestBuilder().setSkipSaasOrgId(true).setLimit(50);
        advancedSearchRequest
            .putPropertyToCondition(
            publishingStatus, Operator.notEqual, "unpublished")
            .putPropertyToCondition(
            categoryId,
            Operator.equal,
            categoryID);
      WorkListingResponse apiResponse =
      await _dataSource.getWorkListing(advancedSearchRequest.build());
      return apiResponse;
    } catch (e, st) {
      AppLog.e(
          'getWorkListing: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<EligiblityEntityResponse> fetchEligiblity(int categoryApplicationId, int workListingId) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder();
      advancedSearchRequest
          .putPropertyToCondition(
              categoryApplicationid, Operator.equal, categoryApplicationId)
          .putPropertyToCondition(
              ineligibleWorklistings, Operator.contains, workListingId);
      EligiblityEntityResponse eligiblityEntityResponse =
          await _dataSource.fetchEligiblity(advancedSearchRequest.build());
      return eligiblityEntityResponse;
    } catch (e, st) {
      AppLog.e(
          'fetchEligiblity: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Question>> getQuestions(List<ApplicationAnswers>? applicationAnswerList,int? userID) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder();
      List<int> questionIds = [];
      for (ApplicationAnswers applicationrAnswer in applicationAnswerList!) {
        questionIds.add(applicationrAnswer.applicationQuestionId!);
      }
      advancedSearchRequest
          .putPropertyToCondition(
          "id", Operator.IN, questionIds);
      InEligibleQuestionAnswerEntity inEligibleQuestionAnswerEntity =
      await _dataSource.getQuestions(advancedSearchRequest.build());
      List<Question> questions = QuestionMapper.transformApplicationQuestions(
          inEligibleQuestionAnswerEntity.applicationQuestions,
          0,
          0,
          userID,
          ModuleType.eligiblityCriteria);
      return questions;
    } catch (e, st) {
      AppLog.e(
          'getQuestions: ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
