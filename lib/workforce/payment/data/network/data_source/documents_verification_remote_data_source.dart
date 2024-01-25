import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/payment/data/model/document_entity.dart';
import 'package:awign/workforce/payment/data/network/api/documents_api.dart';
import 'package:dio/dio.dart';

import '../../model/pan_details_request.dart';
import '../../model/pan_details_response.dart';
import '../api/payments_bff_api.dart';

abstract class DocumentsVerificationRemoteDataSource {
  Future<ApiResponse> parsePAN(DocumentRequest documentRequest);

  Future<ApiResponse> parseAadhaar(DocumentRequest documentRequest);

  Future<ApiResponse> parseDrivingLicence(DocumentRequest documentRequest);

  Future<PANDetailsResponse> getPANDetails(String userID, PANDetailsRequest panDetailsRequest);

  Future<PANDetailsResponse> updatePANStatus(String userID, PANDetailsRequest panDetailsRequest);
}

class DocumentsVerificationRemoteDataSourceImpl extends DocumentsAPI
    implements DocumentsVerificationRemoteDataSource {
  @override
  Future<ApiResponse> parsePAN(DocumentRequest documentRequest) async {
    try {
      Response response = await documentsRestClient.post(parsePanAPI,
          body: documentRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> parseAadhaar(DocumentRequest documentRequest) async {
    try {
      Response response = await documentsRestClient.post(parseAadharAPI,
          body: documentRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> parseDrivingLicence(
      DocumentRequest documentRequest) async {
    try {
      Response response = await documentsRestClient.post(parseDLAPI,
          body: documentRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PANDetailsResponse> getPANDetails(String userID, PANDetailsRequest panDetailsRequest) async {
    try {
      Response response = await authRestClient.patch(
          getPANDetailsAPI.replaceFirst('USER_ID', userID), body: panDetailsRequest.toJson());
      return PANDetailsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PANDetailsResponse> updatePANStatus(String userID, PANDetailsRequest panDetailsRequest) async {
    try {
      Response response = await authRestClient.patch(
          updatePANStatusAPI.replaceFirst('USER_ID', userID), body: panDetailsRequest.toJson());
      return PANDetailsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
