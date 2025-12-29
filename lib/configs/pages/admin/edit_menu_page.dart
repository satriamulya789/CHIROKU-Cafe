import 'dart:io';
import 'package:chiroku_cafe/shared/models/menu_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditMenuPage extends StatefulWidget {
  final MenuModel? menu; // null untuk add, ada value untuk edit
  
  const EditMenuPage({super.key, this.menu});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descCtrl;
  
  // State variables
  List<Map<String, dynamic>> categories = [];
  int? selectedCat;
  String? imageUrl;
  bool isAvailable = true;
  bool isLoading = true;
  bool isUploading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCategories();
  }

  void _initializeControllers() {
    nameCtrl = TextEditingController(text: widget.menu?.name ?? '');
    priceCtrl = TextEditingController(text: widget.menu?.price.toString() ?? '');
    descCtrl = TextEditingController(text: widget.menu?.description ?? '');
    
    selectedCat = widget.menu?.categoryId;
    imageUrl = widget.menu?.imageUrl;
    isAvailable = widget.menu?.isAvailable ?? true;
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final catData = await supabase.from('categories').select().order('id');
      setState(() {
        categories = List<Map<String, dynamic>>.from(catData as List);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      // Show dialog untuk pilih sumber
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return null;

      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return null;

      setState(() => isUploading = true);

      final file = File(picked.path);
      final fileExt = file.path.split('.').last.toLowerCase();
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('menus').upload(
        fileName,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/$fileExt',
        ),
      );

      final publicUrl = supabase.storage.from('menus').getPublicUrl(fileName);
      
      setState(() {
        imageUrl = publicUrl;
        isUploading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      return publicUrl;
    } catch (e) {
      setState(() => isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveMenu() async {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text) ?? 0.0;
    final desc = descCtrl.text.trim();

    if (name.isEmpty || selectedCat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and category are required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      if (widget.menu == null) {
        // Add new menu
        await supabase.from('menu').insert({
          'category_id': selectedCat,
          'name': name,
          'price': price,
          'description': desc,
          'image_url': imageUrl,
          'is_available': isAvailable,
        });
      } else {
        // Update existing menu
        await supabase.from('menu').update({
          'category_id': selectedCat,
          'name': name,
          'price': price,
          'description': desc,
          'image_url': imageUrl,
          'is_available': isAvailable,
        }).eq('id', widget.menu!.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.menu == null
                ? 'Menu added successfully!'
                : 'Menu updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            const SizedBox(height: 12),
            
            // Image preview
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              Text('Failed to load image'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                      onPressed: isUploading || isSaving ? null : () {
                        setState(() => imageUrl = null);
                      },
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 50, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isUploading 
                  ? const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Icon(Icons.photo_camera),
                label: Text(isUploading ? 'Uploading...' : 'Pick & Upload Image'),
                onPressed: isUploading || isSaving ? null : _pickAndUploadImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menu == null ? 'Add Menu' : 'Edit Menu',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveMenu,
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Image section
                  _buildImageSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Form section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Menu Name
                          TextField(
                            controller: nameCtrl,
                            enabled: !isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Menu Name *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.restaurant_menu),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Price
                          TextField(
                            controller: priceCtrl,
                            enabled: !isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Price *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Category
                          DropdownButtonFormField<int>(
                            value: selectedCat,
                            onChanged: isSaving ? null : (value) {
                              setState(() => selectedCat = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: categories.map((c) {
                              return DropdownMenuItem<int>(
                                value: c['id'] as int,
                                child: Text(c['name']?.toString().toUpperCase() ?? ''),
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description
                          TextField(
                            controller: descCtrl,
                            enabled: !isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Available Switch
                          SwitchListTile(
                            title: const Text('Available for order'),
                            subtitle: Text(isAvailable ? 'Menu is available' : 'Menu is not available'),
                            value: isAvailable,
                            onChanged: isSaving ? null : (value) {
                              setState(() => isAvailable = value);
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveMenu,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Saving...'),
                              ],
                            )
                          : Text(
                              widget.menu == null ? 'ADD MENU' : 'UPDATE MENU',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}