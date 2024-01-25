import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/notification_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/notification/cubit/notification_cubit.dart';
import 'package:awign/workforce/core/widget/notification/helper/fcm_notification_action_helper.dart';
import 'package:awign/workforce/core/widget/notification/widget/tile/notification_tile.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'bottom_sheet/select_notification_bottom_sheet.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key? key}) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final NotificationCubit _notificationCubit = sl<NotificationCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    setState(() {
      _currentUser = spUtil?.getUserData();
      if (_currentUser!.unreadNotificationCount != 0) {
        _notificationCubit
            .changeUnReadCount(_currentUser!.unreadNotificationCount!);
      } else {
        _notificationCubit.changeUnReadCount(0);

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      topPadding: 0,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: 'notification'.tr,
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _notificationCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  (uiStatus.data?.isOnScreenLoading ?? false)) {
                return AppCircularProgressIndicator();
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimens.padding_16,
                          Dimens.padding_16,
                          Dimens.padding_16,
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<int>(
                                stream: _notificationCubit.unReadCount,
                                builder: (context, snapshot) {
                                  final count = snapshot.data;
                                  return Text(
                                    '$count Unread notifications',
                                    style: Get.context?.textTheme.bodyMedium
                                        ?.copyWith(
                                            color: AppColors.backgroundGrey900),
                                  );
                                }),
                            PopupMenuButton<int>(
                              color: Get.theme.backgroundColor,
                              icon: RotatedBox(
                                quarterTurns: -1,
                                child: SvgPicture.asset(
                                    'assets/images/ic_more.svg',
                                    color: AppColors.backgroundGrey900),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: Text('mark_as_all_read'.tr,
                                      style: Get.textTheme.bodyMedium),
                                ),
                              ],
                              onSelected: (item) {
                                _notificationCubit.updateNotificationsStatus(
                                    _currentUser!.id ?? 0,
                                    StringUtils
                                        .getDateTimeInYYYYMMDDHHMMSSFormat(
                                            DateTime.now())!);
                                _notificationCubit.updateUnReadCount();
                                _paginationKey.currentState?.refresh();
                              },
                            ),
                          ],
                        ),
                      ),
                      HDivider(),
                      SizedBox(
                        height: Get.height - 160,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            Dimens.padding_16,
                            0,
                            Dimens.padding_16,
                          ),
                          child: buildTabs(),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildTabs() {
    return SizedBox(
      height: double.infinity,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              margin: const EdgeInsets.symmetric(horizontal: Dimens.margin_56),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimens.radius_6),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    color: AppColors.primaryMain,
                    borderRadius: BorderRadius.circular(Dimens.radius_6)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: Get.context?.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryMain, fontWeight: FontWeight.w600),
                unselectedLabelStyle: Get.context?.textTheme.bodyMedium
                    ?.copyWith(
                        color: AppColors.backgroundWhite,
                        fontWeight: FontWeight.w600),
                tabs: [
                  Tab(
                      child: Text(
                    'work'.tr,
                  )),
                  Tab(
                      child: Text(
                    "new_job".tr,
                  )),
                ],
              ),
            ),
            const SizedBox(
              height: Dimens.padding_16,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildNotificationList(),
                  buildNoApplicationFound(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationList() {
    return PaginationView<Notifications>(
      key: _paginationKey,
      paginationViewType: PaginationViewType.listView,
      itemBuilder:
          (BuildContext context, Notifications notifications, int index) {
        return NotificationTile(
          index: index,
          notifications: notifications,
          onNotificationTap: onNotificationTap,
        );
      },
      pageFetch: _notificationCubit.fetchNotificationList,
      onEmpty: buildNoApplicationFound(),
      onError: (dynamic error) => Center(
        child: buildNoApplicationFound(),
      ),
      pageIndex: 1,
      bottomLoader: const SizedBox(),
      initialLoader: AppCircularProgressIndicator(),
    );
  }

  Widget buildNoApplicationFound() {
    return Column(
      children: [
        const SizedBox(
          height: Dimens.pbHeight_72,
        ),
        Image.asset(
          'assets/images/empty_icon.png',
          height: Dimens.imageHeight_150,
        ),
        const SizedBox(height: Dimens.padding_24),
        Text(
          'no_notification'.tr,
          textAlign: TextAlign.center,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.black,
              fontSize: Dimens.font_14,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  onNotificationTap(int index, Notifications notification) {
    _notificationCubit.updateSingleNotificationStatus(notification.id!);
    updateUnreadNotification(index, notification);
    _paginationKey.currentState?.refresh();
    showNotificationBottomSheet(context, () {
      MRouter.pop(null);
      FCMNotificationActionHelper.launchWidgetFromActionData(notification);
    }, notification);
  }

  void updateUnreadNotification(int index, Notifications notifications) async {
    if (notifications.status != Constants.acknowledged) {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currentUser = spUtil?.getUserData();
      currentUser!.unreadNotificationCount =
          currentUser.unreadNotificationCount! - 1;
      spUtil?.putUserData(currentUser);
      getCurrentUser();
    }
  }
}
