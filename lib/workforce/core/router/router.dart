import 'dart:async';
import 'dart:io';

import 'package:awign/packages/flutter_camera/in_app_camera_widget.dart';
import 'package:awign/packages/flutter_image_editor/image_editor_widget.dart';
import 'package:awign/packages/flutter_image_editor/image_editor_widget_new.dart';
import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/profile_attributes_and_application_questions.dart';
import 'package:awign/workforce/auth/feature/app_language_selection/widget/app_language_selection_widget.dart';
import 'package:awign/workforce/auth/feature/confirm_pin/widget/confirm_pin_widget.dart';
import 'package:awign/workforce/auth/feature/education_details/widget/education_details_widget.dart';
import 'package:awign/workforce/auth/feature/email_sign_in/widget/email_sign_in_widget.dart';
import 'package:awign/workforce/auth/feature/enter_email_manually/widget/enter_email_manually_widget.dart';
import 'package:awign/workforce/auth/feature/forgot_pin/widget/forgot_pin_widget.dart';
import 'package:awign/workforce/auth/feature/onboarding/widget/onboarding_widget.dart';
import 'package:awign/workforce/auth/feature/onboarding_intro/onboarding_intro_widget.dart';
import 'package:awign/workforce/auth/feature/onboarding_questions/widget/onboarding_questions_widget.dart';
import 'package:awign/workforce/auth/feature/otp_less_login/widget/login_screen_widget.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/auth/feature/personal_details/widget/personal_details_widget.dart';
import 'package:awign/workforce/auth/feature/phone_verification/widget/phone_verification_widget.dart';
import 'package:awign/workforce/auth/feature/splash/widget/splash_widget.dart';
import 'package:awign/workforce/auth/feature/trust_building/widget/trust_building_widget.dart';
import 'package:awign/workforce/auth/feature/user_email/widget/user_email_widget.dart';
import 'package:awign/workforce/auth/feature/user_location/widget/user_location_widget.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/array_question_widget/widget/array_question_widget.dart';
import 'package:awign/workforce/aw_questions/widget/code_scanner/widget/code_scanner_widget.dart';
import 'package:awign/workforce/aw_questions/widget/image_details/image_details_widget.dart';
import 'package:awign/workforce/aw_questions/widget/nested/nested_question_widget/widget/nested_question_widget.dart';
import 'package:awign/workforce/aw_questions/widget/signature/widget/signature_widget.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/widget/notification/widget/notification_widget.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_map_view_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section_details_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/screen_question_arguments.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_capture_image/widget/attendance_capture_image.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_input_fields/widgets/attendance_input_fields_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_upload_image/widget/attendance_upload_image_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/availablity/widget/provide_availability_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/widget/batches_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/widget/category_application_details_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/widget/dashboard_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/widget/lead_list_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/helper/lead_screens_data.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/widget/lead_screens_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/leadpayout/widget/leadpayout_screen_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/offer_letter/widget/offer_letter_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/online_test/widget/online_test_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/sign_offer_letter/widget/sign_offer_letter_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/widget/slots_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/worklog/widgets/worklog_widget.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/ca_application_widget.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/ca_dashboard_widget.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/campus_ambassador_widget.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/no_access_widget.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/opencatask_widget.dart';
import 'package:awign/workforce/more/feature/dream_application/widget/bottom_sheet/widget/dream_application_questions_bottom_sheet.dart';
import 'package:awign/workforce/more/feature/edit_address/widget/edit_address_widget.dart';
import 'package:awign/workforce/more/feature/edit_collage_details/widget/edit_collage_details_widget.dart';
import 'package:awign/workforce/more/feature/edit_other_details/widget/edit_other_details_widget.dart';
import 'package:awign/workforce/more/feature/edit_personal_info/widget/edit_personal_info_widget.dart';
import 'package:awign/workforce/more/feature/edit_professional_details/widget/edit_professional_details_widget.dart';
import 'package:awign/workforce/more/feature/faq_and_support/widget/faq_and_support_widget.dart';
import 'package:awign/workforce/more/feature/how_app_works/widgets/demo_videos_widget.dart';
import 'package:awign/workforce/more/feature/how_app_works/widgets/how_app_works_widget.dart';
import 'package:awign/workforce/more/feature/how_app_works/widgets/show_yt_videos_widget.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/leaderboard_widget.dart';
import 'package:awign/workforce/more/feature/more/data/model/more_widget_data.dart';
import 'package:awign/workforce/more/feature/more/widget/more_widget.dart';
import 'package:awign/workforce/more/feature/my_profile/widget/my_profile_widget.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/profile_details_widget.dart';
import 'package:awign/workforce/more/feature/rate_us/widget/thanks_feedback_widget.dart';
import 'package:awign/workforce/more/feature/web_view/widget/office_web_view_widget.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_data.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/application_history/widget/application_history_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_application/category_application_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_details/widget/category_details_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/widget/category_listing_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/widget/category_questions_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/resources/widget/resource_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/widget/worklisting_details_widget.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:awign/workforce/payment/data/model/earning_data.dart';
import 'package:awign/workforce/payment/feature/add_bank_details/widget/add_bank_details_widget.dart';
import 'package:awign/workforce/payment/feature/add_upi/widget/add_upi_widget.dart';
import 'package:awign/workforce/payment/feature/all_deduction/widget/all_deduction_widget.dart';
import 'package:awign/workforce/payment/feature/confirm_amount/widget/confirm_amount_widget.dart';
import 'package:awign/workforce/payment/feature/document_verification/widget/document_verification_widget.dart';
import 'package:awign/workforce/payment/feature/earning_statement/widget/earning_statement_widget.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/EarningsWidget.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/manage_beneficiary_widget.dart';
import 'package:awign/workforce/payment/feature/select_beneficiary/widget/select_beneficiary_widget.dart';
import 'package:awign/workforce/payment/feature/tds_deduction_details/widget/tds_deduction_details_widget.dart';
import 'package:awign/workforce/payment/feature/verify_pan/cubit/verify_pan_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/withdrawal_history_widget.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/withdrawal_verification_widget.dart';
import 'package:awign/workforce/university/data/model/university_entity.dart';
import 'package:awign/workforce/university/feature/awign_university/widget/awign_university_widget.dart';
import 'package:awign/workforce/university/feature/awign_university/widget/university_video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

import '../../execution_in_house/data/model/eligibility_entity_response.dart';
import '../../execution_in_house/data/model/lead_payout_entity.dart';
import '../../execution_in_house/data/model/worklog_widget_data.dart';
import '../../execution_in_house/feature/application_id_details/widget/application_id_details_widget.dart';
import '../../execution_in_house/feature/application_result/widget/application_result_widget.dart';
import '../../execution_in_house/feature/dashboard/data/model/dashboard_widget_argument.dart';
import '../../execution_in_house/feature/lead_map_view/lead_map_view_widget.dart';
import '../../payment/feature/early_redemption_policy/widget/early_redemption_policy_widget.dart';
import '../../onboarding/presentation/feature/category_detail_and_job/widget/category_detail_and_job_widget.dart';
import '../../payment/feature/verify_pan/widget/verify_pan_widget.dart';
import '../di/app_injection_container.dart';

class MRouter {
  final _currentRouteSubject = BehaviorSubject<String>();

  StreamSink<String> get _currentRouteSink => _currentRouteSubject.sink;

  Stream<String> get currentRouteStream => _currentRouteSubject.stream;

  String get currentRoute => _currentRouteSubject.value;

  void closeStream() => _currentRouteSubject.close();

  final _currentLocalRouteSubject = BehaviorSubject<String>();

  StreamSink<String> get _currentLocalRouteSink =>
      _currentLocalRouteSubject.sink;

  Stream<String> get currentLocalRouteStream =>
      _currentLocalRouteSubject.stream;

  String get currentLocalRoute => _currentLocalRouteSubject.value;

  void closeLocalStream() => _currentLocalRouteSubject.close();

  static bool get mounted => globalNavigatorKey.currentState != null;

  static final GlobalKey<NavigatorState> globalNavigatorKey =
      GlobalKey(debugLabel: 'Main Navigator');

  static final GlobalKey<NavigatorState> localNavigatorKey =
      GlobalKey(debugLabel: 'local Navigator');

  static const String splashRoute = 'SplashWidget';
  static const String welcomeRoute = 'WelcomeWidget';
  static const String emailSignInWidget = 'EmailSignInWidget';
  static const String userEmailWidget = 'UserEmailWidget';
  static const String personalDetailsWidget = 'PersonalDetailsWidget';
  static const String yourLocationWidget = 'YourLocationWidget';
  static const String phoneVerificationWidget = "PhoneVerificationWidget";
  static const String educationDetailsWidget = 'EducationDetailsWidget';
  static const String oTPVerificationWidget = 'OTPVerificationWidget';
  static const String officeWidget = 'OfficeWidget';
  static const String categoryListingWidget = 'CategoryListingWidget';
  static const String earningsWidget = 'EarningsWidget';
  static const String moreWidget = 'MoreWidget';
  static const String openCaTaskWidget = 'OpenCaTaskWidget';
  static const String myProfileWidget = 'MyProfileWidget';
  static const String editPersonalInfoWidget = 'EditPersonalInfoWidget';
  static const String editCollageDetailsWidget = 'EditCollageDetailsWidget';
  static const String editProfessionalDetailsWidget =
      'EditProfessionalDetailsWidget';
  static const String editAddressWidget = 'EditAddressWidget';
  static const String editOtherDetailsWidget = 'EditOtherDetailsWidget';
  static const String categoryDetailsWidget = 'CategoryDetailsWidget';
  static const String categoryQuestionsWidget = 'CategoryQuestionsWidget';
  static const String applicationHistoryWidget = 'ApplicationHistoryWidget';
  static const String appLanguageSelectionWidget = 'AppLanguageSelectionWidget';
  static const String categoryApplicationDetailsWidget =
      'CategoryApplicationDetailsWidget';
  static const String offerLetterWidget = 'OfferLetterWidget';
  static const String signOfferLetterWidget = 'SignOfferLetterWidget';
  static const String applicationSectionDetailsWidget =
      'ApplicationSectionDetailsWidget';
  static const String applicationSectionDetailsWidgetDeepLink =
      'applicationSectionDetailsWidgetDeepLink';
  static const String onlineTestWidget = 'OnlineTestWidget';
  static const String workListingDetailsWidget = 'WorkListingDetailsWidget';
  static const String slotsWidget = 'SlotsWidget';
  static const String officeWebViewWidget = 'OfficeWebViewWidget';
  static const String batchesWidget = 'BatchesWidget';
  static const String dashboardWidget = 'DashboardWidget';
  static const String leadListWidget = 'LeadListWidget';
  static const String leadScreensWidget = 'LeadScreensWidget';
  static const String arrayQuestionWidget = 'ArrayQuestionWidget';
  static const String nestedQuestionWidget = 'NestedQuestionWidget';
  static const String applicationIdDetailsWidget = 'ApplicationIdDetailsWidget';
  static const String inAppCameraWidget = 'InAppCameraWidget';
  static const String imageEditorWidget = 'ImageEditorWidget';
  static const String imageEditorWidgetNew = 'ImageEditorWidgetNew';
  static const String faqAndSupportWidget = 'FaqAndSupportWidget';
  static const String forgotPINWidget = 'ForgotPINWidget';
  static const String confirmPINWidget = 'ConfirmPINWidget';
  static const String withdrawalHistoryWidget = 'WithdrawalHistoryWidget';
  static const String withdrawalVerificationWidget = 'WithdrawalVerificationWidget';
  static const String verifyPANWidget = 'VerifyPANWidget';
  static const String documentVerificationWidget = 'DocumentVerificationWidget';
  static const String addBankDetailsWidget = 'AddBankDetailsWidget';
  static const String addUPIWidget = 'AddUPIWidget';
  static const String manageBeneficiaryWidget = 'ManageBeneficiaryWidget';
  static const String earningStatementWidget = 'EarningStatementWidget';
  static const String selectBeneficiaryWidget = 'SelectBeneficiaryWidget';
  static const String tDSDeductionDetailsWidget = 'TDSDeductionDetailsWidget';
  static const String howAppWorksWidget = 'HowAppWorksWidget';
  static const String demoVideosWidget = 'DemoVideosWidget';
  static const String showYtVideosWidget = 'ShowYtVideosWidget';
  static const String worklogActivityWidget = 'WorklogActivityWidget';
  static const String thanksFeedbackWidget = 'ThanksFeedbackWidget';
  static const String campusAmbassadorWidget = 'CampusAmbassadorWidget';
  static const String caDashboardWidget = 'CaDashboardWidget';
  static const String noAccessWidget = 'NoAccessWidget';
  static const String caApllicationWidget = 'CaApllicationWidget';
  static const String provideAvailabilityWidget = 'ProvideAvailabilityWidget';
  static const String leadPayoutScreenWidget = 'LeadPayoutScreenWidget';
  static const String universityWidget = 'UniversityWidget';
  static const String universityVideoWidget = 'UniversityVideoWidget';
  static const String notificationWidget = 'NotificationWidget';
  static const String onboardingIntroWidget = 'OnboardingIntroWidget';
  static const String loginScreenWidget = 'LoginScreenWidget';
  static const String enterEmailManuallyWidget = 'EnterEmailManuallyWidget';
  static const String trustBuildingWidget = 'TrustBuildingWidget';
  static const String onboardingQuestionsWidget = 'OnboardingQuestionsWidget';
  static const String dreamApplicationQuestionsWidget =
      'DreamApplicationQuestionsWidget';
  static const String profileDetailsWidget = 'ProfileDetailsWidget';
  static const String leaderBoardWidget = 'LeaderBoardWidget';
  static const String categoryDetailAndJobWidget = 'CategoryDetailAndJobWidget';
  static const String confirmAmountWidget = 'ConfirmAmountWidget';
  static const String earlyRedemptionPolicyWidget =
      'EarlyRedemptionPolicyWidget';
  static const String allDeductionWidget = 'AllDeductionWidget';
  static const String applicationResultWidget = 'ApplicationResultWidget';
  static const String resourceWidget = 'ResourceWidget';
  static const String leadMapViewWidget = 'leadMapViewWidget';
  static const String attendanceUploadImageWidget =
      'AttendanceUploadImageWidget';
  static const String attendanceInputFields = 'AttendanceInputFields';
  static const String attendanceCaptureImageWidget = 'AttendanceCaptureImageWidget';
  static const String signatureWidget = 'SignatureWidget';
  static const String imageDetailsWidget = 'ImageDetailsWidget';
  static const String codeScannerWidget = 'CodeScannerWidget';

  void updateRoute(String? routeName) => _currentRouteSink.add(routeName ?? "");

  void updateLocalRoute(String? routeName) =>
      _currentLocalRouteSink.add(routeName ?? "");

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return CupertinoPageRoute(
            builder: (ctx) => const SplashWidget(), settings: settings);
      case welcomeRoute:
        return CupertinoPageRoute(
            builder: (ctx) => const OnBoardingWidget(), settings: settings);
      case emailSignInWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const EmailSignInWidget(), settings: settings);
      case userEmailWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const UserEmailWidget(), settings: settings);
      case personalDetailsWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const PersonalDetailsWidget(),
            settings: settings);
      case yourLocationWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const UserLocationWidget(), settings: settings);
      case phoneVerificationWidget:
        String? originRoute = settings.arguments as String?;
        return CupertinoPageRoute(
            builder: (ctx) => PhoneVerificationWidget(originRoute: originRoute),
            settings: settings);
      case educationDetailsWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const EducationDetailsWidget(),
            settings: settings);
      case oTPVerificationWidget:
        Map map = settings.arguments as Map;
        return CupertinoPageRoute(
            builder: (ctx) => OTPVerificationWidget(
                map['mobile_number'], map['from_route'], map['page_type']),
            settings: settings);
      case officeWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const CategoryApplicationWidget(),
            settings: settings);
      case categoryListingWidget:
        var localSetting  = RouteSettings(name: categoryListingWidget, arguments: {});
        dynamic map = settings.arguments as dynamic;
        return CupertinoPageRoute(
            builder: (ctx) => CategoryListingWidget(map),
            settings: localSetting);
      case earningsWidget:
        try {
          String fromRoute = settings.arguments as String;
          var localSettings = RouteSettings(name: earningsWidget, arguments: {});
          return MaterialPageRoute(
              builder: (ctx) => EarningsWidget(fromRoute: fromRoute),
              settings: localSettings);
        } catch(e) {
          Map<String, dynamic> fromRouteMap = settings.arguments as Map<String, dynamic>;
          var localSettings = RouteSettings(name: earningsWidget, arguments: {});
          return MaterialPageRoute(
              builder: (ctx) => EarningsWidget(fromRouteMap: fromRouteMap),
              settings: localSettings);
        }
      case moreWidget:
        MoreWidgetData moreWidgetData;
        if (settings.arguments is String) {
          moreWidgetData = MoreWidgetData();
        } else {
          moreWidgetData =
              settings.arguments as MoreWidgetData? ?? MoreWidgetData();
        }
        return MaterialPageRoute(
            builder: (ctx) => MoreWidget(moreWidgetData), settings: settings);
      case myProfileWidget:
        var settings = RouteSettings(name: myProfileWidget, arguments: {});
        return MaterialPageRoute(
            builder: (ctx) => const MyProfileWidget(), settings: settings);
      case editPersonalInfoWidget:
        UserData currentUser = settings.arguments as UserData;
        return CupertinoPageRoute(
            builder: (ctx) => EditPersonalInfoWidget(currentUser),
            settings: settings);
      case editCollageDetailsWidget:
        UserProfile userProfile = settings.arguments as UserProfile;
        return CupertinoPageRoute(
            builder: (ctx) => EditCollageDetailsWidget(userProfile),
            settings: RouteSettings(name: editCollageDetailsWidget, arguments: {}));
      case editProfessionalDetailsWidget:
        UserProfile userProfile = settings.arguments as UserProfile;
        return CupertinoPageRoute(
            builder: (ctx) => EditProfessionalDetailsWidget(userProfile),
            settings: RouteSettings(
                name: editProfessionalDetailsWidget, arguments: {}));
      case editOtherDetailsWidget:
        ProfileAttributesAndApplicationQuestions
            profileAttributesAndApplicationQuestions =
            settings.arguments as ProfileAttributesAndApplicationQuestions;
        return CupertinoPageRoute(
            builder: (ctx) => EditOtherDetailsWidget(
                profileAttributesAndApplicationQuestions),
            settings: RouteSettings(name: editOtherDetailsWidget, arguments: {}));
      case editAddressWidget:
        UserProfile userProfile = settings.arguments as UserProfile;
        return CupertinoPageRoute(
            builder: (ctx) => EditAddressWidget(userProfile),
            settings: RouteSettings(name: editAddressWidget, arguments: {}));
      case openCaTaskWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const OpenCaTaskWidget(), settings: settings);
      case categoryDetailsWidget:
        var localSettings = RouteSettings(name: categoryDetailsWidget, arguments: {});
        Map map = settings.arguments as Map;
        return CupertinoPageRoute(
            builder: (ctx) => CategoryDetailsWidget(
                map['category_id'], map['category_application']),
            settings: localSettings);
      case categoryQuestionsWidget:
        List<dynamic> arguments = settings.arguments as List<dynamic>;
        return CupertinoPageRoute(
            builder: (ctx) => CategoryQuestionsWidget(
                arguments[0], arguments[1], arguments[2]),
            settings: settings);
      case applicationHistoryWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const ApplicationHistoryWidget(),
            settings: settings);
      case appLanguageSelectionWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const AppLanguageSelection(), settings: settings);
      case categoryApplicationDetailsWidget:
        var localSettings = RouteSettings(
            name: categoryApplicationDetailsWidget, arguments: {});
        CategoryApplication categoryApplication =
            settings.arguments as CategoryApplication;
        return CupertinoPageRoute(
            builder: (ctx) =>
                CategoryApplicationDetailsWidget(categoryApplication),
            settings: localSettings);
      case offerLetterWidget:
        Execution execution = settings.arguments as Execution;
        return CupertinoPageRoute(
            builder: (ctx) => OfferLetterWidget(execution), settings: settings);
      case signOfferLetterWidget:
        Execution execution = settings.arguments as Execution;
        return CupertinoPageRoute(
            builder: (ctx) => SignOfferLetterWidget(execution),
            settings: settings);
      case applicationSectionDetailsWidget:
        WorkApplicationEntity workApplicationEntity =
            settings.arguments as WorkApplicationEntity;
        var localSettings = RouteSettings(name: applicationSectionDetailsWidget, arguments: {});
        return CupertinoPageRoute(
            builder: (ctx) =>
                ApplicationSectionDetailsWidget(workApplicationEntity),
            settings: localSettings);
      case applicationSectionDetailsWidgetDeepLink:
        var localSettings =
        RouteSettings(name: applicationSectionDetailsWidgetDeepLink, arguments: {});
        int applicationId = settings.arguments as int;
        return CupertinoPageRoute(
            builder: (ctx) => ApplicationSectionDetailsWidget.aa(applicationId),
            settings: localSettings);
      case onlineTestWidget:
        WorkApplicationEntity workApplicationEntity =
            settings.arguments as WorkApplicationEntity;
        return CupertinoPageRoute(
            builder: (ctx) => OnlineTestWidget(workApplicationEntity),
            settings: settings);
      case workListingDetailsWidget:
        WorkListingDetailsArguments workListingDetailsArguments =
            settings.arguments as WorkListingDetailsArguments;
        var localSettings = RouteSettings(name: workListingDetailsWidget, arguments: {});
        return CupertinoPageRoute(
            builder: (ctx) =>
                WorkListingDetailsWidget(workListingDetailsArguments),
            settings: localSettings);
      case slotsWidget:
        WorkApplicationEntity workApplicationEntity =
            settings.arguments as WorkApplicationEntity;
        var localSettings = RouteSettings(name: slotsWidget, arguments: {});
        return CupertinoPageRoute(
            builder: (ctx) => SlotsWidget(workApplicationEntity),
            settings: localSettings);
      case officeWebViewWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const OfficeWebViewWidget(), settings: settings);
      case batchesWidget:
        WorkApplicationEntity workApplicationEntity =
            settings.arguments as WorkApplicationEntity;
        var localSettings = RouteSettings(name: batchesWidget, arguments: {});
        return CupertinoPageRoute(
            builder: (ctx) => BatchesWidget(workApplicationEntity),
            settings: localSettings);
      case dashboardWidget:
        DashboardWidgetArgument dashboardWidgetArgument = settings.arguments as DashboardWidgetArgument;
        return CupertinoPageRoute(
            builder: (ctx) => DashboardWidget(dashboardWidgetArgument), settings: settings);
      case leadListWidget:
        Execution execution = settings.arguments as Execution;
        var localSettings = RouteSettings(name: leadListWidget, arguments: {});
        return CupertinoPageRoute(
            builder: (ctx) => LeadListWidget(execution),
            settings: localSettings);
      case leadScreensWidget:
        LeadScreensData leadScreensData = settings.arguments as LeadScreensData;
        return CupertinoPageRoute(
            builder: (ctx) => LeadScreensWidget(leadScreensData),
            settings: settings);
      case arrayQuestionWidget:
        Question question = settings.arguments as Question;
        return CupertinoPageRoute(
            builder: (ctx) => ArrayQuestionWidget(question),
            settings: settings);
      case nestedQuestionWidget:
        Question question = settings.arguments as Question;
        return CupertinoPageRoute(
            builder: (ctx) => NestedQuestionWidget(question),
            settings: settings);
      case applicationIdDetailsWidget:
        Execution execution = settings.arguments as Execution;
        return CupertinoPageRoute(
            builder: (ctx) => ApplicationIdDetailsWidget(execution),
            settings: settings);
      case inAppCameraWidget:
        ImageDetails imageDetails = settings.arguments as ImageDetails;
        return CupertinoPageRoute(
            builder: (ctx) => InAppCameraWidget(imageDetails),
            settings: settings);
      case imageEditorWidget:
        File originImage = settings.arguments as File;
        return CupertinoPageRoute(
            builder: (ctx) => ImageEditorWidget(originImage: originImage),
            settings: settings);
      case imageEditorWidgetNew:
        ImageDetails imageDetails = settings.arguments as ImageDetails;
        return CupertinoPageRoute(
            builder: (ctx) => ImageEditorWidgetNew(imageDetails),
            settings: settings);
      case faqAndSupportWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const FaqAndSupportWidget(), settings: settings);
      case forgotPINWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const ForgotPINWidget(), settings: settings);
      case confirmPINWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const ConfirmPINWidget(), settings: settings);
      case withdrawalHistoryWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const WithdrawalHistoryWidget(),
            settings: settings);
      case withdrawalVerificationWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const WithdrawalVerificationWidget(),
            settings: settings);
      case verifyPANWidget:
      VerifyPANCubit verifyPANCubit = VerifyPANCubit(sl());
      VerifyPANWidget verifyPANWidget = VerifyPANWidget();
        return CupertinoPageRoute(
            builder: (ctx) => BlocProvider(
              create: (context) => verifyPANCubit,
              child: verifyPANWidget,
            ),
            settings: settings);
      case documentVerificationWidget:
        DocumentVerificationData documentVerificationData =
            settings.arguments as DocumentVerificationData;
        return CupertinoPageRoute(
            builder: (ctx) =>
                DocumentVerificationWidget(documentVerificationData),
            settings: settings);
      case addBankDetailsWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const AddBankDetailsWidget(), settings: settings);
      case addUPIWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const AddUPIWidget(), settings: settings);
      case manageBeneficiaryWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const ManageBeneficiaryWidget(),
            settings: settings);
      case earningStatementWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const EarningStatementWidget(),
            settings: settings);
      case selectBeneficiaryWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const SelectBeneficiaryWidget(),
            settings: settings);
      case tDSDeductionDetailsWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const TDSDeductionDetailsWidget(),
            settings: settings);
      case howAppWorksWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const HowAppWorksWidget(), settings: settings);
      case demoVideosWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const DemoVideosWidget(), settings: settings);
      case showYtVideosWidget:
        Map<String, dynamic> demoVideos =
            settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
            builder: (ctx) => ShowYtVideosWidget(demoVideos),
            settings: settings);
      case worklogActivityWidget:
        WorkLogWidgetData workLogWidgetData =
            settings.arguments as WorkLogWidgetData;
        return CupertinoPageRoute(
            builder: (ctx) => WorkLogWidget(workLogWidgetData),
            settings: settings);
      case thanksFeedbackWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const ThanksFeedbackWidget(), settings: settings);
      case campusAmbassadorWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const CampusAmbassadorWidget(),
            settings: settings);
      case caDashboardWidget:
        CampusAmbassadorData campusAmbassadorTasks =
            settings.arguments as CampusAmbassadorData;
        return CupertinoPageRoute(
            builder: (ctx) => CaDashboardWidget(
                  campusAmbassadorTasks: campusAmbassadorTasks,
                ),
            settings: settings);
      case noAccessWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const NoAccessWidget(), settings: settings);
      case caApllicationWidget:
        CampusApplicationData campusApplicationData =
            settings.arguments as CampusApplicationData;
        return CupertinoPageRoute(
            builder: (ctx) => CaApplicationWidget(
                  campusApplicationData: campusApplicationData,
                ),
            settings: settings);
      case provideAvailabilityWidget:
        Map<String, dynamic> cleverTapEvent =
            settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
            builder: (ctx) => ProvideAvailabilityWidget(cleverTapEvent),
            settings: settings);
      case leadPayoutScreenWidget:
        EarningBreakupParams execution =
            settings.arguments as EarningBreakupParams;
        return CupertinoPageRoute(
            builder: (ctx) => LeadPayoutScreenWidget(execution),
            settings: settings);
      case universityWidget:
        return MaterialPageRoute(
            builder: (ctx) => const AwignUniversityWidget(),
            settings: settings);
      case universityVideoWidget:
        CoursesEntity coursesEntity = settings.arguments as CoursesEntity;
        return CupertinoPageRoute(
            builder: (ctx) => UniversityVideoWidget(coursesEntity),
            settings: settings);
      case notificationWidget:
        return MaterialPageRoute(
            builder: (ctx) => const NotificationWidget(), settings: settings);
      case onboardingIntroWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const OnboardingIntroWidget(),
            settings: settings);
      case loginScreenWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const LoginScreenWidget(), settings: settings);
      case confirmAmountWidget:
        EarningData earningData = settings.arguments as EarningData;
        return CupertinoPageRoute(
            builder: (ctx) => ConfirmAmountWidget(earningData),
            settings: settings);
      case enterEmailManuallyWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const EnterEmailManuallyWidget(),
            settings: settings);
      case trustBuildingWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const TrustBuildingWidget(), settings: settings);
      case onboardingQuestionsWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const OnboardingQuestionsWidget(),
            settings: settings);
      case dreamApplicationQuestionsWidget:
        ScrollController scrollController =
            settings.arguments as ScrollController;
        return CupertinoPageRoute(
            builder: (ctx) => DreamApplicationQuestionsWidget(scrollController,
                DreamApplicationCompletionStage.professionalDetails1),
            settings: settings);
      case profileDetailsWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const ProfileDetailsWidget(), settings: settings);
      case leaderBoardWidget:
        return CupertinoPageRoute(
            builder: (ctx) => const LeaderBoardWidget(), settings: settings);
      case categoryDetailAndJobWidget:
        var localSettings = RouteSettings(
            name: categoryDetailAndJobWidget, arguments: {});
        Map map = settings.arguments as Map;
        return CupertinoPageRoute(
            builder: (ctx) => CategoryDetailAndJobWidget(map['category_id'],
                map['category_application'], map['open_notify_bottom_sheet']),
            settings: localSettings);
      case earlyRedemptionPolicyWidget:
        CalculateDeductionResponse calculateDeductionResponse =
            settings.arguments as CalculateDeductionResponse;
        return CupertinoPageRoute(
            builder: (ctx) =>
                EarlyRedemptionPolicyWidget(calculateDeductionResponse),
            settings: settings);
      case allDeductionWidget:
        CalculateDeductionResponse calculateDeductionResponse =
            settings.arguments as CalculateDeductionResponse;
        return CupertinoPageRoute(
            builder: (ctx) => AllDeductionWidget(calculateDeductionResponse),
            settings: settings);
      case applicationResultWidget:
        EligiblityData eligiblityData  = settings.arguments as EligiblityData;
        var localSettings = RouteSettings(name: applicationResultWidget, arguments: {});
        return CupertinoPageRoute(
            builder: (ctx) =>  ApplicationResultWidget(eligiblityData),
            settings: localSettings);
      case resourceWidget:
        int? applicationId = settings.arguments as int;
        return CupertinoPageRoute(
            builder: (ctx) =>  ResourceWidget(applicationId),
            settings: settings);
      case leadMapViewWidget:
        LeadMapViewEntity leadMapViewEntity = settings.arguments as LeadMapViewEntity;
        return CupertinoPageRoute(builder: (ctx) => LeadMapViewWidget(leadMapViewEntity), settings: settings);
      case attendanceUploadImageWidget:
        ScreenQuestionArguments screenQuestionArguments =
            settings.arguments as ScreenQuestionArguments;
        return CupertinoPageRoute(
            builder: (ctx) =>
                AttendanceUploadImageWidget(screenQuestionArguments),
            settings: settings);
      case attendanceInputFields:
        ScreenQuestionArguments screenQuestionArguments =
            settings.arguments as ScreenQuestionArguments;
        return CupertinoPageRoute(
            builder: (ctx) => AttendanceInputFields(screenQuestionArguments),
            settings: settings);
      case leadMapViewWidget:
        LeadMapViewEntity leadMapViewEntity = settings.arguments as LeadMapViewEntity;
        return CupertinoPageRoute(builder: (ctx) => LeadMapViewWidget(leadMapViewEntity), settings: settings);
      case attendanceCaptureImageWidget:
        ImageDetails imageDetails = settings.arguments as ImageDetails;
        return CupertinoPageRoute(
            builder: (ctx) => AttendanceCaptureImageWidget(imageDetails),
            settings: settings);
      case signatureWidget:
        Question question = settings.arguments as Question;
        return CupertinoPageRoute(
            builder: (ctx) => SignatureWidget(question), settings: settings);
      case imageDetailsWidget:
        ImageDetails imageDetails = settings.arguments as ImageDetails;
        return CupertinoPageRoute(
            builder: (ctx) => ImageDetailsWidget(imageDetails), settings: settings);
      case codeScannerWidget:
        Question question = settings.arguments as Question;
        return CupertinoPageRoute(
            builder: (ctx) => CodeScannerWidget(question), settings: settings);
    }
  }

  static Future<dynamic> pushNamed(String route,
      {Object? arguments, bool isLocal = false}) {
    if (isLocal) {
      return localNavigatorKey.currentState!
          .pushNamed(route, arguments: arguments);
    } else {
      return globalNavigatorKey.currentState!
          .pushNamed(route, arguments: arguments);
    }
  }

  static Future<dynamic> pushReplacementNamed(String route,
      {Object? arguments, bool isLocal = false}) {
    if (isLocal) {
      return localNavigatorKey.currentState!
          .pushReplacementNamed(route, arguments: arguments);
    } else {
      return globalNavigatorKey.currentState!
          .pushReplacementNamed(route, arguments: arguments);
    }
  }

  static Future<dynamic> pushNamedAndRemoveUntil(String route,
      {Object? arguments, bool isLocal = false}) {
    if (isLocal) {
      return localNavigatorKey.currentState!.pushNamedAndRemoveUntil(
          route, (Route<dynamic> route) => false,
          arguments: arguments);
    } else {
      return globalNavigatorKey.currentState!.pushNamedAndRemoveUntil(
          route, (Route<dynamic> route) => false,
          arguments: arguments);
    }
  }

  static Future<Map?> pushNamedWithResult(
      BuildContext context, Widget widget, String? routeName,
      {bool isLocal = false}) async {
    var localSettings = RouteSettings(name: routeName, arguments: {});
    if (isLocal) {
      Object? value = await localNavigatorKey.currentState!.push(
          CupertinoPageRoute(
              builder: (ctx) => widget, settings: localSettings));
    } else {
      Object? value = await globalNavigatorKey.currentState!.push(
          CupertinoPageRoute(
              builder: (ctx) => widget, settings: localSettings));
    }
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    return arguments;
  }

  static Future<bool?> popNamedWithResult(
      String? routeName, String key, dynamic value) async {
    globalNavigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == routeName) {
        (route.settings.arguments as Map)[key] = value;
        return true;
      } else {
        return false;
      }
    });
  }

  static pop(Object? result, {bool isLocal = false}) {
    if (isLocal) {
      return localNavigatorKey.currentState!.pop(result);
    } else {
      return globalNavigatorKey.currentState!.pop(result);
    }
  }

  static void popUntil(String untilRoute, {bool isLocal = false}) {
    if (isLocal) {
      return localNavigatorKey.currentState!
          .popUntil(ModalRoute.withName(untilRoute));
    } else {
      return globalNavigatorKey.currentState!
          .popUntil(ModalRoute.withName(untilRoute));
    }
  }

  static Future exitApp() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return FlutterExitApp.exitApp(iosForceExit: true);
    } else {
      return FlutterExitApp.exitApp();
    }
  }
}

class NoRouteScreen extends StatelessWidget {
  final String screenName;

  NoRouteScreen(this.screenName);

  @override
  Widget build(BuildContext context) {
    return RouteWidget(
      child: Scaffold(
        body: Center(child: Text('${'no_route_defined'.tr} "$screenName"')),
      ),
    );
  }
}
