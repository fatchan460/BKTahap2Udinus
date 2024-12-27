import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
const DashboardPage({super.key});

@override
State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  Future<int> _getTotalProduct() async {
    try {
      final response = await Supabase.instance.client.from('products').select();
      if (response.isEmpty) {
        return 0;
      }
      return response.length;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    }
  }
  Future<int> _getTotalSupplier() async {
    try {
      final response = await Supabase.instance.client.from('suppliers').select();
      if (response.isEmpty) {
        return 0;
      }
      return response.length;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data:\n ${e.message}');
    }
  }
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<int>(
                  future: _getTotalProduct(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final totalProduct = snapshot.data ?? 0;
                    /*return _DashboardCard(
                      title: 'Barang',
                      icon: Icons.inventory_sharp,
                      total: totalProduct,
                      onTap: () {
                        Navigator.pushNamed(context, '/barangList');
                      },
                    )*/
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 80,
                              color: Colors.lightBlueAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Product',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalProduct items',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/barangList');
                              },
                              child: const Text(
                                'Lihat List',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: _getTotalSupplier(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final totalSupplier = snapshot.data ?? 0;
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store,
                              size: 80,
                              color: Colors.lightBlueAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Supplier',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalSupplier orang',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/supplierList');
                              },
                              child: const Text(
                                'Lihat List',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(), // Spacer untuk mendorong tombol ke bawah
            ElevatedButton(
              onPressed: _logout,
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ));
  }
}