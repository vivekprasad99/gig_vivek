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
import 'package:awign/workforce/auth/data/network/data_source/auth_remote_data_source.dart';
import 'package:awign/workforce/auth/feature/otp_verification/data/mobile_verification_request.dart';
import 'package:awign/workforce/auth/feature/user_location/data/model/address_request.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/education_detail_response.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/omni_auth.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/sign_in_with_number_response.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/device_info_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:awign/workforce/onboarding/data/model/nudge/nudge_response.dart';
import 'package:tuple/tuple.dart';

abstract class AuthRemoteRepository {
  Future<Tuple2<ValidateTokenResponse, String?>> validateToken();

  Future<UserProfileResponse> getUserProfile(int? userID);

  Future<Tuple2<LoginResponse, String?>> signInByEmail(String email);

  Future<Tuple2<LoginResponse, String?>> signInByGoogle(String uID, String name,
      String email, String image, String provider, List<String> roles);

  Future<ApiResponse> generateOTP(int? userID);

  Future<ApiResponse> subscribeWhatsapp(int? userID);

  Future<Tuple2<LoginResponse, String?>> verifyOTP(
      int? userID, UserNewLoginRequest userNewLoginRequest);

  Future<Tuple2<ValidateTokenResponse, String?>> updateUserMobileNumber(
      int? userID, String mobileNumber);

  Future<ApiResponse> updateUserProfile(
      int? userID,
      String? name,
      String? email,
      Gender? gender,
      String? educationLevel,
      String? dob,
      String? profileCompletionStage,
      bool? userDetailsRequired,
      bool? workedBefore);

  Future<ApiResponse> updateLanguages(int? userID, List<Languages>? languages);

  Future<ApiResponse> createAddress(int? userID, Address addresses);

  Future<ApiResponse> updateAddress(
      int? userID, int? addressID, Address addresses);

  Future<Tuple2<ProfileAttributesResponse, String?>> searchProfileAttributes(
      int? userID);

  Future<Tuple2<EducationDetailResponse, String?>> searchCollage(
      String? searchTerm, int? page);

  Future<Tuple2<ApiResponse, String?>> createEducation(
      int? userID, Education education);

  Future<Tuple2<ApiResponse, String?>> updateEducation(
      int? userID, int? educationID, Education education);

  Future<ApiResponse> updateProfileAttributes(
      int? userID, int? id, ProfileAttributes profileAttributes);

  Future<List<ProfileAttributes>> createProfileAttribute(
      int? userId, String? attributeName, String? value);

  Future<ApiResponse> updateProfessionalExperiences(
      int? userID, List<WorkingDomain> workingDomainList);

  Future<ApiResponse> signInWithNumber(UserNewLoginRequest userNewLoginRequest);

  Future<ApiResponse> unSubscribeWhatsapp(int? userID);

  Future<NudgeResponse> getUserNudge(int? userID);

  Future<ApiResponse> nudgeEvents(
      int userId, String eventName, String eventType, String eventAt);

  Future<KycDetails> getPANDetails(int userID);

  Future<Tuple2<KycDetails, DocumentDetailsData>> updatePanDetails(
      int userID, KycDetails kycDetails, bool rejectIfFailed);

  Future<Tuple2<KycDetails, DocumentDetailsData>> updateAadharDetails(
      int userID, KycDetails kycDetails);

  Future<Tuple2<KycDetails, DocumentDetailsData>> updateDrivingLicence(
      int userID, KycDetails kycDetails);

  Future<KycDetails> verifyAadharOTP(
      int userID, String otp, bool rejectIfFailed);

  Future<ApiResponse> updateDeviceInfo(
      int? userID, String? role, String fcmToken);

  Future<UserFeedbackRequest> internalUserFeedback(
      UserFeedbackRequest userFeedbackRequest);

  Future<FeedbackEventResponse> internalFeedbackEventSearch(int userId);

  Future<ApiResponse> deleteUserAccount(int userID);

  Future<ApiResponse> initiateOtpLess();

  Future<Tuple2<LoginResponse, String?>> signInWhatsappLogin(String token);

  Future<ApiResponse> emailUpdate(int? userID, String email);
}

class AuthRemoteRepositoryImpl implements AuthRemoteRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRemoteRepositoryImpl(this._dataSource);

  @override
  Future<Tuple2<ValidateTokenResponse, String?>> validateToken() async {
    try {
      final apiResponse = await _dataSource.validateToken();
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(ValidateTokenResponse.fromJson(apiResponse.data),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('validateToken : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<UserProfileResponse> getUserProfile(int? userID) async {
    try {
      final apiResponse = await _dataSource.getUserProfile(userID);
      return UserProfileResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getUserProfile : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<NudgeResponse> getUserNudge(int? userID) async {
    try {
      final apiResponse = await _dataSource.getUserNudge(userID);
      return NudgeResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getUserNudge : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<LoginResponse, String?>> signInByEmail(String email) async {
    try {
      UserData userData = UserData(email: email);
      UserLoginRequest userLoginRequest = UserLoginRequest(userData: userData);
      final apiResponse = await _dataSource.signInByEmail(userLoginRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            LoginResponse.fromJson(apiResponse.data as Map<String, dynamic>),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('signInByEmail : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<LoginResponse, String?>> signInByGoogle(String uID, String name,
      String email, String image, String provider, List<String> roles) async {
    try {
      GoogleSignInInfo googleSignInInfo =
          GoogleSignInInfo(name: name, email: email, image: image);
      GoogleSignInData googleSignInData = GoogleSignInData(
          uid: uID, info: googleSignInInfo, provider: provider);
      OmniAuthRequest omniAuthRequest =
          OmniAuthRequest(omniauth: googleSignInData);
      final apiResponse = await _dataSource.signInByGoogle(omniAuthRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            LoginResponse.fromJson(apiResponse.data as Map<String, dynamic>),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('signInByGoogle : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> generateOTP(int? userID) async {
    try {
      final apiResponse = await _dataSource.generateOTP(userID);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('generateOTP : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> subscribeWhatsapp(int? userID) async {
    try {
      final apiResponse = await _dataSource.subscribeWhatsapp(userID);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('subscribeWhatsapp : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<LoginResponse, String?>> verifyOTP(
      int? userID, UserNewLoginRequest userNewLoginRequest) async {
    try {
      final apiResponse =
          await _dataSource.verifyOTP(userID, userNewLoginRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            LoginResponse.fromJson(apiResponse.data as Map<String, dynamic>),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('verifyOTP : ${e.toString()}\n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<ValidateTokenResponse, String?>> updateUserMobileNumber(
      int? userID, String mobileNumber) async {
    try {
      OTPVerificationRequest otpVerificationRequest =
          OTPVerificationRequest(mobileNumber: mobileNumber, otp: null);
      UserMobileVerificationRequest userMobileVerificationRequest =
          UserMobileVerificationRequest(user: otpVerificationRequest);
      final apiResponse = await _dataSource.updateUserMobileNumber(
          userID, userMobileVerificationRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(ValidateTokenResponse.fromJson(apiResponse.data),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateUserMobileNumber : ${e.toString()}\n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateUserProfile(
      int? userID,
      String? name,
      String? email,
      Gender? gender,
      String? educationLevel,
      String? dob,
      String? profileCompletionStage,
      bool? userDetailsRequired,
      bool? workedBefore) async {
    try {
      WorkforceDetailsRequest workforceDetailsRequest = WorkforceDetailsRequest(
          name: name,
          email: email,
          gender: gender,
          educationLevel: educationLevel,
          dob: dob,
          profileCompletionStage: profileCompletionStage,
          userDetailsRequired: userDetailsRequired,
          workedBefore: workedBefore);
      UpdateUserProfileRequest updateUserProfileRequest =
          UpdateUserProfileRequest(workforceDetails: workforceDetailsRequest);
      final apiResponse =
          await _dataSource.updateUserProfile(userID, updateUserProfileRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateUserProfile : ${e.toString()}\n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateLanguages(
      int? userID, List<Languages>? languages) async {
    try {
      UpdateLanguagesRequest updateLanguagesRequest =
          UpdateLanguagesRequest(languages: languages);
      final apiResponse =
          await _dataSource.updateLanguages(userID, updateLanguagesRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateLanguages : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createAddress(int? userID, Address address) async {
    try {
      AddressRequest addressRequest = AddressRequest(address: address);
      final apiResponse =
          await _dataSource.createAddress(userID, addressRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('createAddress : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateAddress(
      int? userID, int? addressID, Address address) async {
    try {
      AddressRequest addressRequest = AddressRequest(address: address);
      final apiResponse =
          await _dataSource.updateAddress(userID, addressID, addressRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateAddress : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<ProfileAttributesResponse, String?>> searchProfileAttributes(
      int? userID) async {
    try {
      final apiResponse = await _dataSource.searchProfileAttributes(
          userID, AdvanceSearchRequestBuilder().build());
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(ProfileAttributesResponse.fromJson(apiResponse.data),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('searchProfileAttributes : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<EducationDetailResponse, String?>> searchCollage(
      String? searchTerm, int? page) async {
    try {
      CollageSearchDetailRequest collageSearchDetailRequest =
          CollageSearchDetailRequest(searchTerm: searchTerm, page: page);
      final apiResponse =
          await _dataSource.searchCollage(collageSearchDetailRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(EducationDetailResponse.fromJson(apiResponse.data),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('searchCollage : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<ApiResponse, String?>> createEducation(
      int? userID, Education education) async {
    try {
      EducationDetailRequest educationDetailRequest =
          EducationDetailRequest(education: education);
      final apiResponse =
          await _dataSource.createEducation(userID, educationDetailRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            ApiResponse.fromJson(apiResponse.data), apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('createEducation : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<ApiResponse, String?>> updateEducation(
      int? userID, int? educationID, Education education) async {
    try {
      EducationDetailRequest educationDetailRequest =
          EducationDetailRequest(education: education);
      final apiResponse = await _dataSource.updateEducation(
          userID, educationID, educationDetailRequest);
      if (apiResponse.status == ApiResponse.success) {
        return Tuple2(
            ApiResponse.fromJson(apiResponse.data), apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateEducation : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateProfileAttributes(
      int? userID, int? id, ProfileAttributes profileAttributes) async {
    try {
      ProfileAttributesRequest profileAttributesRequest =
          ProfileAttributesRequest(profileAttributes: profileAttributes);
      final apiResponse = await _dataSource.updateProfileAttributes(
          userID, id, profileAttributesRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateProfileAttributes : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateProfessionalExperiences(
      int? userID, List<WorkingDomain> workingDomainList) async {
    try {
      List<ProfessionalExperiences> professionalExperiencesList = [];
      for (WorkingDomain workingDomain in workingDomainList) {
        ProfessionalExperiences professionalExperiences =
            ProfessionalExperiences(skill: workingDomain.name);
        professionalExperiencesList.add(professionalExperiences);
      }
      ProfessionalExperienceRequest professionalExperienceRequest =
          ProfessionalExperienceRequest(
              professionalExperiences: professionalExperiencesList);
      final apiResponse = await _dataSource.updateProfessionalExperiences(
          userID, professionalExperienceRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e(
          'updateProfessionalExperiences : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> signInWithNumber(
      UserNewLoginRequest userNewLoginRequest) async {
    try {
      final apiResponse =
          await _dataSource.signInWithNumber(userNewLoginRequest);
      if (apiResponse.status == ApiResponse.success) {
        SignInWithNumberResponse signInWithNumberResponse =
            SignInWithNumberResponse.fromJson(apiResponse.data);
        SPUtil? spUtil = await SPUtil.getInstance();
        if (signInWithNumberResponse.user != null) {
          spUtil?.putUserData(signInWithNumberResponse.user);
        }
        if (signInWithNumberResponse.headers?.xROUTE != null) {
          spUtil?.putXRoute(signInWithNumberResponse.headers!.xROUTE!);
        }
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('signInWithNumber : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> unSubscribeWhatsapp(int? userID) async {
    try {
      final apiResponse = await _dataSource.unSubscribeWhatsapp(userID);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('subscribeWhatsapp : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> nudgeEvents(
      int userId, String eventName, String eventType, String eventAt) async {
    try {
      Map<String, String> otherProperties = {'nudge_type': eventType};
      NudgeEventRequest nudgeEventRequest = NudgeEventRequest(
          event: eventName,
          eventAt: eventAt,
          otherProperties: otherProperties,
          userId: userId);
      final apiResponse = await _dataSource.nudgeEvent(nudgeEventRequest);
      return apiResponse;
    } catch (e, st) {
      AppLog.e('nudgeEvents : ${e.toString()}\n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<ProfileAttributes>> createProfileAttribute(
      int? userId, String? attributeName, String? value) async {
    try {
      Map<String, String?> profileAttributes = {
        "attribute_name": attributeName,
        "attribute_value": value
      };
      List<Object> array = [profileAttributes];
      Map<String, Object> profileAttributesRequest = {
        "profile_attribute": array
      };
      final apiResponse = await _dataSource.createProfileAttribute(
          userId, profileAttributesRequest);
      if (apiResponse.status == ApiResponse.success) {
        return List.from(apiResponse.data['profile_attribute'])
            .map((e) => ProfileAttributes.fromJson(e))
            .toList();
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('createProfileAttribute : ${e.toString()}\n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<KycDetails> getPANDetails(int userID) async {
    try {
      final apiResponse = await _dataSource.getPANDetails(userID);
      DocumentDetailsData documentDetailsData =
          DocumentDetailsData.fromJson(apiResponse.data);
      if (documentDetailsData.panDetails != null) {
        return KycDetails.fromPANDetails(documentDetailsData.panDetails!);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('getPANDetails : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<KycDetails, DocumentDetailsData>> updatePanDetails(
      int userID, KycDetails kycDetails, bool rejectIfFailed) async {
    try {
      DocumentDetails panDetails = DocumentDetails(
          panName: kycDetails.panCardName,
          panNumber: kycDetails.panCardNumber,
          panDob: kycDetails.panDOB,
          panImage: kycDetails.panImage,
          rejectIfFailed: rejectIfFailed);
      DocumentDetailsData documentDetailsData =
          DocumentDetailsData(panDetails: panDetails);
      final apiResponse =
          await _dataSource.updatePanDetails(userID, documentDetailsData);
      if (apiResponse.data != null) {
        DocumentDetailsData documentDetailsData =
            DocumentDetailsData.fromJson(apiResponse.data);
        return Tuple2(
            KycDetails.fromPANDetails(documentDetailsData.panDetails!),
            documentDetailsData);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('updatePanDetails : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<KycDetails, DocumentDetailsData>> updateAadharDetails(
      int userID, KycDetails kycDetails) async {
    try {
      DocumentDetails aadharDetails = DocumentDetails(
          aadharNumber: kycDetails.aadhardNumber,
          aadharFrontImage: kycDetails.aadharFrontImage,
          aadharBackImage: kycDetails.aadharBackImage,
          autoVerifyAadhaar: true);
      DocumentDetailsData documentDetailsData =
          DocumentDetailsData(aadharDetails: aadharDetails);
      final apiResponse =
          await _dataSource.updateAadharDetails(userID, documentDetailsData);
      if (apiResponse.data != null) {
        DocumentDetailsData documentDetailsData =
            DocumentDetailsData.fromJson(apiResponse.data);
        return Tuple2(
            KycDetails.fromAadharDetails(documentDetailsData.aadharDetails!),
            documentDetailsData);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e(
          'updateAadharDetails : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<KycDetails, DocumentDetailsData>> updateDrivingLicence(
      int userID, KycDetails kycDetails) async {
    try {
      DocumentDetails dlDetails = DocumentDetails(
          drivingLicenceNumber: kycDetails.dldNumber,
          drivingLicenceData: DrivingLicenceData(
              frontImage: kycDetails.dlFrontImage,
              backImage: kycDetails.dlBackImage),
          drivingLicenceVehicleTypes: kycDetails.dlVehicleType,
          drivingLicenceType: kycDetails.dlType,
          drivingLicenceValidity: kycDetails.dlValidity);
      DocumentDetailsData documentDetailsData =
          DocumentDetailsData(drivingLicenceDetails: dlDetails);
      final apiResponse =
          await _dataSource.updateDrivingLicence(userID, documentDetailsData);
      if (apiResponse.data != null) {
        DocumentDetailsData documentDetailsData =
            DocumentDetailsData.fromJson(apiResponse.data);
        return Tuple2(
            KycDetails.fromDLDetails(
                documentDetailsData.drivingLicenceDetails!),
            documentDetailsData);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e(
          'updateDrivingLicence : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<KycDetails> verifyAadharOTP(
      int userID, String otp, bool rejectIfFailed) async {
    try {
      Map<String, dynamic> map = {};
      Map<String, dynamic> mapOTP = {};
      mapOTP['otp'] = otp;
      mapOTP['reject_if_failed'] = rejectIfFailed;
      map['aadhar_details'] = mapOTP;
      final apiResponse = await _dataSource.verifyAadharOTP(userID, map);
      if (apiResponse.data != null) {
        DocumentDetailsData documentDetailsData =
            DocumentDetailsData.fromJson(apiResponse.data);
        return KycDetails.fromAadharDetails(documentDetailsData.aadharDetails!);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('verifyAadharOTP : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateDeviceInfo(
      int? userID, String? role, String fcmToken) async {
    try {
      DeviceInfo? deviceInfo = await DeviceInfoUtils.getDeviceInfoData();
      deviceInfo?.fcmToken = fcmToken;
      deviceInfo?.loggedInRole = role;
      DeviceInfoRequest deviceInfoRequest =
          DeviceInfoRequest(deviceInfo: deviceInfo, userID: userID);
      final apiResponse = await _dataSource.updateDeviceInfo(deviceInfoRequest);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('updateDeviceInfo : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<UserFeedbackRequest> internalUserFeedback(
      UserFeedbackRequest userFeedbackRequest) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.internalUserFeedback(userFeedbackRequest);
      if (apiResponse.status == ApiResponse.success) {
        return UserFeedbackRequest.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getWorkLog : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<FeedbackEventResponse> internalFeedbackEventSearch(int userId) async {
    try {
      var advancedSearchRequest = AdvanceSearchRequestBuilder();
      List<String> arrList = [];
      arrList.add(FeedbackEvents.feedback_submitted.name);
      arrList.add(FeedbackEvents.feedback_discarded.name);
      advancedSearchRequest
          .putPropertyToCondition("event_name", Operator.IN, arrList)
          .putPropertyToCondition("user_id", Operator.equal, userId)
          .setLimit(1);
      var apiResponse = await _dataSource
          .internalFeedbackEventSearch(advancedSearchRequest.build());
      return FeedbackEventResponse.fromJson(apiResponse.data);
    } catch (e, st) {
      AppLog.e(
          'internalFeedbackEventSearch : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> deleteUserAccount(int userID) async {
    try {
      final apiResponse = await _dataSource.deleteUserAccount(userID);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('deleteUserAccount : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> initiateOtpLess() async {
    try {
      final apiResponse = await _dataSource.initiateOtpLess();
      return apiResponse;
    } catch (e, st) {
      AppLog.e('initiateOtpLess : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<Tuple2<LoginResponse, String?>> signInWhatsappLogin(
      String token) async {
    try {
      final apiResponse = await _dataSource.signInWhatsappLogin(token);
      if (apiResponse.status == ApiResponse.success) {
        SPUtil? spUtil = await SPUtil.getInstance();
        spUtil?.putUserData(UserData.fromJson(apiResponse.data['user']));
        return Tuple2(
            LoginResponse.fromJson(apiResponse.data as Map<String, dynamic>),
            apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('signInWhatsappLogin : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<ApiResponse> emailUpdate(int? userID, String email) async {
    try {
      UserRequestPayload userRequestPayload = UserRequestPayload(email: email);
      UserRequestDataPayload userRequestDataPayload =
          UserRequestDataPayload(userRequestPayload: userRequestPayload);
      final apiResponse =
          await _dataSource.emailUpdate(userID, userRequestDataPayload);
      if (apiResponse.status == ApiResponse.success) {
        return apiResponse;
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('emailUpdate : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
