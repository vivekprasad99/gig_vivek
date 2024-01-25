import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/university/data/repository/university/university_remote_repository.dart';

void init() {
  /* Repositories */
  sl.registerFactory<UniversityRemoteRepository>(() => UniversityRemoteRepositoryImpl(sl()));
}