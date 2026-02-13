import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class UserRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final AppDatabase _database;
  final NetworkInfo _networkInfo = NetworkInfoImpl(Connectivity());

  UserRepositories() {
    final dbHelper = Get.find<DatabaseHelper>();
    _database = dbHelper.database;
  }

  // ==================== GET USERS ====================
  Future<List<UserModel>> getUsers() async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        log('🌐 Online: Fetching users from Supabase...');
        await _syncFromSupabase();
      }

      log('📦 Loading users from local DB...');
      final localUsers = await _database.getAllUsers();
      return localUsers.map((u) => UserModel.fromLocal(u)).toList();
    } catch (e) {
      log('❌ Error getting users: $e');
      final localUsers = await _database.getAllUsers();
      return localUsers.map((u) => UserModel.fromLocal(u)).toList();
    }
  }

  // ==================== WATCH USERS (STREAM) ====================
  Stream<List<UserModel>> watchUsers() {
    try {
      log('👁️ Repository: Setting up users stream from local DB...');
      return _database.watchAllUsers().map((users) {
        return users.map((u) => UserModel.fromLocal(u)).toList();
      });
    } catch (e) {
      log('❌ Error setting up users stream: $e');
      rethrow;
    }
  }

  // ==================== SYNC FROM SUPABASE ====================
  Future<void> _syncFromSupabase() async {
    try {
      log('📥 Syncing users from Supabase...');
      final response = await _supabase
          .from(ApiConstant.usersTable)
          .select()
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      await _database.upsertUsers(users.map((u) => u.toLocal()).toList());
      log('✅ Synced ${users.length} users from Supabase');
    } catch (e) {
      log('❌ Error syncing from Supabase: $e');
    }
  }

  // ==================== GET USER BY ID ====================
  Future<UserModel> getUserById(String id) async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        log('🌐 Online: Fetching user $id from Supabase...');
        final response = await _supabase
            .from(ApiConstant.usersTable)
            .select()
            .eq('id', id)
            .single();

        final user = UserModel.fromJson(response);
        await _database.upsertUser(user.toLocal());

        return user;
      } else {
        log('📴 Offline: Loading user $id from local DB...');
        final localUser = await _database.getUserById(id);
        if (localUser == null) {
          throw Exception('User not found in local database');
        }
        return UserModel.fromLocal(localUser);
      }
    } catch (e) {
      log('❌ Error in getUserById, trying local: $e');
      final localUser = await _database.getUserById(id);
      if (localUser == null) {
        throw Exception('Failed to load user: $e');
      }
      return UserModel.fromLocal(localUser);
    }
  }

  // ==================== CREATE USER (WITHOUT ADMIN API) ====================
  Future<String> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        try {
          log('🌐 ONLINE: Creating user via temporary client...');

          // Create temporary Supabase client
          final tempClient = SupabaseClient(
            ApiConstant.supabaseUrl,
            ApiConstant.supabaseAnonKey,
            authOptions: const AuthClientOptions(
              authFlowType: AuthFlowType.implicit,
            ),
          );

          // Sign up new user
          final authResponse = await tempClient.auth.signUp(
            email: email,
            password: password,
            data: {'full_name': fullName, 'role': role},
          );

          if (authResponse.user == null) {
            throw Exception('Failed to create user in Supabase Auth');
          }

          final userId = authResponse.user!.id;
          log('✅ User created in Auth: $userId');

          // Insert into users table
          await tempClient.from(ApiConstant.usersTable).upsert({
            'id': userId,
            'full_name': fullName,
            'email': email,
            'role': role,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          log('✅ User created in users table');

          // Save to local DB
          final newUser = UserModel(
            id: userId,
            fullName: fullName,
            email: email,
            role: role,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            needsSync: false,
            isDeleted: false,
          );

          await _database.upsertUser(newUser.toLocal());
          log('✅ User created in Supabase and synced locally: $userId');

          // Dispose temporary client
          await tempClient.dispose();

          return userId;
        } catch (e) {
          log('❌ Error creating user online: $e');
          log('⚠️ Falling back to offline mode...');

          return await _createUserOffline(
            email: email,
            password: password,
            fullName: fullName,
            role: role,
          );
        }
      } else {
        log('📴 OFFLINE: Creating user locally...');
        return await _createUserOffline(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
        );
      }
    } catch (e) {
      log('❌ Error in createUser: $e');
      rethrow;
    }
  }

  // ==================== OFFLINE CREATE HELPER ====================
  Future<String> _createUserOffline({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    log('📴 Creating user offline with password storage...');

    final tempId = await _database.createUserOffline(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );

    log('✅ User created offline with temp ID: $tempId');
    return tempId;
  }

  // ==================== UPDATE USER ====================
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final isOnline = await _networkInfo.isConnected;

      // Always update local first
      await _database.updateUserOffline(
        id,
        fullName: data['full_name'] as String?,
        email: data['email'] as String?,
        role: data['role'] as String?,
      );
      log('✅ User updated locally');

      if (isOnline && !id.startsWith('temp_')) {
        try {
          log('🌐 Online: Updating user in Supabase...');
          data['updated_at'] = DateTime.now().toIso8601String();

          await _supabase
              .from(ApiConstant.usersTable)
              .update(data)
              .eq('id', id);

          await _database.markUserAsSynced(id);
          log('✅ User updated in Supabase and marked as synced');
        } catch (e) {
          log('❌ Error syncing update to Supabase: $e');
        }
      } else if (id.startsWith('temp_')) {
        log('⚠️ Cannot update temp user in Supabase, will sync when online');
      }
    } catch (e) {
      log('❌ Error updating user: $e');
      rethrow;
    }
  }

  // ==================== DELETE USER ====================
  Future<void> deleteUser(String id) async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (id.startsWith('temp_')) {
        log('🗑️ Deleting local-only user: $id');
        await _database.permanentlyDeleteUser(id);
        log('✅ Local-only user deleted');
        return;
      }

      if (isOnline) {
        try {
          log('🌐 Online: Deleting user from Supabase...');

          await _supabase.from(ApiConstant.usersTable).delete().eq('id', id);

          await _database.permanentlyDeleteUser(id);
          log('✅ User deleted from Supabase and local');
        } catch (e) {
          log('❌ Error deleting user online: $e');

          await _database.deleteUserOffline(id);
          log('✅ User marked for deletion, will sync when online');
        }
      } else {
        log('📴 Offline: Marking user for deletion...');
        await _database.deleteUserOffline(id);
        log('✅ User marked for deletion');
      }
    } catch (e) {
      log('❌ Error deleting user: $e');
      rethrow;
    }
  }

  // ==================== SYNC PENDING CHANGES ====================
  Future<void> syncPendingChanges() async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (!isOnline) {
        log('📴 Cannot sync: offline');
        return;
      }

      log('🔄 Syncing pending changes...');
      final usersNeedingSync = await _database.getUsersNeedingSync();

      if (usersNeedingSync.isEmpty) {
        log('✅ No pending changes');
        return;
      }

      log('🔄 Syncing ${usersNeedingSync.length} users...');

      for (final user in usersNeedingSync) {
        try {
          final operation = user.pendingOperation;
          log('🔄 Processing $operation for user: ${user.id}');

          if (operation == 'CREATE') {
            await _syncCreate(user);
          } else if (operation == 'UPDATE') {
            await _syncUpdate(user);
          } else if (operation == 'DELETE') {
            await _syncDelete(user);
          }
        } catch (e) {
          log('❌ Failed to sync user ${user.id}: $e');
        }
      }

      log('✅ All pending changes synced');
    } catch (e) {
      log('❌ Error syncing pending changes: $e');
      rethrow;
    }
  }

  // ==================== SYNC CREATE ====================
  Future<void> _syncCreate(dynamic user) async {
    log('➕ Syncing CREATE: ${user.fullName}');

    final password = user.tempPassword;
    if (password == null || password.isEmpty) {
      log('❌ Password not found for temp user: ${user.id}');
      throw Exception('Password not found for temp user: ${user.id}');
    }

    // Create temporary client
    final tempClient = SupabaseClient(
      ApiConstant.supabaseUrl,
      ApiConstant.supabaseAnonKey,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );

    try {
      // Sign up new user
      final authResponse = await tempClient.auth.signUp(
        email: user.email!,
        password: password,
        data: {'full_name': user.fullName, 'role': user.role},
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user in Auth');
      }

      final realUserId = authResponse.user!.id;
      log('✅ Real user ID from Auth: $realUserId');

      // Insert into users table
      await tempClient.from(ApiConstant.usersTable).upsert({
        'id': realUserId,
        'full_name': user.fullName,
        'email': user.email,
        'role': user.role,
        'created_at':
            user.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update local DB
      await _database.markUserAsSynced(user.id, newId: realUserId);
      log('✅ Created user synced: ${user.id} -> $realUserId');

      // Dispose client
      await tempClient.dispose();
    } catch (e) {
      await tempClient.dispose();
      rethrow;
    }
  }

  // ==================== SYNC UPDATE ====================
  Future<void> _syncUpdate(dynamic user) async {
    log('✏️ Syncing UPDATE: ${user.fullName}');

    await _supabase
        .from(ApiConstant.usersTable)
        .update({
          'full_name': user.fullName,
          'email': user.email,
          'role': user.role,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);

    await _database.markUserAsSynced(user.id);
    log('✅ Updated user synced: ${user.id}');
  }

  // ==================== SYNC DELETE ====================
  Future<void> _syncDelete(dynamic user) async {
    log('🗑️ Syncing DELETE: ${user.fullName}');

    await _supabase.from(ApiConstant.usersTable).delete().eq('id', user.id);

    await _database.permanentlyDeleteUser(user.id);
    log('✅ Deleted user synced: ${user.id}');
  }

  // ==================== MANUAL SYNC TRIGGER ====================
  Future<void> manualSync() async {
    log('🔄 Manual sync triggered...');
    await syncPendingChanges();
    await _syncFromSupabase();
    log('✅ Manual sync completed');
  }
}
