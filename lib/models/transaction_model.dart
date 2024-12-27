import 'dart:convert';

class TransactionModel {
  final int? id;
  final int productId;
  final int quantity;
  final String date;
  final String typeTransaction;

  TransactionModel({
    this.id,
    required this.productId,
    required this.quantity,
    required this.date,
    required this.typeTransaction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idProduct': productId,
      'quantity': quantity,
      'date': date,
      'typeTransaction': typeTransaction,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? 0,
      productId: map['idProduct'] ?? 0,
      quantity: map['quantity'] ?? 0,
      typeTransaction: map['typeTransaction'] ?? 'unknown',
      date: map['date'] ?? 'unknown',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
        id: json['id'],
        productId: json['id_product'],
        quantity: json['quantity'],
        date: json['date'],
        typeTransaction: json['type_transaction']);
  }
}
