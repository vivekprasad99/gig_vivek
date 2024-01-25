import 'package:awign/workforce/auth/feature/app_language_selection/cubit/app_language_selection_cubit.dart';
import 'package:awign/workforce/auth/feature/confirm_pin/cubit/confirm_pin_cubit.dart';
import 'package:awign/workforce/auth/feature/education_details/cubit/education_details_cubit.dart';
import 'package:awign/workforce/auth/feature/email_sign_in/cubit/email_sign_in_cubit.dart';
import 'package:awign/workforce/auth/feature/enter_email_manually/cubit/enter_email_manually_cubit.dart';
import 'package:awign/workforce/auth/feature/forgot_pin/cubit/forgot_pin_cubit.dart';
import 'package:awign/workforce/auth/feature/onboarding_questions/cubit/onboarding_questions_cubit.dart';
import 'package:awign/workforce/auth/feature/otp_less_login/cubit/otp_less_cubit.dart';
import 'package:awign/workforce/auth/feature/otp_verification/cubit/otp_verification_cubit.dart';
import 'package:awign/workforce/auth/feature/personal_details/cubit/personal_details_cubit.dart';
import 'package:awign/workforce/auth/feature/phone_verification/cubit/phone_verification_cubit.dart';
import 'package:awign/workforce/auth/feature/splash/cubit/splash_cubit.dart';
import 'package:awign/workforce/auth/feature/user_email/cubit/user_email_cubit.dart';
import 'package:awign/workforce/auth/feature/user_location/cubit/user_location_cubit.dart';
import 'package:awign/workforce/auth/feature/welcome/cubit/welcome_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/whatsapp/cubit/whatsapp_subscription_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/notification/cubit/notification_cubit.dart';
import 'package:awign/workforce/core/widget/take_a_tour/cubit/take_a_tour_cubit.dart';
import 'package:awign/workforce/more/feature/rate_us/cubit/rate_us_cubit.dart';

void init() {
  /* Cubits */
  sl.registerFactory<SplashCubit>(() => SplashCubit(sl(), sl()));
  sl.registerFactory<WelcomeCubit>(() => WelcomeCubit(sl()));
  sl.registerFactory<UserEmailCubit>(() => UserEmailCubit(sl()));
  sl.registerFactory<AppLanguageSelectionCubit>(
      () => AppLanguageSelectionCubit(sl()));
  sl.registerFactory<EmailSignInCubit>(() => EmailSignInCubit(sl()));
  sl.registerFactory<PersonalDetailsCubit>(
      () => PersonalDetailsCubit(sl(), sl()));
  sl.registerFactory<UserLocationCubit>(() => UserLocationCubit(sl()));
  sl.registerFactory<PhoneVerificationCubit>(
      () => PhoneVerificationCubit(sl()));
  sl.registerFactory<EducationDetailsCubit>(() => EducationDetailsCubit(sl()));
  sl.registerFactory<OtpVerificationCubit>(
      () => OtpVerificationCubit(sl(), sl()));
  sl.registerFactory<ForgotPINCubit>(() => ForgotPINCubit(sl()));
  sl.registerFactory<ConfirmPinCubit>(() => ConfirmPinCubit(sl()));
  sl.registerSingleton<TakeATourCubit>(TakeATourCubit(),
      dispose: (takeATourCubit) => takeATourCubit.close());
  sl.registerFactory<RateUsCubit>(() => RateUsCubit(sl()));
  sl.registerFactory<NotificationCubit>(() => NotificationCubit(sl()));
  sl.registerFactory<OtpLessCubit>(() => OtpLessCubit(sl()));
  sl.registerFactory<EnterEmailManuallyCubit>(
      () => EnterEmailManuallyCubit(sl()));
  sl.registerFactory<OnboardingQuestionsCubit>(
      () => OnboardingQuestionsCubit(sl()));
  sl.registerFactory<WhatsappSubscriptionCubit>(
      () => WhatsappSubscriptionCubit(sl()));
}
