import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/show_certificate_bottom_sheet/widget/show_certificate_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/under_five_rank_bottom_sheet/widget/under_five_rank_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/earning_response.dart';
import 'package:awign/workforce/more/feature/leaderboard/cubits/leaderboard_cubit.dart';
import 'package:awign/workforce/more/feature/leaderboard/data/model/leaderboard_widget_data.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/certificate_widget.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/come_back_later_widget.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/earnings_widget.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/not_yet_started_widget.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/performance_widget.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/tile/nav_bar_tile.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/tile/top_earner_tile.dart';
import 'package:awign/workforce/more/feature/leaderboard/widgets/tips_to_improve_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/config/cubit/flavor_cubit.dart';
import '../../../../core/config/flavor_config.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';
import '../../../data/model/user_certificate_response.dart';
import '../../../data/model/user_earning_response.dart';
import 'blank_certificate.dart';

class LeaderBoardWidget extends StatefulWidget {
  const LeaderBoardWidget({Key? key}) : super(key: key);

  @override
  State<LeaderBoardWidget> createState() => _LeaderBoardWidgetState();
}

class _LeaderBoardWidgetState extends State<LeaderBoardWidget> {
  final _leaderboardCubit = sl<LeaderboardCubit>();
  UserData? _currentUser;
  int dayFour = 4;
  int zero = 0;
  String selectedMonth = 'Jan 2023';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('az');
    getCurrentUser();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _leaderboardCubit.uiStatus.listen(
      (uiStatus) {
        switch (uiStatus.event) {
          case Event.success:
            showUnderFiveRankBottomSheet(context, uiStatus.data as int);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    fetchApisForLeaderBoard(DateTime.now().year, DateTime.now().month,
        _currentUser!.id!, _leaderboardCubit.navBarItemSelectedValue!);
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
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'leaderboard'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    FlavorCubit flavorCubit = context.read<FlavorCubit>();
    return Container(
        decoration: BoxDecoration(
          color: context.theme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimens.radius_16),
            topRight: Radius.circular(Dimens.radius_16),
          ),
        ),
        child: StreamBuilder<UIStatus>(
            stream: _leaderboardCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
                return AppCircularProgressIndicator();
              } else {
                return InternetSensitive(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildNavbarList(),
                        buildMonthYearDate(),
                        HDivider(),
                        DateTime.now().day > dayFour ||
                                StringUtils.getMonthAndYear() !=
                                    _leaderboardCubit.getMonthValue ||
                                flavorCubit.flavorConfig.appFlavor ==
                                    AppFlavor.staging
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    Dimens.padding_16,
                                    Dimens.padding_16,
                                    Dimens.padding_16,
                                    Dimens.padding_16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildEndInDaysLabel(),
                                    const SizedBox(
                                      height: Dimens.margin_8,
                                    ),
                                    buildCommonTextStyle(getSelectedText(
                                            _leaderboardCubit
                                                .navBarItemSelectedValue!)[
                                        Constants.selectedNavItemText]),
                                    const SizedBox(
                                      height: Dimens.margin_16,
                                    ),
                                    topEarnerList(),
                                    const SizedBox(
                                      height: Dimens.margin_8,
                                    ),
                                    StreamBuilder<UserEarningResponse>(
                                        stream:
                                            _leaderboardCubit.userEarningStream,
                                        builder: (context, userEarning) {
                                          if (userEarning.hasData) {
                                            return userEarning.data!.data ==
                                                    zero
                                                ? NotYetStartedWidget(_leaderboardCubit.navBarItemSelectedValue!)
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      (int.parse(StringUtils
                                                                          .getNoOfDaysLeftInMonth()!) ==
                                                                      zero &&
                                                                  userEarning
                                                                          .data!
                                                                          .performance ==
                                                                      Constants
                                                                          .excellent) ||
                                                              (userEarning.data!
                                                                          .performance ==
                                                                      Constants
                                                                          .excellent &&
                                                                  StringUtils
                                                                          .getMonthAndYear() !=
                                                                      _leaderboardCubit
                                                                          .getMonthValue)
                                                          ? buildTopFiveEarningCard(
                                                              userEarning.data!)
                                                          : buildPerformanceCard(
                                                              userEarning
                                                                  .data!),
                                                      const SizedBox(
                                                        height: Dimens.margin_8,
                                                      ),
                                                      buildTipsToImproveText(
                                                          userEarning.data!),
                                                      const SizedBox(
                                                        height: Dimens.margin_8,
                                                      ),
                                                      buildTipsToImproveCard(
                                                          userEarning.data!),
                                                      const SizedBox(
                                                        height: Dimens.margin_8,
                                                      ),
                                                      buildCertificateAwardedText(
                                                          userEarning.data!),
                                                      const SizedBox(
                                                        height: Dimens.margin_8,
                                                      ),
                                                      if (((userEarning.data!
                                                                          .performance ==
                                                                      Constants
                                                                          .good ||
                                                                  userEarning
                                                                          .data!
                                                                          .performance ==
                                                                      Constants
                                                                          .excellent) &&
                                                              int.parse(StringUtils
                                                                      .getNoOfDaysLeftInMonth()!) <=
                                                                  1) ||
                                                          ((userEarning.data!
                                                                          .performance ==
                                                                      Constants
                                                                          .good ||
                                                                  userEarning
                                                                          .data!
                                                                          .performance ==
                                                                      Constants
                                                                          .excellent) &&
                                                              StringUtils
                                                                      .getMonthAndYear() !=
                                                                  _leaderboardCubit
                                                                      .getMonthValue)) ...[
                                                        buildCertificateCard(
                                                            userEarning.data!)
                                                      ] else ...[
                                                        buildKeepUpTheGoodWorkCard()
                                                      ]
                                                    ],
                                                  );
                                          } else {
                                            return AppCircularProgressIndicator();
                                          }
                                        }),
                                  ],
                                ),
                              )
                            : const ComeBackLateWidget(),
                      ],
                    ),
                  ),
                );
              }
            }));
  }

  Widget buildNavbarList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_24,
          Dimens.padding_16, Dimens.padding_16),
      decoration: const BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: SizedBox(
        height: Dimens.margin_40,
        child: StreamBuilder<List<NavBarData>>(
            stream: _leaderboardCubit.navBarDataListStream,
            builder: (context, navBarDataList) {
              if (navBarDataList.hasData) {
                return ListView.builder(
                    itemCount: navBarDataList.data!.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return NavBarTile(
                        index: index,
                        navBarData: navBarDataList.data![index],
                        onNavBarTapped: _onNavBarTapped,
                      );
                    });
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildEndInDaysLabel() {
    return Visibility(
      visible: StringUtils.getNoOfDaysLeftInMonth() != "0" &&
          StringUtils.getMonthAndYear() == _leaderboardCubit.getMonthValue,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.warning200,
              borderRadius: BorderRadius.circular(Dimens.padding_4),
              border: Border.all(
                color: AppColors.warning300,
                width: 1,
              )),
          padding: const EdgeInsets.fromLTRB(Dimens.margin_8, Dimens.margin_8,
              Dimens.margin_8, Dimens.margin_8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/clock.svg',
                color: AppColors.backgroundGrey800,
                height: Dimens.margin_16,
              ),
              const SizedBox(
                width: Dimens.padding_4,
              ),
              Text('End in ${StringUtils.getNoOfDaysLeftInMonth()} days',
                  style: context.textTheme.bodyText1?.copyWith(
                      color: AppColors.backgroundBlack,
                      fontSize: Dimens.padding_12,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPerformanceCard(UserEarningResponse userEarningResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCommonTextStyle('your_performance'.tr),
        const SizedBox(
          height: Dimens.margin_8,
        ),
        PerformanceWidget(
          userEarning: userEarningResponse,
          date: _leaderboardCubit.getMonthValue!,
          selectedNavItem: _leaderboardCubit.navBarItemSelectedValue!,
        ),
      ],
    );
  }

  Widget buildTopFiveEarningCard(UserEarningResponse userEarningResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCommonTextStyle('your_Earnings'.tr),
        const SizedBox(
          height: Dimens.margin_8,
        ),
        UserEarningsWidget(
          userEarning: userEarningResponse,
        ),
      ],
    );
  }

  Widget buildTipsToImproveText(UserEarningResponse userEarningResponse) {
    return Visibility(
        visible: userEarningResponse.performance == Constants.poor ||
            userEarningResponse.performance == Constants.average,
        child: buildCommonTextStyle('tips_to_improve'.tr));
  }

  Widget buildTipsToImproveCard(UserEarningResponse userEarningResponse) {
    return Visibility(
        visible: userEarningResponse.performance == Constants.poor ||
            userEarningResponse.performance == Constants.average,
        child: TipsToImproveWidget(
          userEarning: userEarningResponse,
          selectedNavItem: _leaderboardCubit.navBarItemSelectedValue!,
        ));
  }

  Widget buildCertificateAwardedText(UserEarningResponse userEarningResponse) {
    return Visibility(
      visible: userEarningResponse.performance == Constants.good ||
          userEarningResponse.performance == Constants.excellent,
      child: buildCommonTextStyle('certificate_awarded'.tr),
    );
  }

  Widget buildCertificateCard(UserEarningResponse userEarningResponse) {
    return StreamBuilder<UserCertificateResponse>(
        stream: _leaderboardCubit.userCertificateStream,
        builder: (context, userCertificate) {
          if (userCertificate.hasData) {
            return CertificateWidget(
              userEarningResponse,
              _leaderboardCubit.navBarItemSelectedValue!,
              () {
                showCertificationBottomSheet(context, userCertificate.data!,
                    userEarningResponse.rank ?? 0);
              },
              userCertificate: userCertificate.data!,
              blankPdf: '',
            );
          } else {
            return const BlankCertificate();
          }
        });
  }

  Widget buildKeepUpTheGoodWorkCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimens.padding_16),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.padding_4),
            child: Image.asset(
              'assets/images/good.png',
            ),
          ),
          title: Text(
            'keep_up_the_good_work'.tr,
            style: Get.context?.textTheme.titleMedium?.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w600,
                fontSize: Dimens.margin_16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: Dimens.margin_8),
            child: Text(
              'you_can_view_share'.tr,
              style: Get.context?.textTheme.titleLarge?.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontSize: Dimens.padding_14,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMonthYearDate() {
    return StreamBuilder<String?>(
        stream: _leaderboardCubit.getMonthStream,
        builder: (context, snapshot) {
          return Container(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_20, Dimens.padding_16, Dimens.padding_8),
            color: AppColors.backgroundWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyInkWell(
                    onTap: () {
                      snapshot.data == selectedMonth
                          ? null
                          : _leaderboardCubit.getPreviousMonth(
                              _leaderboardCubit.getMonthValue!);
                    },
                    child: buildBackAndNext(
                        Icons.arrow_back_ios,
                        snapshot.data == selectedMonth
                            ? AppColors.backgroundGrey500
                            : AppColors.primaryMain)),
                buildCalendar(),
                MyInkWell(
                    onTap: () {
                      snapshot.data == StringUtils.getMonthAndYear()
                          ? null
                          : _leaderboardCubit
                              .getNextMonth(_leaderboardCubit.getMonthValue!);
                    },
                    child: buildBackAndNext(
                        Icons.arrow_forward_ios,
                        snapshot.data == StringUtils.getMonthAndYear()
                            ? AppColors.backgroundGrey500
                            : AppColors.primaryMain))
              ],
            ),
          );
        });
  }

  Widget buildBackAndNext(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: Dimens.radius_12,
      child: Padding(
        padding: const EdgeInsets.only(left: Dimens.padding_4),
        child: Icon(
          icon,
          color: AppColors.backgroundWhite,
          size: Dimens.padding_16,
        ),
      ),
    );
  }

  Widget buildCalendar() {
    return MyInkWell(
      onTap: () {
        showMonthPicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year, 1),
                lastDate: DateTime(DateTime.now().year, DateTime.now().month))
            .then((date) {
          if (date != null) {
            String formattedDate =
                DateFormat(StringUtils.dateFormatMY).format(date);
            fetchApisForLeaderBoard(date.year, date.month, _currentUser!.id,
                _leaderboardCubit.navBarItemSelectedValue!);
            _leaderboardCubit.changeGetMonth(formattedDate);
          }
        });
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.margin_16, 0, Dimens.margin_8, 0),
            child: SvgPicture.asset(
              'assets/images/calendar.svg',
              color: AppColors.backgroundGrey900,
            ),
          ),
          StreamBuilder<String?>(
              stream: _leaderboardCubit.getMonthStream,
              builder: (context, snapshot) {
                return Text('${snapshot.data}',
                    style: context.textTheme.bodyLarge?.copyWith(
                        color: AppColors.backgroundGrey900,
                        fontSize: Dimens.padding_16,
                        fontWeight: FontWeight.w600));
              }),
        ],
      ),
    );
  }

  Widget topEarnerList() {
    return SizedBox(
      height: Dimens.margin_120,
      child: StreamBuilder<EarningResponse>(
          stream: _leaderboardCubit.userEarningResponseResponseStream,
          builder: (context, userEarningResponse) {
            if (userEarningResponse.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 0),
                scrollDirection: Axis.horizontal,
                itemCount: userEarningResponse.data?.userData?.length,
                itemBuilder: (_, i) {
                  return TopEarnerTile(
                    topEarner: userEarningResponse.data!,
                    index: i,
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }

  Widget buildCommonTextStyle(String name) {
    return Text(
      name,
      style: Get.context?.textTheme.titleMedium?.copyWith(
          color: AppColors.backgroundBlack,
          fontWeight: FontWeight.w600,
          fontSize: Dimens.margin_16),
    );
  }

  void fetchApisForLeaderBoard(int year, int month, int? id, String item) {
    _leaderboardCubit.getTopEarnerList("$year", "$month", item);
    _leaderboardCubit.getUserEarning(year, month, id, item);
    if(month != DateTime.now().month)
      {
        _leaderboardCubit.getUserCertificate(year, month, id, item);
      }
    if (item == Constants.earning) {
      CaptureEventHelper.captureEvent(
          loggingData: LoggingData(
              event: LoggingEvents.leaderboardEarningsPageOpened,
              pageName: "Leaderboard",
              sectionName: "Profile",
              otherProperty: {"monthID":month.toString(), "yearID": year.toString()})
      );
    } else if (item == Constants.taskCompleted) {
      CaptureEventHelper.captureEvent(
          loggingData: LoggingData(
              event: LoggingEvents.leaderboardTasksCompletedPageOpened,
              pageName: "Leaderboard",
              sectionName: "Profile",
              otherProperty: {"monthID":month.toString(), "yearID": year.toString()})
      );
    }
  }

  Map<String, dynamic> getSelectedText(String selectedNavItem) {
    switch (selectedNavItem) {
      case Constants.earning:
        return {
          Constants.selectedNavItemText: 'top_earner'.tr,
        };
      case Constants.jobOnboarded:
        return {
          Constants.selectedNavItemText: 'top_onboarding_user'.tr,
        };
      case Constants.taskCompleted:
        return {
          Constants.selectedNavItemText: 'top_most_task'.tr,
        };
      default:
        return {"": ""};
    }
  }

  void _onNavBarTapped(int index, NavBarData navBarData) {
    _leaderboardCubit.updateNavBar(index, navBarData);
    navBarData.navBarItem == "Earnings"
        ? _leaderboardCubit.changeNavBarItemSelected(Constants.earning)
        : (navBarData.navBarItem == "Jobs onboarded"
            ? _leaderboardCubit.changeNavBarItemSelected(Constants.jobOnboarded)
            : _leaderboardCubit
                .changeNavBarItemSelected(Constants.taskCompleted));
    DateTime date = DateFormat(StringUtils.dateFormatMY)
        .parse(_leaderboardCubit.getMonthValue!);
    fetchApisForLeaderBoard(date.year, date.month, _currentUser!.id!,
        _leaderboardCubit.navBarItemSelectedValue!);
  }
}
