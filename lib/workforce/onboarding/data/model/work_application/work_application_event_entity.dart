import 'package:awign/workforce/core/data/model/enum.dart';

class WorkApplicationEventEntity<String> extends Enum1<String> {
  const WorkApplicationEventEntity(String val) : super(val);

  static const WorkApplicationEventEntity startInAppInterview = WorkApplicationEventEntity('start');
  static const WorkApplicationEventEntity retakeInAppInterview = WorkApplicationEventEntity('retake_in_app_interview');

  static const WorkApplicationEventEntity scheduleTelephonicInterview = WorkApplicationEventEntity('schedule');
  static const WorkApplicationEventEntity supplyConfirmTelephonicInterview = WorkApplicationEventEntity('supply_confirm');
  static const WorkApplicationEventEntity supplyUnConfirmTelephonicInterview = WorkApplicationEventEntity('supply_unconfirm');
  static const WorkApplicationEventEntity retakeTelephonicInterview = WorkApplicationEventEntity('retake_telephonic_interview');

  static const WorkApplicationEventEntity startInAppTraining = WorkApplicationEventEntity('start');
  static const WorkApplicationEventEntity retakeInAppTraining = WorkApplicationEventEntity('retake_in_app_training');

  static const WorkApplicationEventEntity scheduleWebinarTraining = WorkApplicationEventEntity('schedule');
  static const WorkApplicationEventEntity supplyConfirmWebinarTraining = WorkApplicationEventEntity('supply_confirm');
  static const WorkApplicationEventEntity supplyUnConfirmWebinarTraining = WorkApplicationEventEntity('supply_unconfirm');
  static const WorkApplicationEventEntity retakeWebinarTraining = WorkApplicationEventEntity('retake_webinar_training');

  static const WorkApplicationEventEntity startPitchDemo = WorkApplicationEventEntity('start');
  static const WorkApplicationEventEntity schedulePitchDemo = WorkApplicationEventEntity('schedule');
  static const WorkApplicationEventEntity supplyConfirmPitchDemo = WorkApplicationEventEntity('supply_confirm');
  static const WorkApplicationEventEntity supplyUnConfirmPitchDemo = WorkApplicationEventEntity('supply_unconfirm');
  static const WorkApplicationEventEntity retakePitchDemo = WorkApplicationEventEntity('retake_pitch_demo');

  static const WorkApplicationEventEntity startPitchTest = WorkApplicationEventEntity('start');
  static const WorkApplicationEventEntity retakePitchTest = WorkApplicationEventEntity('retake_pitch_test');

}