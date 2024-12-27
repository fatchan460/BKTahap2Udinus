import 'dart:convert';
import 'dart:typed_data';

class ProductModel {
  final int id;
  final String name;
  final int price;
  final int stock;
  final String image;
  final String description;
  final String category;
  final int idSupplier;

  ProductModel(
      {required this.id,
      required this.name,
      required this.price,
      required this.stock,
      required this.image,
      required this.description,
      required this.category,
      required this.idSupplier});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'image': image,
      'description': description,
      'category': category,
      'idSupplier': idSupplier,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      price: map['price'] as int,
      stock: map['stock'] as int,
      image: map['image'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      idSupplier: map['idSupplier'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json['id'],
        name: json['nama'],
        price: json['harga'],
        stock: json['stok'],
        image: json['image_path'],
        description: json['deskripsi'],
        category: json['kategori'],
        idSupplier: json['id_supplier']);
  }
}
