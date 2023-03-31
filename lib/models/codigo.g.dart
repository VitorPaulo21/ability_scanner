// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codigo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CodigoAdapter extends TypeAdapter<Codigo> {
  @override
  final int typeId = 1;

  @override
  Codigo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Codigo(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Codigo obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.barCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodigoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
