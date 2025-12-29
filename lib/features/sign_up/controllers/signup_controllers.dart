import 'package:chiroku_cafe/features/sign_up/models/signup_models.dart';
import 'package:chiroku_cafe/features/sign_up/repositories/signup_repositories.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final RegisterRepository _repo = RegisterRepository();

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final role = 'cashier'.obs;

  final isLoading = false.obs;
  final statusMessage = Rxn<String>();

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateFullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama harus diisi';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email harus diisi';
    if (!_repo.isValidEmail(v)) return 'Format email tidak valid';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password harus diisi';
    if (!_repo.isValidPassword(v)) return 'Password minimal 6 karakter';
    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    statusMessage.value = null;

    final req = RegisterRequest(
      email: emailController.text.trim(),
      password: passwordController.text,
      fullName: fullNameController.text.trim(),
      role: role.value,
    );

    try {
      final res = await _repo.register(req);

      Get.snackbar(
        'Berhasil',
        'Akun ${res.email} berhasil dibuat',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // setelah register, arahkan ke halaman login
      Get.offAllNamed('/login');
    } on RegisterError catch (e) {
      statusMessage.value = e.message;
      Get.snackbar('Gagal', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      statusMessage.value = 'Terjadi kesalahan';
      Get.snackbar('Error', statusMessage.value ?? 'Error',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void setRole(String r) => role.value = r;
}