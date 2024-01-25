import 'package:awign/workforce/execution_in_house/data/network/data_source/attendance/attendance_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/in_app_interview/in_app_interview_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/in_app_training/in_app_training_remote_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/pitch_demo/pitch_demo_remote_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/telephonic_interview/telephonic_interview_remote_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/webinar_training/webinar_training_remote_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/work_application/work_application_remote_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/work_listing/work_listing_remote_data_source.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/wos_remote_data_source.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/onboarding/data/network/pitch_test/pitch_test_remote_data_source.dart';

import '../data/network/data_source/campus_ambassador/campus_ambassador_data_source.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<WosRemoteDataSource>(() => WosRemoteDataSourceImpl());
  sl.registerFactory<InAppInterviewDataSource>(
      () => InAppInterviewDataSourceImpl());
  sl.registerFactory<WorkApplicationRemoteDataSource>(
      () => WorkApplicationRemoteDataSourceImpl());
  sl.registerFactory<WorkListingRemoteDataSource>(
      () => WorkListingRemoteDataSourceImpl());
  sl.registerFactory<TelephonicInterviewRemoteDataSource>(
      () => TelephonicInterviewRemoteDataSourceImpl());
  sl.registerFactory<InAppTrainingRemoteDataSource>(
      () => InAppTrainingRemoteDataSourceImpl());
  sl.registerFactory<WebinarTrainingRemoteDataSource>(
      () => WebinarTrainingRemoteDataSourceImpl());
  sl.registerFactory<PitchDemoRemoteDataSource>(
      () => PitchDemoRemoteDataSourceImpl());
  sl.registerFactory<PitchTestRemoteDataSource>(
      () => PitchTestRemoteDataSourceImpl());
  sl.registerFactory<CampusAmbassadorDataSource>(
      () => CampusAmbassadorDataSourceImpl());
}
