// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calories_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaloriesDataModelAdapter extends TypeAdapter<CaloriesDataModel> {
  @override
  final typeId = 0;

  @override
  CaloriesDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaloriesDataModel(
      totalCalories: (fields[0] as num).toDouble(),
      activeCalories: (fields[1] as num).toDouble(),
      basalCalories: (fields[2] as num).toDouble(),
      date: fields[3] as DateTime,
      source: fields[4] == null ? 'API Ninjas' : fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CaloriesDataModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalCalories)
      ..writeByte(1)
      ..write(obj.activeCalories)
      ..writeByte(2)
      ..write(obj.basalCalories)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaloriesDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
