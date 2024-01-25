import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/eligibility_entity_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section_details_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/widget/batches_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/cubit/category_application_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/widget/bottom_sheet/webinar_training_bottom_sheet.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/helper/category_application_action_helper.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/widget/tile/application_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/widget/tile/execution_shimmer_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/widget/tile/execution_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/widget/slots_widget.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/widget/bottom_sheet/eligibility_bottom_sheet/widget/eligibility_bottom_sheet.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../dashboard/data/model/dashboard_widget_argument.dart';

class CategoryApplicationDetailsWidget extends StatefulWidget {
  final CategoryApplication _categoryApplication;

  const CategoryApplicationDetailsWidget(this._categoryApplication, {Key? key})
      : super(key: key);

  @override
  State<CategoryApplicationDetailsWidget> createState() =>
      _CategoryApplicationDetailsWidgetState();
}

class _CategoryApplicationDetailsWidgetState
    extends State<CategoryApplicationDetailsWidget> {
  final CategoryApplicationDetailsCubit _applicationDetailsCubit =
      sl<CategoryApplicationDetailsCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  CategoryApplicationActionHelper categoryApplicationHelper =
      CategoryApplicationActionHelper();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _applicationDetailsCubit.getApplicationAndExecution(
        _currentUser!, widget._categoryApplication, isSkipSaasOrgID);

    String categoryID =
        widget._categoryApplication.categoryId?.toString() ?? '';
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.categoryOfficeOpened,
        otherProperty: {Constants.categoryId: categoryID});
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  void subscribeUIStatus() {
    _applicationDetailsCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            if(_applicationDetailsCubit.workApplicationEntityValue != null) {
              _onApplicationActionTapped(
                _applicationDetailsCubit.workApplicationEntityValue!,
                _applicationDetailsCubit
                        .workApplicationEntityValue?.pendingAction ??
                    ActionData());
            }
            break;
          case Event.selected:
            _applicationDetailsCubit.getApplicationAndExecution(
                _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
            break;
          case Event.none:
            break;
        }
      },
    );
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                isActionVisible: false,
                title: widget._categoryApplication.name ?? ''),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(
          bottom: defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_32
              : 0),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _applicationDetailsCubit.uiStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  (snapshot.data?.isOnScreenLoading ?? false)) {
                return ListView(
                  padding: const EdgeInsets.only(top: 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimens.margin_16,
                          Dimens.margin_16, Dimens.margin_16, 0),
                      child: ShimmerWidget.rectangular(
                          width: Dimens.margin_80, height: Dimens.padding_16),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimens.margin_16,
                          Dimens.padding_8, Dimens.margin_16, 0),
                      child: ShimmerWidget.rectangular(
                          width: Dimens.margin_120, height: Dimens.padding_16),
                    ),
                    ExecutionShimmerTile(),
                    ExecutionShimmerTile(),
                    ExecutionShimmerTile(),
                    ExecutionShimmerTile(),
                    ExecutionShimmerTile(),
                    ExecutionShimmerTile(),
                    ExecutionShimmerTile(),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, Dimens.padding_16, 0, Dimens.padding_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildExecutionList(),
                        buildApplicationList(),
                      ],
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildExecutionList() {
    return StreamBuilder<List<Execution>>(
      stream: _applicationDetailsCubit.executionListStream,
      builder: (context, executionList) {
        if (executionList.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildExecutionTitleText(),
              buildExecutionSubTitleText(),
              (executionList.data?.isNotEmpty == true)
                  ? ListView.builder(
                      itemCount: executionList.data?.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 0),
                      itemBuilder: (_, i) {
                        return ExecutionTile(
                          index: i,
                          execution: executionList.data![i],
                          onViewExecutionTap: _onViewExecutionTap,
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16),
                      child: Container(
                        height: Dimens.btnWidth_200,
                        decoration: BoxDecoration(
                            color: AppColors.secondary2200,
                            borderRadius:
                                BorderRadius.circular(Dimens.radius_8),
                            border: Border.all(
                                width: Dimens.border_1_5,
                                color: AppColors.link200)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('no_job_started'.tr),
                          ],
                        ),
                      ),
                    ),
            ],
          );
        } else {
          return ListView(
            padding: const EdgeInsets.only(top: 0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.margin_16, 0, Dimens.margin_16, 0),
                child: ShimmerWidget.rectangular(
                    width: Dimens.margin_80, height: Dimens.padding_16),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
                child: ShimmerWidget.rectangular(
                    width: Dimens.margin_120, height: Dimens.padding_16),
              ),
              ExecutionShimmerTile(),
              ExecutionShimmerTile(),
              ExecutionShimmerTile(),
              ExecutionShimmerTile(),
              ExecutionShimmerTile(),
              ExecutionShimmerTile(),
              ExecutionShimmerTile(),
            ],
          );
        }
      },
    );
  }

  Widget buildExecutionTitleText() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.margin_16, 0, Dimens.margin_16, 0),
      child: Text('my_jobs'.tr, style: context.textTheme.bodyText1SemiBold),
    );
  }

  Widget buildExecutionSubTitleText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
      child: Text(
        'start_working_on_your_jobs'.tr,
        style: context.textTheme.bodyText2
            ?.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }

  _onViewExecutionTap(
      int index, Execution execution, String projectRole) async {
    Map<String, dynamic> properties =
        await getEventProperty(execution, projectRole);
    ClevertapData clevertapData = ClevertapData(
        eventName: ClevertapHelper.projectApened, properties: properties);
    CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    if (execution.status == ExecutionStatus.approved) {
      execution.selectedProjectRole = projectRole;
      MRouter.pushNamed(MRouter.offerLetterWidget, arguments: execution);
    } else {
      execution.selectedProjectRole = projectRole;
      DashboardWidgetArgument dashboardWidgetArgument = DashboardWidgetArgument(execution: execution);
      MRouter.pushNamed(MRouter.dashboardWidget, arguments: dashboardWidgetArgument);
    }
  }

  Widget buildApplicationList() {
    return StreamBuilder<List<WorkApplicationEntity>>(
      stream: _applicationDetailsCubit.applicationListStream,
      builder: (context, applicationList) {
        if (applicationList.hasData &&
            applicationList.data?.isNotEmpty == true) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildApplicationTitleText(),
              buildApplicationSubTitleText(),
              ListView.builder(
                itemCount: applicationList.data?.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 0),
                itemBuilder: (_, i) {
                  return ApplicationTile(
                    index: i,
                    workApplicationEntity: applicationList.data![i],
                    currentUser: _currentUser,
                    onApplicationAction: _onApplicationActionTapped,
                    onViewDetailsTap: _onViewDetailsTapped,
                    onCheckEligibilityTap: _onCheckEligibilityTap,
                  );
                },
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildApplicationTitleText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_24, Dimens.margin_16, 0),
      child:
          Text('pending_jobs'.tr, style: context.textTheme.bodyText1SemiBold),
    );
  }

  Widget buildApplicationSubTitleText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.padding_8, Dimens.margin_16, 0),
      child: Text(
        'complete_pending_steps_to_start_working_on_below_jobs'.tr,
        style: context.textTheme.bodyText2
            ?.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }

  _onApplicationActionTapped(
      WorkApplicationEntity workApplicationEntity, ActionData pendingAction) {
    workApplicationEntity.fromRoute = MRouter.categoryApplicationDetailsWidget;
    categoryApplicationHelper.onApplicationActionTapped(
        context,
        workApplicationEntity,
        pendingAction,
        _currentUser,
            (UserData? currentUser, WorkApplicationEntity workApplicationEntity) {
      executionApplicationEvent(currentUser, workApplicationEntity);
    }, _doRefresh);
  }

  _doRefresh() {
    _applicationDetailsCubit.getApplicationAndExecution(
        _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
  }

  void executionApplicationEvent(
      UserData? currentUser, WorkApplicationEntity workApplicationEntity) {
    _applicationDetailsCubit.executeApplicationEvent(
        currentUser!.id!,
        workApplicationEntity.workListingId!,
        workApplicationEntity.id!,
        workApplicationEntity.pendingAction!.actionKey!);
  }

  _onViewDetailsTapped(WorkApplicationEntity application) async {
    LoggingData loggingData = LoggingData(
        action: LoggingActions.applicationDetailsClicked,
        pageName: LoggingPageNames.pendingJobs,
        sectionName: LoggingSectionNames.office);
    CaptureEventHelper.captureEvent(loggingData: loggingData);

    await MRouter.pushNamed(MRouter.workListingDetailsWidget,
        arguments: WorkListingDetailsArguments(
            application.workListingId?.toString() ?? '-1'));
    _applicationDetailsCubit.getApplicationAndExecution(
        _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
  }

  void openApplicationSectionDetailsWidget(
      WorkApplicationEntity workApplicationEntity) async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        ApplicationSectionDetailsWidget(workApplicationEntity),
        MRouter.applicationSectionDetailsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _applicationDetailsCubit.getApplicationAndExecution(
          _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
    }
  }

  void openSlotsWidget(WorkApplicationEntity workApplicationEntity,
      ActionData actionData) async {
    workApplicationEntity.fromRoute = MRouter.categoryApplicationDetailsWidget;
    Map? map = await MRouter.pushNamedWithResult(
        context, SlotsWidget(workApplicationEntity), MRouter.slotsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _applicationDetailsCubit.getApplicationAndExecution(
          _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
    }
  }

  void openBatchesWidget(WorkApplicationEntity workApplicationEntity,
      ActionData actionData) async {
    workApplicationEntity.fromRoute = MRouter.categoryApplicationDetailsWidget;
    Map? map = await MRouter.pushNamedWithResult(
        context, BatchesWidget(workApplicationEntity), MRouter.batchesWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _applicationDetailsCubit.getApplicationAndExecution(
          _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
    }
  }

  _onCheckEligibilityTap(
      int? categoryApplicationId, int? workListingId, int? categoryId) async {
     await eligibilityBottomSheet(
        Get.context!, categoryApplicationId, workListingId, categoryId, (List<ApplicationAnswers>? applicationAnswers,int? categoryId) async {
      EligiblityData eligiblityData = EligiblityData(
          applicationAnswers: applicationAnswers,
          categoryId: categoryId);
      MRouter.pop(null);
    bool? value = await MRouter.pushNamed(MRouter.applicationResultWidget,
          arguments: eligiblityData);
    if(value ?? false)
      {
        _applicationDetailsCubit.getApplicationAndExecution(
            _currentUser!, widget._categoryApplication, isSkipSaasOrgID);
      }
    });
  }

  Future<Map<String, dynamic>> getEventProperty(
      Execution execution, String projectRole) async {
    Map<String, dynamic> eventProperty = {};
    eventProperty[CleverTapConstant.projectName] = execution.projectName;
    eventProperty[CleverTapConstant.projectId] = execution.projectId;
    eventProperty[CleverTapConstant.roleName] =
        projectRole.replaceAll('_', ' ');
    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser);
    eventProperty.addAll(properties);
    return eventProperty;
  }
}
