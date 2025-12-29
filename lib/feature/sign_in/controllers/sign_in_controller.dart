import 'package:chiroku_cafe/feature/sign_in/models/error_sign_in_model.dart';
import 'package:chiroku_cafe/feature/sign_in/models/sign_in_model.dart';
import 'package:chiroku_cafe/feature/sign_in/repositories/sign_in_auth_repositories.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInController extends GetxController
    with StateMixin<UserModel> {
  late final AuthRepository _repo;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final _isPasswordHidden = true.obs;
  RxBool get isPasswordHidden => _isPasswordHidden;

  final _isLoading = false.obs;
  RxBool get isLoading => _isLoading;
  void togglePassword() {
    _isPasswordHidden.value = !_isPasswordHidden.value;
  }


  @override
  void onInit() {
    super.onInit();
    _repo = AuthRepository(Supabase.instance.client);
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final user = await _repo.autoLogin();
      if (user != null) {
        _redirect(user);
      }
    } catch (_) {}
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    

    if (email.isEmpty || password.isEmpty) {
      _showError(SignInError.emptyField());
      return;
    }

    change(null, status: RxStatus.loading());

    try {
      final user = await _repo.signIn(email as UserModel, password, email: email);

      change(user, status: RxStatus.success());
      _redirect(user);
    } catch (e) {
      final error = SignInError.fromException(e);

      change(null, status: RxStatus.error(error.message));
      _showError(error);
    }
  }

  void _showError(SignInError error) {
    Get.snackbar(
      'Login Failed',
      error.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.alertNormal,
      colorText: AppColors.white,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
    );
  }

  void _redirect(UserModel user) {
    if (user.isAdmin) {
      Get.offAllNamed('/admin');
    } else {
      Get.offAllNamed('/cashier');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
