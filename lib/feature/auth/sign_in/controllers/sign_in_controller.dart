import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/repositories/sign_in_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/not_register_email.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInController extends GetxController {
  //================== Dependencies ===================//
  final signInRepository = SignInRepositories();
  final validator = Validator();
  final _emailNotRegister = NotRegisterEmail();
  final _customSnackbar = CustomSnackbar();

  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  //================== Observables ===================//
  final isLoading = false.obs;
  final _isPasswordObscured = true.obs;
  final passwordText = ''.obs;

  //================== Getters ===================//
  RxBool get isPasswordObscured => _isPasswordObscured;

  //================== Lifecycle ===================//
  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordController.addListener(() {
      passwordText.value = passwordController.text;
    });
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

    isLoading.value = true;
    try {
      final emailNotRegister = await _emailNotRegister.isEmailNotRegistered(
        email,
      );
      if (emailNotRegister) {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.emailNotRegistered().message,
        );
        isLoading.value = false;
        return;
      }
      // Login dan dapatkan role dari repository
      final role = await signInRepository.signInUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _customSnackbar.showSuccessSnackbar(
        AuthErrorModel.accountSignInSuccess().message,
      );

      // Navigate based on role
      if (role == UserRole.admin) {
        toHomeAdmin();
      } else {
        toHomeCashier();
      }
    } on AuthException catch (e) {
      // Handle Supabase authentication errors
      final error = AuthErrorModel.fromException(e);
      _customSnackbar.showErrorSnackbar(error.message);
    } on AuthErrorModel catch (e) {
      // Handle custom auth errors from service layer
      _customSnackbar.showErrorSnackbar(e.message);
    } catch (e) {
      // Handle unknown errors
      final errorMessage = e.toString();

      // Check for network errors
      if (errorMessage.contains('SocketException') ||
          errorMessage.contains('NetworkException') ||
          errorMessage.contains('Failed host lookup')) {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.networkError().message,
        );
      } else {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.unknownError().message,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

void toHomeAdmin() {
  Get.offAllNamed(AppRoutes.bottomBarAdmin);
}

void toHomeCashier() {
  Get.offAllNamed(AppRoutes.bottomBarCashier);
}
