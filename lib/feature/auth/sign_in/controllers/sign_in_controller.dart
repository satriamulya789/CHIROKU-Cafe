import 'package:chiroku_cafe/feature/auth/sign_in/repositories/sign_in_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  //================== Dependencies ===================//
  final signInRepository = SignInRepositories();
  final _customSnackbar = CustomSnackbar();
  final validator = Validator();
  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  //================== Observables ===================//
  final isLoading = false.obs;
  final _isPasswordObscured = true.obs;
  RxBool get isPasswordObscured => _isPasswordObscured;
  //================== Lifecycle ===================//
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  //================== Toggle Functions ===================//
  void togglePasswordVisibility() {
    _isPasswordObscured.value = !_isPasswordObscured.value;
  }

  //================== Sign In Function ===================//
  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      throw AuthErrorModel.passwordEmpty();
    }
    if (email.isEmpty) {
      throw AuthErrorModel.emailEmpty();
    }

    isLoading.value = true;
    try {
      await signInRepository.signUpUser(email: email, password: password);

      // // Routing berdasarkan role menggunakan enum
      // if (user.role == UserRole.admin) {
      //   Get.offAllNamed('/admin');
      // } else if (user.role == UserRole.cashier) {
      //   Get.offAllNamed('/home-cashier');
      // } else {
      //   _customSnackbar.showErrorSnackbar('Role tidak dikenali');
      // }
    } catch (e) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.unknownError().message);
    }
  }
}
