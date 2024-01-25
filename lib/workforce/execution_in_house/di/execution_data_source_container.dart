import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/attendance/attendance_data_source.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/availablity/availablity_remote_data_source.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/dashboard_remote_data_source.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/execution_remote_data_source.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/lead/lead_remote_data_source.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/lead_screen/screen_remote_data_source.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/view_config/view_config_remote_data_source.dart';

import '../data/network/data_source/leadpayout/leadpayout_remote_data_source.dart';
import '../data/network/data_source/worklog/worklog_remote_data_source.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<ExecutionRemoteDataSource>(
      () => ExecutionRemoteDataSourceImpl());
  sl.registerFactory<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl());
  sl.registerFactory<ViewConfigRemoteDataSource>(
      () => ViewConfigRemoteDataSourceImpl());
  sl.registerFactory<LeadRemoteDataSource>(() => LeadRemoteDataSourceImpl());
  sl.registerFactory<ScreenRemoteDataSource>(
      () => ScreenRemoteDataSourceImpl());
  sl.registerFactory<WorklogRemoteDataSource>(
      () => WorklogRemoteDataSourceImpl());
  sl.registerFactory<AvailabilityRemoteDataSource>(
      () => AvailabilityRemoteDataSourceImpl());
  sl.registerFactory<LeadPayoutRemoteDataSource>(
      () => LeadPayoutRemoteDataSourceImpl());
  sl.registerFactory<AttendanceRemoteDataSource>(
          () => AttendanceRemoteDataSourceImpl());
}
