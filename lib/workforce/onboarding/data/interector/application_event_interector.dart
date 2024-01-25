import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/in_app_interview/in_app_interview_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/in_app_training/in_app_training_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_demo/pitch_demo_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_test/pitch_test_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/webinar_training/webinar_training_remote_repository.dart';

abstract class ApplicationEventInterector {
  Future<WorkApplicationEntity?> handleApplicationEvent(int userID, int applicationID, ApplicationAction applicationAction);
}

class ApplicationEventInterectorImpl implements ApplicationEventInterector {
  final InAppInterviewRemoteRepository _inAppInterviewRepository;
  final InAppTrainingRemoteRepository _inAppTrainingRemoteRepository;
  final WebinarTrainingRemoteRepository _webinarTrainingRemoteRepository;
  final PitchDemoRemoteRepository _pitchDemoRemoteRepository;
  final PitchTestRemoteRepository _pitchTestRemoteRepository;

  ApplicationEventInterectorImpl(this._inAppInterviewRepository, this._inAppTrainingRemoteRepository,
      this._webinarTrainingRemoteRepository, this._pitchDemoRemoteRepository, this._pitchTestRemoteRepository);

  @override
  Future<WorkApplicationEntity?> handleApplicationEvent(int userID, int applicationID, ApplicationAction applicationAction) async {
    try {
      WorkApplicationEntity? workApplicationEntity;
      switch(applicationAction) {
        case ApplicationAction.startInAppInterview:
          workApplicationEntity = await _inAppInterviewRepository.executeInAppInterviewEvent(userID, applicationID, applicationAction);
          break;
        case ApplicationAction.redoInAppInterview:
          workApplicationEntity = await _inAppInterviewRepository.executeApplicationEvent(userID, applicationID, applicationAction);
          break;

        case ApplicationAction.reTakeTelephonicInterview:
          workApplicationEntity = await _inAppInterviewRepository.executeApplicationEvent(userID, applicationID, applicationAction);
          break;

        case ApplicationAction.startInAppTraining:
          workApplicationEntity = await _inAppTrainingRemoteRepository.executeInAppTrainingEvent(userID, applicationID, applicationAction);
          break;
        case ApplicationAction.redoInAppTraining:
          workApplicationEntity = await _inAppInterviewRepository.executeApplicationEvent(userID, applicationID, applicationAction);
          break;

        case ApplicationAction.scheduleWebinarTraining:
        case ApplicationAction.reScheduleWebinarTraining:
          workApplicationEntity = await _webinarTrainingRemoteRepository.executeWebinarTrainingEvent(userID, applicationID, applicationAction);
          break;
        case ApplicationAction.webinarTrainingSupplyConfirm:
          workApplicationEntity = await _webinarTrainingRemoteRepository.supplyConfirmWebinarTraining(userID, applicationID, applicationAction.getValue3());
          break;
        case ApplicationAction.webinarTrainingSupplyUnConfirm:
          workApplicationEntity = await _webinarTrainingRemoteRepository.supplyUnConfirmWebinarTraining(userID, applicationID, applicationAction.getValue3());
          break;
        case ApplicationAction.retakeWebinarTraining:
          workApplicationEntity = await _inAppInterviewRepository.executeApplicationEvent(userID, applicationID, applicationAction);
          break;

        case ApplicationAction.startPitchDemo:
          workApplicationEntity = await _pitchDemoRemoteRepository.executePitchDemoEvent(userID, applicationID, applicationAction);
          break;
        case ApplicationAction.redoPitchDemo:
          workApplicationEntity = await _inAppInterviewRepository.executeApplicationEvent(userID, applicationID, applicationAction);
          break;

        case ApplicationAction.startPitchTest:
          workApplicationEntity = await _pitchTestRemoteRepository.executePitchTestEvent(userID, applicationID, applicationAction);
          break;
        case ApplicationAction.redoPitchTest:
          workApplicationEntity = await _inAppInterviewRepository.executeApplicationEvent(userID, applicationID, applicationAction);
          break;
      }
      return workApplicationEntity;
    } catch (e) {
      AppLog.e('handleApplicationEvent : ${e.toString()}');
      rethrow;
    }
  }
}
