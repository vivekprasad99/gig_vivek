// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging_event_hive_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoggingEventHOAdapter extends TypeAdapter<LoggingEventHO> {
  @override
  final int typeId = 0;

  @override
  LoggingEventHO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoggingEventHO()
      ..id = fields[0] as int?
      ..userId = fields[1] as int?
      ..userRole = fields[2] as String?
      ..pageName = fields[3] as String?
      ..sectionName = fields[4] as String?
      ..event = fields[5] as String?
      ..action = fields[6] as String?
      ..origin = fields[7] as String?
      ..applicationName = fields[8] as String?
      ..device = (fields[9] as Map).cast<String, String>()
      ..eventAt = fields[10] as String?
      ..otherProperty = (fields[11] as Map?)?.cast<String, String>();
  }

  @override
  void write(BinaryWriter writer, LoggingEventHO obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userRole)
      ..writeByte(3)
      ..write(obj.pageName)
      ..writeByte(4)
      ..write(obj.sectionName)
      ..writeByte(5)
      ..write(obj.event)
      ..writeByte(6)
      ..write(obj.action)
      ..writeByte(7)
      ..write(obj.origin)
      ..writeByte(8)
      ..write(obj.applicationName)
      ..writeByte(9)
      ..write(obj.device)
      ..writeByte(10)
      ..write(obj.eventAt)
      ..writeByte(11)
      ..write(obj.otherProperty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggingEventHOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
