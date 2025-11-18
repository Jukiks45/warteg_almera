// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 2;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemModel(
      menuId: fields[0] as int,
      menuNama: fields[1] as String,
      menuDeskripsi: fields[2] as String,
      menuHarga: fields[3] as double,
      menuKategori: fields[4] as String,
      menuGambar: fields[5] as String?,
      quantity: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.menuId)
      ..writeByte(1)
      ..write(obj.menuNama)
      ..writeByte(2)
      ..write(obj.menuDeskripsi)
      ..writeByte(3)
      ..write(obj.menuHarga)
      ..writeByte(4)
      ..write(obj.menuKategori)
      ..writeByte(5)
      ..write(obj.menuGambar)
      ..writeByte(6)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
