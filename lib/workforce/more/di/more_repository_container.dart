import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/more/data/repository/leaderboard/leaderboard_remote_repository.dart';

void init() {
  /* Repositories */
  sl.registerFactory<LeaderBoardRemoteRepository>(() => LeaderBoardRemoteRepositoryImpl(sl()));
}
