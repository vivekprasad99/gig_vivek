import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_analytics_response.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_entity.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_response.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/workapplication_request.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/campus_ambassador/campus_ambassador_data_source.dart';
import 'package:dio/dio.dart';

abstract class CampusAmbassadorRemoteRepository {
  Future<ApiResponse> createCampusAmbassador(
      String mobileNumber, int collegeId, String referralCode, int userId);

  Future<CampusAmbassadorResponse> getCampusAmbassador(int userId);

  Future<CampusAmbassdorTaskRespons> getCATask(int userId, int pageIndex);

  Future<Map<String, num>> getCampusAmbassadorAnalyze(
      int workListingid, String referralCode);

  Future<WorkApplicationResponse> caApplicationSearch(
      WorkApplicationPageRequest workApplicationPageRequest, int pageIndex);
}

class CampusAmbassadorRemoteRepositoryImpl
    implements CampusAmbassadorRemoteRepository {
  final CampusAmbassadorDataSource _dataSource;

  CampusAmbassadorRemoteRepositoryImpl(this._dataSource);

  @override
  Future<ApiResponse> createCampusAmbassador(String mobileNumber, int collegeId,
      String referralCode, int userId) async {
    try {
      CampusAmbassador campusAmbassador = CampusAmbassador(
          organisationId: collegeId,
          phoneNumber: mobileNumber,
          referralCode: referralCode,
          userId: userId);
      CampusAmbassdor campusAmbassdor =
          CampusAmbassdor(campusAmbassador: campusAmbassador);
      ApiResponse apiResponse =
          await _dataSource.createCampusAmbassador(userId, campusAmbassdor);
      return apiResponse;
    } catch (e, st) {
      AppLog.e('createCampusAmbassador : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CampusAmbassadorResponse> getCampusAmbassador(int userId) async {
    try {
      var apiResponse = await _dataSource.getCampusAmbassador(userId);
      return CampusAmbassadorResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getCampusAmbassador : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CampusAmbassdorTaskRespons> getCATask(
      int userId, int pageIndex) async {
    try {
      var apiResponse = await _dataSource.getCATask(
          userId,
          CampusAmbassadorTaskData(
            page: pageIndex,
          ));
      return CampusAmbassdorTaskRespons.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getCATask : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, num>> getCampusAmbassadorAnalyze(
      int workListingid, String referralCode) async {
    try {
      var body = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(
              Constants.worklistingid, Operator.equal, workListingid)
          .putPropertyToCondition(
              Constants.referredby, Operator.equal, referralCode)
          .build();
      var apiResponse = await _dataSource.getCampusAmbassadorAnalyze(body);
      CampusAmbassadorAnalyticsResponse campusAmbassadorAnalyticsResponse =
          CampusAmbassadorAnalyticsResponse.fromJson(apiResponse.data);
      return CampusAmbassadorMapper.transform(
          campusAmbassadorAnalyticsResponse);
    } catch (e, st) {
      AppLog.e(
          'getCampusAmbassadorAnalyze : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<WorkApplicationResponse> caApplicationSearch(
      WorkApplicationPageRequest workApplicationPageRequest,
      int pageIndex) async {
    try {
      var builder = AdvanceSearchRequestBuilder();
      if (workApplicationPageRequest.invalidStatuses != null) {
        builder.putPropertyToCondition(Constants.status, Operator.notIn,
            workApplicationPageRequest.invalidStatuses!);
      } else if (workApplicationPageRequest.validStatuses != null) {
        builder.putPropertyToCondition(
            Constants.status, Operator.IN, workApplicationPageRequest.validStatuses!);
      } else if (workApplicationPageRequest.applicationHistoryQueryCondition !=
          null) {
        builder.setConditions(
            workApplicationPageRequest.applicationHistoryQueryCondition);
      }
      if (workApplicationPageRequest.supplyPendingActionAppliedJobs != null) {
        builder.putPropertyToCondition(
            Constants.supplyPendingAction,
            Operator.notEqual,
            workApplicationPageRequest.supplyPendingActionAppliedJobs!);
      }
      if (workApplicationPageRequest.referredBy != null) {
        builder.putPropertyToCondition(Constants.referredby, Operator.equal,
            workApplicationPageRequest.referredBy!);
      }
      if (workApplicationPageRequest.workListingId != null) {
        builder.putPropertyToCondition(Constants.worklistingid, Operator.equal,
            workApplicationPageRequest.workListingId!);
      }
      builder.setSkipSaasOrgId(workApplicationPageRequest.skipSaasOrgId!);
      builder.setPage(pageIndex);
      Response response =
          await _dataSource.caApplicationSearch(builder.build());
      return WorkApplicationResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('getCampusAmbassador : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
