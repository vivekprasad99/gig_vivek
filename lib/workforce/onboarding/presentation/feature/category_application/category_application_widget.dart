import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/banner/feature/dynamic_banner/widget/banner_widget.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/take_a_tour/tour_keys.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/widget/attendance_punch_in_widget.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_application/tile/category_application_shimmer_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_application/tile/category_application_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/widget/category_questions_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import 'cubit/category_application_cubit.dart';

class CategoryApplicationWidget extends StatefulWidget {
  const CategoryApplicationWidget({Key? key}) : super(key: key);

  @override
  _CategoryApplicationWidgetState createState() =>
      _CategoryApplicationWidgetState();
}

class _CategoryApplicationWidgetState extends State<CategoryApplicationWidget> {
  final CategoryApplicationCubit _categoryApplicationCubit =
      sl<CategoryApplicationCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  UserData? _currentUser;
  late CategoryApplication _categoryApplication;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) async => ShowCaseWidget.of(context).startShowCase([
              TourKeys.tourKeys5,
              TourKeys.tourKeys6,
            ]));
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _categoryApplicationCubit.changeCurrentUser(_currentUser!);
    }
  }

  void subscribeUIStatus() {
    _categoryApplicationCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
    _categoryApplicationCubit.category.listen((category) {
      openCategoryQuestionsWidget(category);
    });
  }

  void openCategoryQuestionsWidget(Category category) async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        CategoryQuestionsWidget(
            category.id ?? -1,
            _categoryApplicationCubit
                .getCategoryQuestions(_currentUser?.userProfile?.userId),
            MRouter.officeWidget),
        MRouter.categoryQuestionsWidget);
    bool? success = map?[Constants.success];
    if (success != null && success) {
      _openCategoryApplicationDetailsWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        return true;
      },
      child: RouteWidget(
        bottomNavigation: true,
        child: AppScaffold(
          backgroundColor: AppColors.primaryMain,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                StreamBuilder<UserData>(
                    stream: _categoryApplicationCubit.currentUser,
                    builder: (context, snapshot) {
                      return DefaultAppBar(
                        isCollapsable: true,
                        isActionVisible: true,
                        title: 'my_jobs'.tr,
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
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UserData>(
            stream: _categoryApplicationCubit.currentUser,
            builder: (context, snapshot) {
              return SingleChildScrollView(
                  child: snapshot.data != null
                      ? buildCategoryApplicationsList()
                      : buildNoJobFound());
            }),
      ),
    );
  }

  Widget buildCategoryApplicationsList() {
    return Column(
      children: [
        const BannerWidget(Constants.officetop),
        AttendancePunchInWidget(memberId: _currentUser?.ihOmsId!,),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_12, Dimens.padding_16, Dimens.padding_16),
          child: PaginationView<CategoryApplication>(
            key: _paginationKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context,
                    CategoryApplication categoryApplication, int index) =>
                CategoryApplicationTile(
              index: index,
              categoryApplication: categoryApplication,
              currentUser: _currentUser!,
              onViewJobsTap: _openCategoryDetailsWidget,
            ),
            paginationViewType: PaginationViewType.listView,
            pageIndex: 1,
            pageFetch: _categoryApplicationCubit.getCategoryApplication,
            onError: (dynamic error) => Center(
              child: DataNotFound(),
            ),
            onEmpty: buildEmptyView(),
            bottomLoader: AppCircularProgressIndicator(),
            initialLoader: ListView(
              padding: const EdgeInsets.only(top: 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                CategoryApplicationShimmerTile(),
                CategoryApplicationShimmerTile(),
                CategoryApplicationShimmerTile(),
                CategoryApplicationShimmerTile(),
                CategoryApplicationShimmerTile(),
                CategoryApplicationShimmerTile(),
                CategoryApplicationShimmerTile(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCategoryDetailsWidget(
      int index, CategoryApplication categoryApplication) async {
    _categoryApplication = categoryApplication;
    if (categoryApplication.status == 'created') {
      _categoryApplicationCubit
          .getCategory(categoryApplication.categoryId ?? -1);
    } else {
      _openCategoryApplicationDetailsWidget();
    }

    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser!);
    properties[CleverTapConstant.categoryId] = categoryApplication.categoryId;
    ClevertapData clevertapData = ClevertapData(
        eventName: ClevertapHelper.viewJobsCategory, properties: properties);
    CaptureEventHelper.captureEvent(clevertapData: clevertapData);
  }

  _openCategoryApplicationDetailsWidget() {
    MRouter.pushNamed(MRouter.categoryApplicationDetailsWidget,
        arguments: _categoryApplication);
  }

  Widget buildEmptyView() {
    return Column(
      children: [
        const SizedBox(height: Dimens.padding_64),
        Image.asset('assets/images/empty_icon.png',
            width: Dimens.imageWidth_150, height: Dimens.imageHeight_150),
        const SizedBox(height: Dimens.padding_16),
        Text('you_have_not_applied_for_any_jobs'.tr,
            style: Get.textTheme.bodyText1SemiBold),
        const SizedBox(height: Dimens.padding_16),
        buildExploreJobsButton(),
      ],
    );
  }

  Widget buildExploreJobsButton() {
    return RaisedRectButton(
      width: Dimens.btnWidth_150,
      text: 'explore_jobs'.tr,
      radius: Dimens.radius_24,
      onPressed: () {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
      },
    );
  }

  Widget buildNoJobFound() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: Dimens.imageHeight_100,
          ),
          Image.asset(
            'assets/images/empty_icon.png',
            height: 200,
          ),
          const SizedBox(height: Dimens.padding_24),
          Text(
            'no_job_found'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: Dimens.padding_12,
          ),
          Text(
            'Job_categories_you_apply_to_will_appear_here'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.backgroundGrey900,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: Dimens.padding_24),
          RaisedRectButton(
            width: Dimens.btnWidth_150,
            text: 'explore_jobs'.tr,
            onPressed: () {
              MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
            },
          )
        ],
      ),
    );
  }
}
