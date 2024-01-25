import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/nps_bottom_sheet/cubit/nps_bottom_sheet_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/application_history/cubit/application_history_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_application/cubit/category_application_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_detail_and_job/cubit/category_detail_and_job_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_details/cubit/category_details_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/cubit/category_listing_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/cubit/category_questions_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/resources/cubit/resource_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/cubit/worklisting_details_cubit.dart';

import '../../core/widget/bottom_sheet/eligibility_bottom_sheet/cubit/eligibility_bottom_sheet_cubit.dart';
import '../../execution_in_house/feature/application_result/cubit/application_result_cubit.dart';
import '../presentation/feature/worklisting_details/widget/bottom_sheet/cubit/worklist_cubit.dart';

void init() {
  /* Cubits */
  sl.registerFactory<CategoryListingCubit>(() => CategoryListingCubit(sl(), sl(),sl()));
  sl.registerFactory<CategoryDetailsCubit>(() => CategoryDetailsCubit(sl()));
  sl.registerFactory<CategoryQuestionsCubit>(() => CategoryQuestionsCubit(sl()));
  sl.registerFactory<ApplicationHistoryCubit>(() => ApplicationHistoryCubit(sl()));
  sl.registerFactory<CategoryApplicationCubit>(() => CategoryApplicationCubit(sl()));
  sl.registerFactory<WorkListingDetailsCubit>(() => WorkListingDetailsCubit(sl(), sl(), sl(),sl()));
  sl.registerFactory<CategoryDetailAndJobCubit>(() => CategoryDetailAndJobCubit(sl(),sl()));
  sl.registerFactory<ResourceCubit>(() => ResourceCubit(sl()));
  sl.registerFactory<EligibilityBottomSheetCubit>(
      () => EligibilityBottomSheetCubit(sl()));
  sl.registerFactory<ApplicationResultCubit>(
      () => ApplicationResultCubit(sl()));
  sl.registerFactory<NpsBottomSheetCubit>(() => NpsBottomSheetCubit(sl()));
  sl.registerFactory<WorklistCubit>(
      () => WorklistCubit(sl()));
}
