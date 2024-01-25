import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/pan_details_request.dart';
import 'package:awign/workforce/payment/data/network/api/payments_bff_api.dart';
import 'package:awign/workforce/payment/data/network/api/pds_api.dart';
import 'package:dio/dio.dart';

abstract class BeneficiaryRemoteDataSource {
  Future<ApiResponse> getBeneficiaries(
      Map<String, String> body);

  Future<ApiResponse> validateIFSC(String ifsc);

  Future<ApiResponse> addBeneficiary(Beneficiary beneficiary);

  Future<ApiResponse> verifyBeneficiary(String beneficiaryID);

  Future<ApiResponse> deleteBeneficiary(String beneficiaryID);

  Future<ApiResponse> updateBeneficiaryActiveStatus(
      String beneficiaryID, String status);
}

class BeneficiaryRemoteDataSourceImpl extends PdsAPI
    implements BeneficiaryRemoteDataSource {
  @override
  Future<ApiResponse> getBeneficiaries(
      Map<String, String> body) async {
    try {
      Response response = await bffRestClient.post(PaymentsBffAPI().getBeneficiaries(),
          body: body);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> validateIFSC(String ifsc) async {
    try {
      Response response =
          await bffRestClient.get(PaymentsBffAPI().validateIfsc(ifsc));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> addBeneficiary(Beneficiary beneficiary) async {
    try {
      Response response = await bffRestClient.post(PaymentsBffAPI().createBeneficiary(),
          body: beneficiary.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> verifyBeneficiary(String beneficiaryID) async {
    try {
      Response response = await bffRestClient.patch(
          PaymentsBffAPI().verifyBeneficiary(beneficiaryID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> deleteBeneficiary(String beneficiaryID) async {
    try {
      Response response = await bffRestClient.delete(
          PaymentsBffAPI().deleteBeneficiary(beneficiaryID));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateBeneficiaryActiveStatus(
      String beneficiaryID, String status) async {
    try {
      Response response = await bffRestClient.patch(
          PaymentsBffAPI().updateBeneficiaryActiveStatus(beneficiaryID, status));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
