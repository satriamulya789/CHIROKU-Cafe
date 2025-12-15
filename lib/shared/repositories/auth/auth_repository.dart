import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return await _supabase
        .from(ApiConstant.usersTable)
        .select()
        .eq('id', user.id)
        .single();
  }

  Future<UserRole> getCurrentUserRole() async {
    final user = await getCurrentUser();
    return UserRoleExt.fromString(user['role']);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
