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
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: (json['harga'] ?? 0).toDouble(),
      kategori: json['kategori'] ?? '',
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
}