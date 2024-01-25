import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/show_month_calendar_bottom_sheet/cubit/show_month_calendar_cubit.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/cubit/campus_ambassador_cubit.dart';
import 'package:awign/workforce/more/feature/dream_application/widget/bottom_sheet/cubit/dream_application_questions_cubit.dart';
import 'package:awign/workforce/more/feature/edit_address/cubit/edit_address_cubit.dart';
import 'package:awign/workforce/more/feature/edit_collage_details/cubit/edit_collage_details_cubit.dart';
import 'package:awign/workforce/more/feature/edit_other_details/cubit/edit_other_details_cubit.dart';
import 'package:awign/workforce/more/feature/edit_personal_info/cubit/edit_personal_info_cubit.dart';
import 'package:awign/workforce/more/feature/edit_professional_details/cubit/edit_professional_details_cubit.dart';
import 'package:awign/workforce/more/feature/how_app_works/cubit/how_app_works_cubit.dart';
import 'package:awign/workforce/more/feature/leaderboard/cubits/leaderboard_cubit.dart';
import 'package:awign/workforce/more/feature/more/cubit/more_cubit.dart';
import 'package:awign/workforce/more/feature/my_profile/cubit/my_profile_cubit.dart';
import 'package:awign/workforce/more/feature/profile_details/cubit/profile_details_cubit.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/bottom_sheet/cubit/profile_questions_bottom_sheet_cubit.dart';

void init() {
  /* Cubits */
  sl.registerFactory<MoreCubit>(() => MoreCubit(sl(), sl()));
  sl.registerFactory<MyProfileCubit>(() => MyProfileCubit(sl(), sl()));
  sl.registerFactory<EditPersonalInfoCubit>(() => EditPersonalInfoCubit(sl()));
  sl.registerFactory<EditCollageDetailsCubit>(
      () => EditCollageDetailsCubit(sl()));
  sl.registerFactory<EditProfessionalDetailsCubit>(
      () => EditProfessionalDetailsCubit(sl()));
  sl.registerFactory<EditAddressCubit>(() => EditAddressCubit(sl()));
  sl.registerFactory<EditOtherDetailsCubit>(() => EditOtherDetailsCubit(sl()));
  sl.registerFactory<CampusAmbassadorCubit>(() => CampusAmbassadorCubit(sl()));
  sl.registerFactory<HowAppWorksCubit>(() => HowAppWorksCubit());
  sl.registerFactory<ProfileDetailsCubit>(() => ProfileDetailsCubit(sl()));
  sl.registerFactory<DreamApplicationQuestionsCubit>(
      () => DreamApplicationQuestionsCubit(sl()));
  sl.registerFactory<ProfileQuestionsBottomSheetCubit>(
      () => ProfileQuestionsBottomSheetCubit(sl()));
  sl.registerFactory<LeaderboardCubit>(() => LeaderboardCubit(sl()));
  sl.registerFactory<ShowMonthCalendarCubit>(() => ShowMonthCalendarCubit());
}
