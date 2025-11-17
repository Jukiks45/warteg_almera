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
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0.0,
      kategori: json['kategori']?.toString() ?? '',
      gambar: json['Image_network']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'Image_network': gambar,
    };
  }
}