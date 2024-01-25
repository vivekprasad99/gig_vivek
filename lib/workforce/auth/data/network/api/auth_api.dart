class AuthAPI {
  final String validationTokenAPI = '/central/auth/validate';
  final String fetchUserProfileAPI = 'profile/api/v1/users/';
  final String emailSignInAPI = '/central/auth/email/sign_in';
  final String googleSignInAPI = '/workforce/auth/google/sign_up';
  final String generateAndSendOTPAPI = 'api/v1/users/userID/generate_otp?verification=true';
  final String subscribeWhatsappAPI = 'api/v1/users/userID/whatsapp/subscribe';
  final String unSubscribeWhatsappAPI =
      'api/v1/users/userID/whatsapp/unsubscribe';
  final String verifyOTPAPI = 'api/v1/users/userID/verify_otp';
  final String updateUserMobileNumberAPI = 'api/v1/users/userID/mobile_number';
  final String updateUserProfileAPI = '/profile/api/v1/users/userID';
  final String updateLanguagesAPI = '/profile/api/v1/users/userID/languages';
  final String createAddressAPI = 'profile/api/v1/users/userID/addresses';
  final String updateAddressAPI =
      '/profile/api/v1/users/userID/addresses/addressID';
  final String searchProfileAttributesAPI =
      'profile/api/v1/users/userID/profile_attributes/search';
  final String searchCollageAPI = '/profile/api/v1/colleges/search';
  final String createEducationAPI =
      'profile/api/v1/users/userID/education_details';
  final String updateEducationAPI =
      'profile/api/v1/users/userID/education_details/educationID';
  final String updateProfileAttributesAPI =
      'profile/api/v1/users/userID/profile_attributes/id';
  final String createProfileAttributesAPI =
      'profile/api/v1/users/userID/profile_attributes';
  final String updateProfessionalExperiencesAPI =
      'profile/api/v1/users/userID/professional_experiences';
  final String signInWithNumberAPI = "workforce/auth/mobile_number/sign_in";
  final String fetchUserNudge =
      "profile/api/v1/users/userID/user_nudgess/pending_nudges";
  final String nudgeEventApi = "api/v1/events";
  final String verifyPINApi = "/api/v1/users/userID/pin/verify";
  final String generatePINOTPApi = "/api/v1/users/userID/pin/generate_otp";
  final String updatePINApi = "/api/v1/users/userID/pin/update";
  final String verifyPINOTPApi = "/api/v1/users/userID/pin/verify_otp";
  final String getPANDetailsAPI = "/profile/api/v1/users/userID/pan_details";
  final String updatePanDetailsAPI = "/profile/api/v1/users/userID/pan_details";
  final String updateDrivingLicenceAPI =
      "/profile/api/v1/users/userID/driving_licence_details";
  final String updateAadharDetailsAPI =
      "/profile/api/v1/users/userID/aadhar_details";
  final String verifyAadharOTPAPI =
      "/profile/api/v1/users/userID/aadhar_details/verify_otp";
  final String updateDeviceInfoAPI = "/central/api/v1/devices";
  final String internalUserFeedbackAPI = "/api/v1/supply_feedbacks";
  final String internalFeedbackEventSearchAPI = "/api/v1/events/search";
  final String deactivateUserAPI = "/api/v1/users/userID/deactivate_user";
  final String initiateWhatsappLoginAPI = "/v1/client/user/session/initiate";
  final String signInWhatsappLoginAPI = "/api/v1/user/sign";
  final String emailUpdateAPI = "/central/api/v1/users/userID/email_update";
}
