import 'dart:developer';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/repositories/admin_edit_user_repositories.dart';

class UserService {
  final UserRepositories _repository = UserRepositories();

  // ==================== FETCH ====================
  /// Fetch all users (offline-first)
  Future<List<UserModel>> fetchUsers() async {
    try {
      log('📥 Service: Fetching users...');
      return await _repository.getUsers();
    } catch (e) {
      log('❌ Service: Error fetching users: $e');
      rethrow;
    }
  }

  /// Fetch single user by ID
  Future<UserModel> fetchUserById(String id) async {
    try {
      log('📥 Service: Fetching user $id...');
      return await _repository.getUserById(id);
    } catch (e) {
      log('❌ Service: Error fetching user $id: $e');
      rethrow;
    }
  }

  // ==================== CREATE ====================
  /// Create new user (offline-first)
  /// Returns userId (temp ID if offline, real UUID if online)
  Future<String> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      log('➕ Service: Creating user $email...');
      final userId = await _repository.createUser(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      log('✅ Service: User created with ID: $userId');
      return userId;
    } catch (e) {
      log('❌ Service: Error creating user: $e');
      rethrow;
    }
  }

  // ==================== UPDATE ====================
  /// Update existing user (offline-first)
  Future<void> updateUser(
    String id, {
    String? fullName,
    String? email,
    String? avatarUrl,
    String? role,
  }) async {
    try {
      log('✏️ Service: Updating user $id...');
      
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (role != null) data['role'] = role;

      if (data.isEmpty) {
        log('⚠️ Service: No data to update');
        return;
      }

      await _repository.updateUser(id, data);
      log('✅ Service: User $id updated');
    } catch (e) {
      log('❌ Service: Error updating user $id: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================
  /// Delete user (offline-first)
  Future<void> deleteUser(String id) async {
    try {
      log('🗑️ Service: Deleting user $id...');
      await _repository.deleteUser(id);
      log('✅ Service: User $id deleted');
    } catch (e) {
      log('❌ Service: Error deleting user $id: $e');
      rethrow;
    }
  }

  // ==================== SYNC ====================
  /// Sync pending changes to server
  Future<void> syncPendingChanges() async {
    try {
      log('🔄 Service: Syncing pending changes...');
      await _repository.syncPendingChanges();
      log('✅ Service: Sync completed');
    } catch (e) {
      log('❌ Service: Sync failed: $e');
      rethrow;
    }
  }

  /// Manual sync (push + pull)
  Future<void> manualSync() async {
    try {
      log('🔄 Service: Manual sync started...');
      await _repository.manualSync();
      log('✅ Service: Manual sync completed');
    } catch (e) {
      log('❌ Service: Manual sync failed: $e');
      rethrow;
    }
  }

  // ==================== HELPERS ====================
  /// Check if user exists locally
  Future<bool> userExists(String id) async {
    try {
      await _repository.getUserById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get users count
  Future<int> getUsersCount() async {
    try {
      final users = await _repository.getUsers();
      return users.length;
    } catch (e) {
      log('❌ Service: Error getting users count: $e');
      return 0;
    }
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final users = await _repository.getUsers();
      return users.where((u) => u.role == role).toList();
    } catch (e) {
      log('❌ Service: Error getting users by role: $e');
      return [];
    }
  }

  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final users = await _repository.getUsers();
      final lowerQuery = query.toLowerCase();
      return users.where((u) {
        return u.fullName.toLowerCase().contains(lowerQuery) ||
               (u.email?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      log('❌ Service: Error searching users: $e');
      return [];
    }
  }
}