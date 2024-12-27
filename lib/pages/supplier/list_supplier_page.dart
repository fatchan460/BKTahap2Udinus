import 'package:advance_inventory/models/supplier_model.dart';
import 'package:advance_inventory/pages/supplier/detail_supplier_page.dart';
import 'package:advance_inventory/pages/supplier/edit_supplier_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'add_supplier_page.dart';

class ListSupplierPage extends StatefulWidget {
  const ListSupplierPage({super.key});

  @override
  _ListSupplierPageState createState() => _ListSupplierPageState();
}

class _ListSupplierPageState extends State<ListSupplierPage> {
  late Future<List<SupplierModel>> _supplier;

  @override
  void initState() {
    super.initState();
    _refreshSupplier();
  }

  void _refreshSupplier() {
    setState(() {
      _supplier = _getSuppliers();
    });
  }

  Future<void> _deleteSupplier(int supplierId) async {
    try {
      final products = await Supabase.instance.client
          .from('products')
          .select('id,image_path')
          .eq('id_supplier', supplierId);
      final productData = products as List;
      final productIds = (products as List).map((product) => product['id']).toList();
      if (productIds.isNotEmpty) {
        await Supabase.instance.client
            .from('transaction')
            .delete()
            .inFilter('id_product', productIds);
      }
      for (final product in productData) {
        final imagePath = product['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          final relativePath = imagePath.split('/').last;
          await Supabase.instance.client.storage
              .from('inventory')
              .remove([relativePath]);
        }
      }
      await Supabase.instance.client
          .from('products')
          .delete()
          .eq('id_supplier', supplierId);
      await Supabase.instance.client
          .from('suppliers')
          .delete()
          .eq('id', supplierId);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Supplier berhasil dihapus!')));
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus supplier: $e')));
    }
  }


  Future<List<SupplierModel>> _getSuppliers() async {
    try {
      final response =
          await Supabase.instance.client.from('suppliers').select();
      return response.map((json) => SupplierModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Supplier"),
      ),
      body: FutureBuilder<List<SupplierModel>>(
        future: _supplier,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Product found'));
          } else {
            final suppliers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Text('Nama : ${suppliers[index].nama}'),
                        Text('Alamat : ${suppliers[index].alamat}'),
                        Text('Kontak : ${suppliers[index].kontak}'),
                        const SizedBox(height: 10),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return EditSupplierPage(
                                        supplier: suppliers[index]);
                                  }));
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return DetailSupplierPage(
                                      supplier: suppliers[index],
                                    );
                                  }));
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  _deleteSupplier(suppliers[index].id);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed:
            () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSupplierPage()),
          );
          if (result == true) {
            _refreshSupplier();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
