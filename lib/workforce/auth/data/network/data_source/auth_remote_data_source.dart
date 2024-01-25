import 'package:awign/workforce/auth/data/model/collage_detail_request.dart';
import 'package:awign/workforce/auth/data/model/collage_search_detail_request.dart';
import 'package:awign/workforce/auth/data/model/device_info.dart';
import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/auth/data/model/professional_experiences_request.dart';
import 'package:awign/workforce/auth/data/model/update_languages_request.dart';
import 'package:awign/workforce/auth/data/model/update_user_profile_request.dart';
import 'package:awign/workforce/auth/data/model/user_feedback_response.dart';
import 'package:awign/workforce/auth/data/model/user_mobile_verification_request.dart';
import 'package:awign/workforce/auth/data/model/user_request_payload.dart';
import 'package:awign/workforce/auth/data/network/api/auth_api.dart';
import 'package:awign/workforce/auth/feature/otp_verification/data/mobile_verification_request.dart';
import 'package:awign/workforce/auth/feature/user_location/data/model/address_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/omni_auth.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:dio/dio.dart';

import '../../../../onboarding/data/model/nudge/nudge_response.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse> validateToken();

  Future<ApiResponse> getUserProfile(int? userID);

  Future<ApiResponse> getUserNudge(int? userID);

  Future<ApiResponse> signInByEmail(UserLoginRequest userLoginRequest);

  Future<ApiResponse> signInByGoogle(OmniAuthRequest omniAuthRequest);

  Future<ApiResponse> generateOTP(int? userID);

  Future<ApiResponse> subscribeWhatsapp(int? userID);

  Future<ApiResponse> verifyOTP(
      int? userID, UserNewLoginRequest userNewLoginRequest);

  Future<ApiResponse> updateUserMobileNumber(
      int? userID, UserMobileVerificationRequest userMobileVerificationRequest);

  Future<ApiResponse> updateUserProfile(
      int? userID, UpdateUserProfileRequest updateUserProfileRequest);

  Future<ApiResponse> updateLanguages(
      int? userID, UpdateLanguagesRequest updateLanguagesRequest);

  Future<ApiResponse> createAddress(int? userID, AddressRequest addressRequest);

  Future<ApiResponse> updateAddress(
      int? userID, int? addressID, AddressRequest addressRequest);

  Future<ApiResponse> searchProfileAttributes(
      int? userID, AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> searchCollage(
      CollageSearchDetailRequest collageSearchDetailRequest);

  Future<ApiResponse> createEducation(
      int? userID, EducationDetailRequest educationDetailRequest);

  Future<ApiResponse> updateEducation(int? userID, int? educationID,
      EducationDetailRequest educationDetailRequest);

  Future<ApiResponse> updateProfileAttributes(
      int? userID, int? id, ProfileAttributesRequest profileAttributesRequest);

  Future<ApiResponse> createProfileAttribute(
      int? userId, Map<String, Object> profileAttributesRequest);

  Future<ApiResponse> updateProfessionalExperiences(
      int? userID, ProfessionalExperienceRequest professionalExperienceRequest);

  Future<ApiResponse> signInWithNumber(UserNewLoginRequest userNewLoginRequest);

  Future<ApiResponse> unSubscribeWhatsapp(int? userID);

  Future<ApiResponse> nudgeEvent(NudgeEventRequest nudgeEventRequest);

  Future<ApiResponse> getPANDetails(int userID);

  Future<ApiResponse> updatePanDetails(
      int userID, DocumentDetailsData documentDetailsData);

  Future<ApiResponse> updateAadharDetails(
      int userID, DocumentDetailsData documentDetailsData);

  Future<ApiResponse> updateDrivingLicence(
      int userID, DocumentDetailsData documentDetailsData);

  Future<ApiResponse> verifyAadharOTP(int userID, Map<String, dynamic> map);

  Future<ApiResponse> updateDeviceInfo(DeviceInfoRequest deviceInfoRequest);

  Future<ApiResponse> internalUserFeedback(
      UserFeedbackRequest userFeedbackRequest);

  Future internalFeedbackEventSearch(
      AdvancedSearchRequest advancedSearchRequest);

  Future<ApiResponse> deleteUserAccount(int userID);

  Future<ApiResponse> initiateOtpLess();

  Future<ApiResponse> signInWhatsappLogin(String token);

  Future<ApiResponse> emailUpdate(
      int? userID, UserRequestDataPayload userRequestDataPayload);
}

class AuthRemoteDataSourceImpl extends AuthAPI implements AuthRemoteDataSource {
  @override
  Future<ApiResponse> validateToken() async {
    try {
      Response response = await authRestClient.get(validationTokenAPI);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getUserProfile(int? userID) async {
    try {
      Response response =
          await authRestClient.get('$fetchUserProfileAPI$userID');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> signInByEmail(UserLoginRequest userLoginRequest) async {
    try {
      Response response = await authRestClient.post(emailSignInAPI,
          body: userLoginRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> signInByGoogle(OmniAuthRequest omniAuthRequest) async {
    try {
      Response response = await authRestClient.post(googleSignInAPI,
          body: omniAuthRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> generateOTP(int? userID) async {
    try {
      Response response = await authRestClient
          .post(generateAndSendOTPAPI.replaceAll('userID', '$userID'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> subscribeWhatsapp(int? userID) async {
    try {
      Response response = await authRestClient
          .patch(subscribeWhatsappAPI.replaceAll('userID', '$userID'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> unSubscribeWhatsapp(int? userID) async {
    try {
      Response response = await authRestClient
          .patch(unSubscribeWhatsappAPI.replaceAll('userID', '$userID'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> verifyOTP(
      int? userID, UserNewLoginRequest userNewLoginRequest) async {
    try {
      Response response = await authV2RestClient.post(
          verifyOTPAPI.replaceAll('userID', '$userID'),
          body: userNewLoginRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateUserMobileNumber(int? userID,
      UserMobileVerificationRequest userMobileVerificationRequest) async {
    try {
      Response response = await authRestClient.post(
          updateUserMobileNumberAPI.replaceAll('userID', '$userID'),
          body: userMobileVerificationRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateUserProfile(
      int? userID, UpdateUserProfileRequest updateUserProfileRequest) async {
    try {
      Response response = await authRestClient.patch(
          updateUserProfileAPI.replaceAll('userID', '$userID'),
          body: updateUserProfileRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateLanguages(
      int? userID, UpdateLanguagesRequest updateLanguagesRequest) async {
    try {
      Response response = await authRestClient.post(
          updateLanguagesAPI.replaceAll('userID', '$userID'),
          body: updateLanguagesRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createAddress(
      int? userID, AddressRequest addressRequest) async {
    try {
      Response response = await authRestClient.post(
          createAddressAPI.replaceAll('userID', '$userID'),
          body: addressRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateAddress(
      int? userID, int? addressID, AddressRequest addressRequest) async {
    try {
      Response response = await authRestClient.patch(
          updateAddressAPI
              .replaceAll('userID', '$userID')
              .replaceAll('addressID', '$addressID'),
          body: addressRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> searchProfileAttributes(
      int? userID, AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await authRestClient.post(
          searchProfileAttributesAPI.replaceAll('userID', '$userID'),
          body: advancedSearchRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> searchCollage(
      CollageSearchDetailRequest searchDetailRequest) async {
    try {
      Response response = await authRestClient.post(searchCollageAPI,
          body: searchDetailRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createEducation(
      int? userID, EducationDetailRequest educationDetailRequest) async {
    try {
      Response response = await authRestClient.post(
          createEducationAPI.replaceAll('userID', '$userID'),
          body: educationDetailRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateEducation(int? userID, int? educationID,
      EducationDetailRequest educationDetailRequest) async {
    try {
      Response response = await authRestClient.patch(
          updateEducationAPI
              .replaceAll('userID', '$userID')
              .replaceAll('educationID', '$educationID'),
          body: educationDetailRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateProfileAttributes(int? userID, int? id,
      ProfileAttributesRequest profileAttributesRequest) async {
    try {
      Response response = await authRestClient.patch(
          updateProfileAttributesAPI
              .replaceAll('userID', '$userID')
              .replaceAll('id', '$id'),
          body: profileAttributesRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateProfessionalExperiences(int? userID,
      ProfessionalExperienceRequest professionalExperienceRequest) async {
    try {
      Response response = await authRestClient.post(
          updateProfessionalExperiencesAPI.replaceAll('userID', '$userID'),
          body: professionalExperienceRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> signInWithNumber(
      UserNewLoginRequest userNewLoginRequest) async {
    try {
      Response response = await authV2RestClient.post(signInWithNumberAPI,
          body: userNewLoginRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getUserNudge(int? userID) async {
    try {
      Response response = await authRestClient
          .get(fetchUserNudge.replaceAll('userID', '$userID'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> nudgeEvent(NudgeEventRequest nudgeEventRequest) async {
    try {
      Response response =
          await authRestClient.post(nudgeEventApi, body: nudgeEventRequest);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createProfileAttribute(
      int? userId, Map<String, Object> profileAttributesRequest) async {
    try {
      Response response = await authRestClient.post(
          createProfileAttributesAPI.replaceAll('userID', '$userId'),
          body: profileAttributesRequest);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> getPANDetails(int userID) async {
    try {
      Response response = await authRestClient
          .get(getPANDetailsAPI.replaceAll('userID', '$userID'));
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updatePanDetails(
      int userID, DocumentDetailsData documentDetailsData) async {
    try {
      Response response = await authRestClient.patch(
          updatePanDetailsAPI.replaceAll('userID', '$userID'),
          body: documentDetailsData.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateAadharDetails(
      int userID, DocumentDetailsData documentDetailsData) async {
    try {
      Response response = await authRestClient.patch(
          updateAadharDetailsAPI.replaceAll('userID', '$userID'),
          body: documentDetailsData.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateDrivingLicence(
      int userID, DocumentDetailsData documentDetailsData) async {
    try {
      Response response = await authRestClient.patch(
          updateDrivingLicenceAPI.replaceAll('userID', '$userID'),
          body: documentDetailsData.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> verifyAadharOTP(
      int userID, Map<String, dynamic> map) async {
    try {
      Response response = await authRestClient
          .post(verifyAadharOTPAPI.replaceAll('userID', '$userID'), body: map);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateDeviceInfo(
      DeviceInfoRequest deviceInfoRequest) async {
    try {
      Response response = await authRestClient.post(updateDeviceInfoAPI,
          body: deviceInfoRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> internalUserFeedback(
      UserFeedbackRequest userFeedbackRequest) async {
    try {
      Response response = await authRestClient.post(internalUserFeedbackAPI,
          body: userFeedbackRequest.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future internalFeedbackEventSearch(
      AdvancedSearchRequest advancedSearchRequest) async {
    try {
      Response response = await authRestClient.post(
          internalFeedbackEventSearchAPI,
          body: advancedSearchRequest.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> deleteUserAccount(int userID) async {
    try {
      Response response = await authRestClient
          .post(deactivateUserAPI.replaceAll('userID', '$userID'), body: {});
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> initiateOtpLess() async {
    try {
      Response response =
          await otpLessRestClient.post(initiateWhatsappLoginAPI, body: {
        Constants.loginMethod: Constants.whatsapp,
      }, header: {
        "appId": Constants.otpLessKey
      });
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> signInWhatsappLogin(String token) async {
    try {
      Response response = await whatsappSigninRestClient.post(
          signInWhatsappLoginAPI,
          body: {"oauth_type": Constants.otpLess, "token": token});
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> emailUpdate(
      int? userID, UserRequestDataPayload userRequestDataPayload) async {
    try {
      Response response = await authRestClient.post(
          emailUpdateAPI.replaceAll('userID', '$userID'),
          body: userRequestDataPayload.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
