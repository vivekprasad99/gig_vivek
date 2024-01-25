import 'package:awign/workforce/banner/feature/dynamic_banner/cubit/banner_cubit.dart';
import '../../core/di/app_injection_container.dart';

void init() {
  /* Cubits */
  sl.registerFactory<BannerCubit>(() => BannerCubit(sl()));
}