import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/execution_in_house/data/repository/attendance/attendance_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/availablity/availablity_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/dashboaard_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/execution_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/lead/lead_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/lead_screen/screen_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/leadpayout/leadpayout_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/view_config/view_config_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/worklog/worklog_remote_repository.dart';

void init() {
  /* Repositories */
  sl.registerFactory<ExecutionRemoteRepository>(
      () => ExecutionRemoteRepositoryImpl(sl()));
  sl.registerFactory<DashboardRemoteRepository>(
      () => DashboardRemoteRepositoryImpl(sl()));
  sl.registerFactory<ViewConfigRemoteRepository>(
      () => ViewConfigRemoteRepositoryImpl(sl()));
  sl.registerFactory<LeadRemoteRepository>(
      () => LeadRemoteRepositoryImpl(sl()));
  sl.registerFactory<ScreenRemoteRepository>(
      () => ScreenRemoteRepositoryImpl(sl()));
  sl.registerFactory<WorklogRemoteRepository>(
      () => WorklogRemoteRepositoryImpl(sl()));
  sl.registerFactory<AvailabilityRemoteRepository>(
      () => AvailabilityRemoteRepositoryImpl(sl()));
  sl.registerFactory<LeadPayoutRemoteRepository>(
      () => LeadPayoutRemoteRepositoryImpl(sl()));
  sl.registerFactory<AttendanceRemoteRepository>(
          () => AttendanceRemoteRepositoryImpl(sl()));
}
