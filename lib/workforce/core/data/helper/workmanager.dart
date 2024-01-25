import 'package:awign/workforce/core/data/repository/logging_repository.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/app_log.dart';

class WorkerManager {
  static void callbackDispatcher() async {
    try {
      final LoggingRemoteRepository loggingRepository =
          sl<LoggingRemoteRepository>();
      await loggingRepository.sentLoggingEvents();
    } catch (e, stacktrace) {
      AppLog.e(
          'callbackDispatcher : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
