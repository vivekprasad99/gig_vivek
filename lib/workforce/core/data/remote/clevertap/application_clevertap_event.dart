import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';

class ApplicationClevertapEvent {
  static addApplicationClevertapEvents(
      ApplicationAction? applicationAction,
      WorkApplicationEntity? workApplicationEntity,
      UserData? currentUser) async {
    Map<String, dynamic> listingProperty = {};
    listingProperty[CleverTapConstant.listingName] =
        workApplicationEntity?.workListingTitle;
    listingProperty[CleverTapConstant.listingType] =
        workApplicationEntity?.workListingType;
    listingProperty[CleverTapConstant.listingId] =
        workApplicationEntity?.workListingId;
    listingProperty[CleverTapConstant.listingVertical] =
        workApplicationEntity?.projectVertical;
    listingProperty[CleverTapConstant.listingLocation] =
        workApplicationEntity?.worklisting?.location;
    Map<String, dynamic> userProperties =
        await UserProperty.getUserProperty(currentUser);
    listingProperty.addAll(userProperties);

    switch (applicationAction) {
      case ApplicationAction.startInAppInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.startInAppInterview, listingProperty);
        break;
      case ApplicationAction.redoInAppInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.retakeInAppInterview, listingProperty);
        break;
      case ApplicationAction.completeInAppInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.resumeInAppInterview, listingProperty);
        break;

      case ApplicationAction.startInAppTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.startInAppTraining, listingProperty);
        break;
      case ApplicationAction.redoInAppTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.retakeInAppTraining, listingProperty);
        break;
      case ApplicationAction.completeInAppTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.resumeInAppTraining, listingProperty);
        break;

      case ApplicationAction.startPitchTest:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.startPitchTest, listingProperty);
        break;
      case ApplicationAction.redoPitchTest:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.retakePitchTest, listingProperty);
        break;
      case ApplicationAction.completePitchTest:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.resumePitchTest, listingProperty);
        break;

      case ApplicationAction.scheduleTelephonicInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.scheduleTelephonicInterview, listingProperty);
        break;
      case ApplicationAction.reScheduleTelephonicInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.rescheduleTelephonicInterview, listingProperty);
        break;

      case ApplicationAction.scheduleWebinarTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.scheduleWebinarTraining, listingProperty);
        break;
      case ApplicationAction.reScheduleWebinarTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.rescheduleWebinarTraining, listingProperty);
        break;

      case ApplicationAction.schedulePitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.schedulePitchDemo, listingProperty);
        break;
      case ApplicationAction.reSchedulePitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.reschedulePitchDemo, listingProperty);
        break;

      case ApplicationAction.startPitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.startAutomatedPitchDemo, listingProperty);
        break;
      case ApplicationAction.completePitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.resumeAutomatedPitchDemo, listingProperty);
        break;
      case ApplicationAction.redoPitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.retakeAutomatedPitchDemo, listingProperty);
        break;

      // case ApplicationAction.completeSampleLeadTest:
      //   ClevertapHelper.instance().addApplicationsEvent(
      //       ClevertapHelper.completeSampleLead, listingProperty);
      //   break;
      // case ApplicationAction.startSampleLeadTest:
      //   ClevertapHelper.instance().addApplicationsEvent(
      //       ClevertapHelper.resumeSampleLead, listingProperty);
      //   break;

      // case ApplicationAction.approveToWork:
      //   ClevertapHelper.instance().addApplicationsEvent(
      //       ClevertapHelper.goToOfficeCta, listingProperty);
      //   break;
    }
  }

  static addClevertapActionEvents(
      String? clevertapActionType,
      WorkApplicationEntity? workApplicationEntity,
      UserData? currentUser) async {
    Map<String, dynamic> listingProperty = {};
    listingProperty[CleverTapConstant.listingName] =
        workApplicationEntity?.workListingTitle;
    listingProperty[CleverTapConstant.listingType] =
        workApplicationEntity?.workListingType;
    listingProperty[CleverTapConstant.listingId] =
        workApplicationEntity?.workListingId;
    listingProperty[CleverTapConstant.listingVertical] =
        workApplicationEntity?.projectVertical;
    listingProperty[CleverTapConstant.listingLocation] =
        workApplicationEntity?.worklisting?.location;
    Map<String, dynamic> userProperties =
        await UserProperty.getUserProperty(currentUser);
    listingProperty.addAll(userProperties);

    switch (clevertapActionType) {
      case ClevertapHelper.confirmSlotPitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.confirmSlotPitchDemo, listingProperty);
        break;
      case ClevertapHelper.changeBatchPitchDemo:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.changeBatchPitchDemo, listingProperty);
        break;

      case ClevertapHelper.confirmSlotTelephonicInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.confirmSlotTelephonicInterview, listingProperty);
        break;
      case ClevertapHelper.changeSlotTelephonicInterview:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.changeSlotTelephonicInterview, listingProperty);
        break;

      case ClevertapHelper.confirmBatchWebinarTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.confirmBatchWebinarTraining, listingProperty);
        break;
      case ClevertapHelper.changeBatchWebinarRraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.changeBatchWebinarRraining, listingProperty);
        break;
      // case ClevertapHelper.joinTraining:
      //   ClevertapHelper.instance().addApplicationsEvent(
      //       ClevertapHelper.joinTraining, listingProperty);
      //   break;
      case ClevertapHelper.unableToJoinTraining:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.unableToJoinTraining, listingProperty);
        break;
    }
  }

  static addApplicationStatusClevertapEvents(
      ApplicationStatus? applicationStatus,
      WorkApplicationEntity? workApplicationEntity,
      UserData? currentUser) async {
    Map<String, dynamic> listingProperty = {};
    listingProperty[CleverTapConstant.listingName] =
        workApplicationEntity?.workListingTitle;
    listingProperty[CleverTapConstant.listingType] =
        workApplicationEntity?.workListingType;
    listingProperty[CleverTapConstant.listingId] =
        workApplicationEntity?.workListingId;
    listingProperty[CleverTapConstant.listingVertical] =
        workApplicationEntity?.projectVertical;
    listingProperty[CleverTapConstant.listingLocation] =
        workApplicationEntity?.worklisting?.location;
    Map<String, dynamic> userProperties =
        await UserProperty.getUserProperty(currentUser);
    listingProperty.addAll(userProperties);

    switch (applicationStatus) {
      case ApplicationStatus.inAppInterviewSelected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.passedInAppInterview, listingProperty);
        break;
      case ApplicationStatus.inAppInterviewRejected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.failedInAppInterview, listingProperty);
        break;

      case ApplicationStatus.inAppTrainingSelected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.passedInAppTraining, listingProperty);
        break;
      case ApplicationStatus.inAppTrainingRejected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.failedInAppTraining, listingProperty);
        break;

      case ApplicationStatus.pitchTestSelected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.passedInAppPitchTest, listingProperty);
        break;
      case ApplicationStatus.pitchTestRejected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.failedInAppPitchTest, listingProperty);
        break;

      case ApplicationStatus.telephonicInterviewSelected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.passedTelephonicInterview, listingProperty);
        break;
      case ApplicationStatus.telephonicInterviewRejected:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.failedTelephonicInterview, listingProperty);
        break;

      case ApplicationStatus.webinarTrainingCompleted:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.completedWebinarTraining, listingProperty);
        break;

      case ApplicationStatus.manualPitchDemoCompleted:
        ClevertapHelper.instance().addApplicationsEvent(
            ClevertapHelper.completedPitchDemo, listingProperty);
        break;
    }
  }
}
