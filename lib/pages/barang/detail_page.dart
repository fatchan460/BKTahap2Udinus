import 'package:advance_inventory/pages/barang/riwayat_page.dart';
import 'package:flutter/material.dart';
import 'package:advance_inventory/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';

class DetailPage extends StatefulWidget {
  final ProductModel product;

  const DetailPage({super.key, required this.product});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late ProductModel _product;
  late Future<List<TransactionModel>> _transaksi;
  String? SupplierName;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _transaksi = _getTransactionFromSupabase();
    _fetchSupplierName();
  }

  Future<void> _fetchSupplierName() async {
    try {
      final response = await Supabase.instance.client
          .from('suppliers')
          .select('nama')
          .eq('id', _product.idSupplier)
          .single();
      setState(() {
        SupplierName = response['nama'] as String?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil nama supplier: $e')),
      );
    }
  }

  Future<List<TransactionModel>> _getTransactionFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('transaction')
          .select()
          .eq('id_product', _product.id);
      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch histories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: _product.image != null
                    ? Image.network(
                        _product.image!,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image,
                              size: 200, color: Colors.grey);
                        },
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.white,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Name: ${_product.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'Supplier: ${SupplierName ?? 'Loading...'}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Price: ${_product.price}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Stock: ${_product.stock}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Description: ${_product.description}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Category: ${_product.category}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RiwayatPage(product: _product);
                  }));
                },
                child: Text('Tambah Transaksi')),
            const SizedBox(height: 16),
            FutureBuilder<List<TransactionModel>>(
              future: _transaksi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada riwayat transaksi.');
                }

                final transaksiList = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transaksiList.length,
                  itemBuilder: (context, index) {
                    final transaksi = transaksiList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                          title: Text('Tanggal: ${transaksi.date}'),
                          subtitle: Text(
                              'Jumlah: ${transaksi.quantity} \nJenis: ${transaksi.typeTransaction}')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
