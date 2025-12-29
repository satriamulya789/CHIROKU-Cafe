import 'package:chiroku_cafe/config/routes/route.dart';
import 'package:chiroku_cafe/feature/sign_up/models/sign_up_error_model.dart';
import 'package:chiroku_cafe/feature/sign_up/models/sign_up_model.dart';
import 'package:chiroku_cafe/feature/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final SignUpRepository _signUpRepository;

  SignUpController(this._signUpRepository);

  //Form key and text controllers can be added here for managing form state
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final role = UserRole.cashier.obs;

  final isLoading = false.obs;
  final statusMessage = Rxn<String>();

  @override
  void onClose(){
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  //validation methods
    String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return SignUpErrorModel.emptyField().message;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return SignUpErrorModel.invalidEmailFormat().message;
    }
    return null;
  }
  
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return SignUpErrorModel.emptyField().message;
    }
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
    if (!passwordRegex.hasMatch(password)) {
      return SignUpErrorModel.passwordTooWeak().message;
    }
    return null;
  }

  //Register user method
  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    statusMessage.value = null;

    try {
      await _signUpRepository.registerUser(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: role.value,
      );
      Get.toNamed(AppRoutes.signIn);
      statusMessage.value = "Sign-up successful!";
    } catch (e) {
      statusMessage.value = "Sign-up failed: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }

  }
}