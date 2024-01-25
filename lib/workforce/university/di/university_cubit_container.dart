import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_filter_bottom_sheet/cubit/select_filter_cubit.dart';
import 'package:awign/workforce/university/feature/awign_university/cubit/awign_university_cubit.dart';

void init() {
  /* Cubits */
  sl.registerFactory<AwignUniversityCubit>(() => AwignUniversityCubit(sl()));
  sl.registerFactory<SelectFilterCubit>(() => SelectFilterCubit());
}