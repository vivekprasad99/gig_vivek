import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_event_entity.dart';

class EventMapper {
  static WorkApplicationEventEntity? convertToEvent(ApplicationAction applicationAction) {
    if(applicationAction.getValue2() != ActionType.networkAction) {
      return null;
    }
    switch(applicationAction) {
      case ApplicationAction.startInAppInterview:
        return WorkApplicationEventEntity.startInAppInterview;
      case ApplicationAction.redoInAppInterview:
        return WorkApplicationEventEntity.retakeInAppInterview;

      case ApplicationAction.scheduleTelephonicInterview:
        return WorkApplicationEventEntity.scheduleTelephonicInterview;
      case ApplicationAction.telephonicInterviewSupplyConfirm:
        return WorkApplicationEventEntity.supplyConfirmTelephonicInterview;
      case ApplicationAction.telephonicInterviewSupplyUnConfirm:
        return WorkApplicationEventEntity.supplyUnConfirmTelephonicInterview;
      case ApplicationAction.reTakeTelephonicInterview:
        return WorkApplicationEventEntity.retakeTelephonicInterview;

      case ApplicationAction.startInAppTraining:
        return WorkApplicationEventEntity.startInAppTraining;
      case ApplicationAction.redoInAppTraining:
        return WorkApplicationEventEntity.retakeInAppTraining;

      case ApplicationAction.scheduleWebinarTraining:
      case ApplicationAction.reScheduleWebinarTraining:
        return WorkApplicationEventEntity.scheduleWebinarTraining;
      case ApplicationAction.webinarTrainingSupplyConfirm:
        return WorkApplicationEventEntity.supplyConfirmWebinarTraining;
      case ApplicationAction.webinarTrainingSupplyUnConfirm:
        return WorkApplicationEventEntity.supplyUnConfirmWebinarTraining;
      case ApplicationAction.retakeWebinarTraining:
        return WorkApplicationEventEntity.retakeWebinarTraining;

      case ApplicationAction.startPitchDemo:
        return WorkApplicationEventEntity.startPitchDemo;
      case ApplicationAction.schedulePitchDemo:
      case ApplicationAction.reSchedulePitchDemo:
        return WorkApplicationEventEntity.schedulePitchDemo;
      case ApplicationAction.pitchDemoSupplyConfirm:
        return WorkApplicationEventEntity.supplyConfirmPitchDemo;
      case ApplicationAction.pitchDemoSupplyUnConfirm:
        return WorkApplicationEventEntity.supplyUnConfirmPitchDemo;
      case ApplicationAction.redoPitchDemo:
        return WorkApplicationEventEntity.retakePitchDemo;

      case ApplicationAction.startPitchTest:
        return WorkApplicationEventEntity.startPitchTest;
      case ApplicationAction.redoPitchTest:
        return WorkApplicationEventEntity.retakePitchTest;
    }
    return null;
  }
}