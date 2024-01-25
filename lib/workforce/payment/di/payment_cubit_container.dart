import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/payment/feature/add_bank_details/cubit/add_bank_account_cubit.dart';
import 'package:awign/workforce/payment/feature/add_upi/cubit/add_upi_cubit.dart';
import 'package:awign/workforce/payment/feature/confirm_amount/cubit/confirm_amount_cubit.dart';
import 'package:awign/workforce/payment/feature/document_verification/cubit/document_verification_cubit.dart';
import 'package:awign/workforce/payment/feature/earning_statement/cubit/earning_statement_cubit.dart';
import 'package:awign/workforce/payment/feature/earnings/cubit/earnings_cubit.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/withdrawal_bottom_sheet/cubit/withdrawal_bottom_sheet_cubit.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/cubit/manage_beneficiary_cubit.dart';
import 'package:awign/workforce/payment/feature/select_beneficiary/cubit/select_beneficiary_cubit.dart';
import 'package:awign/workforce/payment/feature/tds_deduction_details/cubit/tds_deduction_details_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/cubit/withdrawal_history_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/bottom_sheet/cubit/transfer_details_bottom_sheet_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/tile/cubit/transfer_history_tile_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/cubit/withdrawal_verification_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/bottom_sheet/cubit/verify_existing_bank_account_cubit.dart';

void init() {
  /* Cubits */
  sl.registerFactory<EarningsCubit>(() => EarningsCubit(sl(), sl(), sl(), sl(),sl()));
  sl.registerFactory<WithdrawalHistoryCubit>(
      () => WithdrawalHistoryCubit(sl(), sl()));
  sl.registerFactory<WithdrawalVerificationCubit>(
      () => WithdrawalVerificationCubit(sl(), sl()));
  sl.registerFactory<DocumentVerificationCubit>(
      () => DocumentVerificationCubit(sl(), sl()));
  sl.registerFactory<VerifyExistingBankAccountCubit>(
      () => VerifyExistingBankAccountCubit(sl()));
  sl.registerFactory<AddBankAccountCubit>(() => AddBankAccountCubit(sl()));
  sl.registerFactory<AddUpiCubit>(() => AddUpiCubit(sl()));
  sl.registerFactory<ManageBeneficiaryCubit>(
      () => ManageBeneficiaryCubit(sl()));
  sl.registerFactory<EarningStatementCubit>(() => EarningStatementCubit(sl()));
  sl.registerFactory<WithdrawalBottomSheetCubit>(
      () => WithdrawalBottomSheetCubit(sl()));
  sl.registerFactory<SelectBeneficiaryCubit>(
      () => SelectBeneficiaryCubit(sl()));
  sl.registerFactory<TransferDetailsBottomSheetCubit>(
      () => TransferDetailsBottomSheetCubit(sl()));
  sl.registerFactory<TdsDeductionDetailsCubit>(
      () => TdsDeductionDetailsCubit());
  sl.registerFactory<ConfirmAmountCubit>(() => ConfirmAmountCubit(sl()));
  sl.registerFactory<TransferHistoryTileCubit>(() => TransferHistoryTileCubit());
}
