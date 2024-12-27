import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaController = TextEditingController();
  final _noHPController = TextEditingController();


  Future<void> _register() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    try {  final response = await Supabase.instance.client.auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response.user != null) {
      await Supabase.instance.client.from('users').insert({
        'id_user': response.user!.id,
        'nama': _namaController.text,
        'email': _emailController.text,
        'no_hp': _noHPController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      Navigator.restorablePushReplacementNamed(context, '/login');

    }} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrasi')),
      body: Padding(padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _namaController,
            decoration: InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            controller: _noHPController,
            decoration: InputDecoration(labelText: 'No HP'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(labelText: 'Konfirmasi Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _register, child: Text('Registrasi'),
          ),
        ],
      ),
      ),
    );
  }
}