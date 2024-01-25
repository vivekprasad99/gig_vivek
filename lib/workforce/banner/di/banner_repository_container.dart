import 'package:awign/workforce/banner/data/repository/banner/banner_remote_repository.dart';
import '../../core/di/app_injection_container.dart';

void init() {
  /* Repositories */
  sl.registerFactory<BannerRemoteRepository>(() => BannerRemoteRepositoryImpl(sl()));
}