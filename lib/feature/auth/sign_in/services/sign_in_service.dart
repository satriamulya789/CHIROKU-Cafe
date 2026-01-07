import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInService {
  final SupabaseClient supabase = Supabase.instance.client;
  final _customSnackbar = CustomSnackbar();

  //sign in with email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      throw AuthErrorModel.emailEmpty();
    }
    if (password.isEmpty) {
      throw AuthErrorModel.passwordEmpty();
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw AuthErrorModel.invalidEmailFormat();
    }
    try {
      // Sign in with Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      //check if user is null
      if (response.user == null) {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.emailNotRegistered().message,
        );
      }
      return response;
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }

  Future<UserRole?> getUserRole(String userId) async {
    try {
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return null;

      final roleString = userData['role'] as String?;

      if (roleString?.toLowerCase() == 'admin') {
        return UserRole.admin;
      } else if (roleString?.toLowerCase() == 'cashier') {
        return UserRole.cashier;
      }
      return null;
    } catch (e) {
      throw AuthErrorModel.failedLoadUser();
    }
  }

  /// Get user data from database
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final data = await supabase
          .from(ApiConstant.usersTable)
          .select('id, email, full_name, role, avatar_url')
          .eq('id', userId)
          .single();

      return data;
    } catch (e) {
      throw AuthErrorModel.failedLoadUser();
    }
  }

  /// Check if user session exists
  Future<bool> hasActiveSession() async {
    final session = supabase.auth.currentSession;
    return session != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}
