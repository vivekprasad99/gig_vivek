import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/webinar_training_bottom_sheet/widget/webinar_training_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/cubit/application_section_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/tile/section_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/widget/batches_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/widget/slots_widget.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ApplicationSectionDetailsWidget extends StatefulWidget {
     WorkApplicationEntity? workApplicationEntity;
    int applicaationID = -1;

    ApplicationSectionDetailsWidget(this.workApplicationEntity, {Key? key})
      : super(key: key);

   ApplicationSectionDetailsWidget.aa(this.applicaationID, {Key? key})
      : super(key: key);

  @override
  State<ApplicationSectionDetailsWidget> createState() =>
      _ApplicationSectionDetailsWidgetState();
}

class _ApplicationSectionDetailsWidgetState
    extends State<ApplicationSectionDetailsWidget> {
  final ApplicationSectionDetailsCubit _applicationSectionDetailsCubit =
      sl<ApplicationSectionDetailsCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;

  @override
  void initState() {
    super.initState();
    if(widget.applicaationID != -1){
    getCurrentUser2(widget.applicaationID);
    }else{
      getCurrentUser();
    }
    subscribeUIStatus();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _applicationSectionDetailsCubit.fetchWorkApplicationForDetailsSection(
        _currentUser!.id!, widget.workApplicationEntity!.id!);
  }

  void getCurrentUser2(int applicationId) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _applicationSectionDetailsCubit.fetchWorkApplicationForDetailsSection(
        _currentUser!.id!, applicationId);
  }

  void subscribeUIStatus() {
    _applicationSectionDetailsCubit.uiStatus.listen(
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
          case Event.scheduled:
            Helper.showInfoToast('slot_scheduled'.tr);
            MRouter.popNamedWithResult(widget.workApplicationEntity?.fromRoute ?? MRouter.categoryApplicationDetailsWidget,
                Constants.doRefresh, true);
            break;
          case Event.batchScheduled:
            Helper.showInfoToast('batch_scheduled'.tr);
            webinarTrainingBottomSheet(Get.context!,(){});
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
    return WillPopScope(
      onWillPop: () async {
        MRouter.popNamedWithResult(widget.workApplicationEntity?.fromRoute ?? MRouter.categoryApplicationDetailsWidget, Constants.doRefresh, true);
        return true;
      },
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        bottomPadding: 0,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              StreamBuilder<UIStatus>(
                  stream: _applicationSectionDetailsCubit.uiStatus,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        !(snapshot.data?.isOnScreenLoading ?? true) &&
                        snapshot.data?.event == Event.success) {
                      String title = 'Application Details';
                      if (snapshot.data?.data != null) {
                        WorkApplicationEntity workApplicationEntity =
                            snapshot.data?.data;
                        if ((workApplicationEntity.pendingAction?.actionKey
                                ?.isInAppInterview() ??
                            false)) {
                          title = 'In-App Interview';
                        } else if ((workApplicationEntity.pendingAction?.actionKey
                                ?.isTelephonicInterview() ??
                            false)) {
                          title = 'Telephonic Interview';
                        } else if ((workApplicationEntity.pendingAction?.actionKey
                                ?.isInAppTraining() ??
                            false)) {
                          title = 'In-App Training';
                        } else if ((workApplicationEntity.pendingAction?.actionKey
                                ?.isWebinarTraining() ??
                            false)) {
                          title = 'Zoom Training';
                        } else if ((workApplicationEntity.pendingAction?.actionKey
                                ?.isPitchDemo() ??
                            false)) {
                          title = 'Pitch Demo';
                        } else if ((workApplicationEntity.pendingAction?.actionKey
                                ?.isPitchTest() ??
                            false)) {
                          title = 'Pitch Test';
                        }
                      }
                      return DefaultAppBar(
                          isCollapsable: true,
                          title: title
                      );
                    } else {
                      return const DefaultAppBar(
                          isCollapsable: true,
                          title: 'Awign'
                      );
                    }
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
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _applicationSectionDetailsCubit.uiStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  !(snapshot.data?.isOnScreenLoading ?? true) &&
                  (snapshot.data?.event == Event.success || snapshot.data?.event == Event.batchScheduled)) {
                WorkApplicationEntity? workApplicationEntity =
                    snapshot.data?.data;
                return Column(
                  children: [
                    buildSectionList(
                        workApplicationEntity?.detailsData?.detailSections,
                        workApplicationEntity),
                    buildActionButton(workApplicationEntity),
                  ],
                );
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildSectionList(List<BaseSection>? detailSections,
      WorkApplicationEntity? workApplicationEntity) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount: detailSections?.length,
        itemBuilder: (_, i) {
          BaseSection baseSection = detailSections![i];
          return SectionTile(
            index: i,
            baseSection: baseSection,
            workApplicationEntity: workApplicationEntity!,
            onApplicationAction: _onApplicationAction,
          );
        },
      ),
    );
  }

  Widget buildActionButton(WorkApplicationEntity? workApplicationEntity) {
    String text = '';
    StepType? stepType = workApplicationEntity?.pendingAction?.actionKey
        ?.getOnlineTestStepType();
    switch (stepType) {
      case StepType.interview:
        text = 'Give Online Interview';
        break;
      case StepType.training:
        text = 'Give Online Training';
        break;
      case StepType.pitchDemo:
        text = 'Give Pitch Demo';
        break;
      case StepType.pitchTest:
        text = 'Give Pitch Test';
        break;
    }
    if (workApplicationEntity?.pendingAction?.actionKey != null) {
      if (workApplicationEntity!.pendingAction!.actionKey!
          .isStatusButtonVisible()) {
        return const SizedBox();
      } else if (!text.isNullOrEmpty) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.margin_16,
              Dimens.margin_40,
              Dimens.margin_16,
              defaultTargetPlatform == TargetPlatform.iOS
                  ? Dimens.margin_32
                  : Dimens.margin_16),
          child: RaisedRectButton(
            text: text,
            onPressed: () {
              workApplicationEntity.fromRoute = widget.workApplicationEntity?.fromRoute;
              MRouter.pushNamed(MRouter.onlineTestWidget, arguments: workApplicationEntity);
            },
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  void _onApplicationAction(
      WorkApplicationEntity workApplicationEntity, ActionData actionData) {
    switch (actionData.actionKey) {
      case ApplicationAction.scheduleTelephonicInterview:
        SlotEntity selectedSlotEntity = actionData.data as SlotEntity;
        _applicationSectionDetailsCubit.scheduleTelephonicInterview(
            _currentUser?.id ?? -1,
            _currentUser?.mobileNumber ?? '',
            widget.workApplicationEntity!,
            selectedSlotEntity);
        break;
      case ApplicationAction.reScheduleTelephonicInterview:
        openSlotsWidget(workApplicationEntity, actionData);
        break;
      case ApplicationAction.scheduleWebinarTraining:
        BatchEntity selectedBatchEntity = actionData.data as BatchEntity;
        _applicationSectionDetailsCubit.scheduleTrainingBatch(
            _currentUser?.id ?? -1,
            widget.workApplicationEntity!,
            selectedBatchEntity);
        break;
      case ApplicationAction.reScheduleWebinarTraining:
        ClevertapData clevertapData = ClevertapData(
            isApplicationActionEvent: true,
            clevertapActionType: ClevertapHelper.changeBatchWebinarRraining,
            workApplicationEntity: workApplicationEntity,
            currentUser: _currentUser);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
        openBatchesWidget(workApplicationEntity, actionData);
        break;
      case ApplicationAction.schedulePitchDemo:
        SlotEntity selectedSlotEntity = actionData.data as SlotEntity;
        _applicationSectionDetailsCubit.schedulePitchDemo(
            _currentUser?.id ?? -1,
            widget.workApplicationEntity!,
            selectedSlotEntity);
        break;
      case ApplicationAction.reSchedulePitchDemo:
        openSlotsWidget(workApplicationEntity, actionData);
        break;
    }
  }

  void openSlotsWidget(WorkApplicationEntity workApplicationEntity,
      ActionData actionData) async {
    workApplicationEntity.fromRoute = MRouter.applicationSectionDetailsWidget;
    Map? map = await MRouter.pushNamedWithResult(
        context, SlotsWidget(workApplicationEntity), MRouter.slotsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _applicationSectionDetailsCubit.fetchWorkApplicationForDetailsSection(
          _currentUser!.id!, widget.workApplicationEntity!.id!);
    }
  }

  void openBatchesWidget(WorkApplicationEntity workApplicationEntity,
      ActionData actionData) async {
    workApplicationEntity.fromRoute = MRouter.applicationSectionDetailsWidget;
    Map? map = await MRouter.pushNamedWithResult(
        context, BatchesWidget(workApplicationEntity), MRouter.batchesWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _applicationSectionDetailsCubit.fetchWorkApplicationForDetailsSection(
          _currentUser!.id!, widget.workApplicationEntity!.id!);
    }
  }
}
