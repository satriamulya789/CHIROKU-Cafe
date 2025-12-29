import 'package:chiroku_cafe/features/sign_in/models/login_models.dart';
import 'package:chiroku_cafe/shared/repositories/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with email and password
  Future<LoginResponse> signIn(LoginRequest request) async {
    try {
      // Call auth service
      final response = await _authService.signIn(
        email: request.email,
        password: request.password,
      );

      // Check if session exists
      if (response.session == null) {
        throw Exception('Tidak ada session yang diterima');
      }

      // Get user role
      final role = await _authService.getUserRole();
      
      // Get user data from database
      final userData = await _getUserData(response.user!.id);

      // Return login response
      return LoginResponse(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken,
        userId: response.user!.id,
        email: response.user!.email!,
        role: role ?? 'cashier',
        fullName: userData?['full_name'] as String?,
        avatarUrl: userData?['avatar_url'] as String?,
        expiresAt: response.session!.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(
                response.session!.expiresAt! * 1000)
            : null,
      );
    } catch (e) {
      print('❌ Login Repository Error: $e');
      throw LoginError.fromException(e);
    }
  }

  /// Get user data from database
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('full_name, avatar_url, role')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('⚠️ Warning: Failed to get user data: $e');
      return null;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  /// Check if user is authenticated

  bool isAuthenticated() {
    // Use Supabase client
    return _supabase.auth.currentUser != null;
  }

  

  /// Get current session
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      print('❌ Refresh session error: $e');
      rethrow;
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password
  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}