// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trackable_entity_ho.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackableDataHOAdapter extends TypeAdapter<TrackableDataHO> {
  @override
  final int typeId = 2;

  @override
  TrackableDataHO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackableDataHO(
      accuracy: fields[0] as double?,
      address: fields[1] as String?,
      area: fields[2] as String?,
      city: fields[3] as String?,
      countryName: fields[4] as String?,
      latLong: (fields[5] as List?)?.cast<double>(),
      pinCode: fields[6] as String?,
      timeStamp: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackableDataHO obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.accuracy)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.countryName)
      ..writeByte(5)
      ..write(obj.latLong)
      ..writeByte(6)
      ..write(obj.pinCode)
      ..writeByte(7)
      ..write(obj.timeStamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackableDataHOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
