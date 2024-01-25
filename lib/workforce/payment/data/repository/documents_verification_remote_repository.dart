import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/model/document_entity.dart';
import 'package:awign/workforce/payment/data/network/data_source/documents_verification_remote_data_source.dart';

import '../model/pan_details_request.dart';
import '../model/pan_details_response.dart';

abstract class DocumentsVerificationRemoteRepository {
  Future<DocumentParseResponse> parsePAN(String docURL);

  Future<DocumentParseResponse> parseAadhaar(String docURL);

  Future<DocumentParseResponse> parseDrivingLicence(String docURL);

  Future<PANDetailsResponse> getPANDetails(String userID, PANDetailsRequest panDetailsRequest);

  Future<PANDetailsResponse> updatePANStatus(String userID, PANDetailsRequest panDetailsRequest);
}

class DocumentsVerificationRemoteRepositoryImpl
    implements DocumentsVerificationRemoteRepository {
  final DocumentsVerificationRemoteDataSource _dataSource;

  DocumentsVerificationRemoteRepositoryImpl(this._dataSource);

  @override
  Future<DocumentParseResponse> parsePAN(String docURL) async {
    try {
      DocumentRequestBody documentRequestBody =
          DocumentRequestBody(frontImage: docURL);
      DocumentRequest documentRequest =
          DocumentRequest(pan: documentRequestBody);
      ApiResponse apiResponse = await _dataSource.parsePAN(documentRequest);
      if (apiResponse.status == ApiResponse.success) {
        return DocumentParseResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('parsePAN : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<DocumentParseResponse> parseAadhaar(String docURL) async {
    try {
      DocumentRequestBody documentRequestBody =
          DocumentRequestBody(frontImage: docURL);
      DocumentRequest documentRequest =
          DocumentRequest(aadhar: documentRequestBody);
      ApiResponse apiResponse = await _dataSource.parseAadhaar(documentRequest);
      if (apiResponse.status == ApiResponse.success) {
        return DocumentParseResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('parseAadhaar : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<DocumentParseResponse> parseDrivingLicence(String docURL) async {
    try {
      DocumentRequestBody documentRequestBody =
          DocumentRequestBody(frontImage: docURL);
      DocumentRequest documentRequest =
          DocumentRequest(drivingLicence: documentRequestBody);
      ApiResponse apiResponse =
          await _dataSource.parseDrivingLicence(documentRequest);
      if (apiResponse.status == ApiResponse.success) {
        return DocumentParseResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('parseDrivingLicence : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<PANDetailsResponse> getPANDetails(String userID, PANDetailsRequest panDetailsRequest) async {
    try {
      PANDetailsResponse panDetailsResponse = await _dataSource.getPANDetails(userID, panDetailsRequest);
      return panDetailsResponse;
    } catch (e, st) {
      AppLog.e('getPANDetails : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<PANDetailsResponse> updatePANStatus(String userID, PANDetailsRequest panDetailsRequest) async {
    try {
      PANDetailsResponse panDetailsResponse = await _dataSource.updatePANStatus(userID, panDetailsRequest);
      return panDetailsResponse;
    } catch (e, st) {
      AppLog.e('updatePANStatus : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
