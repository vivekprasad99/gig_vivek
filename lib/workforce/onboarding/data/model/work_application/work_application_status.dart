import 'package:awign/workforce/core/data/model/enum.dart';

class WorkApplicationStatusEntity<String> extends Enum1<String> {
  const WorkApplicationStatusEntity(String val) : super(val);

  static const WorkApplicationStatusEntity created = WorkApplicationStatusEntity('created');
  static const WorkApplicationStatusEntity waitListed = WorkApplicationStatusEntity('waitlisted');
  static const WorkApplicationStatusEntity backedOut = WorkApplicationStatusEntity('backed_out');
  static const WorkApplicationStatusEntity disqualified = WorkApplicationStatusEntity('disqualified');
  static const WorkApplicationStatusEntity applied = WorkApplicationStatusEntity('applied');
  static const WorkApplicationStatusEntity inAppInterview = WorkApplicationStatusEntity('in_app_interview');
  static const WorkApplicationStatusEntity telephonicInterview = WorkApplicationStatusEntity('telephonic_interview');
  static const WorkApplicationStatusEntity inAppTraining = WorkApplicationStatusEntity('in_app_training');
  static const WorkApplicationStatusEntity webinarTraining = WorkApplicationStatusEntity('webinar_training');
  static const WorkApplicationStatusEntity pitchDemo = WorkApplicationStatusEntity('pitch_demo');
  static const WorkApplicationStatusEntity pitchTest = WorkApplicationStatusEntity('pitch_test');
  static const WorkApplicationStatusEntity sampleLeadTest = WorkApplicationStatusEntity('sample_lead_test');
  static const WorkApplicationStatusEntity selected = WorkApplicationStatusEntity('selected');
  static const WorkApplicationStatusEntity rejected = WorkApplicationStatusEntity('rejected');
  static const WorkApplicationStatusEntity approvedToWork = WorkApplicationStatusEntity('approved_to_work');
  static const WorkApplicationStatusEntity executionCompleted = WorkApplicationStatusEntity('execution_completed');
  static const WorkApplicationStatusEntity executionStarted = WorkApplicationStatusEntity('execution_started');

  static WorkApplicationStatusEntity? getStatus(dynamic status) {
    switch(status) {
      case 'created':
        return  WorkApplicationStatusEntity.created;
      case 'waitlisted':
        return WorkApplicationStatusEntity.waitListed;
      case 'backed_out':
        return WorkApplicationStatusEntity.backedOut;
      case 'disqualified':
        return WorkApplicationStatusEntity.disqualified;
      case 'applied':
        return WorkApplicationStatusEntity.applied;
      case 'in_app_interview':
        return WorkApplicationStatusEntity.inAppInterview;
      case 'telephonic_interview':
        return WorkApplicationStatusEntity.telephonicInterview;
      case 'in_app_training':
        return WorkApplicationStatusEntity.inAppTraining;
      case 'webinar_training':
        return WorkApplicationStatusEntity.webinarTraining;
      case 'pitch_demo':
        return WorkApplicationStatusEntity.pitchDemo;
      case 'pitch_test':
        return WorkApplicationStatusEntity.pitchTest;
      case 'sample_lead_test':
        return WorkApplicationStatusEntity.sampleLeadTest;
      case 'selected':
        return WorkApplicationStatusEntity.selected;
      case 'rejected':
        return WorkApplicationStatusEntity.rejected;
      case 'approved_to_work':
        return WorkApplicationStatusEntity.approvedToWork;
      case 'execution_completed':
        return WorkApplicationStatusEntity.executionCompleted;
      case 'execution_started':
        return WorkApplicationStatusEntity.executionStarted;
    }
    return null;
  }
}
