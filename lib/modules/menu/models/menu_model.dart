import 'package:hive/hive.dart';

part 'menu_model.g.dart';

@HiveType(typeId: 0) // typeId harus unik untuk setiap model Hive
class MenuModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nama;

  @HiveField(2)
  final String deskripsi;

  @HiveField(3)
  final double harga;

  @HiveField(4)
  final String kategori;

  @HiveField(5)
  final String gambar;

  MenuModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.gambar,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      // Pastikan harga selalu double, handle jika dari API datang sebagai integer
      harga: (json['harga'] as num).toDouble(),
      kategori: json['kategori'],
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'gambar': gambar,
    };
  }

  MenuModel copyWith({
    int? id,
    String? nama,
    String? deskripsi,
    double? harga,
    String? kategori,
    String? gambar,
  }) {
    return MenuModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      kategori: kategori ?? this.kategori,
      gambar: gambar ?? this.gambar,
    );
  }
}
