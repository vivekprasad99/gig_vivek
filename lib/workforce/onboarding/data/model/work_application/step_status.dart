import 'package:awign/workforce/core/data/model/enum.dart';

class StepStatus<String> extends Enum1<String> {
  const StepStatus(String val) : super(val);

  static const StepStatus pending = StepStatus('pending');
  static const StepStatus started = StepStatus('started');
  static const StepStatus completed = StepStatus('completed');
  static const StepStatus telephonicInterviewCompleted = StepStatus('interview_completed');
  static const StepStatus interviewCompleted = StepStatus('interview_completed');
  static const StepStatus trainingCompleted = StepStatus('training_completed');
  static const StepStatus pitchDemoCompleted = StepStatus('demo_completed');
  static const StepStatus selected = StepStatus('selected');
  static const StepStatus rejected = StepStatus('rejected');
  static const StepStatus passed = StepStatus('passed');
  static const StepStatus failed = StepStatus('failed');
  static const StepStatus scheduled = StepStatus('scheduled');
  static const StepStatus incomplete = StepStatus('incomplete');

  static StepStatus? getStatus(dynamic status) {
    switch(status) {
      case 'pending':
        return  StepStatus.pending;
      case 'started':
        return StepStatus.started;
      case 'completed':
        return StepStatus.completed;
      case 'interview_completed':
        return StepStatus.telephonicInterviewCompleted;
      case 'training_completed':
        return StepStatus.trainingCompleted;
      case 'demo_completed':
        return StepStatus.pitchDemoCompleted;
      case 'selected':
        return StepStatus.selected;
      case 'rejected':
        return StepStatus.rejected;
      case 'passed':
        return StepStatus.passed;
      case 'failed':
        return StepStatus.failed;
      case 'scheduled':
        return StepStatus.scheduled;
      case 'incomplete':
        return StepStatus.incomplete;
    }
    return null;
  }
}