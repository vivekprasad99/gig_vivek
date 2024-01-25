import 'dart:async';

import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/navigation_item.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../../config/permission/awign_permission_constants.dart';

class BottomNavigationCubit extends Cubit<String> {
  late StreamSubscription<String> _routeNameSubscription;

  final _navigationItems = BehaviorSubject<List<NavigationItem>>();
  Stream<List<NavigationItem>> get navigationItemsStream =>
      _navigationItems.stream;
  Function(List<NavigationItem>) get changeNavigationItems =>
      _navigationItems.sink.add;
  List<NavigationItem> navigationItems = [
    NavigationItem(
      navigateTo: MRouter.categoryListingWidget,
      text: 'explore'.tr,
      iconUrl: 'assets/images/ic_explore_tab.svg',
    ),
    NavigationItem(
      navigateTo: MRouter.officeWidget,
      text: 'office'.tr,
      iconUrl: 'assets/images/ic_office_tab.svg',
    ),
    NavigationItem(
      navigateTo: MRouter.universityWidget,
      text: 'university'.tr,
      iconUrl: 'assets/images/ic_university_tab.svg',
    ),
    NavigationItem(
      navigateTo: MRouter.earningsWidget,
      text: 'earnings'.tr,
      iconUrl: 'assets/images/ic_earnings_tab.svg',
    ),
    NavigationItem(
      navigateTo: MRouter.moreWidget,
      text: 'profile'.tr,
      iconUrl: 'assets/images/ic_profile_tab.svg',
      gifUrl: 'assets/images/new_update_profile.gif'
    ),
  ];

  BottomNavigationCubit() : super("") {
    _routeNameSubscription = sl<MRouter>().currentRouteStream.listen((route) {
      List<String?> possibleRoutes =
          navigationItems.map((e) => e.navigateTo).toList();
      if (possibleRoutes.contains(route)) {
        emit(route);
      }
    });
  }

  loadNavigationItem() async {
   SPUtil? spUtil = await SPUtil.getInstance();

   bool shouldShowNewUpdateOnLeaderBoard() {
     DateTime now = DateTime.now();
     int currentDay = now.day;
     int startDay = 5;
     int endDay = RemoteConfigHelper.instance().showNewUpdateForLeaderBoard + startDay;
     int lastShownMonth = (spUtil!.leaderBoardFlagShownLastMonth() ?? -1);
     return currentDay >= startDay && currentDay <= endDay && lastShownMonth != getCurrentMonth();
   }

   String? gifUrl;
   if(shouldShowNewUpdateOnLeaderBoard()){
     gifUrl = 'assets/images/new_update_profile.gif';
   }

    navigationItems = [
      NavigationItem(
        navigateTo: MRouter.categoryListingWidget,
        text: 'explore'.tr,
        iconUrl: 'assets/images/ic_explore_tab.svg',
      ),
      NavigationItem(
        navigateTo: MRouter.officeWidget,
        text: 'office'.tr,
        iconUrl: 'assets/images/ic_office_tab.svg',
      ),
      NavigationItem(
        navigateTo: MRouter.universityWidget,
        text: 'university'.tr,
        iconUrl: 'assets/images/ic_university_tab.svg',
      ),
      NavigationItem(
        navigateTo: MRouter.earningsWidget,
        text: 'earnings'.tr,
        iconUrl: 'assets/images/ic_earnings_tab.svg',
      ),
      NavigationItem(
        navigateTo: MRouter.moreWidget,
        text: 'profile'.tr,
        iconUrl: 'assets/images/ic_profile_tab.svg',
          gifUrl: gifUrl
      ),
    ];
    UserData? currentUser = spUtil?.getUserData();
    bool showEarning = true;
    if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideEarningsSection) ??
        false)) {
      showEarning = false;
    } /*else if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.earnings) ??
        false)) {
      showEarning = true;
    }*/
    if (!showEarning) {
      navigationItems.removeAt(3);
    }
    bool showUniversity = true;
    if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideUniversitySection) ??
        false)) {
      showUniversity = false;
    } else if (RemoteConfigHelper.instance().enableAwignUniversity) {
      showUniversity = true;
    }
    if (!showUniversity) {
      navigationItems.removeAt(2);
    }
    bool showExploreJobs = true;
    if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.hideExploreSection) ??
        false)) {
      showExploreJobs = false;
    } else if ((currentUser?.permissions?.awign
            ?.contains(AwignPermissionConstants.applications) ??
        false)) {
      showExploreJobs = true;
    }
    if (!showExploreJobs) {
      navigationItems.removeAt(0);
    }
    changeNavigationItems(navigationItems ?? []);
  }



  int getCurrentMonth() {
    return DateTime.now().month; // Subtract 1 because DateTime uses zero-based months
  }

  @override
  Future<void> close() {
    _routeNameSubscription.cancel();
    _navigationItems.close();
    return super.close();
  }
}
