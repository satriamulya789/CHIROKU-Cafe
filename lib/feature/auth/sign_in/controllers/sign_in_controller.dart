import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/repositories/sign_in_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
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
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  //================== Observables ===================//
  final isLoading = false.obs;
  final _isPasswordObscured = true.obs;
  RxBool get isPasswordObscured => _isPasswordObscured;

  //================== Lifecycle ===================//
  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

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
    // Validasi input
    if (email.isEmpty) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.emailEmpty().message);
      return;
    }
    if (password.isEmpty) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.passwordEmpty().message);
      return;
    }

    try {
      isLoading.value = true;
      // Login dan dapatkan role dari repository
     final role = await signInRepository.signInUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _customSnackbar.showSuccessSnackbar(AuthErrorModel.successAccount().message);

      // Navigate based on role
       if (role == UserRole.admin) {
        toHomeAdmin();
      } else {
        toHomeCashier();
      }
      
    } on AuthErrorModel catch (e) {
      // Handle auth specific errors
      _customSnackbar.showErrorSnackbar(e.message);
    } catch (e) {
      // Handle general errors
      _customSnackbar.showErrorSnackbar('Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void toSignUp() {
    Get.toNamed(AppRoutes.signUp);
  }

  void toHomeAdmin() {
    Get.offAllNamed(AppRoutes.bottomBarAdmin);
  }

  void toHomeCashier() {
    Get.offAllNamed(AppRoutes.bottomBarCashier);
  }
}

