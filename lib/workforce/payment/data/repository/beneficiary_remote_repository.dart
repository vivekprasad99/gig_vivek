import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/ifsc_response.dart';
import 'package:awign/workforce/payment/data/model/pan_details_request.dart';
import 'package:awign/workforce/payment/data/network/data_source/beneficiary_remote_data_source.dart';

abstract class BeneficiaryRemoteRepository {
  Future<BeneficiaryResponse> getBeneficiaries(
      BeneficiaryRequestParam beneficiaryRequestParam);

  Future<BankData> validateIFSC(String ifsc);

  Future<AddBeneficiaryResponse> addBeneficiary(Beneficiary beneficiary);

  Future<AddBeneficiaryResponse> verifyBeneficiary(String beneficiaryID);

  Future<ApiResponse> deleteBeneficiary(String beneficiaryID);

  Future<AddBeneficiaryResponse> updateBeneficiaryActiveStatus(
      String beneficiaryID, bool isActive);
}

class BeneficiaryRemoteRepositoryImpl implements BeneficiaryRemoteRepository {
  final BeneficiaryRemoteDataSource _dataSource;

  BeneficiaryRemoteRepositoryImpl(this._dataSource);

  @override
  Future<BeneficiaryResponse> getBeneficiaries(
      BeneficiaryRequestParam beneficiaryRequestParam) async {
    try {
      Map<String, String> body = {};
      body['user_id'] = beneficiaryRequestParam.userId.toString();

      if (beneficiaryRequestParam.status != null) {
        body['verification_status'] = beneficiaryRequestParam.status!.value.toString();
      }

      ApiResponse apiResponse = await _dataSource
          .getBeneficiaries(body);
      return BeneficiaryResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e('getBeneficiaries : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<BankData> validateIFSC(String ifsc) async {
    try {
      ApiResponse apiResponse = await _dataSource.validateIFSC(ifsc);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return BankData.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('validateIFSC : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<AddBeneficiaryResponse> addBeneficiary(Beneficiary beneficiary) async {
    try {
      ApiResponse apiResponse = await _dataSource.addBeneficiary(beneficiary);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return AddBeneficiaryResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('addBeneficiary : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<AddBeneficiaryResponse> verifyBeneficiary(String beneficiaryID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.verifyBeneficiary(beneficiaryID);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return AddBeneficiaryResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('verifyBeneficiary : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> deleteBeneficiary(String beneficiaryID) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.deleteBeneficiary(beneficiaryID);
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('deleteBeneficiary : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<AddBeneficiaryResponse> updateBeneficiaryActiveStatus(
      String beneficiaryID, bool isActive) async {
    try {
      ApiResponse apiResponse = await _dataSource.updateBeneficiaryActiveStatus(
          beneficiaryID, isActive ? 'active' : 'inactive');
      if (apiResponse.status?.toLowerCase() == ApiResponse.success) {
        return AddBeneficiaryResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e(
          'updateBeneficiaryActiveStatus : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
