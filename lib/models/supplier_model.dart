
class SupplierModel {
  final int id;
  final String nama;
  final String alamat;
  final String kontak;
  final String latitude;
  final String longitude;

  SupplierModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.kontak,
    required this.latitude,
    required this.longitude,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      kontak: map['kontak'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String,dynamic> {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'kontak': kontak,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      kontak: json['kontak'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

}
