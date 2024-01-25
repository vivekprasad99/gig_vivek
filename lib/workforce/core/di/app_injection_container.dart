import 'package:awign/packages/flutter_image_editor/cubit/image_editor_widget_cubit.dart';
import 'package:awign/workforce/core/deep_link/cubit/deep_link_cubit.dart';
import 'package:awign/workforce/core/di/cubit_container/cubit_container.dart'
    as cc;
import 'package:awign/workforce/core/di/data_source_container/data_source_container.dart'
    as dsc;
import 'package:awign/workforce/core/di/repository_container/repository_container.dart'
    as rc;
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_navigation/cubit/bottom_navigation_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/pin_locked_bottom_sheet/cubit/pin_locked_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/pin_verify_bottom_sheet/cubit/pin_verify_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_collage_bottom_sheet/cubit/select_collage_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/cubit/select_education_level_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/cubit/select_language_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/cubit/select_location_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_month_year_bottom_sheet/cubit/select_month_year_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/cubit/select_working_domain_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void init() {
  /* Data Sources */
  dsc.init();

  /* Repositories */
  rc.init();

  /* Cubits */
  cc.init();

  /* Services */
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<SelectLanguageCubit>(() => SelectLanguageCubit());
  sl.registerLazySingleton<SelectLocationCubit>(
      () => SelectLocationCubit(sl()));
  sl.registerLazySingleton<SelectEducationLevelCubit>(
      () => SelectEducationLevelCubit());
  sl.registerLazySingleton<SelectWorkingDomainCubit>(
      () => SelectWorkingDomainCubit());
  sl.registerLazySingleton<SelectCollageCubit>(() => SelectCollageCubit(sl()));
  sl.registerLazySingleton<DeepLinkCubit>(() => DeepLinkCubit());
  sl.registerFactory<ImageEditorWidgetCubit>(
      () => ImageEditorWidgetCubit(sl()));
  sl.registerFactory<PinLockedBottomSheetCubit>(
      () => PinLockedBottomSheetCubit());
  sl.registerFactory<PinVerifyBottomSheetCubit>(
      () => PinVerifyBottomSheetCubit(sl()));
  sl.registerFactory<SelectMonthYearCubit>(() => SelectMonthYearCubit());

  /* Navigation */
  sl.registerSingleton<MRouter>(MRouter(), dispose: (router) {
    router.closeStream();
    router.closeLocalStream();
  });
  sl.registerSingleton<BottomNavigationCubit>(BottomNavigationCubit(),
      dispose: (cubit) => cubit.close());
}
