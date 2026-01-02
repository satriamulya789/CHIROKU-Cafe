
import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final SupabaseClient supabase = Supabase.instance.client;

  final ExistingEmail _existingEmail = ExistingEmail();

  //create user record in table 'users'
  Future<void> _createUserRecord({
    required String userId,
    required String email,
  }) async {
    try {
      await supabase.from(ApiConstant.usersTable).insert({
        'id': userId,
        'email': email.trim().toLowerCase(),
        'role': 'cashier',
        'created_at': DateTime.now().toIso8601String(),
      });
      print('Service: User record created');
    } catch (e) {
      print('Service: Error creating user record - $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password, 
    required String role,

  }) async {
    final emailExists = await _existingEmail.isEmailExists(email);
    if (emailExists) {
      throw AuthErrorModel.emailAlreadyExists();
    }
    if (email.isEmpty || password.isEmpty) {
      throw AuthErrorModel.passwordEmpty();
    }
    if (password.length < 6) {
      throw AuthErrorModel.passwordTooShort();
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw AuthErrorModel.invalidEmailFormat();
    }
    try {
      final response = await supabase.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {'role': 'cashier'},
      );

       final user = response.user; 
      if (user != null) {
        await _createUserRecord(
          userId: response.user!.id,
          email: email,
        );
         Get.snackbar(
          'Sign Up Successful',
          AuthErrorModel.successAccount().message,
          colorText: AppColors.white,
          backgroundColor: AppColors.successNormal,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
          borderRadius: 16,
        );
      }
      return response;
    } on AuthException catch (e) {
      print('AuthException: ${e.message}'); // Debug
      rethrow;
    } catch (e) {
      print('Unknown error in signUp: $e'); // Debug
      throw AuthErrorModel.unknownError();
    }
  }
}
