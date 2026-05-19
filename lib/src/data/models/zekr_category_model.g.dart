// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zekr_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZekrCategoryModelAdapter extends TypeAdapter<ZekrCategoryModel> {
  @override
  final int typeId = 2;

  @override
  ZekrCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZekrCategoryModel(
      id: fields[0] as int,
      name: fields[1] as String,
      type: fields[2] as String,
      azkar: (fields[3] as List).cast<ZekrModel>(),
      lastResetTime: fields[4] as String?,
      audio: fields[5] as String?,
      filename: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ZekrCategoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.azkar)
      ..writeByte(4)
      ..write(obj.lastResetTime)
      ..writeByte(5)
      ..write(obj.audio)
      ..writeByte(6)
      ..write(obj.filename);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZekrCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
