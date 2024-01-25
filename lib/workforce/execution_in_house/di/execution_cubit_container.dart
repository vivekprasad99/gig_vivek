import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/location_captured_bottom_sheet/cubit/location_captured_bottom_sheet_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/application_id_details/cubit/application_id_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/cubit/application_section_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/cubit/attendance_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_capture_image/cubit/attendance_capture_image_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_input_fields/cubits/attendance_input_fields_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_upload_image/cubit/attendance_upload_image_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/availablity/cubit/availablity_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/cubit/batches_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/cubit/category_application_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/cubit/dashboard_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/cubit/call_bridge_bottom_sheet_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/cubit/lead_list_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_map_view/cubit/lead_map_view_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/cubit/lead_screens_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/leadpayout/cubit/leadpayout_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/offer_letter/cubit/offer_letter_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/online_test/cubit/online_test_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/sign_offer_letter/cubit/sign_offer_letter_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/cubit/slots_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/worklog/cubit/worklog_cubit.dart';

void init() {
  /* Cubits */
  sl.registerFactory<CategoryApplicationDetailsCubit>(
      () => CategoryApplicationDetailsCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory<OfferLetterCubit>(() => OfferLetterCubit(sl()));
  sl.registerFactory<SignOfferLetterCubit>(() => SignOfferLetterCubit(sl()));
  sl.registerFactory<ApplicationSectionDetailsCubit>(
      () => ApplicationSectionDetailsCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory<OnlineTestCubit>(
      () => OnlineTestCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory<SlotsCubit>(() => SlotsCubit(sl()));
  sl.registerFactory<BatchesCubit>(() => BatchesCubit(sl()));
  sl.registerFactory<DashboardCubit>(
      () => DashboardCubit(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory<LeadListCubit>(
      () => LeadListCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory<LeadScreensCubit>(() => LeadScreensCubit(sl(), sl()));
  sl.registerFactory<ApplicationIdDetailsCubit>(
      () => ApplicationIdDetailsCubit(sl()));
  sl.registerFactory<WorklogCubit>(() => WorklogCubit(sl()));
  sl.registerFactory<AvailabilityCubit>(() => AvailabilityCubit(sl()));
  sl.registerFactory<LeadpayoutCubit>(() => LeadpayoutCubit(sl()));
  sl.registerFactory<CallBridgeBottomSheetCubit>(
      () => CallBridgeBottomSheetCubit(sl()));
  sl.registerFactory<LeadMapViewCubit>(() => LeadMapViewCubit());
  sl.registerFactory<AttendanceCubit>(() => AttendanceCubit(sl()));
  sl.registerFactory<AttendanceUploadImageCubit>(
      () => AttendanceUploadImageCubit());
  sl.registerFactory<AttendanceInputFieldsCubit>(
      () => AttendanceInputFieldsCubit());
  sl.registerFactory<AttendanceCaptureImageCubit>(
      () => AttendanceCaptureImageCubit());
  sl.registerFactory<LocationCapturedBottomSheetCubit>(
      () => LocationCapturedBottomSheetCubit());
}
