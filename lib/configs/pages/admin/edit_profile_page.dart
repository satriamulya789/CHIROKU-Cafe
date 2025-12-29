import 'dart:io';
import 'package:chiroku_cafe/shared/repositories/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _avatarUrl;
  String _role = '';
  String _originalEmail = '';
  bool _isLoading = true;
  bool _isSaving = false;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      final avatarUrl = await _authService.getUserAvatarUrl();
      
      setState(() {
        _fullNameController.text = userData?['full_name'] ?? '';
        _emailController.text = userData?['email'] ?? '';
        _originalEmail = userData?['email'] ?? '';
        _role = userData?['role'] ?? 'cashier';
        _avatarUrl = avatarUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Avatar Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_avatarUrl != null || _imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove Avatar',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageFile = null;
                      _avatarUrl = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _uploadAvatar() async {
    if (_imageFile == null) return _avatarUrl;

    try {
      final userId = _authService.getCurrentUser()?.id;
      if (userId == null) throw Exception('User not logged in');

      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'avatars/$fileName';

      // Delete old avatar 
      if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
        try {
          final oldPath = Uri.parse(_avatarUrl!).path.split('/').last;
          await supabase.storage.from('avatars').remove(['avatars/$oldPath']);
        } catch (e) {
          print('Error deleting old avatar: $e');
        }
      }

      // Upload to Supabase Storage
      await supabase.storage.from('avatars').upload(
            filePath,
            _imageFile!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<bool> _updateEmail(String newEmail) async {
    try {
      // Update email in Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      // Update email in users table
      final userId = _authService.getCurrentUser()?.id;
      if (userId != null) {
        await supabase
            .from('users')
            .update({'email': newEmail})
            .eq('id', userId);
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final newEmail = _emailController.text.trim();
    final emailChanged = newEmail != _originalEmail;

    // Show confirmation dialog if email changed
    if (emailChanged) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirm Email Change',
            style: TextStyle(
              fontStyle: GoogleFonts.montserrat().fontStyle,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to change your email from:',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _originalEmail,
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'to:',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                newEmail,
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A confirmation email will be sent to your new email address.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload avatar if changed
      String? newAvatarUrl;
      if (_imageFile != null) {
        newAvatarUrl = await _uploadAvatar();
        if (newAvatarUrl == null) {
          setState(() => _isSaving = false);
          return;
        }
      } else if (_avatarUrl == null) {
        newAvatarUrl = null;
      } else {
        newAvatarUrl = _avatarUrl;
      }

      // Update email if changed
      if (emailChanged) {
        final emailUpdateSuccess = await _updateEmail(newEmail);
        if (!emailUpdateSuccess) {
          setState(() => _isSaving = false);
          return;
        }
      }

      // Update profile
      await _authService.updateProfile(
        fullName: _fullNameController.text.trim(),
        avatarUrl: newAvatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              emailChanged
                  ? 'Profile updated! Please check your new email for confirmation.'
                  : 'Profile updated successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Get.back(result: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;
    
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageProvider,
          backgroundColor: Colors.grey[300],
          child: imageProvider == null
              ? Icon(Icons.person, size: 60, color: Colors.grey[600])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildAvatar(),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change avatar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Email (Now Editable)
                    TextFormField(
                      controller: _emailController,
                      enabled: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: _emailController.text != _originalEmail
                            ? const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 18)
                            : null,
                      ),
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        // Email validation regex
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {}); // Rebuild to show warning icon
                      },
                    ),
                    const SizedBox(height: 8),
                    if (_emailController.text != _originalEmail)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Changing email will require verification',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[900],
                                    fontStyle: GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Role (Read-only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Role',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _role == 'admin' ? Colors.blue : Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _role.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: GoogleFonts.montserrat().fontStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.lock_outline,
                              size: 18, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: GoogleFonts.montserrat().fontStyle,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}