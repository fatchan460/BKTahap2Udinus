import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = Supabase.instance;

  @override
  void initState(){
    super.initState();
    _CheckLoginStatus();
  }
  Future<void> login() async {
    try {
      await _auth.client.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')),
      );
    }
  }
  Future<void> _CheckLoginStatus() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
      final session = Supabase.instance.client.auth.currentSession;
      Future.delayed(const Duration(seconds: 1), () {
        if (session != null) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          return 0;
        }
      });
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: login, child: const Text('Login'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun? '),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  'Daftar di sini',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          )

        ],
      ),),
    );
  }

}