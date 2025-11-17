import 'package:hive/hive.dart';

part 'menu_model.g.dart';

@HiveType(typeId: 0)
class MenuModel extends HiveObject {
  @HiveField(0)
  final int id; // PASTIKAN INI ADALAH 'int'

  @HiveField(1)
  final String nama;

  @HiveField(2)
  final double harga;

  @HiveField(3)
  final String kategori;

  @HiveField(4)
  final String? deskripsi;

  @HiveField(5)
  final String? gambar;

  MenuModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    this.deskripsi,
    this.gambar,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
  return MenuModel(
    id: (json['id'] is int) ? json['id'] as int
        : (json['id'] is String) ? int.tryParse(json['id']) ?? 0
        : 0,
    nama: (json['nama'] as String?) ?? 'Tanpa Nama',
    harga: (json['harga'] as num?)?.toDouble() ?? 0.0,
    kategori: (json['kategori'] as String?) ?? 'Lainnya',
    deskripsi: (json['deskripsi'] as String?),
    gambar: (json['gambar'] as String?),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }
}
