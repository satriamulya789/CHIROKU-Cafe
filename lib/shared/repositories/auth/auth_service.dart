import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Check if email already exists
  Future<bool> isEmailExists(String email) async {
    try {
      final response = await supabase
          .from('users')
          .select('email')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Get user data by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Authentication
  /// Sign Up - Register new user
  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Double check: pastikan email belum terdaftar
      final emailExists = await isEmailExists(email);
      if (emailExists) {
        throw Exception('Email already registered. Please use another email.');
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'email': email},
      );

      if (response.user != null) {
        await _createUserRecord(
          userId: response.user!.id,
          fullName: fullName,
          email: email,
        );
      }

      return response;
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  /// Create User Record in users table
  Future<void> _createUserRecord({
    required String userId,
    required String fullName,
    required String email,
  }) async {
    try {
      await supabase.from('users').insert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'role': 'cashier',
      });
      print('✅ User record created in database');
    } catch (e) {
      print('Error creating user record: $e');
    }
  }

  /// Sign In - Login user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign Out - Logout user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // ==================== User Info ====================

  /// Get Current User
  User? getCurrentUser() => supabase.auth.currentUser;

  /// Check if user is logged in
  bool isLoggedIn() => supabase.auth.currentSession != null;

  /// Get User Data from users table
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userId = getCurrentUser()?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Get User Full Name
  Future<String?> getUserFullName() async {
    try {
      final userData = await getUserData();
      return userData?['full_name'];
    } catch (e) {
      final user = getCurrentUser();
      return user?.userMetadata?['full_name'] ?? user?.email?.split('@')[0];
    }
  }

  /// Get User Avatar URL
  Future<String?> getUserAvatarUrl() async {
    try {
      final userData = await getUserData();
      return userData?['avatar_url'];
    } catch (e) {
      print('Error getting avatar URL: $e');
      return null;
    }
  }

  /// Get User Role
  Future<String?> getUserRole() async {
    try {
      final userData = await getUserData();
      return userData?['role'];
    } catch (e) {
      return null;
    }
  }

  /// Check if user is Admin
  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Check if user is Cashier
  Future<bool> isCashier() async {
    try {
      final role = await getUserRole();
      return role == 'cashier';
    } catch (e) {
      return false;
    }
  }

  // ==================== Update Profile ====================

  /// Update User Profile
  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
      final userId = getCurrentUser()?.id;
      if (userId == null) throw Exception('User not logged in');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        await supabase.from('users').update(updates).eq('id', userId);

        await supabase.auth.updateUser(UserAttributes(data: updates));

        print('✅ Profile updated successfully');
      }
    } catch (e) {
      throw Exception('Update profile gagal: ${e.toString()}');
    }
  }

  /// Verify current password (for change password feature)
  Future<bool> verifyCurrentPassword(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.session != null;
    } catch (e) {
      return false;
    }
  }

  /// Update user password by email (for forgot password flow)
  Future<void> updatePasswordByEmail({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Verify email exists
      final userData = await getUserByEmail(email);
      if (userData == null) {
        throw Exception('Email not found');
      }

      // Update password via auth
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  /// Update user password (for logged in user)
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  // ==================== Password Reset ====================

  /// Reset password (send email)
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Error sending reset password email: $e');
    }
  }

  // ==================== Stream ====================

  /// Auth State Changes
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}
