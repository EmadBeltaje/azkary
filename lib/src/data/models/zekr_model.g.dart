// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zekr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZekrModelAdapter extends TypeAdapter<ZekrModel> {
  @override
  final int typeId = 1;

  @override
  ZekrModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZekrModel(
      id: fields[0] as int,
      text: fields[1] as String,
      count: fields[2] as int,
      currentCount: fields[3] as int,
      audio: fields[4] as String?,
      filename: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ZekrModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.currentCount)
      ..writeByte(4)
      ..write(obj.audio)
      ..writeByte(5)
      ..write(obj.filename);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZekrModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
