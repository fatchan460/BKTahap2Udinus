import 'dart:io';
import 'package:advance_inventory/models/supplier_model.dart';
import 'package:flutter/material.dart';
import 'package:advance_inventory/models/product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EditPage extends StatefulWidget {
  final ProductModel product;
  const EditPage({super.key, required this.product});

  @override
  State<EditPage> createState() => _EditPageState();
}


class _EditPageState extends State<EditPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _imageBase64;
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  List<SupplierModel> _supplierList = [];
  int? _selectedSupplierId;
  File? _pickedImage;


  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _descriptionController.text = widget.product.description;
    _categoryController.text = widget.product.category;
    _selectedSupplierId = widget.product.idSupplier;

    if (widget.product.image != null) {
      _imageBase64 = widget.product.image!;
    }
    _fetchSupplier();

  }
  Future<void> _fetchSupplier() async {
    try {
      final response = await Supabase.instance.client
          .from('suppliers')
          .select();
      setState(() {
        _supplierList = response.map((json) => SupplierModel.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil nama supplier: $e')),
      );
    }
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    final nama = _nameController.text;
    final deskripsi = _descriptionController.text;
    final harga = int.tryParse(_priceController.text) ?? 0;
    final kategori = _categoryController.text;

    if (nama.isEmpty ||
        deskripsi.isEmpty ||
        kategori.isEmpty ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data harus diisi!')),
      );
      return;
    }

    try {
      if (_pickedImage != null) {
        final relativePath = widget.product.image.split('/').last;
        if (relativePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('inventory')
              .remove([relativePath]);
        }
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        await Supabase.instance.client.storage
            .from('inventory')
            .upload(fileName, _pickedImage!);
        final imageUrl = Supabase.instance.client.storage
            .from('inventory')
            .getPublicUrl(fileName);
        await Supabase.instance.client.from('products').update({
          'nama': nama,
          'deskripsi': deskripsi,
          'kategori': kategori,
          'harga': harga,
          'image_path': imageUrl,
          'id_supplier': _selectedSupplierId,
        }).eq('id', widget.product.id);
      } else {
        await Supabase.instance.client.from('products').update({
          'nama': nama,
          'deskripsi': deskripsi,
          'kategori': kategori,
          'harga': harga,
          'id_supplier': _selectedSupplierId,
        }).eq('id', widget.product.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _pickedImage == null
              ? Image.network(
            _imageBase64!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.broken_image,
                  size: 200, color: Colors.grey);
            },
          )
              : Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: _pickedImage != null
                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                : Icon(Icons.camera_alt,
                size: 50, color: Colors.grey),
          ),
          ElevatedButton(onPressed: _pickImage, child: const Text('Pilih Gambar',style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,color: Colors.black),)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Product Name',
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Product Price',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Product Description',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Product Category',
            ),
          ),
          SizedBox(height: 20),
          if (_supplierList.isNotEmpty)
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedSupplierId,
              hint: Text('Pilih Supplier'),
              items: _supplierList.map((supplier) {
                return DropdownMenuItem<int>(
                  value: supplier.id,
                  child: Text(supplier.nama),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSupplierId = value;
                });
              },
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _updateProduct,
            child: const Text('Update Product'),
          ),
        ],
      ),
    );
  }
}
