import 'package:awign/workforce/core/data/local/database/boxes.dart';
import 'package:awign/workforce/core/data/local/database/logging_event_ho/logging_event_hive_object.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/network/data_source/logging_remote_data_source.dart';
import 'package:awign/workforce/core/utils/app_log.dart';

abstract class LoggingRemoteRepository {
  Future sentLoggingEvents();
}

class LoggingRemoteRepositoryImpl implements LoggingRemoteRepository {
  final LoggingRemoteDataSource _dataSource;
  LoggingRemoteRepositoryImpl(this._dataSource);

  @override
  Future sentLoggingEvents() async {
    try {
      final loggingBox = Boxes.getLoggingBox();
      if (loggingBox.isNotEmpty) {
        Iterable<LoggingEventHO> loggingEventHOList = loggingBox.values;
        List<Map<String, Object?>> jsonList = [];
        for (var loggingEvent in loggingEventHOList) {
          jsonList.add(loggingEvent.toJson());
        }
        final apiResponse = await _dataSource.sentLoggingEvents(jsonList);
        if (apiResponse.status == ApiResponse.success) {
          loggingBox.clear();
        }
      }
    } catch (e, stacktrace) {
      AppLog.e('getLoggingEvent : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
