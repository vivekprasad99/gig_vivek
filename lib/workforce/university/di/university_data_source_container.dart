import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/university/data/network/data_source/university/university_remote_data_source.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<UniversityRemoteDataSource>(() => UniversityRemoteDataSourceImpl());
}