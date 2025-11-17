import 'package:hive/hive.dart';
import 'cart_item_model.dart';
import '../../menu/models/menu_model.dart';

class CartItemAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 0;

  @override
  CartItemModel read(BinaryReader reader) {
    final menuData = {
      'id': reader.readInt(),
      'nama': reader.readString(),
      'deskripsi': reader.readString(),
      'harga': reader.readDouble(),
      'kategori': reader.readString(),
      'Image_network': reader.readString(),
    };
    
    final quantity = reader.readInt();
    
    return CartItemModel(
      menu: MenuModel.fromJson(menuData),
      quantity: quantity,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer.writeInt(obj.menu.id);
    writer.writeString(obj.menu.nama);
    writer.writeString(obj.menu.deskripsi);
    writer.writeDouble(obj.menu.harga);
    writer.writeString(obj.menu.kategori);
    writer.writeString(obj.menu.gambar ?? '');
    writer.writeInt(obj.quantity);
  }
}
