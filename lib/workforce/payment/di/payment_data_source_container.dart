import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/payment/data/network/data_source/beneficiary_remote_data_source.dart';
import 'package:awign/workforce/payment/data/network/data_source/documents_verification_remote_data_source.dart';
import 'package:awign/workforce/payment/data/network/data_source/earning_remote_data_source.dart';
import 'package:awign/workforce/payment/data/network/data_source/payment_bff_data_source.dart';
import 'package:awign/workforce/payment/data/network/data_source/pds_remote_data_source.dart';
import 'package:awign/workforce/payment/data/network/data_source/pts_remote_data_source.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<PDSRemoteDataSource>(() => PDSRemoteDataSourceImpl());
  sl.registerFactory<PTSRemoteDataSource>(() => PTSRemoteDataSourceImpl());
  sl.registerFactory<BeneficiaryRemoteDataSource>(() => BeneficiaryRemoteDataSourceImpl());
  sl.registerFactory<DocumentsVerificationRemoteDataSource>(() => DocumentsVerificationRemoteDataSourceImpl());
  sl.registerFactory<EarningRemoteDataSource>(() => EarningRemoteDataSourceImpl());
  sl.registerFactory<PaymentBffDataSource>(() => PaymentBffDataSourceImpl());
}
