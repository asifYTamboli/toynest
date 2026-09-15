import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; 

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _voltageController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _galleryUrlsController = TextEditingController();
  
  bool _remoteControl = true;
  bool _isSaving = false;
  bool _isUploadingPrimary = false;
  bool _isUploadingGallery = false;

  @override
  void dispose() {
    _nameController.dispose(); _brandController.dispose(); _voltageController.dispose();
    _priceController.dispose(); _stockController.dispose(); _imageUrlController.dispose();
    _descriptionController.dispose(); _colorController.dispose(); _galleryUrlsController.dispose();
    super.dispose();
  }
  Future<void> _uploadImageFromDevice({required bool isPrimary}) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img == null) return; 

    final ext = img.name.split('.').last.toLowerCase();
    final allowed = ['jpg', 'jpeg', 'png', 'webp'];
    if (!allowed.contains(ext)) return;

    final bytes = await img.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) return; 

    setState(() {
      if (isPrimary) {
        _isUploadingPrimary = true;
      } else {
        _isUploadingGallery = true;
      }
    });

    try {
      final name = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      await supabase.storage.from('car-images').uploadBinary(
        name, bytes, fileOptions: FileOptions(contentType: 'image/$ext'),
      );
      final url = supabase.storage.from('car-images').getPublicUrl(name);

      setState(() {
        if (isPrimary) {
          _imageUrlController.text = url; 
        } else {
          _galleryUrlsController.text = _galleryUrlsController.text.isEmpty ? url : '${_galleryUrlsController.text}, $url';
        }
      });
    } catch (e) {
      // Handle silently or print
    } finally {
      setState(() {
        if (isPrimary) {
          _isUploadingPrimary = false;
        } else {
          _isUploadingGallery = false;
        }
      });
    }
  }

  Future<void> _saveProductToInventory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    List<String> parseTags(String text) {
      if (text.trim().isEmpty) return [];
      return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    try {
      await supabase.from('cars_inventory').insert({
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        'voltage': _voltageController.text.trim().isEmpty ? null : _voltageController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'color': parseTags(_colorController.text),
        'remote_control': _remoteControl,
        'stock_count': int.parse(_stockController.text.trim()),
        'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'gallery_urls': parseTags(_galleryUrlsController.text),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      // Error callback
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle Product'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Form(key: _formKey, child: _buildFormFields()),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    final fields = <Widget>[
      TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Car Model Name*', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextFormField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand Name', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextFormField(controller: _voltageController, decoration: const InputDecoration(labelText: 'Voltage spec (e.g. 12V)', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Retail Price (₹)*', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock Count', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextFormField(controller: _colorController, decoration: const InputDecoration(labelText: 'Colors (comma-separated)', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextFormField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Primary Image Link URL', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: () => _uploadImageFromDevice(isPrimary: true), child: const Text('Upload Main Photo')),
      const SizedBox(height: 12),
      TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description text details', border: OutlineInputBorder()), maxLines: 2),
      const SizedBox(height: 12),
      TextFormField(controller: _galleryUrlsController, decoration: const InputDecoration(labelText: 'Gallery Links URL List', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: () => _uploadImageFromDevice(isPrimary: false), child: const Text('Upload Gallery Photo')),
      const SizedBox(height: 16),
      CheckboxListTile(title: const Text('Remote Control Included'), value: _remoteControl, onChanged: (v) => setState(() => _remoteControl = v ?? true)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _saveProductToInventory, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text('Publish to Catalog')),
    ];

    return ListView(padding: const EdgeInsets.all(24), children: fields);
  }
} // End of Class state structure
