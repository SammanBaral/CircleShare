// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemHiveModelAdapter extends TypeAdapter<ItemHiveModel> {
  @override
  final int typeId = 1;

  @override
  ItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemHiveModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      categoryId: fields[2] as String?,
      locationId: fields[3] as String?,
      description: fields[4] as String?,
      availabilityStatus: fields[5] as String?,
      borrowerId: fields[6] as String?,
      imageName: fields[7] as String?,
      rulesNotes: fields[8] as String?,
      price: fields[9] as double,
      condition: fields[10] as String?,
      maxBorrowDuration: fields[11] as int,
      userId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.locationId)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.availabilityStatus)
      ..writeByte(6)
      ..write(obj.borrowerId)
      ..writeByte(7)
      ..write(obj.imageName)
      ..writeByte(8)
      ..write(obj.rulesNotes)
      ..writeByte(9)
      ..write(obj.price)
      ..writeByte(10)
      ..write(obj.condition)
      ..writeByte(11)
      ..write(obj.maxBorrowDuration)
      ..writeByte(12)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
