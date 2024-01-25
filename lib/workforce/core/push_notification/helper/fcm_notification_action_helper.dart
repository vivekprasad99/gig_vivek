import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/fcm/fcm_data.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/more/feature/more/data/model/more_widget_data.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';

import '../../config/permission/awign_permission_constants.dart';

class FCMNotificationHelper {
  static const openWorkList = "OPEN_WORKLISTING";
  static const actionApplicationWorkListing = "ACTION_APPLICATION_WORKLISTING";
  static const openCategory = "OPEN_CATEGORY";
  static const openJobs = "OPEN_JOBS";
  static const openCategoryDetails = "OPEN_CATEGORY_DETAIL";
  static const openBanner = "OPEN_BANNER";
  static const openOffice = "OPEN_OFFICE";
  static const actionApplicationDetails = "ACTION_APPLICATION_DETAILS";
  static const openEarnings = "OPEN_EARNINGS";
  static const openProfile = "OPEN_PROFILE";
  static const openShareApp = "OPEN_SHARE_APP";
  static const openCAPage = "OPEN_CA_PAGE";
  static const openDashboard = "OPEN_DASHBOARD";
  static const openOfferLetter = "OPEN_OFFER_LETTER";
  static const openEarningsBreakup = "OPEN_EARNINGS_BREAKUP";
  static const openSingleLead = "OPEN_SINGLE_LEAD";
  static const openLeadList = "OPEN_LEAD_LIST";

  static void launchWidgetFromFCMAction(
      String? action, FCMViewBody? fcmViewBody) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? currentUser = spUtil?.getUserData();
    if (currentUser?.id == null || currentUser?.id == -1) {
      MRouter.pushNamedAndRemoveUntil(MRouter.onboardingIntroWidget);
    } else if (currentUser?.email == null) {
      MRouter.pushNamedAndRemoveUntil(MRouter.userEmailWidget);
    } else {
      switch (action) {
        case openWorkList:
          _openWorkListing(currentUser, fcmViewBody);
          break;
        case actionApplicationWorkListing:
        case openCategory:
        case openJobs:
          _openJobs(currentUser, fcmViewBody);
          break;
        case openCategoryDetails:
          _openCategoryDetails(currentUser, fcmViewBody);
          break;
        case openBanner:
          break;
        case openOffice:
          break;
        case actionApplicationDetails:
          break;
        case openEarnings:
          _openEarnings(currentUser);
          break;
        case openProfile:
          break;
        case openShareApp:
          break;
        case openCAPage:
          openCampusAmbassadorWidget(currentUser);
          break;
        case openDashboard:
          break;
        case openOfferLetter:
          break;
        case openEarningsBreakup:
          break;
        case openSingleLead:
          break;
        case openLeadList:
          break;
        default:
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
      }
    }
  }

  static _openWorkListing(UserData? currentUser, FCMViewBody? fcmViewBody) {
    if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.listings) ??
        false)) {
      MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
      MRouter.pushNamed(MRouter.workListingDetailsWidget,
          arguments: WorkListingDetailsArguments(
              fcmViewBody?.intentData?.workListingID?.toString() ?? ''));
    } else {
      MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
    }
  }

  static _openCategoryDetails(UserData? currentUser, FCMViewBody? fcmViewBody) {
    if ((currentUser?.permissions?.awign
                ?.contains(AwignPermissionConstants.applications) ??
            false) ||
        !(currentUser?.permissions?.awign
                ?.contains(AwignPermissionConstants.hideExploreSection) ??
            false)) {
      MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
      MRouter.pushNamed(MRouter.categoryDetailsWidget,
          arguments: fcmViewBody?.intentData?.categoryID ?? -1);
    }
  }

  static _openEarnings(UserData? currentUser) {
    bool showEarning = false;
    if (!(currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideEarningsSection) ??
        false)) {
      showEarning = true;
    } else if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.earnings) ??
        false)) {
      showEarning = true;
    }
    if (showEarning) {
      MRouter.pushNamedAndRemoveUntil(MRouter.earningsWidget,
          arguments: sl<MRouter>().currentRoute);
    }
  }

  static _openJobs(UserData? currentUser, FCMViewBody? fcmViewBody) {
    if ((currentUser?.permissions?.awign
                ?.contains(AwignPermissionConstants.applications) ??
            false) ||
        !(currentUser?.permissions?.awign
                ?.contains(AwignPermissionConstants.hideExploreSection) ??
            false)) {
      MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
    }
  }

  static openCampusAmbassadorWidget(UserData? currentUser) {
    if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.campusAmbassador) ??
        false)) {
      MRouter.pushNamedAndRemoveUntil(MRouter.moreWidget,
          arguments: MoreWidgetData(openCampusAmbassadorWidget: true));
    }
  }
}
