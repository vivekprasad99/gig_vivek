import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/array_question_widget/cubit/array_question_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/attendance_image/cubit/attendance_image_input_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/audio/cubit/sound_recorder_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/code_scanner/cubit/code_scanner_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/nested/nested_question_widget/cubit/nested_question_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/select/bottom_sheet/multi_select_bottom_sheet/cubit/multi_select_bottom_sheet_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/select/bottom_sheet/single_select_bottom_sheet/cubit/single_select_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/signature/cubit/signature_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';

import '../cubit/upload_or_sync_process_cubit/upload_or_sync_process_cubit.dart';
import '../widget/attachment/async_image/cubit/async_image_input_cubit.dart';
import '../widget/attachment/sync_image/cubit/sync_image_input_cubit.dart';

void init() {
  /* Cubits */
  sl.registerSingleton<AwQuestionsCubit>(AwQuestionsCubit(sl()),
      dispose: (awQuestionCubit) => awQuestionCubit.close());
  sl.registerFactory<SingleSelectCubit>(() => SingleSelectCubit());
  sl.registerFactory<MultiSelectBottomSheetCubit>(
      () => MultiSelectBottomSheetCubit());
  sl.registerFactory<SoundRecorderCubit>(() => SoundRecorderCubit());
  sl.registerFactory<ArrayQuestionCubit>(() => ArrayQuestionCubit(sl(), sl()));
  sl.registerFactory<NestedQuestionCubit>(() => NestedQuestionCubit());
  sl.registerFactory<AsyncImageInputCubit>(() => AsyncImageInputCubit(sl(), sl()));
  sl.registerFactory<SyncImageInputCubit>(() => SyncImageInputCubit());
  sl.registerFactory<SignatureCubit>(() => SignatureCubit());
  sl.registerFactory<AttendanceImageInputCubit>(() => AttendanceImageInputCubit());
  sl.registerSingleton<UploadOrSyncProcessCubit>(
      UploadOrSyncProcessCubit(sl(), sl()),
      dispose: (uploadOrSyncProcessCubit) => uploadOrSyncProcessCubit.close());
  sl.registerFactory<CodeScannerCubit>(() => CodeScannerCubit());
}
