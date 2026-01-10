import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/repositories/admin_edit_user_repositories.dart';

class UserService {
  final UserRepositories _repository = UserRepositories();

  Future<List<UserModel>> fetchUsers() async {
    return await _repository.getUsers();
  }

  Future<UserModel> fetchUserById(String id) async {
    return await _repository.getUserById(id);
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    await _repository.createUser(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  Future<void> updateUser(String id, {
    String? fullName,
    String? email,
    String? avatarUrl,
    String? role,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (email != null) data['email'] = email;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (role != null) data['role'] = role;

    await _repository.updateUser(id, data);
  }

  Future<void> deleteUser(String id) async {
    await _repository.deleteUser(id);
  }
}