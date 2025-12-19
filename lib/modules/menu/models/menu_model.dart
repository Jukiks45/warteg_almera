class MenuModel {
  final int id;
  final String nama;
  final String deskripsi;
  final double harga;
  final String kategori;
  final String? gambar;

  MenuModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    this.gambar,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int,
      nama: json['Nama']?.toString() ?? '',
      deskripsi: json['Deskripsi']?.toString() ?? '',
      harga: (json['Harga'] as num).toDouble() * 1000, // opsional scaling
      kategori: json['Kategori']?.toString() ?? '',
      gambar: json['Gambar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Nama': nama,
      'Deskripsi': deskripsi,
      'Harga': harga / 1000,
      'Kategori': kategori,
      'Gambar': gambar,
    };
  }
}
