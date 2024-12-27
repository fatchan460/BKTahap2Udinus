import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product_model.dart';
import '../models/transaction_model.dart';

class DbHelper {
  Database? _database;

  Future<void> _createDB(Database db, int version) async {
    //   await db.execute('''
    //   CREATE TABLE product(
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     name TEXT ,
    //     price INTEGER ,
    //     stock INTEGER,
    //     image BLOB,
    //     description TEXT DEFAULT '',
    //     category TEXT,
    //   )
    // ''');

    await db.execute('''
    CREATE TABLE product(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price INTEGER,
      stock INTEGER,
      category TEXT,
      description TEXT,
      image BLOB 
    )
  ''');

    await db.execute('''
    CREATE TABLE transaksi(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      idProduct INTEGER,
      quantity INTEGER,
      typeTransaction TEXT,
      date TEXT,
      FOREIGN KEY (idProduct) REFERENCES product (id)
    )
  ''');
  }
  Future<List<TransactionModel>> getTransactions(int id) async {
    final db = await getDB;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'transaksi',
        where: 'idProduct = ?',
        whereArgs: [id],
        orderBy: 'id DESC',
      );
      return results.map((res) => TransactionModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions db: $e');
    }
  }
  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await getDB;
    try {
      // Memulai transaksi database
      return await db.transaction((txn) async {
        // Insert ke tabel transaksi
        final int transaksiId = await txn.insert('transaksi', transaction.toMap());

        // Mendapatkan stok produk saat ini
        final List<Map<String, dynamic>> productData = await txn.query(
          'product',
          where: 'id = ?',
          whereArgs: [transaction.productId],
        );

        if (productData.isEmpty) {
          throw Exception('Produk dengan ID ${transaction.productId} tidak ditemukan.');
        }

        // Hitung stok baru berdasarkan jenis transaksi
        final int currentStock = productData.first['stock'];
        int updatedStock = currentStock;

        if (transaction.typeTransaction == 'keluar') {
          updatedStock -= transaction.quantity;
          if (updatedStock < 0) {
            throw Exception('Stok tidak mencukupi untuk penjualan.');
          }
        } else if (transaction.typeTransaction == 'masuk') {
          updatedStock += transaction.quantity;
        } else {
          throw Exception('Jenis transaksi tidak valid.');
        }

        // Update stok produk di tabel product
        await txn.update(
          'product',
          {'stock': updatedStock},
          where: 'id = ?',
          whereArgs: [transaction.productId],
        );

        return transaksiId; // Kembalikan ID transaksi yang baru ditambahkan
      });
    } catch (e) {
      throw Exception('Gagal menambahkan transaksi: $e');
    }
  }

  Future<void> fixNullDescriptions() async {
    final db = await DbHelper().getDB;
    await db.rawUpdate('UPDATE product SET description = ? WHERE description IS NULL', ['']);
  }

  Future<void> _migrateDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE product ADD COLUMN description TEXT DEFAULT ""');
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _migrateDB,
    );
  }

  Future<Database> get getDB async {
    _database ??= await _initDB('product.db');
    return _database!;
  }

  Future<int> insert(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.insert('product', product.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan data: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await getDB;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'product',
        orderBy: 'id DESC',
      );
      return results.map((res) => ProductModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Gagal mendapatkan data: $e');
    }
  }

  Future<int> update(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.update(
        'product',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui data: $e');
    }
  }

  Future<int> delete(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.delete(
        'product',
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }
}


