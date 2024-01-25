import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/signature_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_block_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_view_response.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/execution_remote_data_source.dart';
import 'package:tuple/tuple.dart';

abstract class ExecutionRemoteRepository {
  Future<Tuple2<ExecutionsResponse, String>> getExecutions(
      int page, ExecutionPageParameters executionPageParameters);

  Future<SignatureResponse> getSignatures(String memberID);

  Future<SignatureResponse> createSignature(
      String memberID,
      String name,
      String phoneNo,
      String address,
      String pincode,
      String city,
      String state,
      String fontType);

  Future<ApiResponse> acceptOfferLetter(
      String projectID, String executionID, String signatureID);

  Future<SummaryViewResponse> fetchSummaryView(
      String executionID, String projectRoleUID);

  Future<SummaryBlockResponse> fetchLeadBlock(String executionID,
      String projectRoleUID, String listViewID, String summaryViewID);
}

class ExecutionRemoteRepositoryImpl implements ExecutionRemoteRepository {
  final ExecutionRemoteDataSource _dataSource;

  ExecutionRemoteRepositoryImpl(this._dataSource);

  @override
  Future<Tuple2<ExecutionsResponse, String>> getExecutions(
      int page, ExecutionPageParameters executionPageParameters) async {
    try {
      String uIDS = 'category_uids';
      var advancedSearchRequest = AdvanceSearchRequestBuilder()
          .putPropertyToCondition(
              uIDS, Operator.IN, executionPageParameters.uIDs)
          .setSkipSaasOrgId(executionPageParameters.skipSaasOrgId)
          .setLimit(50)
          .setPage(page)
          .build();
      ApiResponse apiResponse = await _dataSource.getExecutions(
          executionPageParameters.memberID, advancedSearchRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            ExecutionsResponse.fromJson(
                apiResponse.data, executionPageParameters.uIDs),
            apiResponse.message ?? '');
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getExecutions : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<SignatureResponse> getSignatures(String memberID) async {
    try {
      ApiResponse apiResponse = await _dataSource.getSignatures(memberID);
      if (apiResponse.status == ApiResponse.success) {
        return SignatureResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getSignatures : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<SignatureResponse> createSignature(
      String memberID,
      String name,
      String phoneNo,
      String address,
      String pincode,
      String city,
      String state,
      String fontType) async {
    try {
      Signature signature = Signature(
          name: name,
          mobileNumber: phoneNo,
          address: address,
          pincode: pincode,
          city: city,
          state: state,
          font: fontType);
      CreateSignatureRequest createSignatureRequest =
          CreateSignatureRequest(signature: signature);
      ApiResponse apiResponse =
          await _dataSource.createSignature(memberID, createSignatureRequest);
      if (apiResponse.status == ApiResponse.success) {
        return SignatureResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('createSignature : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> acceptOfferLetter(
      String projectID, String executionID, String signatureID) async {
    try {
      ApiResponse apiResponse = await _dataSource.acceptOfferLetter(
          projectID, executionID, signatureID);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('acceptOfferLetter : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<SummaryViewResponse> fetchSummaryView(
      String executionID, String projectRoleUID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.fetchSummaryView(executionID, projectRoleUID);
      if (apiResponse.status == ApiResponse.success) {
        return SummaryViewResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('fetchSummaryView : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<SummaryBlockResponse> fetchLeadBlock(String executionID,
      String projectRoleUID, String listViewID, String summaryViewID) async {
    try {
      ApiResponse apiResponse = await _dataSource.fetchLeadBlock(
          executionID, projectRoleUID, listViewID, summaryViewID);
      if (apiResponse.status == ApiResponse.success) {
        return SummaryBlockResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('fetchLeadBlock : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
