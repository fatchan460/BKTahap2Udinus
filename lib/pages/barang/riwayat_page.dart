import 'package:advance_inventory/pages/barang/list_product_page.dart';
import 'package:flutter/material.dart';
import 'package:advance_inventory/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/db_helper.dart';
import '../../models/transaction_model.dart';

class RiwayatPage extends StatefulWidget {
  final ProductModel product;

  const RiwayatPage({super.key, required this.product});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late Future<List<TransactionModel>> _transactions;

  final _formkey = GlobalKey<FormState>();

  late final String _name;
  late final int _stock;
  late final int _idProduct;
  String jenisTransaksi = 'Masuk';
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _stock = widget.product.stock;
    _idProduct = widget.product.id!;
  }

  Future<void> _updateAndAddHistory() async {
    final perubahanStok = int.tryParse(_jumlahController.text);
    if (perubahanStok == null || perubahanStok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan jumlah stok yang valid!')),
      );
      return;
    } else if (jenisTransaksi == 'Keluar' && perubahanStok > _stock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stok keluar tidak bisa lebih dari stok yang ada')));
      return;
    }

    if (_idProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID produk tidak valid!')),
      );
      return;
    }
    late int stokBaru;
    if (jenisTransaksi == "Masuk") {
      stokBaru = _stock + perubahanStok;
    } else {
      stokBaru = _stock - perubahanStok;
    }
    try {
      await Supabase.instance.client.from('transaction').insert({
        'id_product': _idProduct,
        'date': _tanggalController.text,
        'quantity': _jumlahController.text,
        'type_transaction': jenisTransaksi,
      });
      await Supabase.instance.client.from('products').update({
        'stok': stokBaru,
      }).eq('id', _idProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok berhasil diperbarui.')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Page'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formkey, // Hubungkan dengan GlobalKey
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name : $_name',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock : $_stock',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tanggalController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jumlahController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah is required';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Enter a valid jumlah';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        jenisTransaksi = 'Keluar';
                        _updateAndAddHistory();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Keluar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        jenisTransaksi = 'Masuk';
                        _updateAndAddHistory();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
