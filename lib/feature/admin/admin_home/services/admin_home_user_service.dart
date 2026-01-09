import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_user_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final CustomSnackbar _snackbar = CustomSnackbar();

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      _snackbar.showErrorSnackbar('Failed to load user data');
      return null;
    }
  }

  Future<String?> getUserFullName() async {
    try {
      final user = await getCurrentUser();
      return user?.fullName;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserAvatarUrl() async {
    try {
      final user = await getCurrentUser();
      return user?.avatarUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }

  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }
}