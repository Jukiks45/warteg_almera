class AdminMenuModel {
  final int id;
  final String nama;
  final double harga;
  final String kategori;
  final String deskripsi;
  final String? gambar;

  AdminMenuModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.deskripsi,
    this.gambar,
  });

  factory AdminMenuModel.fromJson(Map<String, dynamic> json) {
    return AdminMenuModel(
      id: json['id'],
      nama: json['Nama'] ?? '',
      harga: (json['Harga'] as num).toDouble(),
      kategori: json['Kategori'] ?? '',
      deskripsi: json['Deskripsi'] ?? '',
      gambar: json['Gambar'],
    );
  }
}
