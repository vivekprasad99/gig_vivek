import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/payment/data/repository/beneficiary_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/documents_verification_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/earning_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/payment_bff_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/pds_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/pts_remote_repository.dart';

void init() {
  /* Repositories */
  sl.registerFactory<PDSRemoteRepository>(() => PDSRemoteRepositoryImpl(sl()));
  sl.registerFactory<PTSRemoteRepository>(() => PTSRemoteRepositoryImpl(sl()));
  sl.registerFactory<BeneficiaryRemoteRepository>(() => BeneficiaryRemoteRepositoryImpl(sl()));
  sl.registerFactory<DocumentsVerificationRemoteRepository>(() => DocumentsVerificationRemoteRepositoryImpl(sl()));
  sl.registerFactory<EarningRemoteRepository>(() => EarningRemoteRepositoryImpl(sl()));
  sl.registerFactory<PaymentBffRemoteRepository>(() => PaymentBffRemoteRepositoryImpl(sl()));
}
