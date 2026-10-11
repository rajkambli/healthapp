// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_segment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepSegmentModelAdapter extends TypeAdapter<SleepSegmentModel> {
  @override
  final typeId = 2;

  @override
  SleepSegmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepSegmentModel(
      id: fields[0] as String,
      stage: fields[1] as SleepStage,
      start: fields[2] as DateTime,
      end: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SleepSegmentModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stage)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSegmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
