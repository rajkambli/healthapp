// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepSessionModelAdapter extends TypeAdapter<SleepSessionModel> {
  @override
  final typeId = 3;

  @override
  SleepSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepSessionModel(
      id: fields[0] as String,
      start: fields[1] as DateTime,
      end: fields[2] as DateTime,
      segments: fields[3] == null
          ? const []
          : (fields[3] as List).cast<SleepSegmentModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, SleepSessionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end)
      ..writeByte(3)
      ..write(obj.segments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
