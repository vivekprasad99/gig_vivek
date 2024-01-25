import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/auth/data/repository/bff/bff_remote_repository.dart';
import 'package:awign/workforce/auth/data/repository/pin/pin_remote_repository.dart';
import 'package:awign/workforce/core/data/local/repository/upload_entry/upload_entry_local_repository.dart';
import 'package:awign/workforce/core/data/repository/core_remote_repository.dart';
import 'package:awign/workforce/core/data/repository/logging_repository.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';

import '../../core/data/local/repository/logging_event/logging_local_repository.dart';
import '../../file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';

void init() {
  /* Repositories */
  sl.registerFactory<AuthRemoteRepository>(
      () => AuthRemoteRepositoryImpl(sl()));
  sl.registerFactory<CoreRemoteRepository>(
      () => CoreRemoteRepositoryImpl(sl()));
  sl.registerFactory<PINRemoteRepository>(() => PINRemoteRepositoryImpl(sl()));
  sl.registerFactory<LoggingRemoteRepository>(
      () => LoggingRemoteRepositoryImpl(sl()));
  sl.registerFactory<LoggingLocalRepository>(
      () => LoggingLocalRepositoryImpl());
  sl.registerFactory<BFFRemoteRepository>(() => BFFRemoteRepositoryImpl(sl()));
  sl.registerFactory<UploadEntryLocalRepository>(
      () => UploadEntryLocalRepositoryImpl(sl()));
  sl.registerSingleton<RemoteStorageRepository>(RemoteStorageRepository(),
      dispose: (remoteStorageRepository) => remoteStorageRepository.close());
}
