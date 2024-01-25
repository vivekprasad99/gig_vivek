import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/application_section_details_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/widget/batches_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/cubit/category_application_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/widget/slots_widget.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../../../onboarding/data/model/work_application/work_application_response.dart';
import '../../../../onboarding/data/model/work_application/work_application_section.dart';
import '../widget/bottom_sheet/webinar_training_bottom_sheet.dart';

class CategoryApplicationActionHelper {
  void onApplicationActionTapped(
      BuildContext context,
      WorkApplicationEntity workApplicationEntity,
      ActionData pendingAction,
      UserData? currentUser,
      void Function(UserData?, WorkApplicationEntity) executeApplicationEvent,
      void Function() onRefresh) {
    ClevertapData clevertapData = ClevertapData(
        isApplicationEvent: true,
        applicationAction: pendingAction.actionKey,
        workApplicationEntity: workApplicationEntity,
        currentUser: currentUser);
    CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    switch (pendingAction.actionKey?.getValue2()) {
      case ActionType.networkAction:executeApplicationEvent(currentUser, workApplicationEntity);
        break;
      case ActionType.navigation:
        if ((pendingAction.actionKey?.isWebinarTrainingMissed() ?? false)) {
          openBatchesWidget(context, workApplicationEntity, onRefresh);
        } else if ((pendingAction.actionKey?.isOnlineTestAction() ?? false)) {
          openApplicationSectionDetailsWidget(context, workApplicationEntity, onRefresh);
        } else if ((pendingAction.actionKey?.isApplicationDetailsAction() ?? false)) {
          openApplicationSectionDetailsWidget(context, workApplicationEntity, onRefresh);
        } else if ((pendingAction.actionKey?.isScheduleSlotAction() ?? false)) {
          openSlotsWidget(context, workApplicationEntity, onRefresh);
        } else if ((pendingAction.actionKey?.isScheduleBatchAction() ?? false)) {
          openBatchesWidget(context, workApplicationEntity, onRefresh);
        } else if ((pendingAction.actionKey?.isReApply() ?? false)) {
          onViewDetailsTapped(workApplicationEntity, onRefresh);
        } else if ((pendingAction.actionKey?.isJoinTrainingAction() ?? false)) {
          if (pendingAction.data is TrainingData) {
            sl<CategoryApplicationDetailsCubit>().markAttendance(workApplicationEntity.id!);
            showWebinarTrainingBottomSheet(context, pendingAction.data);
          }
        } else if ((pendingAction.actionKey?.isResourceAction() ?? false)) {
          if (pendingAction.data is int?) {
            MRouter.pushNamed(MRouter.resourceWidget, arguments: pendingAction.data);
          }
        } else {
          // Helper.showInfoToast('Coming soon...');
          MRouter.pushNamed(MRouter.officeWebViewWidget);
        }
        break;
      default:
        MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
        break;
    }
  }

  void openApplicationSectionDetailsWidget(
      BuildContext context,
      WorkApplicationEntity workApplicationEntity,
      void Function() onRefresh) async {
    Map? map = await MRouter.pushNamedWithResult(context,
        ApplicationSectionDetailsWidget(workApplicationEntity), MRouter.applicationSectionDetailsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      onRefresh();
    }
  }

  void openBatchesWidget(
      BuildContext context,
      WorkApplicationEntity workApplicationEntity,
      void Function() onRefresh) async {
    workApplicationEntity.fromRoute = workApplicationEntity.fromRoute ?? MRouter.categoryApplicationDetailsWidget;
    Map? map = await MRouter.pushNamedWithResult(context,
        BatchesWidget(workApplicationEntity), MRouter.batchesWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      onRefresh();
    }
  }

  void onViewDetailsTapped(
      WorkApplicationEntity application,
      void Function() onRefresh) async {
    LoggingData loggingData = LoggingData(
        action: LoggingActions.applicationDetailsClicked,
        pageName: LoggingPageNames.pendingJobs,
        sectionName: LoggingSectionNames.office);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
    await MRouter.pushNamed(MRouter.workListingDetailsWidget,
        arguments: WorkListingDetailsArguments(application.workListingId?.toString() ?? '-1'));
    onRefresh();
  }

  void openSlotsWidget(
      BuildContext context,
      WorkApplicationEntity workApplicationEntity,
      void Function() onRefresh) async {
    workApplicationEntity.fromRoute = workApplicationEntity.fromRoute ?? MRouter.categoryApplicationDetailsWidget;
    Map? map = await MRouter.pushNamedWithResult(context,
        SlotsWidget(workApplicationEntity), MRouter.slotsWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      onRefresh();
    }
  }
}
