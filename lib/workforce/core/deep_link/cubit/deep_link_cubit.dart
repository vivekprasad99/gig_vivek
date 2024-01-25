import 'dart:async';

import 'package:awign/workforce/auth/feature/otp_less_login/cubit/otp_less_cubit.dart';
import 'package:awign/workforce/auth/feature/splash/cubit/splash_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/zoho/zoho_helper.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_entity.dart';
import 'package:awign/workforce/more/feature/more/data/model/more_widget_data.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:uni_links/uni_links.dart';

import '../../config/permission/awign_permission_constants.dart';

part 'deep_link_state.dart';

class DeepLinkCubit extends Cubit<DeepLinkState> {
  static const categories = '/categories';
  static const office = '/office';
  static const jobs = '/jobs';
  static const earnings = '/earnings';
  static const profile = '/profile';
  static const editProfile = '/edit_profile';
  static const shareApp = '/share_app';
  static const campusAmbassador = '/campus_ambassador';
  static const executionID = 'execution_id';
  static const projectID = 'project_id';
  static const projectRoleUID = 'project_role_uid';
  static const dashboardEarnings = '/dashboard/earnings';
  static const offerLetter = '/dashboard/offer_letter';
  static const applications =
      '/applications/'; //deep link -> https://www.awign.com/applications/2361755/in-app-interview
  static const transferHistory =
      'payment/transfer'; // sample link -> https://www.awign.com/payment/transfer/725
  static const confirmAmount = '/earnings/confirm_amount'; // sample link -> https://www.awign.com/earnings/confirm_amount
  static const faqAndSupport = '/faq_and_support';

  Uri? initialURI;
  String? deepLinkURL;

  StreamSubscription? _streamSubscription;

  DeepLinkCubit() : super(DeepLinkInitial());

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  Future<void> initURIHandler() async {
    try {
      initialURI = await getInitialUri();
      AppLog.i("Initial URI received $initialURI");
    } on PlatformException {
      AppLog.e("Failed to receive initial uri");
    } on FormatException catch (err) {
      AppLog.e('Malformed Initial URI received');
    }
  }

  void incomingLinkHandler() {
    if (kIsWeb) {
    } else {
      _streamSubscription = uriLinkStream.listen((Uri? uri) {
        AppLog.i('Received URI: $uri');
        if (uri != null) {
          launchWidgetFromDeepLink(uri.path);
        }
      }, onError: (Object err) {
        AppLog.e('Error occurred: $err');
      });
    }
  }

  void launchWidgetFromDeepLink(String deepLink) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    String? accessToken = spUtil?.getAccessToken();
    UserData? currentUser = spUtil?.getUserData();
    if (accessToken == null &&
        currentUser != null &&
        currentUser.email != null) {
      deepLinkURL = deepLink;
      AuthHelper.checkOnboardingStages(currentUser);
    } else if (currentUser != null && currentUser.email != null) {
      if (deepLink.contains(categories)) {
        if (deepLink.contains(jobs) &&
            (currentUser.permissions?.awign
                    ?.contains(AwignPermissionConstants.listings) ??
                false)) {
          try {
            MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget,
                arguments: int.parse(deepLink.split("/").last));
          } catch (e, st) {
            AppLog.e('launchWidgetFromDeepLink : ${e.toString()} \n${st.toString()}');
          }
          MRouter.pushNamed(MRouter.workListingDetailsWidget,
              arguments: WorkListingDetailsArguments(deepLink.split("/").last));
        } else {
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryDetailsWidget,
              arguments: int.parse(deepLink.split("/").last));
        }
      } else if (deepLink.contains(office)) {
        MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
      } else if (deepLink.contains(jobs)) {
        MRouter.pushNamedAndRemoveUntil(MRouter.workListingDetailsWidget,
            arguments: WorkListingDetailsArguments(deepLink.split("/").last));
      } else if (deepLink.contains(confirmAmount)) {
        openConfirmAmount(currentUser);
      } else if (deepLink.contains(earnings)) {
        openEarnings(currentUser);
      } else if (deepLink.contains(profile)) {
        MRouter.pushNamedAndRemoveUntil(MRouter.moreWidget);
      } else if (deepLink.contains(editProfile)) {
        MRouter.pushNamedAndRemoveUntil(MRouter.moreWidget,
            arguments: MoreWidgetData(openProfileWidget: true));
      } else if (deepLink.contains(shareApp)) {
        MRouter.pushNamedAndRemoveUntil(MRouter.moreWidget,
            arguments: MoreWidgetData(shareAwignAppLink: true));
      } else if (deepLink.contains(campusAmbassador)) {
        openCampusAmbassadorWidget(currentUser);
      } else if (deepLink.contains(dashboardEarnings)) {
        openDashboardEarnings(currentUser, deepLink);
      } else if (deepLink.contains(offerLetter)) {
        MRouter.pushNamedAndRemoveUntil(MRouter.offerLetterWidget);
      } else if (deepLink.contains(transferHistory)) {
        openTransferHistory(currentUser, deepLink);
      } else if (deepLink.contains(applications)) {
        Uri uri = Uri.parse(deepLink);
        List<String> pathSegments = uri.pathSegments;
        String stringValue = pathSegments[
            1]; // Change the index based on where the required segment is
        int intValue = int.parse(stringValue);
        MRouter.pushNamedAndRemoveUntil(
            MRouter.applicationSectionDetailsWidgetDeepLink,
            arguments: intValue);
      } else if (deepLink.contains(faqAndSupport)) {
        ZohoHelper.setupAndOpenZohoFaq(currentUser);
      }
    }
  }

  static openTransferHistory(UserData? currentUser, String deepLink) {
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
      MRouter.pushNamedAndRemoveUntil(MRouter.earningsWidget, arguments: {
        'is_from_deep_link': true,
        'action': 'open_withdrawal_history',
        'data': deepLink.split('/')[deepLink.split('/').length - 1]
      });
    }
  }

  static openConfirmAmount(UserData? currentUser) {
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
      MRouter.pushNamedAndRemoveUntil(MRouter.earningsWidget, arguments: {
        'is_from_deep_link': true,
        'action': 'open_confirm_amount',
        'data': null
      });
    }
  }

  static openEarnings(UserData? currentUser) {
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

  static openDashboardEarnings(UserData? currentUser, String deepLink) {
    bool showEarning = false;
    if (!(currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideTotalEarnings) ??
        false)) {
      showEarning = false;
    } else if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.earnings) ??
        false)) {
      showEarning = true;
    }
    if (showEarning) {
      Map<String, String> dataMap = getExecutionKeyData(deepLink);
      EarningBreakupParams earningBreakupParams =
          EarningBreakupParams(executionID: dataMap[executionID]);
      MRouter.pushNamedAndRemoveUntil(MRouter.leadPayoutScreenWidget,
          arguments: earningBreakupParams);
    }
  }

  static Map<String, String> getExecutionKeyData(String deeplink) {
    List<String> tokenizer = deeplink.split("/");
    if (tokenizer.length < 8) return {};
    Map<String, String> dataMap = {};
    dataMap[projectID] = tokenizer[2];
    dataMap[executionID] = tokenizer[4];
    dataMap[projectRoleUID] = tokenizer[6];
    return dataMap;
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
