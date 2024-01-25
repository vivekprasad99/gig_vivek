class LoggingEvents {
  //beneficiary
  static const addBeneficiary = 'add_beneficiary';
  static const verify = 'verify';
  static const deactivate = 'deactivate';
  static const activate = 'activate';
  static const maximumAccountReached = 'maximum_account_reached';
  static const notification = 'notification';
  static const workRequested = 'work_requested';
  static const earningsWithdrawn = 'earnings_withdrawn';
  //project properties
  static const projectID = 'projectId';
  static const available = 'available';
  static const roleName = 'roleName';
  //PAN DL Aadhar
  static const verifyNowPAN = 'verify_now_pan';

  // Verify PAN
  static const panVerificationThresholdCrossed = 'PAN_verification_threshold_crossed';
  static const userLandingInsidePANPage = 'User_landing_inside_PAN_page';
  static const withdrawalJourneyVerify = 'Withdrawal_journey_verify';
  static const profileJourneyVerify = 'Profile_journey_verify';
  static const panView = 'PAN_view';

  static const appReviewPopUp = 'app_review_pop-up';
  static const appReviewSubmitClicked = 'app_review_submit_clicked';
  static const appReviewCrossClicked = 'app_review_cross_clicked';
  static const rateUsClicked = 'rate_us_clicked';

  static const downloadCtaClickedApp = 'LOI_download_cta_clicked_app';

  //Banner
  static const closeButtonClicked = 'close_button_clicked';
  // static const statusClicked = 'status_clicked';

  static const firstLeadSubmitted = 'first_lead_submitted';
  // static const killApp = 'kill_app';
  // static const killApp = 'exit_app';
  static const openApp = 'open_app';
  static const earningsTabClicked = 'earnings_tab_clicked';
  static const profileTabClicked = 'profile_tab_clicked';
  static const universityTabClicked = 'university_tab_clicked';
  static const officeTabClicked = 'office_tab_clicked';
  static const exploreTabClicked = 'explore_tab_clicked';
  // static const language = 'language';
  // static const aboutTheJobClicked = 'about_the_job_clicked';
  // static const backoutFromTheJobClicked = 'backout_from_the_job_clicked';
  // static const applicationIdCopied = 'application_id_copied';
  // static const executionIdCopied = 'execution_id_copied';
  // static const applicationIdInfoOpened = 'application_id_info_opened';
  // static const executionIdInfoOpened = 'execution_id_info_opened';

  //Category
  static const categoryOfficeOpened = 'category_office_opened';
  static const categoryDetailPageOpen = 'category_detail_page_open';
  static const goToOfficeButtonClicked = 'go_to_office_button_clicked';
  static const categoryApplyButtonClicked = 'category_apply_button_clicked';
  static const categoryQuestionsOpened = 'category_questions_opened';
  static const categoryQuestionsSubmitted = 'category_questions_submited';

  // Nudge
  static const otherDetailsFilled = 'other_details_filled';
  static const collegeDetailsFilled = 'college_details_filled';

  //Profile
  static const verifyPanProfile = 'verify_pan_profile';
  static const verifyAadhaarProfile = 'verify_aadhaar_profile';
  static const verifyDlProfile = 'verify_dl_profile';

  //university
  static const awignUniversityTab = 'awign_university_tab';
  static const courseCardClicked = 'course_card_clicked';
  static const courseId = 'course_id';
  static const category = 'category';
  static const byWhom = 'by_whom';
  static const skills = 'skills';

  // Login/Signup Flow
  static const otpEnterContinueSuccessful = 'otp_enter_continue_successful';
  static const mobileNumberContinueSuccessful =
      'mobile_number_continue_successful';
  static const mobileNumberContinueUnSuccessful =
      'mobile_number_continue_unsucessful';
  static const otpEnterContinueUnSuccessful = 'otp_enter_continue_unsuccessful';
  static const signUpSuccessful = 'sign_up_successful';

  // Earning properties
  static const panStatus = 'panStatus';

  // Earning statement
  static const earningsStatement = 'earnings_statement';

  //payment-withdrawal-request
  static const upcomingEarningsToggle = "upcoming_earnings_toggle";
  static const upcomingEarnings = "upcoming_earnings";
  static const deductionsApplicable = "deductions_applicable";
  static const requestedTransfer = "requested_transfer";
  static const recentFailure = "recent_failure";
  static const retries = "retries";
  static const contactSupport = "contact_support";
  static const initiateWithdrawal = "initiate_withdrawal";
  static const uncheckApproveDeduction = "uncheck_approve_deduction";

  //leaderboard
  static const accessedLeaderboard = "accessed_leaderboard";
  static const certificateViewGoodEarnings = "certificate_view_good_earnings";
  static const certificateViewExcellentEarnings =
      "certificate_view_excellent_earnings";
  static const certificateViewGoodTasks = "certificate_view_good_tasks";
  static const certificateViewExcellentTasks =
      "certificate_view_excellent_tasks";
  static const viewExploreJobsFromEarnings = "view_explore_jobs_from_earnings";
  static const viewExploreJobsFromTasks = "view_explore_jobs_from_tasks";
  static const leaderboardEarningsPageOpened =
      "leaderboard_earnings_page_opened";
  static const leaderboardTasksCompletedPageOpened =
      "leaderboard_tasks_completed_page_opened";
  static const usersReceivedGoodEarningsCertificate =
      "users_received_good_earnings_certificate";
  static const usersReceivedGoodTasksCertificate =
      "users_received_good_tasks_certificate";
  static const usersReceivedExcellentTasksCertificate =
      "users_received_excellent_tasks_certificate";
  static const usersReceivedExcellentEarningsCertificate =
      "users_received_excellent_earnings_certificate";

  //resend otp
  static const resendOtpLoginClicked = "resend_otp_login_clicked";
  static const resendOtpPinClicked = "resend_otp_pin_clicked";

  //attendance
  static const myJobsOpened = 'my_jobs_opened';
  static const punchInMyJobsClicked = 'punch_in_my_jobs_clicked';
  static const punchOutMyJobsClicked = 'punch_out_my_jobs_clicked';
  static const submissionProjectCliked = 'submission_project_cliked';
  static const markAttendanceOpened = 'mark_attendance_opened';
  static const punchInProjectClicked = 'punch_in_project_clicked';
  static const doItLaterClicked = 'do_it_later_clicked';
  static const enableCameraAccessOpened = 'enable_camera_access_opened';
  static const takingSelfieOpened = 'taking_selfie_opened';
  static const clickPictureClicked = 'click_picture_clicked';
  static const uploadSelfieOpened = 'upload_selfie_opened';
  static const retakeSelfieClicked = 'retake_selfie_clicked';
  static const submitProceedSelfieClicked = 'submit_&_proceed_selfie_clicked';
  static const attendanceSuccessfulOpened = 'attendance_successful_opened';
  static const enableGeoLocationOpened = 'enable_geo_location_opened';
  static const openSettingLocation = 'open_setting_location';
  static const locationCapturedOpened = 'location_captured_opened';
  static const submitProceedLocationClicked = 'submit_&_proceed_location_clicked';
  static const retakeLocationClicked = 'retake_location_clicked';
  static const enableAccessFilesOpened = 'enable_access_files_opened';
  static const openSettingAccessFiles = 'open_setting_access_files';
  static const uploadImageOpened = 'upload_image_opened';
  static const addImageClicked = 'add_image_clicked';
  static const pleaseSelectOpened = 'please_select_opened';
  static const captureClicked = 'capture_clicked';
  static const uploadClicked = 'upload_clicked';
  static const capturePageOpened = 'capture_page_opened';
  static const captureClickedCamera = 'capture_clicked_camera';
  static const addImageOpened = 'add_image_opened';
  static const clickAgainClicked = 'click_again_clicked';
  static const addClicked = 'add_clicked';
  static const inputRemoved = 'input_removed';
  static const wantToDicontinueOpened = 'want_to_dicontinue_opened';
  static const discontinueClicked = 'discontinue_clicked';
  static const noClicked = 'no_clicked';

  //  nps ratings
  static const ratingPopupOpened = 'rating_popup_opened';
  static const ratingSubmitted = 'rating_submitted';
}
