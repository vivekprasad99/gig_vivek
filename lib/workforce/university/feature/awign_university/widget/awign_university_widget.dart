import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_filter_bottom_sheet/widget/select_filter_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/university/data/model/university_entity.dart';
import 'package:awign/workforce/university/feature/awign_university/cubit/awign_university_cubit.dart';
import 'package:awign/workforce/university/feature/awign_university/widget/onboarding_university_widget.dart';
import 'package:awign/workforce/university/feature/awign_university/widget/tile/university_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/shared_preference_keys.dart';
import '../../../../core/router/router.dart';
import '../../../../core/widget/route_widget/route_widget.dart';
import '../../../data/model/navbar_item.dart';

class AwignUniversityWidget extends StatefulWidget {
  const AwignUniversityWidget({Key? key}) : super(key: key);

  @override
  State<AwignUniversityWidget> createState() => _AwignUniversityWidgetState();
}

class _AwignUniversityWidgetState extends State<AwignUniversityWidget> {
  final _awignUniversityCubit = sl<AwignUniversityCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  bool? showOnboardingUniversity;
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    isShowOnboardingUniversity();
    LoggingData loggingData =
        LoggingData(event: LoggingEvents.awignUniversityTab);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
    getCurrentUser();
  }

  void isShowOnboardingUniversity() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    showOnboardingUniversity =
        spUtil?.getBool(SPKeys.showAwignUniversity) ?? false;
    setState(() {});
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _awignUniversityCubit.changeCurrentUser(_currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return showOnboardingUniversity ?? false
        ? ScreenTypeLayout(
            mobile: buildMobileUI(context),
            desktop: const DesktopComingSoonWidget(),
          )
        : const OnboardingUniversityWidget();
  }

  Widget buildMobileUI(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        return true;
      },
      child: RouteWidget(
        bottomNavigation: true,
        child: AppScaffold(
          backgroundColor: AppColors.primaryMain,
          bottomPadding: 0,
          topPadding: 0,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                StreamBuilder<UserData>(
                    stream: _awignUniversityCubit.currentUser,
                    builder: (context, snapshot) {
                      return DefaultAppBar(
                        isCollapsable: true,
                        isActionVisible: true,
                        title: 'university'.tr,
                        isUserLoggedIn: snapshot.data != null ? true : false,
                      );
                    }),
              ];
            },
            body: buildBody(),
          ),
        ),
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
      child: StreamBuilder<UIStatus>(
          stream: _awignUniversityCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_16,
                        Dimens.padding_16,
                        Dimens.padding_16,
                        Dimens.padding_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyInkWell(
                          onTap: () {
                            showFilterBottomSheet(
                              context,
                              (value) {
                                _awignUniversityCubit
                                    .changeCourseSkillFilter(value);
                                _paginationKey.currentState?.refresh();
                              },
                            );
                          },
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 0, top: 0),
                            visualDensity: const VisualDensity(
                              vertical: -4,
                            ),
                            trailing: SvgPicture.asset(
                                'assets/images/filter.svg',
                                height: Dimens.iconSize_32),
                          ),
                        ),
                        const SizedBox(height: Dimens.margin_8),
                        SizedBox(
                          height: 40,
                          child: StreamBuilder<List<NavBarData>>(
                              stream:
                                  _awignUniversityCubit.navBarDataListStream,
                              builder: (context, navBarDataList) {
                                if (navBarDataList.hasData) {
                                  return ListView.builder(
                                      itemCount: navBarDataList.data!.length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (_, index) {
                                        return MyInkWell(
                                          onTap: () {
                                            _awignUniversityCubit.updateNavBar(
                                                index,
                                                navBarDataList.data![index]);
                                            _paginationKey.currentState
                                                ?.refresh();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              Dimens.padding_16,
                                              Dimens.padding_8,
                                              Dimens.padding_16,
                                              Dimens.padding_8,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: Dimens.padding_4),
                                            decoration: BoxDecoration(
                                                color: navBarDataList
                                                        .data![index].isSelected
                                                    ? AppColors
                                                        .backgroundGrey900
                                                    : AppColors.backgroundWhite,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimens.radius_32),
                                                border: Border.all(
                                                  color: AppColors
                                                      .backgroundGrey400,
                                                  width: 2,
                                                )),
                                            child: Center(
                                              child: Text(
                                                navBarDataList
                                                    .data![index].navBarItem!,
                                                style: Get.context?.textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                        color: navBarDataList
                                                                .data![index]
                                                                .isSelected
                                                            ? AppColors
                                                                .backgroundWhite
                                                            : AppColors
                                                                .backgroundGrey800,
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                } else {
                                  return AppCircularProgressIndicator();
                                }
                              }),
                        ),
                        buildUniversityList(),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildUniversityList() {
    return PaginationView<CoursesEntity>(
        key: _paginationKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        paginationViewType: PaginationViewType.listView,
        itemBuilder:
            (BuildContext context, CoursesEntity coursesEntity, int index) {
          return UniversityTile(index: index, coursesEntity: coursesEntity, onCourseTileClicked: _onCourseTileClicked);
        },
        pageFetch: _awignUniversityCubit.getCourseList,
        onEmpty: buildNoApplicationFound(),
        onError: (dynamic error) => Center(
              child: buildNoApplicationFound(),
            ),
        pageIndex: 1);
  }

  Widget buildNoApplicationFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          height: Dimens.pbWidth_72,
        ),
        Center(
          child: Image.asset('assets/images/empty_icon.png'),
        ),
        const SizedBox(height: Dimens.padding_24),
        Text(
          'no_course_found'.tr,
          textAlign: TextAlign.start,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.black,
              fontSize: Dimens.font_18,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<void> _onCourseTileClicked(CoursesEntity coursesEntity) async {
    await MRouter.pushNamed(MRouter.universityVideoWidget,
        arguments: coursesEntity);
    _paginationKey.currentState?.refresh();
  }
}
