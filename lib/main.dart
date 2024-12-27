import 'package:advance_inventory/pages/barang/list_product_page.dart';
import 'package:advance_inventory/pages/dashboard_page.dart';
import 'package:advance_inventory/pages/login_page.dart';
import 'package:advance_inventory/pages/register_page.dart';
import 'package:advance_inventory/pages/supplier/list_supplier_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hsdrkgpkduwjraoexxfd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhzZHJrZ3BrZHV3anJhb2V4eGZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwMjY2NzQsImV4cCI6MjA1MDYwMjY3NH0.OihwpBh9bz1ry0EnJ6krSCLZ3nhWu4hArXaJhNPwgA4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advance Inventory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
       // '/': (context) => const SplashPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/barangList': (context) => const ListProductPage(),
        '/supplierList': (context) => const ListSupplierPage(),
      },
    );
  }
}
