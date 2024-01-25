import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/mobile_on_desktop_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/cubit/profile_details_cubit.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/tile/profile_section_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ProfileDetailsWidget extends StatefulWidget {
  const ProfileDetailsWidget({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsWidget> createState() => _ProfileDetailsWidgetState();
}

class _ProfileDetailsWidgetState extends State<ProfileDetailsWidget>
    with TickerProviderStateMixin {
  final _profileDetailsCubit = sl<ProfileDetailsCubit>();
  UserData? _currentUser;
  int tabsLength = 1;
  List<Widget> tabs = [];
  TabController? _tabController;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void subscribeUIStatus() {
    _profileDetailsCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _profileDetailsCubit.getQuestionAnswers(_currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mobileWidget = buildMobileUI();
    return ScreenTypeLayout(
      mobile: mobileWidget,
      desktop: MobileOnDesktopWidget(mobileWidget),
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
            DefaultAppBar(
              title: 'edit_profile'.tr,
              isCollapsable: true,
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
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<QuestionAnswersResponse>(
            stream: _profileDetailsCubit.questionAnswersResponseStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // buildBanner(),
                      // const SizedBox(height: Dimens.padding_24),
                      buildTabBar(),
                      buildProfileCategoryList(snapshot.data!),
                    ],
                  ),
                );
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildBanner() {
    // return SvgPicture.asset('assets/images/ic_profile_details_banner.svg');
    return Image.asset('assets/images/ic_profile_details_banner.png',
        fit: BoxFit.fitWidth);
  }

  Widget buildTabBar() {
    return StreamBuilder<List<SectionDetails>>(
        stream: _profileDetailsCubit.sectionDetailsListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            tabs.clear();
            for (SectionDetails sectionDetails in snapshot.data!) {
              String title = '';
              if (sectionDetails.title != null &&
                  sectionDetails.title!.contains(' ')) {
                title = sectionDetails.title!.split(' ').first;
              } else {
                title = sectionDetails.title ?? '';
              }
              Widget requiredWidget = const SizedBox();
              if (sectionDetails.isRequired) {
                requiredWidget = Text(' *',
                    style: Get.textTheme.caption2Medium
                        .copyWith(color: AppColors.error300));
              }
              tabs.add(Tab(
                // text: title,
                child: Container(
                  padding: const EdgeInsets.only(bottom: Dimens.padding_8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: sectionDetails.isSelected
                            ? AppColors.primaryMain
                            : AppColors.backgroundGrey400,
                        width: Dimens.dividerHeight_1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(title,
                          style: Get.textTheme.bodyText2Medium?.copyWith(
                              color: sectionDetails.isSelected
                                  ? AppColors.primaryMain
                                  : AppColors.backgroundGrey800)),
                      requiredWidget,
                    ],
                  ),
                ),
              ));
            }
            _tabController =
                TabController(length: snapshot.data!.length, vsync: this);
            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  height: Dimens.dividerHeight_1,
                  color: AppColors.backgroundGrey400,
                  margin: const EdgeInsets.only(bottom: Dimens.margin_11),
                ),
                TabBar(
                  onTap: (index) {
                    SectionDetails sectionDetails = snapshot.data![index];
                    _profileDetailsCubit.updateSectionDetailsList(
                        index, sectionDetails);
                    itemScrollController.scrollTo(
                        index: index,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOutCubic);
                  },
                  controller: _tabController,
                  labelColor: AppColors.primaryMain,
                  unselectedLabelColor: AppColors.backgroundGrey800,
                  indicatorColor: AppColors.transparent,
                  indicatorWeight: Dimens.tabIndicatorHeight,
                  indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  labelPadding: const EdgeInsets.fromLTRB(
                      Dimens.padding_8, 0, Dimens.padding_8, 0),
                  isScrollable: snapshot.data!.length > 2 ? true : false,
                  tabs: tabs,
                ),
              ],
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildProfileCategoryList(
      QuestionAnswersResponse questionAnswersResponse) {
    if (!questionAnswersResponse.sectionDetailsQuestionsList.isNullOrEmpty) {
      return Expanded(
        child: ScrollablePositionedList.builder(
          itemCount:
              questionAnswersResponse.sectionDetailsQuestionsList!.length,
          itemBuilder: (context, i) {
            return ProfileSectionTile(
              sectionDetailsQuestions:
                  questionAnswersResponse.sectionDetailsQuestionsList![i],
              onUpdateRequiredAnswer: _onUpdateRequiredAnswer,
            );
          },
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
        ),
      );
    } else {
      return AppCircularProgressIndicator();
    }
  }

  _onUpdateRequiredAnswer(SectionDetailsQuestions sectionDetailsQuestions) {
    _profileDetailsCubit.onUpdateRequiredAnswer(sectionDetailsQuestions);
  }
}
