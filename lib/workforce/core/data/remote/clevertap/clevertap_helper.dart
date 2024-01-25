import 'package:awign/workforce/core/utils/app_log.dart';
// import 'package:clevertap_plugin/clevertap_plugin.dart';

class ClevertapHelper {
  static const exploreJobs = "explore_jobs";
  static const exploreJobsApplicationHistory =
      "explore_jobs_application_history";
  static const internship = "internship";
  static const fullTimeJob = "full_time_job";
  static const partTimeJob = "part_time_job";
  static const workFromHome = "work_from_home";
  static const listingViewed = "listing_viewed";
  static const listingPageVisits = "listingpage_visits";
  static const campusAmbassadorCta = "campus_ambassador_cta";
  static const campusAmbassadorSubmit = "campus_ambassador_submit";
  static const viewOldApp = "view_old_app";
  static const appliedToListing = "applied_to_listing";

  static const googleSignIn = "google_signin";

  static const startInAppInterview = "start_inapp_interview";
  static const resumeInAppInterview = "resume_inapp_interview";
  static const retakeInAppInterview = "retake_inapp_interview";
  static const failedInAppInterview = "failed_inapp_interview";
  static const passedInAppInterview = "passed_inapp_interview";

  static const startInAppTraining = "start_inapp_training";
  static const resumeInAppTraining = "resume_inapp_training";
  static const retakeInAppTraining = "retake_inapp_training";
  static const failedInAppTraining = "failed_inapp_training";
  static const passedInAppTraining = "passed_inapp_training";

  static const startPitchTest = "start_pitchtest";
  static const resumePitchTest = "resume_pitchtest";
  static const retakePitchTest = "retake_pitchtest";
  static const failedInAppPitchTest = "failed_inapp_pitchtest";
  static const passedInAppPitchTest = "passed_inapp_pitchtest";

  static const scheduleTelephonicInterview = "schedule_telephonic_interview";
  static const rescheduleTelephonicInterview =
      "reschedule_telephonic_interview";
  static const confirmSlotTelephonicInterview =
      "confirm_slot_telephonic_interview";
  static const changeSlotTelephonicInterview =
      "change_slot_telephonic_interview";
  static const failedTelephonicInterview = "failed_telephonic_interview";
  static const passedTelephonicInterview = "passed_telephonic_interview";

  static const scheduleWebinarTraining = "schedule_webinar_training";
  static const rescheduleWebinarTraining = "reschedule_webinar_training";
  static const confirmBatchWebinarTraining = "confirm_batch_webinar_training";
  static const changeBatchWebinarRraining = "change_batch_webinar_training";
  // static const joinTraining = "join_training";
  static const unableToJoinTraining = "unable_to_join_training";

  static const schedulePitchDemo = "schedule_pitch_demo";
  static const reschedulePitchDemo = "reschedule_pitch_demo";
  static const confirmSlotPitchDemo = "confirm_slot_pitch_demo";
  static const changeBatchPitchDemo = "change_batch_pitch_demo";

  static const startAutomatedPitchDemo = "start_automated_pitch_demo";
  static const resumeAutomatedPitchDemo = "resume_automated_pitch_demo";
  static const retakeAutomatedPitchDemo = "retake_automated_pitch_demo";

  static const completeSampleLead = "complete_sample_lead";
  static const resumeSampleLead = "resume_sample_lead";

  static const goToOfficeCta = "go_to_office_cta";
  static const viewNewApp = "view_new_app";

  static const projectApened = "project_opened";
  static const leadListViewApened = "lead_list_view_opened";
  static const singleLeadViewApened = "single_lead_view_opened";
  static const offerLetterAccepted = "offer_letter_accepted";
  static const leadSubmitted = "lead_submitted";
  static const offerLetterOpened = "offer_letter_opened";
  static const offerLetterSignInitiate = "offer_letter_sign_initiate";
  static const aadhaarSubmittedOffice = "aadhaar_submitted_office";
  static const drivingLicenceSubmittedOffice =
      "driving_licence_submited_office";

  static const faqsOpened = "faqs_opened";
  static const faqsQuestion = "faqs_question";

  //profile section
  static const applicationHistory = "application_history";
  static const editProfile = "edit_profile";
  static const shareApp = "share_app";
  static const profileContactSupport = "profile_contactsupport";
  static const completeKyc = "complete_kyc";
  static const applicationSuccessful = "application_successful";
  static const applicationDisqualified = "application_disqualified";

  //faqs
  static const readFaqs = "read_faqs";
  static const unresolvedIssueCta = "unresolved_issue_cta";
  static const unresolvedIssueCallUs = "unresolved_issue_call_us";
  static const unresolvedIssueMailUs = "unresolved_issue_mail_us";

  //banner
  static const bannerClosed = "banner_closed";
  static const bannerOpen = "banner_open";
  static const bannerCta = "banner_cta";

  //earning
  static const earningsPage = "earnings_page";
  static const earningsWithdrawCta = "earnings_withdraw_cta";
  static const withdrawalHistory = "withdrawal_history";
  static const transferRetry = "transfer_retry";
  // static const transferContactSupport = "transfer_contactsupport";
  // static const earningsContactSupport = "earnings_contactsupport";
  static const withdrawButtonClicked = "withdraw_button_clicked";
  static const retryButtonClicked = "retry_button_clicked";

  //onboarding
  static const onboardingPhoneNumberVerified =
      "onboarding_phone_number_verified";
  // static const onboardingGraduationDetailsProvided =
  //     "onboarding_graduation_details_provided";
  static const onboardingPersonalDetails = "onboarding_personal_details";
  static const onboardingLocationProvided = "onboarding_location_provided";
  static const onboardingComplete = "onboarding_complete";

  //Capture availability
  static const proceedToWork = "proceed_to_work";
  static const tabOpened = "tab_opened";
  static const selectTimeSlotToWork = "select_time_slot_to_work";
  static const notAvailableNow = "not_available_now";
  static const changeSchedule = "change_schedule";
  static const provideAvailabilityClose = "provide_availability_close";
  static const addMoreSlotToday = "add_more_slot_today";
  static const addMoreSlotTomorrow = "add_more_slot_tomorrow";
  static const notAvailableToday = "not_available_today";
  static const copyScheduleFromToday = "copy_schedule_from_today";
  static const confirmTodaysAvailability = "confirm_todays_availability";
  static const confirmTomorrowsAvailability = "confirm_tomorrows_availability";
  static const notAvailableTomorrow = "not_available_tomorrow";
  static const backedOut = "backed_out";
  static const completedPitchDemo = "completed_pitch_demo";
  static const completedWebinarTraining = "completed_webinar_training";

  //notification
  static const appNotificationReceivedWithoutUrl =
      "app_notification_received_without_url";
  static const appNotificationReceivedWithUrl =
      "app_notification_received_with_url";
  static const appNotificationClickedWithUrl =
      "app_notification_clicked_with_url";
  static const appNotificationClickedWithoutUrl =
      "app_notification_clicked_without_url";
  static const notificationPopupOpen = "notification_popup_open";
  static const notificationPopupCtaClicked = "notification_popup_cta_clicked";

  //category
  static const categoryShareCta = "category_share_cta";
  static const categoryViewed = "category_viewed";
  static const categoryApplicationFormOpened =
      "category_application_form_opened";
  static const categoryApplicationFormSubmitted =
      "category_application_form_submitted";
  static const categoryApplicationFormSubmittedSuccessfully =
      "category_applicaiton_form_submitted_succesfully";
  static const categoryApplicationFormSubmissionFailed =
      "category_applicaiton_form_submission_failed";
  static const categoryGoToOffice = "category_go_to_office";
  static const jobPageGoToOffice = "job_page_go_to_office";
  static const applyNowCategory = "apply_now_category";
  static const applyNowJob = "apply_now_job";
  static const viewJobsCategory = "view_jobs_category";
  static const jobViewed = "job_viewed";
  static const officePage = "office_page";
  static const explorePage = "explore_page";

  //language
  static const languageIcon = "language_icon";
  static const languageSelected = "language_selected";

  //signup
  static const mobileNumberOtpSend = "mobile_number_otp_send";
  static const mobileNumberOtpVerify = "mobile_number_otp_verify";
  static const emailSignup = "email_signup";
  static const googleSignup = "google_signup";

  static const zoomModule = "zoom_module";

  static ClevertapHelper? _instance;

  ClevertapHelper._();

  static ClevertapHelper instance() {
    _instance ??= ClevertapHelper._();
    return _instance!;
  }

  // addLanguageSelectedEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(languageSelected, eventProperty);
  // }

  // adDownloadZoomEvent(String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(zoomModule, eventProperty);
  // }

  // addAppNotificationClickedWithoutUrlEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(appNotificationReceivedWithoutUrl, eventProperty);
  // }

  // addAppNotificationClickedWithUrlEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(appNotificationReceivedWithUrl, eventProperty);
  // }

  // addNotificationPopupOpenEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(notificationPopupOpen, eventProperty);
  // }

  // addNotificationPopupCtaClickedEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(notificationPopupCtaClicked, eventProperty);
  // }

  // addBackedOutEvent(String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(backedOut, eventProperty);
  // }

  // addFaqsOpenedEvent(Map<String, dynamic> eventProperty) {
  //   _addUserEvent(faqsOpened, eventProperty);
  // }

  // addFaqsQuestionEvent(String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(faqsQuestion, eventProperty);
  // }

  // addUnresolvedIssuesEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(unresolvedIssueCta, eventProperty);
  // }

  // addUnresolvedIssuesCallEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(unresolvedIssueCallUs, eventProperty);
  // }

  // addUnresolvedIssuesMailEvent(
  //     String eventName, Map<String, dynamic> eventProperty) {
  //   _addUserEvent(unresolvedIssueMailUs, eventProperty);
  // }

  addApplicationsEvent(String eventName, Map<String, dynamic> eventProperty) {
    _addUserEvent(eventName, eventProperty);
  }

  addCleverTapEvent(String eventName, Map<String, dynamic> eventProperty) {
    _addUserEvent(eventName, eventProperty);
  }

  _addUserEvent(String eventName, Map<String, dynamic> eventProperty) {
    try {
      // CleverTapPlugin.recordEvent(eventName, eventProperty);
    } catch (e, st) {
      AppLog.e('_addUserEvent : ${e.toString()} \n${st.toString()}');
    }
  }

  addUserData(Map<String, dynamic> eventProperty) {
    try {
      // CleverTapPlugin.profileSet(eventProperty);
    } catch (e, st) {
      AppLog.e('_addUserEvent : ${e.toString()} \n${st.toString()}');
    }
  }
}
