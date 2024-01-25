import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/aw_questions/widget/whatsapp/cubit/whatsapp_subscription_cubit.dart';
import 'package:awign/workforce/banner/feature/dynamic_banner/widget/banner_widget.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_event_helper.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/dream_application_bottom_sheet/widget/dream_application_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/nps_bottom_sheet/widget/nps_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/whatsapp_notifications_bottom_sheet/widget/whatsapp_notification_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_icon_button.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/take_a_tour/welcome_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/dream_application/widget/bottom_sheet/widget/dream_application_questions_bottom_sheet.dart';
import 'package:awign/workforce/more/feature/more/widget/dream_application_nudge_widget.dart';
import 'package:awign/workforce/more/feature/more/widget/profile_completion_percent_widget.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/cubit/category_listing_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/widget/tile/category_shimmer_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/widget/tile/category_tile.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/config/cubit/flavor_cubit.dart';
import '../../../../../core/config/flavor_config.dart';
import '../../../../../core/data/helper/workmanager.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../../core/data/local/shared_preference_utils.dart';
import '../../../../../core/data/model/user_data.dart';
import '../../../../../core/utils/app_upgrade_dialog.dart';
import '../../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../../core/widget/buttons/raised_rect_button.dart';
import '../../../../../core/widget/circle_avatar/custom_circle_avatar.dart';
import '../../../../../core/widget/take_a_tour/take_a_tour.dart';
import '../../../../../core/widget/take_a_tour/tour_keys.dart';
import '../bottom_sheet/notified_soon_bottomsheet_widget.dart';

class CategoryListingWidget extends StatefulWidget {
  final dynamic openNotifyBottomSheet;

  const CategoryListingWidget(this.openNotifyBottomSheet, {Key? key})
      : super(key: key);

  @override
  _CategoryListingWidgetState createState() => _CategoryListingWidgetState();
}

class _CategoryListingWidgetState extends State<CategoryListingWidget> {
  final CategoryListingCubit _categoryCubit = sl<CategoryListingCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  String NUDGE_DISPLAYED = "nudge_displayed";
  String NUDGE_CANCELLED = "nudge_cancelled";
  String NUDGE_CLICKED = "nudge_clicked";
  String WORK_PROFILE_COMPLETION = "workforce_profile_completion";
  UserData? _currentUser;
  SPUtil? spUtil;
  late CategoryApplication _categoryApplication;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    callCron();
    subscribeUIStatus();
    WidgetsBinding.instance.addPostFrameCallback((_)  async {
      if (TourKeys.loginCount == 1)  {
        spUtil = await SPUtil.getInstance();
        _currentUser = spUtil?.getUserData();
        if(!(_currentUser?.subscribedToWhatsapp ?? true))
        {
          showWhatsappNotification();
        }else{
          showTourKey();
        }
        // showWelcomeBottomSheet(context);
      }
    });
    shouldShow();
  }

  void shouldShow() async {
    var shouldShow = await _categoryCubit.shouldShow();
    if (shouldShow) {
      spUtil = await SPUtil.getInstance();
      spUtil!.previousWhatsappBottomSheetOpenTime(
          DateTime.now().millisecondsSinceEpoch);
      showWhatsappNotification();
    }
  }

  void subscribeUIStatus() {
    _categoryCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage,
              color: AppColors.success300);
        }
        switch (uiStatus.event) {
          case Event.created:
            _paginationKey.currentState?.refresh();
            showNotifiedSooBottomSheet(context);
            break;
          case Event.success:
            LoggingData loggingData = LoggingData(event: LoggingEvents.ratingPopupOpened,
                action: LoggingActions.opened,pageName: LoggingPageNames.enterOtpLogin);
            CaptureEventHelper.captureEvent(
                loggingData: loggingData);
            showNpsBottomSheet(context);
            break;
        }
      },
    );
  }

  void showWhatsappNotification() {
    showWhatsappNotificationBottomSheet(context, () async {
      sl<WhatsappSubscriptionCubit>().subscribeWhatsapp(_currentUser!,false);
      spUtil = await SPUtil.getInstance();
      await spUtil!.putWhatsappSubscribe(true);
      MRouter.pop(null);
      Helper.showInfoToast('successfully_enabled'.tr,color: AppColors.success300);
      openCategoryDetail();
    }, () async {
      spUtil = await SPUtil.getInstance();
      spUtil!.shouldShowBottomSheet(true);
      MRouter.pop(null);
      openCategoryDetail();
    }, () async {
      spUtil = await SPUtil.getInstance();
      spUtil!.shouldShowBottomSheet(true);
      MRouter.pop(null);
      openCategoryDetail();
    });
  }

  openCategoryDetail() {
    if(widget.openNotifyBottomSheet == true) {
      MRouter.pushNamed(MRouter.categoryDetailAndJobWidget, arguments: {
      'category_id': spUtil?.getNotifyCategoryId(),
      'open_notify_bottom_sheet': true
    });
    } else {
      showTourKey();
    }
    spUtil?.putNotifyCategoryId(-1);
  }

  void callCron() {
    final cron = Cron();
    cron.schedule(Schedule.parse('*/15 * * * *'), () {
      WorkerManager.callbackDispatcher();
    });
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    String? fcmToken = spUtil?.getFCMToken();
    if (_currentUser != null) {
      _categoryCubit.getUserNudge(_currentUser?.id ?? -1);
      _categoryCubit.getNpsAction("${_currentUser?.id}");
    }
    String role = '';
    if (_currentUser != null && !_currentUser!.roles.isNullOrEmpty) {
      role = _currentUser!.roles![0];
    }
    _categoryCubit.updateDeviceInfo(
        _currentUser?.id ?? -1, role, fcmToken ?? '');
    if (_currentUser != null) {
      _categoryCubit.getUserProfile(_currentUser!);
    }
    if ((spUtil?.getProfileCompletionBottomSheetCount() == 2) &&
        _currentUser?.userProfile?.dreamApplicationCompletionStage !=
            DreamApplicationCompletionStage.completed) {
      dreamApplicationSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppUpgradeDialogHelper().checkVersionAndShowAppUpgradeDialog(context, false);
    return RouteWidget(
      bottomNavigation: true,
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              StreamBuilder<UserData>(
                  stream: _categoryCubit.currentUser,
                  builder: (context, snapshot) {
                    return DefaultAppBar(
                      isCollapsable: true,
                      isActionVisible: true,
                      title: 'explore'.tr,
                      isUserLoggedIn: snapshot.hasData
                          ? (snapshot.data != null ? true : false)
                          : false,
                    );
                  }),
            ];
          },
          body: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _categoryCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
                return AppCircularProgressIndicator();
              } else {
                return StreamBuilder<UserData>(
                    stream: _categoryCubit.currentUser,
                    builder: (context, snapshot) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const BannerWidget(Constants.explorejobtop),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0, 0, 0, Dimens.padding_16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // buildProfileCompletionIndicator(),
                                  buildDreamApplicationNudgeBannerWidgets(
                                      snapshot.data),
                                  buildTitleText(),
                                  buildExploreJobsText(),
                                  buildCategoryList(),
                                ],
                              ),
                            ),
                            const BannerWidget(Constants.explorejobbottom),
                          ],
                        ),
                      );
                    });
              }
            }),
      ),
    );
  }

  Widget buildProfileCompletionIndicator() {
    return StreamBuilder<bool?>(
      stream: _categoryCubit.showProfileCompletionNudge,
      builder: (context, showProfileCompletionNudge) {
        if (showProfileCompletionNudge.hasData &&
            showProfileCompletionNudge.data == true) {
          _categoryCubit.nudgeEvent(
              _currentUser?.id ?? -1, NUDGE_DISPLAYED, WORK_PROFILE_COMPLETION);
          if (_categoryCubit
                  .userNudges?.nudgeData?.profileCompletionPercentage !=
              null) {
            _currentUser?.userProfile?.profileCompletionPercentage = int.parse(
                _categoryCubit
                    .userNudges!.nudgeData!.profileCompletionPercentage!
                    .replaceAll(RegExp(r'[^0-9]'), ''));
            spUtil?.putUserData(_currentUser);
          }
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimens.radius_16),
                topRight: Radius.circular(Dimens.radius_16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.padding_16, vertical: Dimens.margin_24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: Dimens.radius_40,
                        lineWidth: 5.0,
                        percent: double.parse(_categoryCubit
                                    .profileCompletionPercentage
                                    ?.replaceAll(RegExp(r'[^0-9]'), '') ??
                                '20') /
                            100,
                        progressColor: AppColors.success300,
                        backgroundColor: AppColors.primary50,
                      ),
                      CustomCircleAvatar(
                          radius: Dimens.radius_32,
                          url: _currentUser?.image ??
                              "https://awign-production.s3.ap-south-1.amazonaws.com/awign/defaults/icons/${_currentUser?.name?.substring(0, 1).toLowerCase() ?? 'z'}.png")
                    ],
                  ),
                  const SizedBox(width: Dimens.margin_20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${_categoryCubit.userNudges?.nudgeData?.profileCompletionPercentage ?? 20} profile_complete'
                                .tr,
                            style: Get.context?.textTheme.headline7Bold),
                        const SizedBox(height: Dimens.margin_4),
                        Text('speed_up_your_application_process'.tr,
                            style: Get.context?.textTheme.bodyText1Medium),
                        const SizedBox(height: Dimens.margin_12),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: Dimens.padding_60),
                          child: RaisedRectButton(
                            height: Dimens.margin_40,
                            text: 'complete_profile'.tr,
                            onPressed: () {
                              LoggingData loggingData = LoggingData(
                                  action: LoggingActions
                                      .completeProfileExplorePage);
                              CaptureEventHelper.captureEvent(
                                  loggingData: loggingData);
                              MRouter.pushNamed(MRouter.myProfileWidget,
                                  arguments: {});
                              _categoryCubit.nudgeEvent(_currentUser?.id ?? -1,
                                  NUDGE_CLICKED, WORK_PROFILE_COMPLETION);
                            },
                            backgroundColor: AppColors.success300,
                          ),
                        )
                      ],
                    ),
                  ),
                  MyInkWell(
                      onTap: () {
                        _categoryCubit.changeShowProfileCompletionNudge(false);
                        _categoryCubit.nudgeEvent(_currentUser?.id ?? -1,
                            NUDGE_CANCELLED, WORK_PROFILE_COMPLETION);
                      },
                      child: SvgPicture.asset('assets/images/ic_delete.svg')),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildMaybeLatterButton(UserData? currentUser) {
    return Expanded(
      child: CustomTextButton(
        height: Dimens.btnHeight_40,
        text: 'maybe_later'.tr,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.backgroundGrey400,
        textStyle: Get.textTheme.bodyText2SemiBold
            ?.copyWith(color: AppColors.backgroundGrey800),
        onPressed: () {
          spUtil?.putIsDreamApplicationMaybeLater(true);
          spUtil?.putProfileCompletionBottomSheetCount((spUtil?.getProfileCompletionBottomSheetCount() ?? 0) + 3);
          if (currentUser != null) {
            _categoryCubit.changeCurrentUser(currentUser);
          }
        },
      ),
    );
  }

  Widget buildDreamApplicationNudgeBannerWidgets(UserData? currentUser) {
    if (currentUser != null) {
      if ((spUtil?.getIsDreamApplicationMaybeLater() ?? false)) {
        return const SizedBox();
      } else {
        return DreamApplicationNudgeWidget(
            currentUser: currentUser,
            bottomWidget: Column(
              children: [
                ProfileCompletionPercentWidget(currentUser),
                const SizedBox(height: Dimens.padding_24),
                Row(
                  children: [
                    buildMaybeLatterButton(currentUser),
                    const SizedBox(width: Dimens.padding_16),
                    buildCompleteNowButton(),
                  ],
                )
              ],
            ));
      }
    } else {
      return const SizedBox();
    }
  }

  Widget buildCompleteNowButton() {
    return Expanded(
      child: RaisedRectButton(
        text: 'complete_now'.tr,
        height: Dimens.btnHeight_40,
        elevation: 0,
        textStyle: Get.textTheme.bodyText2SemiBold
            ?.copyWith(color: AppColors.backgroundWhite),
        onPressed: () {
          spUtil?.putProfileCompletionBottomSheetCount((spUtil?.getProfileCompletionBottomSheetCount() ?? 0) + 3);
          showDreamApplicationQuestionsBottomSheet(
              context,
              DreamApplicationCompletionStage.professionalDetails1,
              _onBottomSheetClosed);
        },
      ),
    );
  }

  _onBottomSheetClosed() {
    _categoryCubit.getUserProfile(_currentUser!);
  }

  _onNotifiedBottomSheetClosed(CategoryApplication categoryApplication) {}

  Widget buildTitleText() {
    return Padding(
      padding:
          const EdgeInsets.only(left: Dimens.padding_16, top: Dimens.margin_28),
      child: Text('job_categories'.tr,
          style: Get.context?.textTheme.headline7Bold),
    );
  }

  Widget buildExploreJobsText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.margin_4, Dimens.padding_16, 0),
      child: TextFieldLabel(
          label: 'explore_jobs_by_categories'.tr,
          color: AppColors.backgroundGrey800),
    );
  }

  Widget buildCategoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: PaginationView<Category>(
        key: _paginationKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, Category category, int index) =>
            index == 0
                ? TakeATourWidget(
                    globalKey: TourKeys.tourKeys4,
                    buildShowContainer: buildShowContainer(),
                    child: CategoryTile(
                      index: index,
                      category: category,
                      onProceedNextTap: _openCategoryDetailsWidget,
                      onViewCategoryTap:
                          (selectedIndex, selectedCategory) async {
                        await MRouter.pushNamed(
                            MRouter.categoryDetailAndJobWidget,
                            arguments: {
                              'category_id': selectedCategory.id,
                              'category_application':
                                  selectedCategory.categoryApplication
                            });
                        _paginationKey.currentState?.refresh();
                      },
                      onShareCategoryTap: _onShareCategoryTap,
                      onNotifyMeClicked: _onNotifyMeClicked,
                    ),
                  )
                : CategoryTile(
                    index: index,
                    category: category,
                    onProceedNextTap: _openCategoryDetailsWidget,
                    onViewCategoryTap: (selectedIndex, selectedCategory) async {
                      await MRouter.pushNamed(
                          MRouter.categoryDetailAndJobWidget,
                          arguments: {
                            'category_id': selectedCategory.id,
                            'category_application':
                                selectedCategory.categoryApplication
                          });
                      _paginationKey.currentState?.refresh();
                    },
                    onShareCategoryTap: _onShareCategoryTap,
                    onNotifyMeClicked: _onNotifyMeClicked,
                  ),
        paginationViewType: PaginationViewType.listView,
        pageIndex: 1,
        pageFetch: _categoryCubit.getCategoryList,
        onError: (dynamic error) => Center(
          child: DataNotFound(),
        ),
        onEmpty: DataNotFound(),
        bottomLoader: AppCircularProgressIndicator(),
        initialLoader: ListView(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            CategoryShimmerTile(),
            CategoryShimmerTile(),
            CategoryShimmerTile(),
            CategoryShimmerTile(),
            CategoryShimmerTile(),
            CategoryShimmerTile(),
            CategoryShimmerTile(),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategoryDetailsWidget(int index, Category category) async {
    if (category.categoryApplication != null) {
      _openCategoryApplicationDetailsWidget(category.categoryApplication);
    }
  }

  _openCategoryApplicationDetailsWidget(
      CategoryApplication? categoryApplication) {
    MRouter.pushNamed(MRouter.categoryApplicationDetailsWidget,
        arguments: categoryApplication);
  }

  Widget buildShowContainer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('category_details'.tr,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.2)),
          const SizedBox(
            height: Dimens.margin_12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyInkWell(
                onTap: () async {
                  TourKeys.loginCount = 0;
                  TourKeys.officeLoginCount = 1;
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) async => ShowCaseWidget.of(context).dismiss());
                  LoggingData loggingData = LoggingData(
                      event: Constants.skipExplore,
                      action: LoggingActions.clicked,
                      pageName: Constants.explore);
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
                child: Text('skip'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.2)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: RaisedRectButton(
                  height: Dimens.margin_40,
                  width: 80,
                  text: 'next'.tr,
                  onPressed: () async {
                    TourKeys.loginCount = 0;
                    TourKeys.officeLoginCount = 1;
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) async => ShowCaseWidget.of(context).dismiss());
                    LoggingData loggingData = LoggingData(
                        event: Constants.nextExplore,
                        action: LoggingActions.clicked,
                        pageName: Constants.explore);
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                  },
                  backgroundColor: AppColors.primaryMain,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget bottomWidget(UserData? currentUser) {
    return ProfileCompletionPercentWidget(
      currentUser!,
      isBottomSheet: true,
    );
  }

  // void showWelcomeBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       isDismissible: false,
  //       enableDrag: false,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(Dimens.radius_16),
  //           topRight: Radius.circular(Dimens.radius_16),
  //         ),
  //       ),
  //       builder: (_) {
  //         return const WelcomeBottomSheet();
  //       });
  // }

  _onNotifyMeClicked(selectedIndex, categoryId) async {
    try {
      if (_currentUser != null) {
        _categoryCubit.createApplicationInNotifyStatus(
            selectedIndex, categoryId, spUtil?.getUserData()?.id ?? -1);
      } else {
        //manage login flow
        spUtil?.putNotifyCategoryId(categoryId);
        MRouter.pushNamedAndRemoveUntil(MRouter.phoneVerificationWidget);
      }
    } catch (e, st) {
      AppLog.e(
          'CategoryListingWidget _onNotifyMeClicked: ${e.toString()} \n ${st.toString()}');
    }
  }

  _onShareCategoryTap(selectedIndex, selectedCategory) async {
    try {
      String url = "";
      String? referralCode = _currentUser?.referralCode;
      FlavorCubit flavorCubit = context.read<FlavorCubit>();
      if (flavorCubit.flavorConfig.appFlavor != AppFlavor.production) {
        url = "https://www.awigntest.com/categories/${selectedCategory.id}";
      } else {
        url = "https://www.awign.com/categories/${selectedCategory.id}";
      }
      if (referralCode != null) {
        url += "?ref=$referralCode";
      } else {
        url += "";
      }
      await Share.share(url);
    } catch (e, st) {
      AppLog.e(
          'CategoryListingWidget onShareCategoryTap: ${e.toString()} \n${st.toString()}');
    }
    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser!);
    properties[CleverTapConstant.categoryId] = selectedCategory.id;
    ClevertapData clevertapData = ClevertapData(
        eventName: ClevertapHelper.categoryShareCta, properties: properties);
    CaptureEventHelper.captureEvent(clevertapData: clevertapData);
  }

  void showTourKey() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) async => ShowCaseWidget.of(context).startShowCase([
              TourKeys.tourKeys1,
              TourKeys.tourKeys2,
              TourKeys.tourKeys3,
              TourKeys.tourKeys4,
              TourKeys.tourKeys5,
              TourKeys.tourKeys6,
            ]));
  }

  void dreamApplicationSheet() {
    dreamApplicationBottomSheet(context, () {
      spUtil?.putProfileCompletionBottomSheetCount((spUtil?.getProfileCompletionBottomSheetCount() ?? 0) + 3);
      showDreamApplicationQuestionsBottomSheet(
          context,
          DreamApplicationCompletionStage.professionalDetails1,
          _onBottomSheetClosed);
    }, () {
      spUtil?.putProfileCompletionBottomSheetCount((spUtil?.getProfileCompletionBottomSheetCount() ?? 0) + 3);
      MRouter.pop(true);
    }, bottomWidget(_currentUser));
  }
}
