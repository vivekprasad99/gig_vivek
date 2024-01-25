import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/application_history/cubit/application_history_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/application_history/widget/tile/application_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ApplicationHistoryWidget extends StatefulWidget {
  const ApplicationHistoryWidget({Key? key}) : super(key: key);

  @override
  _ApplicationHistoryWidgetState createState() =>
      _ApplicationHistoryWidgetState();
}

class _ApplicationHistoryWidgetState extends State<ApplicationHistoryWidget> {
  final ApplicationHistoryCubit _applicationHistoryCubit =
      sl<ApplicationHistoryCubit>();
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
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _applicationHistoryCubit.changeCurrentUser(_currentUser!);
    }
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                isActionVisible: false,
                title: 'application_history'.tr)
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
        child: Stack(
          children: [
            SingleChildScrollView(child: buildApplicationHistoryList()),
            buildExploreJobsButton(),
          ],
        ),
      ),
    );
  }

  Widget buildExploreJobsButton() {
    return StreamBuilder<UserData>(
        stream: _applicationHistoryCubit.currentUserStream,
        builder: (context, currentUserStream) {
          if ((currentUserStream.data?.permissions?.awign
                  ?.contains(AwignPermissionConstants.jobs) ??
              false)) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimens.margin_24),
                height: Dimens.margin_38,
                margin: const EdgeInsets.fromLTRB(Dimens.margin_4,
                    Dimens.margin_24, Dimens.margin_4, Dimens.margin_4),
                child: RaisedRectButton(
                  text: 'explore_jobs'.tr,
                  onPressed: () async {
                    SPUtil? spUtil = await SPUtil.getInstance();
                    Map<String, dynamic> properties =
                        await UserProperty.getUserProperty(
                            spUtil?.getUserData());
                    ClevertapData clevertapData = ClevertapData(
                        eventName:
                            ClevertapHelper.exploreJobsApplicationHistory,
                        properties: properties);
                    CaptureEventHelper.captureEvent(
                        clevertapData: clevertapData);
                    MRouter.pushNamed(MRouter.categoryListingWidget);
                  },
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildApplicationHistoryList() {
    return PaginationView<WorkApplicationEntity>(
      key: _paginationKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context,
              WorkApplicationEntity workApplicationEntity, int index) =>
          ApplicationHistoryTile(
              index: index,
              currentUser: _currentUser,
              workApplication: workApplicationEntity,
              onReApplyTap: (selectedIndex, selectedCategory) {}),
      paginationViewType: PaginationViewType.listView,
      pageIndex: 1,
      pageFetch: _applicationHistoryCubit.getApplicationHistory,
      onError: (dynamic error) => Center(
        child: buildNoApplicationFound(),
      ),
      onEmpty: buildNoApplicationFound(),
      bottomLoader: AppCircularProgressIndicator(),
      initialLoader: AppCircularProgressIndicator(),
    );
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
          'no_application_found'.tr,
          textAlign: TextAlign.start,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.black,
              fontSize: Dimens.font_18,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
