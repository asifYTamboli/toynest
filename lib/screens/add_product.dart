import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers mapped exactly to your database schema fields
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _voltageController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Array parameters handled via comma-separated string inputs
  final _colorController = TextEditingController();
  final _galleryUrlsController = TextEditingController();
  
  bool _remoteControl = true;
  bool _isSaving = false;

  Future<void> _saveProductToInventory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final supabase = Supabase.instance.client;

    // Convert comma-separated strings cleanly into lists/arrays for Postgres text[]
    List<String> parseCommaSeparated(String text) {
      if (text.trim().isEmpty) return [];
      return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    try {
      // 2. Submit payload explicitly mapped to your columns
      await supabase.from('cars_inventory').insert({
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        'voltage': _voltageController.text.trim().isEmpty ? null : _voltageController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'color': parseCommaSeparated(_colorController.text),
        'remote_control': _remoteControl,
        'stock_count': int.parse(_stockController.text.trim()),
        'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'gallery_urls': parseCommaSeparated(_galleryUrlsController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Vehicle catalog successfully created!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vehicle: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _voltageController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _galleryUrlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle to Schema Catalog'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Row(
                    children: [
                      Icon(Icons.inventory_2, size: 28, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('Schema Entry Console', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Name and Brand row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Car Model Name*', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(labelText: 'Brand (e.g. Audi, BMW)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Voltage and Price and Stock row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _voltageController,
                          decoration: const InputDecoration(labelText: 'Voltage (e.g. 12V, 24V)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Price (₹)*', border: OutlineInputBorder(), prefixText: '₹'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid price' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(labelText: 'Stock Count', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid stock' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Colors Array Field
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Available Colors (Comma separated, e.g. Red, White, Metallic Black)',
                      border: OutlineInputBorder(),
                      helperText: 'Separate multiple choices with commas',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main image and Description
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Primary Image Web Link (URL)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.image)),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Product Long Description details', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Gallery Array URLs
                  TextFormField(
                    controller: _galleryUrlsController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Gallery Images (Comma separated URLs)',
                      border: OutlineInputBorder(),
                      helperText: 'Separate asset links with commas',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Remote control checkbox switch wrapper row
                  CheckboxListTile(
                    title: const Text('Includes Parental Remote Control unit'),
                    value: _remoteControl,
                    onChanged: (val) => setState(() => _remoteControl = val ?? true),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProductToInventory,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      child: _isSaving 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Sync & Publish to Schema Catalog', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
