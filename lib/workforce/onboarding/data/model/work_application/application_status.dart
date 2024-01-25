import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/pitch_demo.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/step_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_pending_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_status.dart';

class ApplicationStatus<String> extends Enum1<String> {
  const ApplicationStatus(String val) : super(val);

  static const ApplicationStatus created = ApplicationStatus('created');
  static const ApplicationStatus waitListed = ApplicationStatus('waitListed');
  static const ApplicationStatus selected = ApplicationStatus('selected');
  static const ApplicationStatus backedOut = ApplicationStatus('backed_out');
  static const ApplicationStatus applied = ApplicationStatus('applied');
  static const ApplicationStatus inAppInterviewPending =
      ApplicationStatus('inAppInterviewPending');
  static const ApplicationStatus inAppInterviewStarted =
      ApplicationStatus('inAppInterviewStarted');
  static const ApplicationStatus inAppInterviewCompleted =
      ApplicationStatus('inAppInterviewCompleted');
  static const ApplicationStatus inAppInterviewSelected =
      ApplicationStatus('inAppInterviewSelected');
  static const ApplicationStatus inAppInterviewRejected =
      ApplicationStatus('inAppInterviewRejected');
  static const ApplicationStatus telephonicInterviewPending =
      ApplicationStatus('telephonicInterviewPending');
  static const ApplicationStatus telephonicInterviewStarted =
      ApplicationStatus('telephonicInterviewStarted');
  static const ApplicationStatus telephonicInterviewScheduled =
      ApplicationStatus('telephonicInterviewScheduled');
  static const ApplicationStatus telephonicInterviewSupplyConfirmationPending =
      ApplicationStatus('telephonicInterviewSupplyConfirmationPending');
  static const ApplicationStatus telephonicInterviewCompleted =
      ApplicationStatus('telephonicInterviewCompleted');
  static const ApplicationStatus telephonicInterviewInComplete =
      ApplicationStatus('telephonicInterviewInComplete');
  static const ApplicationStatus telephonicInterviewSelected =
      ApplicationStatus('telephonicInterviewSelected');
  static const ApplicationStatus telephonicInterviewRejected =
      ApplicationStatus('telephonicInterviewRejected');
  static const ApplicationStatus inAppTrainingPending =
      ApplicationStatus('inAppTrainingPending');
  static const ApplicationStatus inAppTrainingStarted =
      ApplicationStatus('inAppTrainingStarted');
  static const ApplicationStatus inAppTrainingCompleted =
      ApplicationStatus('inAppTrainingCompleted');
  static const ApplicationStatus inAppTrainingSelected =
      ApplicationStatus('inAppTrainingSelected');
  static const ApplicationStatus inAppTrainingRejected =
      ApplicationStatus('inAppTrainingRejected');
  static const ApplicationStatus disqualified =
      ApplicationStatus('disqualified');
  static const ApplicationStatus executionCompleted =
      ApplicationStatus('executionCompleted');
  static const ApplicationStatus executionStarted =
      ApplicationStatus('executionStarted');
  static const ApplicationStatus webinarTrainingPending =
      ApplicationStatus('webinarTrainingPending');
  static const ApplicationStatus webinarTrainingStarted =
      ApplicationStatus('webinarTrainingStarted');
  static const ApplicationStatus webinarTrainingScheduled =
      ApplicationStatus('webinarTrainingScheduled');
  static const ApplicationStatus webinarTrainingSupplyConfirmationPending =
      ApplicationStatus('webinarTrainingSupplyConfirmationPending');
  static const ApplicationStatus webinarTrainingCompleted =
      ApplicationStatus('webinarTrainingCompleted');
  static const ApplicationStatus webinarTrainingInComplete =
      ApplicationStatus('webinarTrainingInComplete');
  static const ApplicationStatus webinarTrainingSelected =
      ApplicationStatus('webinarTrainingSelected');
  static const ApplicationStatus webinarTrainingRejected =
      ApplicationStatus('webinarTrainingRejected');
  static const ApplicationStatus webinarTrainingMissed =
      ApplicationStatus('webinarTrainingMissed');
  static const ApplicationStatus automatedPitchDemoPending =
      ApplicationStatus('automatedPitchDemoPending');
  static const ApplicationStatus automatedPitchDemoStarted =
      ApplicationStatus('automatedPitchDemoStarted');
  static const ApplicationStatus automatedPitchDemoCompleted =
      ApplicationStatus('automatedPitchDemoCompleted');
  static const ApplicationStatus automatedPitchDemoSelected =
      ApplicationStatus('automatedPitchDemoSelected');
  static const ApplicationStatus automatedPitchDemoRejected =
      ApplicationStatus('automatedPitchDemoRejected');
  static const ApplicationStatus manualPitchDemoPending =
      ApplicationStatus('manualPitchDemoPending');
  static const ApplicationStatus manualPitchDemoStarted =
      ApplicationStatus('manualPitchDemoStarted');
  static const ApplicationStatus manualPitchDemoScheduled =
      ApplicationStatus('manualPitchDemoScheduled');
  static const ApplicationStatus manualPitchDemoSupplyConfirmationPending =
      ApplicationStatus('manualPitchDemoSupplyConfirmationPending');
  static const ApplicationStatus manualPitchDemoInComplete =
      ApplicationStatus('manualPitchDemoInComplete');
  static const ApplicationStatus manualPitchDemoCompleted =
      ApplicationStatus('manualPitchDemoCompleted');
  static const ApplicationStatus manualPitchDemoSelected =
      ApplicationStatus('manualPitchDemoSelected');
  static const ApplicationStatus manualPitchDemoRejected =
      ApplicationStatus('manualPitchDemoRejected');
  static const ApplicationStatus pitchTestPending =
      ApplicationStatus('pitchTestPending');
  static const ApplicationStatus pitchTestStarted =
      ApplicationStatus('pitchTestStarted');
  static const ApplicationStatus pitchTestCompleted =
      ApplicationStatus('pitchTestCompleted');
  static const ApplicationStatus pitchTestSelected =
      ApplicationStatus('pitchTestSelected');
  static const ApplicationStatus pitchTestRejected =
      ApplicationStatus('pitchTestRejected');
  static const ApplicationStatus genericSelected =
      ApplicationStatus('genericSelected');
  static const ApplicationStatus genericRejected =
      ApplicationStatus('genericRejected');
  static const ApplicationStatus approvedToWork =
      ApplicationStatus('approved_to_work');
  static const ApplicationStatus customerSupport =
      ApplicationStatus('contactSupport');
  static const ApplicationStatus rejected = ApplicationStatus('rejected');
  static const ApplicationStatus sampleleadtest =
      ApplicationStatus('sampleleadtest');

  static ApplicationStatus? getStatus(
      WorkApplicationEntity workApplicationEntity) {
    switch (workApplicationEntity.status) {
      case WorkApplicationStatusEntity.created:
        return ApplicationStatus.created;
      case WorkApplicationStatusEntity.backedOut:
        return ApplicationStatus.backedOut;
      case WorkApplicationStatusEntity.disqualified:
        return ApplicationStatus.disqualified;
      case WorkApplicationStatusEntity.waitListed:
        return ApplicationStatus.waitListed;
      case WorkApplicationStatusEntity.executionCompleted:
        return ApplicationStatus.executionCompleted;
      case WorkApplicationStatusEntity.executionStarted:
        return ApplicationStatus.executionStarted;
      case WorkApplicationStatusEntity.applied:
        switch (workApplicationEntity.supplyPendingAction) {
          case WorkApplicationPendingAction.scheduleTelephonicInterview:
            return ApplicationStatus.telephonicInterviewPending;
          case WorkApplicationPendingAction.scheduleWebinarTraining:
            return ApplicationStatus.webinarTrainingPending;
          case WorkApplicationPendingAction.schedulePitchDemo:
            return ApplicationStatus.manualPitchDemoPending;
          default:
            return ApplicationStatus.applied;
        }

      case WorkApplicationStatusEntity.inAppInterview:
        switch (workApplicationEntity.inAppInterview?.status) {
          case StepStatus.pending:
            return ApplicationStatus.inAppInterviewPending;
          case StepStatus.started:
            return ApplicationStatus.inAppInterviewStarted;
          case StepStatus.completed:
          case StepStatus.selected:
          case StepStatus.rejected:
            return ApplicationStatus.inAppInterviewCompleted;
          case StepStatus.passed:
            return ApplicationStatus.inAppInterviewSelected;
          case StepStatus.failed:
            return ApplicationStatus.inAppInterviewRejected;
          default:
            return null;
        }

      case WorkApplicationStatusEntity.telephonicInterview:
        switch (workApplicationEntity.telephonicInterview?.status) {
          case StepStatus.pending:
            return ApplicationStatus.telephonicInterviewPending;
          case StepStatus.scheduled:
            switch (workApplicationEntity.supplyPendingAction) {
              case WorkApplicationPendingAction.askSupplyInterviewConfirmation:
                return ApplicationStatus
                    .telephonicInterviewSupplyConfirmationPending;
              case WorkApplicationPendingAction.waitWhileWeProcess:
                return ApplicationStatus.telephonicInterviewCompleted;
              case WorkApplicationPendingAction.waitForResult:
                return ApplicationStatus.telephonicInterviewCompleted;
              case WorkApplicationPendingAction.allTheBest:
                return ApplicationStatus.telephonicInterviewScheduled;
              case WorkApplicationPendingAction.prepareInterview:
                return ApplicationStatus.telephonicInterviewScheduled;
              case WorkApplicationPendingAction.customerSupport:
                return ApplicationStatus.customerSupport;
              default:
                return ApplicationStatus.telephonicInterviewScheduled;
            }
          case StepStatus.started:
            switch (workApplicationEntity.supplyPendingAction) {
              case WorkApplicationPendingAction.askSupplyInterviewConfirmation:
                return ApplicationStatus
                    .telephonicInterviewSupplyConfirmationPending;
              case WorkApplicationPendingAction.waitWhileWeProcess:
                return ApplicationStatus.telephonicInterviewCompleted;
              case WorkApplicationPendingAction.waitForResult:
                return ApplicationStatus.telephonicInterviewCompleted;
              case WorkApplicationPendingAction.allTheBest:
                return ApplicationStatus.telephonicInterviewScheduled;
              case WorkApplicationPendingAction.prepareInterview:
                return ApplicationStatus.telephonicInterviewScheduled;
              case WorkApplicationPendingAction.customerSupport:
                return ApplicationStatus.customerSupport;
              default:
                return ApplicationStatus.telephonicInterviewScheduled;
            }
          case StepStatus.selected:
          case StepStatus.rejected:
          case StepStatus.telephonicInterviewCompleted:
            switch (workApplicationEntity.supplyPendingAction) {
              case WorkApplicationPendingAction.askSupplyInterviewConfirmation:
                return ApplicationStatus
                    .telephonicInterviewSupplyConfirmationPending;
              case WorkApplicationPendingAction.customerSupport:
                return ApplicationStatus.customerSupport;
              case WorkApplicationPendingAction.waitWhileWeProcess:
                return ApplicationStatus.telephonicInterviewCompleted;
              case WorkApplicationPendingAction.waitForResult:
                return ApplicationStatus.telephonicInterviewCompleted;
              default:
                return ApplicationStatus.telephonicInterviewCompleted;
            }
          case StepStatus.passed:
            return ApplicationStatus.telephonicInterviewSelected;
          case StepStatus.failed:
            return ApplicationStatus.telephonicInterviewRejected;
          case StepStatus.incomplete:
            return ApplicationStatus.telephonicInterviewInComplete;
          default:
            return ApplicationStatus.customerSupport;
        }

      case WorkApplicationStatusEntity.inAppTraining:
        switch (workApplicationEntity.inAppTraining?.status) {
          case StepStatus.pending:
            return ApplicationStatus.inAppTrainingPending;
          case StepStatus.started:
            return ApplicationStatus.inAppTrainingStarted;
          case StepStatus.completed:
          case StepStatus.selected:
          case StepStatus.rejected:
            return ApplicationStatus.inAppTrainingCompleted;
          case StepStatus.passed:
            return ApplicationStatus.inAppTrainingSelected;
          case StepStatus.failed:
            return ApplicationStatus.inAppTrainingRejected;
          default:
            return ApplicationStatus.customerSupport;
        }

      case WorkApplicationStatusEntity.webinarTraining:
        switch (workApplicationEntity.webinarTraining?.status) {
          case StepStatus.pending:
            return ApplicationStatus.webinarTrainingPending;
          case StepStatus.scheduled:
            switch (workApplicationEntity.supplyPendingAction) {
              case WorkApplicationPendingAction.askSupplyTrainingConfirmation:
                return ApplicationStatus
                    .webinarTrainingSupplyConfirmationPending;
              case WorkApplicationPendingAction.waitWhileWeProcess:
                return ApplicationStatus.webinarTrainingCompleted;
              case WorkApplicationPendingAction.waitForResult:
                return ApplicationStatus.webinarTrainingCompleted;
              case WorkApplicationPendingAction.customerSupport:
                return ApplicationStatus.customerSupport;
              case WorkApplicationPendingAction.allTheBest:
              case WorkApplicationPendingAction.prepareTraining:
              case WorkApplicationPendingAction.joinTraining:
                return ApplicationStatus.webinarTrainingScheduled;
              case WorkApplicationPendingAction.missedTraining:
                return ApplicationStatus.webinarTrainingMissed;
              default:
                return ApplicationStatus.webinarTrainingScheduled;
            }
          case StepStatus.started:
            switch (workApplicationEntity.supplyPendingAction) {
              case WorkApplicationPendingAction.askSupplyTrainingConfirmation:
                return ApplicationStatus
                    .webinarTrainingSupplyConfirmationPending;
              case WorkApplicationPendingAction.waitWhileWeProcess:
                return ApplicationStatus.webinarTrainingCompleted;
              case WorkApplicationPendingAction.waitForResult:
                return ApplicationStatus.webinarTrainingCompleted;
              case WorkApplicationPendingAction.customerSupport:
                return ApplicationStatus.customerSupport;
              case WorkApplicationPendingAction.allTheBest:
              case WorkApplicationPendingAction.prepareTraining:
              case WorkApplicationPendingAction.joinTraining:
                return ApplicationStatus.webinarTrainingScheduled;
              default:
                return ApplicationStatus.webinarTrainingStarted;
            }
          case StepStatus.selected:
          case StepStatus.rejected:
          case StepStatus.completed:
            switch (workApplicationEntity.supplyPendingAction) {
              case WorkApplicationPendingAction.askSupplyTrainingConfirmation:
                return ApplicationStatus
                    .webinarTrainingSupplyConfirmationPending;
              case WorkApplicationPendingAction.customerSupport:
                return ApplicationStatus.customerSupport;
              case WorkApplicationPendingAction.waitWhileWeProcess:
              case WorkApplicationPendingAction.waitForResult:
                return ApplicationStatus.webinarTrainingCompleted;
              default:
                return ApplicationStatus.webinarTrainingSelected;
            }
          case StepStatus.passed:
            return ApplicationStatus.webinarTrainingSelected;
          case StepStatus.failed:
            return ApplicationStatus.webinarTrainingRejected;
          case StepStatus.incomplete:
            return ApplicationStatus.webinarTrainingInComplete;
          default:
            return ApplicationStatus.customerSupport;
        }

      case WorkApplicationStatusEntity.pitchDemo:
        switch (workApplicationEntity.pitchDemo?.demoType) {
          case DemoType.automated:
            switch (workApplicationEntity.pitchDemo?.status) {
              case StepStatus.pending:
                return ApplicationStatus.automatedPitchDemoPending;
              case StepStatus.started:
                return ApplicationStatus.automatedPitchDemoStarted;
              case StepStatus.pitchDemoCompleted:
              case StepStatus.selected:
              case StepStatus.rejected:
                return ApplicationStatus.automatedPitchDemoCompleted;
              case StepStatus.passed:
                return ApplicationStatus.automatedPitchDemoSelected;
              case StepStatus.failed:
                return ApplicationStatus.automatedPitchDemoRejected;
              default:
                return ApplicationStatus.customerSupport;
            }
          case DemoType.manual:
            switch (workApplicationEntity.pitchDemo?.status) {
              case StepStatus.pending:
                return ApplicationStatus.manualPitchDemoPending;
              case StepStatus.scheduled:
                switch (workApplicationEntity.supplyPendingAction) {
                  case WorkApplicationPendingAction
                        .askSupplyPitchDemoConfirmation:
                    return ApplicationStatus
                        .manualPitchDemoSupplyConfirmationPending;
                  case WorkApplicationPendingAction.allTheBest:
                    return ApplicationStatus.manualPitchDemoScheduled;
                  case WorkApplicationPendingAction.preparePitchDemo:
                    return ApplicationStatus.manualPitchDemoScheduled;
                  case WorkApplicationPendingAction.waitWhileWeProcess:
                    return ApplicationStatus.manualPitchDemoCompleted;
                  case WorkApplicationPendingAction.waitForResult:
                    return ApplicationStatus.manualPitchDemoCompleted;
                  case WorkApplicationPendingAction.customerSupport:
                    return ApplicationStatus.customerSupport;
                  default:
                    return ApplicationStatus.manualPitchDemoScheduled;
                }
              case StepStatus.started:
                switch (workApplicationEntity.supplyPendingAction) {
                  case WorkApplicationPendingAction
                        .askSupplyPitchDemoConfirmation:
                    return ApplicationStatus
                        .manualPitchDemoSupplyConfirmationPending;
                  case WorkApplicationPendingAction.allTheBest:
                    return ApplicationStatus.manualPitchDemoScheduled;
                  case WorkApplicationPendingAction.preparePitchDemo:
                    return ApplicationStatus.manualPitchDemoScheduled;
                  case WorkApplicationPendingAction.waitWhileWeProcess:
                    return ApplicationStatus.manualPitchDemoCompleted;
                  case WorkApplicationPendingAction.waitForResult:
                    return ApplicationStatus.manualPitchDemoCompleted;
                  case WorkApplicationPendingAction.customerSupport:
                    return ApplicationStatus.customerSupport;
                  default:
                    return ApplicationStatus.manualPitchDemoStarted;
                }
              case StepStatus.selected:
              case StepStatus.rejected:
              case StepStatus.pitchDemoCompleted:
                switch (workApplicationEntity.supplyPendingAction) {
                  case WorkApplicationPendingAction
                        .askSupplyPitchDemoConfirmation:
                    return ApplicationStatus
                        .manualPitchDemoSupplyConfirmationPending;
                  case WorkApplicationPendingAction.customerSupport:
                    return ApplicationStatus.customerSupport;
                  case WorkApplicationPendingAction.waitWhileWeProcess:
                    return ApplicationStatus.manualPitchDemoCompleted;
                  case WorkApplicationPendingAction.waitForResult:
                    return ApplicationStatus.manualPitchDemoCompleted;
                  default:
                    return ApplicationStatus.manualPitchDemoSelected;
                }
              case StepStatus.passed:
                return ApplicationStatus.manualPitchDemoSelected;
              case StepStatus.failed:
                return ApplicationStatus.manualPitchDemoRejected;
              case StepStatus.incomplete:
                return ApplicationStatus.manualPitchDemoInComplete;
              default:
                return ApplicationStatus.customerSupport;
            }
        }
        break;

      case WorkApplicationStatusEntity.pitchTest:
        switch (workApplicationEntity.pitchTest?.status) {
          case StepStatus.pending:
            return ApplicationStatus.pitchTestPending;
          case StepStatus.started:
            return ApplicationStatus.pitchTestStarted;
          case StepStatus.pitchDemoCompleted:
          case StepStatus.selected:
          case StepStatus.rejected:
            return ApplicationStatus.pitchTestCompleted;
          case StepStatus.passed:
            return ApplicationStatus.pitchTestSelected;
          case StepStatus.failed:
            return ApplicationStatus.pitchTestRejected;
          default:
            return ApplicationStatus.customerSupport;
        }

      case WorkApplicationStatusEntity.selected:
        return ApplicationStatus.genericSelected;
      case WorkApplicationStatusEntity.rejected:
        return ApplicationStatus.genericRejected;
      case WorkApplicationStatusEntity.approvedToWork:
        return ApplicationStatus.approvedToWork;
    }
    return null;
  }

  static ApplicationStatus? transformWorkApplicationForDetails(
      WorkApplicationEntity workApplicationEntity) {
    switch (workApplicationEntity.supplyPendingAction) {
      case WorkApplicationPendingAction.scheduleTelephonicInterview:
        return ApplicationStatus.telephonicInterviewPending;
      case WorkApplicationPendingAction.scheduleWebinarTraining:
        return ApplicationStatus.webinarTrainingPending;
      case WorkApplicationPendingAction.schedulePitchDemo:
        return ApplicationStatus.manualPitchDemoPending;
      case WorkApplicationPendingAction.prepareInterview:
        return ApplicationStatus.telephonicInterviewScheduled;
      case WorkApplicationPendingAction.prepareTraining:
        return ApplicationStatus.webinarTrainingScheduled;
      case WorkApplicationPendingAction.reschedulePitchDemo:
        return ApplicationStatus.manualPitchDemoScheduled;
      default:
        return ApplicationStatus.getStatus(workApplicationEntity);
    }
  }
}
