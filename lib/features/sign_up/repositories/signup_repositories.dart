
import 'package:chiroku_cafe/features/sign_up/models/signup_models.dart';
import 'package:chiroku_cafe/shared/repositories/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterRepository {
  final AuthService _auth = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Register via Supabase Auth and insert additional profile data into "users" table.
  Future<RegisterResponse> register(RegisterRequest req) async {
    try {
      final res = await _auth.signUp(email: req.email, password: req.password, fullName: '');

      // Supabase user
      final user = res.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      // Insert profile data to users table (id from auth)
      final profile = {
        'id': user.id,
        'email': req.email,
        'full_name': req.fullName,
        'role': req.role,
        'created_at': DateTime.now().toIso8601String(),
      };

      final inserted = await _supabase.from('users').insert(profile).select().single();

      return RegisterResponse.fromJson(inserted as Map<String, dynamic>);
    } catch (e) {
      print('❌ RegisterRepository error: $e');
      throw RegisterError.fromException(e);
    }
  }

  /// Basic validators (reuse in controller if needed)
  bool isValidEmail(String email) =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool isValidPassword(String password) => password.length >= 6;
}