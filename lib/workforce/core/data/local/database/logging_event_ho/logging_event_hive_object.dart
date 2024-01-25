import 'package:awign/workforce/core/data/local/database/boxes.dart';
import 'package:hive/hive.dart';

part 'logging_event_hive_object.g.dart';

@HiveType(typeId: Boxes.loggingEventHoTypeID)
class LoggingEventHO extends HiveObject {
  @HiveField(0)
  late int? id;
  @HiveField(1)
  late final int? userId;
  @HiveField(2)
  late final String? userRole;
  @HiveField(3)
  late final String? pageName;
  @HiveField(4)
  late final String? sectionName;
  @HiveField(5)
  late final String? event;
  @HiveField(6)
  late final String? action;
  @HiveField(7)
  late final String? origin;
  @HiveField(8)
  late final String? applicationName;
  @HiveField(9)
  late final Map<String, String> device;
  @HiveField(10)
  late final String? eventAt;
  @HiveField(11)
  late final Map<String, String>? otherProperty;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_role': userRole,
      'page_name': pageName,
      'section_name': sectionName,
      'event': event,
      'action': action,
      'origin': origin,
      'application_name': applicationName,
      'device': device,
      'event_at': eventAt,
      'other_properties': otherProperty,
    };
  }
}
