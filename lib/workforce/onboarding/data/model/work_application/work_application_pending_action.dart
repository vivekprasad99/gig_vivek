import 'package:awign/workforce/core/data/model/enum.dart';

class WorkApplicationPendingAction<String> extends Enum1<String> {
  const WorkApplicationPendingAction(String val) : super(val);

  static const WorkApplicationPendingAction inAppInterviewPending =
      WorkApplicationPendingAction('start_in_app_interview');
  static const WorkApplicationPendingAction retakeInAppInterview =
      WorkApplicationPendingAction('retake_in_app_interview');
  static const WorkApplicationPendingAction completeInAppInterview =
      WorkApplicationPendingAction('complete_in_app_interview');

  static const WorkApplicationPendingAction scheduleTelephonicInterview =
      WorkApplicationPendingAction('schedule_telephonic_interview');
  static const WorkApplicationPendingAction askSupplyInterviewConfirmation =
      WorkApplicationPendingAction('ask_supply_interview_confirmation');
  static const WorkApplicationPendingAction
      rescheduleTelephonicInterviewOrContactSupport =
      WorkApplicationPendingAction(
          'reschedule_telephonic_interview_or_contact_support');
  static const WorkApplicationPendingAction rescheduleTelephonicInterview =
      WorkApplicationPendingAction('reschedule_telephonic_interview');
  static const WorkApplicationPendingAction retakeTelephonicInterview =
      WorkApplicationPendingAction('retake_telephonic_interview');
  static const WorkApplicationPendingAction prepareInterview =
      WorkApplicationPendingAction('prepare_interview');

  static const WorkApplicationPendingAction startInAppTraining =
      WorkApplicationPendingAction('start_in_app_training');
  static const WorkApplicationPendingAction retakeInAppTraining =
      WorkApplicationPendingAction('retake_in_app_training');
  static const WorkApplicationPendingAction completeInAppTraining =
      WorkApplicationPendingAction('complete_in_app_training');

  static const WorkApplicationPendingAction scheduleWebinarTraining = WorkApplicationPendingAction('schedule_webinar_training');
  static const WorkApplicationPendingAction askSupplyTrainingConfirmation = WorkApplicationPendingAction('ask_supply_training_confirmation');
  static const WorkApplicationPendingAction reScheduleWebinarTrainingOrSupport = WorkApplicationPendingAction('reschedule_webinar_training_or_contact_support');
  static const WorkApplicationPendingAction reScheduleWebinarTraining = WorkApplicationPendingAction('reschedule_webinar_training');
  static const WorkApplicationPendingAction retakeWebinarTraining = WorkApplicationPendingAction('retake_webinar_training');
  static const WorkApplicationPendingAction prepareTraining = WorkApplicationPendingAction('prepare_training');
  static const WorkApplicationPendingAction prepareTrainingNoResources = WorkApplicationPendingAction('prepare_training_no_resources');
  static const WorkApplicationPendingAction joinTrainingNoResources = WorkApplicationPendingAction('join_training_no_resources');
  static const WorkApplicationPendingAction joinTraining = WorkApplicationPendingAction('join_training');
  static const WorkApplicationPendingAction prepareTrainingNoResource =
      WorkApplicationPendingAction('prepare_training_no_resources');
  static const WorkApplicationPendingAction joinTrainingNoResource =
      WorkApplicationPendingAction('join_training_no_resources');

  static const WorkApplicationPendingAction startPitchDemo =
      WorkApplicationPendingAction('start_pitch_demo');
  static const WorkApplicationPendingAction completePitchDemo =
      WorkApplicationPendingAction('complete_pitch_demo');
  static const WorkApplicationPendingAction schedulePitchDemo =
      WorkApplicationPendingAction('schedule_pitch_demo');
  static const WorkApplicationPendingAction askSupplyPitchDemoConfirmation =
      WorkApplicationPendingAction('ask_supply_demo_confirmation');
  static const WorkApplicationPendingAction preparePitchDemo =
      WorkApplicationPendingAction('prepare_pitch_demo');
  static const WorkApplicationPendingAction reschedulePitchDemoOrSupport =
      WorkApplicationPendingAction('reschedule_pitch_demo_or_contact_support');
  static const WorkApplicationPendingAction reschedulePitchDemo =
      WorkApplicationPendingAction('reschedule_pitch_demo');
  static const WorkApplicationPendingAction retakePitchDemo =
      WorkApplicationPendingAction('retake_pitch_demo');

  static const WorkApplicationPendingAction startPitchTest =
      WorkApplicationPendingAction('start_pitch_test');
  static const WorkApplicationPendingAction retakePitchTest =
      WorkApplicationPendingAction('retake_pitch_test');
  static const WorkApplicationPendingAction completePitchTest =
      WorkApplicationPendingAction('complete_pitch_test');

  static const WorkApplicationPendingAction waitWhileWeProcess =
      WorkApplicationPendingAction('wait_while_we_process');
  static const WorkApplicationPendingAction waitForResult =
      WorkApplicationPendingAction('wait_for_results');
  static const WorkApplicationPendingAction allTheBest =
      WorkApplicationPendingAction('all_the_best');

  static const WorkApplicationPendingAction goToOffice =
      WorkApplicationPendingAction('go_to_office');
  static const WorkApplicationPendingAction reapply =
      WorkApplicationPendingAction('reapply');
  static const WorkApplicationPendingAction missedTraining =
      WorkApplicationPendingAction('missed_training');

  static const WorkApplicationPendingAction contactSupport =
      WorkApplicationPendingAction('contact_support');
  static const WorkApplicationPendingAction customerSupport =
      WorkApplicationPendingAction('contact_support');

  static WorkApplicationPendingAction? getAction(dynamic status) {
    switch (status) {
      case 'start_in_app_interview':
        return WorkApplicationPendingAction.inAppInterviewPending;
      case 'retake_in_app_interview':
        return WorkApplicationPendingAction.retakeInAppInterview;
      case 'complete_in_app_interview':
        return WorkApplicationPendingAction.completeInAppInterview;
      case 'schedule_telephonic_interview':
        return WorkApplicationPendingAction.scheduleTelephonicInterview;
      case 'ask_supply_interview_confirmation':
        return WorkApplicationPendingAction.askSupplyInterviewConfirmation;
      case 'reschedule_telephonic_interview_or_contact_support':
        return WorkApplicationPendingAction
            .rescheduleTelephonicInterviewOrContactSupport;
      case 'reschedule_telephonic_interview':
        return WorkApplicationPendingAction.rescheduleTelephonicInterview;
      case 'retake_telephonic_interview':
        return WorkApplicationPendingAction.retakeTelephonicInterview;
      case 'prepare_interview':
        return WorkApplicationPendingAction.prepareInterview;

      case 'start_in_app_training':
        return WorkApplicationPendingAction.startInAppTraining;
      case 'retake_in_app_training':
        return WorkApplicationPendingAction.retakeInAppTraining;
      case 'complete_in_app_training':
        return WorkApplicationPendingAction.completeInAppTraining;

      case 'schedule_webinar_training':
        return WorkApplicationPendingAction.scheduleWebinarTraining;
      case 'ask_supply_training_confirmation':
        return WorkApplicationPendingAction.askSupplyTrainingConfirmation;
      case 'reschedule_webinar_training_or_contact_support':
        return WorkApplicationPendingAction.reScheduleWebinarTrainingOrSupport;
      case 'reschedule_webinar_training':
        return WorkApplicationPendingAction.reScheduleWebinarTraining;
      case 'retake_webinar_training':
        return WorkApplicationPendingAction.retakeWebinarTraining;
      case 'prepare_training':
        return WorkApplicationPendingAction.prepareTraining;
      case 'prepare_training_no_resources':
        return WorkApplicationPendingAction.prepareTrainingNoResource;
      case 'join_training':
        return WorkApplicationPendingAction.joinTraining;
      case 'missed_training':
        return WorkApplicationPendingAction.missedTraining;
      case 'join_training_no_resources':
        return WorkApplicationPendingAction.joinTrainingNoResources;

      case 'start_pitch_demo':
        return WorkApplicationPendingAction.startPitchDemo;
      case 'complete_pitch_demo':
        return WorkApplicationPendingAction.completePitchDemo;
      case 'schedule_pitch_demo':
        return WorkApplicationPendingAction.schedulePitchDemo;
      case 'ask_supply_demo_confirmation':
        return WorkApplicationPendingAction.askSupplyPitchDemoConfirmation;
      case 'prepare_pitch_demo':
        return WorkApplicationPendingAction.preparePitchDemo;
      case 'reschedule_pitch_demo_or_contact_support':
        return WorkApplicationPendingAction.reschedulePitchDemoOrSupport;
      case 'reschedule_pitch_demo':
        return WorkApplicationPendingAction.reschedulePitchDemo;
      case 'retake_pitch_demo':
        return WorkApplicationPendingAction.retakePitchDemo;

      case 'start_pitch_test':
        return WorkApplicationPendingAction.startPitchTest;
      case 'retake_pitch_test':
        return WorkApplicationPendingAction.retakePitchTest;
      case 'complete_pitch_test':
        return WorkApplicationPendingAction.completePitchTest;

      case 'wait_while_we_process':
        return WorkApplicationPendingAction.waitWhileWeProcess;
      case 'wait_for_results':
        return WorkApplicationPendingAction.waitWhileWeProcess;
      case 'all_the_best':
        return WorkApplicationPendingAction.allTheBest;

      case 'go_to_office':
        return WorkApplicationPendingAction.goToOffice;
      case 'reapply':
        return WorkApplicationPendingAction.reapply;

      case 'contact_support':
        return WorkApplicationPendingAction.contactSupport;
    }
    return null;
  }
}
