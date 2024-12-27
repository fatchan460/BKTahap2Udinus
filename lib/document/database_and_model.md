## DOKUMENTASI DATABASE SQLITE DAN MODEL

### 1. Import Package

```dart
flutter pub add sqflite
```

### 2. Database

1. Import Package `sqflite`.

```dart
import 'package:sqflite/sqflite.dart';
```

2. Buat Sebuah Class `DatabaseHelper` yang berisi method untuk membuat database.

```dart
class DbHelper {}
```

3. Inialiasi `Databases`.

```dart
class DbHelper {
    Database? _database;
}
```

### Semua Function `Future` bearada di dalam `DbHelper` Class.

4. Buat fungsi `_createDB` untuk membuat database dan tabel.

```dart
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE product(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT ,
      price INTEGER ,
      stock INTEGER,
      image BLOB
    )
  ''');
  }
```

- `CREATE TABLE product` adalah membuat tabel `product`.
- `id INTEGER PRIMARY KEY AUTOINCREMENT` adalah membuat kolom `id` dengan tipe data `INTEGER` sebagai primary key dan auto increment.
- `name TEXT` adalah membuat kolom `name` dengan tipe data `TEXT`.
- `price INTEGER` adalah membuat kolom `price` dengan tipe data `INTEGER`.
- `stock INTEGER` adalah membuat kolom `stock` dengan tipe data `INTEGER`.
- `image BLOB` adalah membuat kolom `image` dengan tipe data `BLOB`.

> Ketika `_createDB` dijalankan maka akan membuat tabel `product` dengan kolom `id`, `name`, `price`, `stock`, dan `image`.

5. Buat fungsi `initDb` untuk inisialisasi database.

```dart
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
```

- `getDatabasesPath()` adalah fungsi untuk mendapatkan path database.
- `openDatabase()` adalah fungsi untuk membuka database.
- `version` adalah versi database.
- `onCreate` adalah fungsi yang akan dijalankan ketika database dibuat.

6. Buat fungsi `database` untuk mengambil database.

```dart
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('product.db');
    return _database!;
  }
```

- `get` adalah fungsi untuk mengambil database. tanpa dalam bentuk function `database()`.
- `if (_database != null) return _database!;` adalah kondisi jika database sudah ada maka akan mengembalikan database yang sudah ada.
- `product.db` adalah nama database.
- `_database = await _initDB('product.db');` adalah kondisi jika database belum ada maka akan membuat database baru.
- `return _database!;` adalah mengembalikan database yang sudah dibuat.

7. Buat fungsi `insert` untuk menambahkan data ke dalam database.

```dart
  Future<int> insert(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.insert('product', product.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan data: $e');
    }
  }
```

- `insert(ProductModel product)` adalah fungsi untuk menambahkan data ke dalam database.
- `ProductModel` adalah model data.
- `final db = await getDB;` adalah mengambil database.
- `return await db.insert('product', product.toMap());` adalah menambahkan data ke dalam tabel `product`.
- `product.toMap()` adalah mengubah data ke dalam bentuk `Map`.
- `throw Exception('Gagal menambahkan data: $e');` adalah menampilkan pesan error jika gagal menambahkan data.
- `try catch` adalah fungsi untuk menangkap error.

8. Buat fungsi `getProduct` untuk mengambil data dari database.

```dart
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
```

- `getProducts()` adalah fungsi untuk mengambil data dari database.
- `final db = await getDB;` adalah mengambil database.
- `final List<Map<String, dynamic>> results = await db.query('product', orderBy: 'id DESC',);` adalah mengambil data dari tabel `product` dan diurutkan berdasarkan `id` secara descending.
- `return results.map((res) => ProductModel.fromMap(res)).toList();` adalah mengubah data ke dalam bentuk `List`.
- `ProductModel.fromMap(res)` adalah mengubah data ke dalam bentuk `ProductModel`.

9. Buat fungsi `update` untuk mengubah data di dalam database.

```dart
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
```

- `update(ProductModel product)` adalah fungsi untuk mengubah data di dalam database.
- `final db = await getDB;` adalah mengambil database.
- `return await db.update('product', product.toMap(), where: 'id = ?', whereArgs: [product.id],);` adalah mengubah data di dalam tabel `product`.
- `product.toMap()` adalah mengubah data ke dalam bentuk `Map`.
- `where: 'id = ?'` adalah kondisi untuk mengubah data berdasarkan `id`.
- `whereArgs: [product.id]` adalah parameter untuk mengubah data berdasarkan `id`.
- `throw Exception('Gagal memperbarui data: $e');` adalah menampilkan pesan error jika gagal mengubah data.

10. Buat fungsi `delete` untuk menghapus data di dalam database.

```dart
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
```

- `delete(ProductModel product)` adalah fungsi untuk menghapus data di dalam database.
- `final db = await getDB;` adalah mengambil database.
- `return await db.delete('product', where: 'id = ?', whereArgs: [product.id],);` adalah menghapus data di dalam tabel `product`.
- `where: 'id = ?'` adalah kondisi untuk menghapus data berdasarkan `id`.
- `whereArgs: [product.id]` adalah parameter untuk menghapus data berdasarkan `id`.
- `throw Exception('Gagal menghapus data: $e');` adalah menampilkan pesan error jika gagal menghapus data.

### 3. Membuat Model

```dart
import 'dart:convert';
import 'dart:typed_data';

class ProductModel {
  final int? id;
  final String name;
  final int price;
  final int stock;
  final Uint8List? image;

  ProductModel(
      {this.id,
      required this.name,
      required this.price,
      required this.stock,
      this.image});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as int,
      stock: map['stock'] as int,
      image: map['image'] as Uint8List?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

```

### 4. Full Code

```dart
import '../models/product_model.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  Database? _database;

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE product(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT ,
      price INTEGER ,
      stock INTEGER,
      image BLOB
    )
  ''');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;
    return await openDatabase(path, version: 1, onCreate: _createDB);
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

```
