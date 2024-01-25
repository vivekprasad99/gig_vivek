import 'package:awign/workforce/onboarding/data/interector/application_event_interector.dart';
import 'package:awign/workforce/onboarding/data/repository/campus_ambassador/campus_ambassador_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/in_app_interview/in_app_interview_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/in_app_training/in_app_training_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_demo/pitch_demo_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/pitch_test/pitch_test_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/telephonic_interview/telephonic_interview_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/webinar_training/webinar_training_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/work_application/work_application_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/work_listing/work_listing_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';

void init() {
  /* Repositories */
  sl.registerFactory<WosRemoteRepository>(() => WosRemoteRepositoryImpl(sl()));
  sl.registerFactory<InAppInterviewRemoteRepository>(
      () => InAppInterviewRemoteRepositoryImpl(sl()));
  sl.registerFactory<ApplicationEventInterector>(
      () => ApplicationEventInterectorImpl(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory<WorkApplicationRemoteRepository>(
      () => WorkApplicationRemoteRepositoryImpl(sl()));
  sl.registerFactory<WorkListingRemoteRepository>(
      () => WorkListingRemoteRepositoryImpl(sl()));
  sl.registerFactory<TelephonicInterviewRemoteRepository>(
      () => TelephonicInterviewRemoteRepositoryImpl(sl()));
  sl.registerFactory<InAppTrainingRemoteRepository>(
      () => InAppTrainingRemoteRepositoryImpl(sl()));
  sl.registerFactory<WebinarTrainingRemoteRepository>(
      () => WebinarTrainingRemoteRepositoryImpl(sl()));
  sl.registerFactory<PitchDemoRemoteRepository>(
      () => PitchDemoRemoteRepositoryImpl(sl()));
  sl.registerFactory<PitchTestRemoteRepository>(
      () => PitchTestRemoteRepositoryImpl(sl()));
  sl.registerFactory<CampusAmbassadorRemoteRepository>(
      () => CampusAmbassadorRemoteRepositoryImpl(sl()));
}
