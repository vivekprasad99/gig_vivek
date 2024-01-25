import 'package:awign/workforce/auth/data/network/data_source/auth_remote_data_source.dart';
import 'package:awign/workforce/auth/data/network/data_source/bff/bff_remote_data_source.dart';
import 'package:awign/workforce/auth/data/network/data_source/pin/pin_remote_data_source.dart';
import 'package:awign/workforce/core/data/local/data_srouce/upload_entry/upload_entry_local_data_source.dart';
import 'package:awign/workforce/core/data/network/data_source/core_remote_data_source.dart';
import 'package:awign/workforce/core/data/network/data_source/logging_remote_data_source.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  sl.registerFactory<CoreRemoteDataSource>(() => CoreRemoteDataSourceImpl());
  sl.registerFactory<PINRemoteDataSource>(() => PINRemoteDataSourceImpl());
  sl.registerFactory<LoggingRemoteDataSource>(
      () => LoggingRemoteDataSourceImpl());
  sl.registerFactory<BFFRemoteDataSource>(() => BFFRemoteDataSourceImpl());
  sl.registerFactory<UploadEntryLocalDataSource>(
      () => UploadEntryLocalDataSourceImpl());
}
