import 'package:awign/workforce/banner/data/network/data_source/banner/banner_remote_data_source.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<BannerRemoteDataSource>(() => BannerRemoteDataSourceImpl());
}