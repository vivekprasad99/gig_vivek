import 'package:awign/workforce/core/data/local/database/logging_event_ho/logging_event_hive_object.dart';
import 'package:hive/hive.dart';

import 'upload_entity_ho/upload_entity_ho.dart';

class Boxes {
  static const String awignLoggingTable = 'awignLoggingTable';
  static const String uploadEntityTable = 'uploadEntityTable';

  static const int loggingEventHoTypeID = 0;
  static const int uploadEntityHoTypeID = 1;
  static const int trackableEntityHoTypeID = 2;

  static Box<LoggingEventHO> getLoggingBox() =>
      Hive.box<LoggingEventHO>(awignLoggingTable);

  static Box<UploadEntityHO> getUploadEntityBox() =>
      Hive.box<UploadEntityHO>(uploadEntityTable);
}
