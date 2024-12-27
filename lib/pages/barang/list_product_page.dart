import 'package:advance_inventory/pages/barang/edit_page.dart';
import 'package:flutter/material.dart';
import 'package:advance_inventory/pages/barang/riwayat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import 'add_barang_page.dart';
import 'detail_page.dart';

class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  late Future<List<ProductModel>> _products;

  @override
  void initState() {
    super.initState();
    _products = _getProducts();
  }

  Future<List<ProductModel>> _getProducts() async {
    try{
      final response = await Supabase.instance.client.from('products').select();
      return response.map((json)=> ProductModel.fromJson(json)).toList();
    }catch (e){
      throw Exception("gagal load data : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Inventory System'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Product found'));
          } else {
            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                mainAxisExtent: 270,
              ),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  color: Colors.grey[200],
                  child: Padding(

                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: products[index].image != null
                              ? Image.network(
                            products[index].image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image,
                                  size: 200, color: Colors.grey);
                            },
                          )
                              : const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(products[index].name),
                        Text('Price: ${products[index].price}'),
                        Text('Stock: ${products[index].stock}'),
                        Text('Description: ${products[index].description}'),
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
                                        return EditPage(product: products[index]);
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return DetailPage(
                                      product: products[index],
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
                                  final relativePath = products[index].image.split('/').last;
                                  if (relativePath.isNotEmpty) {
                                    await Supabase.instance.client.storage
                                        .from('inventory')
                                        .remove([relativePath]);
                                  }
                                  final response = await Future.wait([
                                    Supabase.instance.client
                                        .from('products')
                                        .delete()
                                        .eq('id', products[index].id),
                                    Supabase.instance.client
                                        .from('transaction')
                                        .delete()
                                        .eq('id_product', products[index].id),
                                  ]);

                                  if (response.isNotEmpty) {
                                    setState(() {
                                      _products = _getProducts();
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                            'Berhasil menghapus product ${products[index].name}'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'Gagal menghapus product ${products[index].name}'),
                                      ),
                                    );
                                  }
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
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddPage();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
