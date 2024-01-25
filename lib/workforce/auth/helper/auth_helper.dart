import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';
import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/deep_link/cubit/deep_link_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';

class AuthHelper {
  static const personalDetails = "personal_details";
  static const addressDetails = "address_details";
  static const professionDetails = "professional_details";
  static const done = "done";

  static void checkOnboardingStages(UserData user,
      {bool? isTrustBuildingWidgetShown, Object? arguments}) {
    if (user.id == null || user.id == -1) {
      MRouter.pushNamedAndRemoveUntil(MRouter.onboardingIntroWidget);
    } else if (user.email == null) {
      MRouter.pushNamedAndRemoveUntil(MRouter.userEmailWidget);
    } else {
      switch (user.userProfile?.onboardingCompletionStage) {
        case OnboardingCompletionStage.completed:
          if (sl<DeepLinkCubit>().deepLinkURL != null) {
            sl<DeepLinkCubit>()
                .launchWidgetFromDeepLink(sl<DeepLinkCubit>().deepLinkURL!);
          } else {
            openCategoryListingWidget(user, arguments);
          }
          break;
        case OnboardingCompletionStage.personalDetails:
          MRouter.pushNamedAndRemoveUntil(MRouter.personalDetailsWidget);
          break;
        case OnboardingCompletionStage.workPreferences:
          if (isTrustBuildingWidgetShown != null &&
              isTrustBuildingWidgetShown) {
            MRouter.pushNamedAndRemoveUntil(MRouter.onboardingQuestionsWidget);
          } else {
            MRouter.pushNamedAndRemoveUntil(MRouter.trustBuildingWidget);
          }
          break;
        case OnboardingCompletionStage.availabilityType:
          MRouter.pushNamedAndRemoveUntil(MRouter.onboardingQuestionsWidget);
          break;
        default:
          openCategoryListingWidget(user, arguments);
      }
    }
  }

  static openCategoryListingWidget(
      UserData currentUser, Object? arguments) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    bool showExploreJobs = true;
    if ((currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hideExploreSection) ??
        false)) {
      showExploreJobs = false;
    } else if ((currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.applications) ??
        false)) {
      showExploreJobs = true;
    }
    if (showExploreJobs) {
      if (arguments != null) {
        Map map = arguments as Map;
        if (map['from_route'] == MRouter.oTPVerificationWidget &&
            spUtil?.getNotifyCategoryId() != null) {
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryDetailAndJobWidget,
              arguments: {
                'category_id': spUtil?.getNotifyCategoryId(),
                'open_notify_bottom_sheet': true
              });
        } else if (spUtil?.getNotifyCategoryId() != null) {
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget,
              arguments: true);
        } else {
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        }
      } else {
        if (spUtil?.getNotifyCategoryId() != null) {
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget,
              arguments: true);
        } else {
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        }
      }
    } else {
      MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
    }
  }
}
