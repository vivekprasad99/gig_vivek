import 'package:awign/workforce/core/data/local/database/boxes.dart';
import 'package:awign/workforce/core/data/local/database/logging_event_ho/logging_event_hive_object.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/trackable_entity_ho.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveHelper {
  static Future hiveInit() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);
    if (!Hive.isAdapterRegistered(Boxes.loggingEventHoTypeID)) {
      Hive.registerAdapter(LoggingEventHOAdapter());
    }
    if (!Hive.isAdapterRegistered(Boxes.uploadEntityHoTypeID)) {
      Hive.registerAdapter(UploadEntityHOAdapter());
    }
    if (!Hive.isAdapterRegistered(Boxes.trackableEntityHoTypeID)) {
      Hive.registerAdapter(TrackableDataHOAdapter());
    }
    await Hive.openBox<LoggingEventHO>(Boxes.awignLoggingTable);
    await Hive.openBox<UploadEntityHO>(Boxes.uploadEntityTable);
  }
}
