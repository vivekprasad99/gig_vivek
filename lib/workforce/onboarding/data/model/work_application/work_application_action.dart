import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';

class ActionType<String> extends Enum1<String> {
  const ActionType(String val) : super(val);

  static const ActionType navigation = ActionType('navigation');
  static const ActionType networkAction = ActionType('networkAction');

  static ActionType? getStatus(dynamic status) {
    switch (status) {
      case 'navigation':
        return ActionType.navigation;
      case 'networkAction':
        return ActionType.networkAction;
    }
    return null;
  }
}

class ApplicationAction<T1, T2, T3> extends Enum3<String, ActionType, dynamic> {
  const ApplicationAction(String val1, ActionType val2, dynamic val3)
      : super(val1, val2, val3);

  static const ApplicationAction startInAppInterview = ApplicationAction(
      'Start In App Interview', ActionType.networkAction, null);
  static const ApplicationAction redoInAppInterview = ApplicationAction(
      'Redo In App Interview', ActionType.networkAction, null);
  static const ApplicationAction completeInAppInterview = ApplicationAction(
      'Complete In App Interview', ActionType.navigation, null);

  static const ApplicationAction scheduleTelephonicInterview =
      ApplicationAction(
          'Schedule Telephonic Interview', ActionType.navigation, null);
  static const ApplicationAction reScheduleTelephonicInterview =
      ApplicationAction(
          'Re-Schedule Telephonic Interview', ActionType.navigation, null);
  static const ApplicationAction reTakeTelephonicInterview = ApplicationAction(
      'Retake Telephonic Interview', ActionType.networkAction, null);
  static const ApplicationAction telephonicInterviewAskConfirmation =
      ApplicationAction(
          'Telephonic Interview Ask Confirmation', ActionType.navigation, null);
  static const ApplicationAction telephonicInterviewSupplyConfirm =
      ApplicationAction('Telephonic Interview Supply Confirm',
          ActionType.networkAction, null);
  static const ApplicationAction
      telephonicInterviewSupplyConfirmWithNavigation = ApplicationAction(
          'Telephonic Interview Supply Confirm', ActionType.navigation, null);
  static const ApplicationAction telephonicInterviewSupplyUnConfirm =
      ApplicationAction('Telephonic Interview Supply Un-Confirm',
          ActionType.networkAction, null);
  static const ApplicationAction
      telephonicInterviewSupplyUnConfirmWithNavigation = ApplicationAction(
          'Telephonic Interview Supply Un-Confirm',
          ActionType.navigation,
          null);
  static const ApplicationAction prepareInterview =
      ApplicationAction('Prepare Interview', ActionType.navigation, null);

  static const ApplicationAction scheduleWebinarTraining = ApplicationAction(
      'Schedule Webinar Training', ActionType.navigation, null);
  static const ApplicationAction reScheduleWebinarTraining = ApplicationAction(
      'Re-Schedule Webinar Training', ActionType.navigation, null);
  static const ApplicationAction retakeWebinarTraining = ApplicationAction(
      'Retake Webinar Training', ActionType.networkAction, null);
  static const ApplicationAction webinarTrainingAskConfirmation =
      ApplicationAction(
          'Webinar Training Ask Confirmation', ActionType.navigation, null);
  static const ApplicationAction webinarTrainingSupplyConfirm =
      ApplicationAction(
          'Webinar Training Supply Confirm', ActionType.networkAction, null);
  static const ApplicationAction webinarTrainingSupplyConfirmWithNavigation =
      ApplicationAction(
          'Webinar Training Supply Confirm', ActionType.navigation, null);
  static const ApplicationAction webinarTrainingSupplyUnConfirm =
      ApplicationAction(
          'Webinar Training Supply Un-Confirm', ActionType.networkAction, null);
  static const ApplicationAction webinarTrainingSupplyUnConfirmWithNavigation =
      ApplicationAction(
          'Webinar Training Supply Un-Confirm', ActionType.navigation, null);
  static const ApplicationAction prepareTraining =
      ApplicationAction('Prepare Training', ActionType.navigation, null);
  static const ApplicationAction prepareTrainingNoResource = ApplicationAction(
      'Prepare Training No Resource', ActionType.navigation, null);
  static const ApplicationAction missedTraining =
      ApplicationAction('Mised Training', ActionType.navigation, null);
  static const ApplicationAction joinTraining =
      ApplicationAction('Join Training', ActionType.navigation, null);
  static const ApplicationAction joinTrainingNoResource = ApplicationAction(
      'Join Training No Resource', ActionType.navigation, null);

  static const ApplicationAction startPitchDemo =
      ApplicationAction('Start Pitch Demo', ActionType.networkAction, null);
  static const ApplicationAction redoPitchDemo =
      ApplicationAction('Redo Pitch Demo', ActionType.networkAction, null);
  static const ApplicationAction completePitchDemo =
      ApplicationAction('Complete Pitch Demo', ActionType.navigation, null);
  static const ApplicationAction schedulePitchDemo =
      ApplicationAction('Schedule Pitch Demo', ActionType.navigation, null);
  static const ApplicationAction reSchedulePitchDemo =
      ApplicationAction('Re-Schedule Pitch Demo', ActionType.navigation, null);
  static const ApplicationAction preparePitchDemo =
      ApplicationAction('Prepare Pitch Demo', ActionType.navigation, null);
  static const ApplicationAction pitchDemoAskConfirmation = ApplicationAction(
      'Pitch Demo Ask Confirmation', ActionType.navigation, null);
  static const ApplicationAction pitchDemoSupplyConfirm = ApplicationAction(
      'Pitch Demo Supply Confirm', ActionType.networkAction, null);
  static const ApplicationAction pitchDemoSupplyUnConfirm = ApplicationAction(
      'Pitch Demo Supply Un-Confirm', ActionType.networkAction, null);

  static const ApplicationAction startPitchTest =
      ApplicationAction('Start Pitch Test', ActionType.networkAction, null);
  static const ApplicationAction redoPitchTest =
      ApplicationAction('Redo Pitch Test', ActionType.networkAction, null);
  static const ApplicationAction completePitchTest =
      ApplicationAction('Complete Pitch Test', ActionType.navigation, null);

  static const ApplicationAction startInAppTraining = ApplicationAction(
      'Start In App Training', ActionType.networkAction, null);
  static const ApplicationAction redoInAppTraining =
      ApplicationAction('Redo In App Training', ActionType.networkAction, null);
  static const ApplicationAction completeInAppTraining = ApplicationAction(
      'Complete In App Training', ActionType.navigation, null);

  static const ApplicationAction reApply =
      ApplicationAction('ReApply', ActionType.navigation, null);

  static const ApplicationAction customerSupport =
      ApplicationAction('Contact Support', ActionType.navigation, null);

  @override
  String getValue1() {
    return value1;
  }

  @override
  ActionType getValue2() {
    return value2;
  }

  @override
  dynamic getValue3() {
    return value3;
  }

  bool isApplicationDetailsAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.scheduleTelephonicInterview:
      case ApplicationAction.scheduleWebinarTraining:
      case ApplicationAction.schedulePitchDemo:
        return true;
    }
    return false;
  }

  bool isScheduleSlotAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.reScheduleTelephonicInterview:
      case ApplicationAction.reSchedulePitchDemo:
      case ApplicationAction.schedulePitchDemo:
        return true;
    }
    return false;
  }

  bool isScheduleBatchAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.reScheduleWebinarTraining:
        return true;
    }
    return false;
  }

  bool isWebinarTraining() {
    switch (this as ApplicationAction) {
      case ApplicationAction.scheduleWebinarTraining:
      case ApplicationAction.reScheduleWebinarTraining:
      case ApplicationAction.retakeWebinarTraining:
      case ApplicationAction.webinarTrainingAskConfirmation:
      case ApplicationAction.prepareTraining:
        return true;
    }
    return false;
  }

  bool isWebinarTrainingMissed() {
    switch (this as ApplicationAction) {
      case ApplicationAction.missedTraining:
        return true;
    }
    return false;
  }

  bool isJoinTrainingAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.joinTraining:
      case ApplicationAction.joinTrainingNoResource:
      case ApplicationAction.prepareTrainingNoResource:
        return true;
    }
    return false;
  }

  bool isResourceAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.prepareInterview:
      case ApplicationAction.prepareTraining:
      case ApplicationAction.preparePitchDemo:
        return true;
    }
    return false;
  }

  bool isOnlineTestAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.startInAppInterview:
      case ApplicationAction.completeInAppInterview:
      case ApplicationAction.startInAppTraining:
      case ApplicationAction.completeInAppTraining:
      case ApplicationAction.startPitchDemo:
      case ApplicationAction.completePitchDemo:
      case ApplicationAction.startPitchTest:
      case ApplicationAction.completePitchTest:
        return true;
    }
    return false;
  }

  bool isInAppInterview() {
    switch (this as ApplicationAction) {
      case ApplicationAction.startInAppInterview:
      case ApplicationAction.completeInAppInterview:
      case ApplicationAction.redoInAppInterview:
        return true;
    }
    return false;
  }

  bool isTelephonicInterview() {
    switch (this as ApplicationAction) {
      case ApplicationAction.scheduleTelephonicInterview:
      case ApplicationAction.reScheduleTelephonicInterview:
      case ApplicationAction.prepareInterview:
      case ApplicationAction.reTakeTelephonicInterview:
      case ApplicationAction.telephonicInterviewAskConfirmation:
        return true;
    }
    return false;
  }

  bool isInAppTraining() {
    switch (this as ApplicationAction) {
      case ApplicationAction.startInAppTraining:
      case ApplicationAction.completeInAppTraining:
      case ApplicationAction.redoInAppTraining:
        return true;
    }
    return false;
  }

  bool isPitchDemo() {
    switch (this as ApplicationAction) {
      case ApplicationAction.schedulePitchDemo:
      case ApplicationAction.reSchedulePitchDemo:
      case ApplicationAction.preparePitchDemo:
      case ApplicationAction.pitchDemoAskConfirmation:
      case ApplicationAction.startPitchDemo:
      case ApplicationAction.completePitchDemo:
      case ApplicationAction.redoPitchDemo:
        return true;
    }
    return false;
  }

  bool isPitchTest() {
    switch (this as ApplicationAction) {
      case ApplicationAction.startPitchTest:
      case ApplicationAction.completePitchTest:
      case ApplicationAction.redoPitchTest:
        return true;
    }
    return false;
  }

  bool isStatusButtonVisible() {
    switch (this as ApplicationAction) {
      case ApplicationAction.scheduleWebinarTraining:
      case ApplicationAction.reScheduleWebinarTraining:
      case ApplicationAction.schedulePitchDemo:
      case ApplicationAction.reSchedulePitchDemo:
      case ApplicationAction.preparePitchDemo:
        return true;
    }
    return false;
  }

  StepType? getOnlineTestStepType() {
    if (isInAppInterview()) {
      return StepType.interview;
    }
    if (isInAppTraining()) {
      return StepType.training;
    }
    if (isPitchDemo()) {
      return StepType.pitchDemo;
    }
    if (isPitchTest()) {
      return StepType.pitchTest;
    } else {
      return null;
    }
  }

  bool isReApply() {
    switch (this as ApplicationAction) {
      case ApplicationAction.reApply:
        return true;
    }
    return false;
  }

  bool isContactSupportAction() {
    switch (this as ApplicationAction) {
      case ApplicationAction.customerSupport:
        return true;
    }
    return false;
  }
}
