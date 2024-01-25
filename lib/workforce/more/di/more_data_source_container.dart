import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/more/data/network/data_source/leaderboard/leaderboard_remote_data_source.dart';

void init() {
  /* Data Sources */
  sl.registerFactory<LeaderBoardRemoteDataSource>(() => LeaderBoardRemoteDataSourceImpl());
}
