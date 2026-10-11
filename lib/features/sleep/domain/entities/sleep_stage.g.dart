// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_stage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepStageAdapter extends TypeAdapter<SleepStage> {
  @override
  final typeId = 1;

  @override
  SleepStage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SleepStage.deep;
      case 1:
        return SleepStage.rem;
      case 2:
        return SleepStage.light;
      case 3:
        return SleepStage.awake;
      default:
        return SleepStage.deep;
    }
  }

  @override
  void write(BinaryWriter writer, SleepStage obj) {
    switch (obj) {
      case SleepStage.deep:
        writer.writeByte(0);
      case SleepStage.rem:
        writer.writeByte(1);
      case SleepStage.light:
        writer.writeByte(2);
      case SleepStage.awake:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepStageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
