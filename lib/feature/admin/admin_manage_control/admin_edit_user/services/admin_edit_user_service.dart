import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_user/repositories/admin_edit_user_repositories.dart';

class UserService {
  final AdminEditUserRepositories _repository = AdminEditUserRepositories();

  Future<List<UserModel>> fetchUsers() async {
    return await _repository.getUsers();
  }

  Future<UserModel> fetchUserById(String id) async {
    return await _repository.getUserById(id);
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