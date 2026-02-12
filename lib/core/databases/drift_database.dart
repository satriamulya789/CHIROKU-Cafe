import 'package:chiroku_cafe/core/tables/session_table.dart';
import 'package:chiroku_cafe/core/tables/user_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:developer';

part 'drift_database.g.dart';

@DriftDatabase(tables: [SessionTable, UsersLocalTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'chiroku_cafe.sqlite'));
      log('📁 Database path: ${file.path}');
      return NativeDatabase(file);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        log('🔨 Creating all tables...');
        await m.createAll();
        log('✅ All tables created');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        log('⬆️ Upgrading database from $from to $to');
        
        if (from < 4) {
          log('➕ Migrating to version 4: Recreating session table');
          await m.deleteTable('session_table');
          await m.createTable(sessionTable);
          log('✅ Table recreated with role column');
        }
        if (from < 5) {
          log('➕ Migrating to version 5: Creating users local table');
          await m.createTable(usersLocalTable);
          log('✅ Users local table created');
        }
        if (from < 7) {
          log('➕ Migrating to version 7: Adding offline operation columns');
          await m.addColumn(usersLocalTable, usersLocalTable.pendingOperation);
          await m.addColumn(usersLocalTable, usersLocalTable.isLocalOnly);
          await m.addColumn(usersLocalTable, usersLocalTable.tempPassword);
          log('✅ Offline operation columns added');
        }
      },
    );
  }

  // =========================== SESSION METHODS ===========================

  Future<void> upsertSession({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required String role,
    required DateTime expiresAt,
  }) async {
    log('💾 Upserting session: userId=$userId, role=$role, expiresAt=$expiresAt');
    try {
      await into(sessionTable).insertOnConflictUpdate(
        SessionTableCompanion.insert(
          userId: userId,
          accessToken: accessToken,
          refreshToken: refreshToken,
          role: role,
          expiresAt: expiresAt,
          updatedAt: Value(DateTime.now()),
        ),
      );
      log('✅ Session upserted successfully');
      
      final savedSession = await getSession();
      log('🔍 Verification - Saved session: ${savedSession?.userId}, role=${savedSession?.role}');
    } catch (e) {
      log('❌ Error upserting session: $e');
      rethrow;
    }
  }

  Future<SessionLocal?> getSession() async {
    log('🔍 Getting session from DB...');
    try {
      final session = await (select(sessionTable)..limit(1)).getSingleOrNull();
      if (session != null) {
        log('✅ Session found: userId=${session.userId}, role=${session.role}, expires=${session.expiresAt}');
      } else {
        log('❌ No session found in DB');
      }
      return session;
    } catch (e) {
      log('❌ Error getting session: $e');
      return null;
    }
  }

  Stream<SessionLocal?> watchSession() {
    log('👂 Setting up session watcher...');
    return (select(sessionTable)..limit(1)).watchSingleOrNull();
  }

  Future<void> deleteSession() async {
    log('🗑️ Deleting session from DB...');
    try {
      await delete(sessionTable).go();
      log('✅ Session deleted');
    } catch (e) {
      log('❌ Error deleting session: $e');
    }
  }

  Future<bool> hasValidSession() async {
    log('🔍 Checking valid session...');
    final session = await getSession();
    if (session == null) {
      log('❌ No session exists');
      return false;
    }
    
    final isValid = session.expiresAt.isAfter(DateTime.now());
    log('✅ Session valid: $isValid');
    return isValid;
  }

  // =========================== OFFLINE USER CRUD ===========================

  Future<String> createUserOffline({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final userId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    log('📴 Creating user offline: $userId - $fullName');
    log('🔐 Password length: ${password.length} chars');
    
    try {
      await into(usersLocalTable).insert(
        UsersLocalTableCompanion.insert(
          id: userId,
          fullName: fullName,
          email: Value(email),
          role: role.isNotEmpty ? Value(role) : const Value('cashier'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
          isLocalOnly: const Value(true),
          pendingOperation: const Value('CREATE'),
          tempPassword: Value(password),
        ),
      );
      log('✅ User created offline with temp ID: $userId');
      return userId;
    } catch (e) {
      log('❌ Error creating user offline: $e');
      rethrow;
    }
  }

  Future<void> updateUserOffline(String id, {
    String? fullName,
    String? email,
    String? role,
  }) async {
    log('✏️ Updating user offline: $id');
    try {
      final user = await getUserById(id);
      if (user == null) {
        throw Exception('User not found');
      }

      // If user was created offline, keep CREATE operation
      final pendingOp = user.isLocalOnly ? 'CREATE' : 'UPDATE';

      await (update(usersLocalTable)..where((tbl) => tbl.id.equals(id)))
          .write(UsersLocalTableCompanion(
        fullName: fullName != null ? Value(fullName) : const Value.absent(),
        email: email != null ? Value(email) : const Value.absent(),
        role: role != null ? Value(role) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
        pendingOperation: Value(pendingOp),
      ));
      log('✅ User updated offline (operation: $pendingOp)');
    } catch (e) {
      log('❌ Error updating user offline: $e');
      rethrow;
    }
  }

  Future<void> deleteUserOffline(String id) async {
    log('🗑️ Deleting user offline: $id');
    try {
      final user = await (select(usersLocalTable)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
          
      if (user == null) {
        throw Exception('User not found');
      }

      if (user.isLocalOnly) {
        // If created offline and never synced, permanently delete
        await (delete(usersLocalTable)..where((tbl) => tbl.id.equals(id))).go();
        log('✅ Local-only user permanently deleted: $id');
      } else {
        // Mark for deletion sync
        await (update(usersLocalTable)..where((tbl) => tbl.id.equals(id)))
            .write(UsersLocalTableCompanion(
          isDeleted: const Value(true),
          needsSync: const Value(true),
          pendingOperation: const Value('DELETE'),
          updatedAt: Value(DateTime.now()),
        ));
        log('✅ User marked for deletion: $id');
      }
    } catch (e) {
      log('❌ Error deleting user offline: $e');
      rethrow;
    }
  }

  Future<List<UsersLocal>> getUsersNeedingSync() async {
    log('🔄 Getting users needing sync...');
    try {
      final users = await (select(usersLocalTable)
            ..where((tbl) => tbl.needsSync.equals(true)))
          .get();
      log('✅ Found ${users.length} users needing sync');
      for (final user in users) {
        log('  📋 User: ${user.id} (${user.fullName}) - Operation: ${user.pendingOperation}');
      }
      return users;
    } catch (e) {
      log('❌ Error getting users needing sync: $e');
      return [];
    }
  }

  Future<void> markUserAsSynced(String oldId, {String? newId}) async {
    log('✅ Marking user as synced: $oldId ${newId != null ? "-> $newId" : ""}');
    try {
      if (newId != null && oldId != newId) {
        // Replace temp ID with real Supabase ID
        final user = await (select(usersLocalTable)
              ..where((tbl) => tbl.id.equals(oldId)))
            .getSingleOrNull();
            
        if (user != null) {
          // Delete old temp user
          await (delete(usersLocalTable)..where((tbl) => tbl.id.equals(oldId))).go();
          
          // Insert with real ID
          await into(usersLocalTable).insert(
            UsersLocalTableCompanion.insert(
              id: newId,
              fullName: user.fullName,
              email: Value(user.email),
              avatarUrl: Value(user.avatarUrl),
              role: user.role.isNotEmpty ? Value(user.role) : const Value('cashier'),
              createdAt: Value(user.createdAt),
              updatedAt: Value(user.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isLocalOnly: const Value(false),
              pendingOperation: const Value.absent(),
              tempPassword: const Value.absent(),
            ),
          );
          log('✅ User ID replaced: $oldId -> $newId');
          
          // Verification
          final verifyUser = await getUserById(newId);
          if (verifyUser != null) {
            log('🔍 Verification: User exists with new ID: ${verifyUser.fullName}');
          }
        }
      } else {
        // Just mark as synced
        await (update(usersLocalTable)..where((tbl) => tbl.id.equals(oldId)))
            .write(UsersLocalTableCompanion(
          needsSync: const Value(false),
          syncedAt: Value(DateTime.now()),
          isLocalOnly: const Value(false),
          pendingOperation: const Value.absent(),
          tempPassword: const Value.absent(),
        ));
        log('✅ User marked as synced: $oldId');
      }
    } catch (e) {
      log('❌ Error marking user as synced: $e');
      rethrow;
    }
  }

  // =========================== ONLINE SYNC METHODS ===========================

  Future<void> upsertUser(UsersLocal user) async {
    log('💾 Upserting user from Supabase: ${user.id} - ${user.fullName}');
    try {
      await into(usersLocalTable).insertOnConflictUpdate(
        UsersLocalTableCompanion(
          id: Value(user.id),
          fullName: Value(user.fullName),
          email: Value(user.email),
          avatarUrl: Value(user.avatarUrl),
          role: Value(user.role),
          createdAt: Value(user.createdAt),
          updatedAt: Value(user.updatedAt),
          syncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
          isDeleted: Value(user.isDeleted),
          isLocalOnly: const Value(false),
          pendingOperation: const Value.absent(),
          tempPassword: const Value.absent(),
        ),
      );
      log('✅ User upserted: ${user.id}');
    } catch (e) {
      log('❌ Error upserting user: $e');
      rethrow;
    }
  }

  Future<void> upsertUsers(List<UsersLocal> usersList) async {
    log('💾 Bulk upserting ${usersList.length} users from Supabase...');
    try {
      await batch((batch) {
        for (final user in usersList) {
          batch.insert(
            usersLocalTable,
            UsersLocalTableCompanion(
              id: Value(user.id),
              fullName: Value(user.fullName),
              email: Value(user.email),
              avatarUrl: Value(user.avatarUrl),
              role: Value(user.role),
              createdAt: Value(user.createdAt),
              updatedAt: Value(user.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isDeleted: Value(user.isDeleted),
              isLocalOnly: const Value(false),
              pendingOperation: const Value.absent(),
              tempPassword: const Value.absent(),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      log('✅ Bulk upsert completed');
    } catch (e) {
      log('❌ Error bulk upserting users: $e');
      rethrow;
    }
  }

  // =========================== QUERY METHODS ===========================

  Future<List<UsersLocal>> getAllUsers() async {
    log('🔍 Getting all users...');
    try {
      final users = await (select(usersLocalTable)
            ..where((tbl) => tbl.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();
      log('✅ Found ${users.length} users');
      return users;
    } catch (e) {
      log('❌ Error getting users: $e');
      return [];
    }
  }

  Stream<List<UsersLocal>> watchAllUsers() {
    log('👂 Setting up users realtime watcher...');
    return (select(usersLocalTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<UsersLocal?> getUserById(String id) async {
    log('🔍 Getting user by ID: $id');
    try {
      final user = await (select(usersLocalTable)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
          
      if (user != null) {
        log('✅ User found: ${user.fullName} (deleted: ${user.isDeleted})');
      } else {
        log('❌ User not found: $id');
      }
      return user;
    } catch (e) {
      log('❌ Error getting user: $e');
      return null;
    }
  }

  // =========================== COUNT METHODS ===========================

  Future<int> getUsersCount() async {
    log('🔢 Counting users...');
    try {
      final users = await (select(usersLocalTable)
            ..where((tbl) => tbl.isDeleted.equals(false)))
          .get();
      final count = users.length;
      log('✅ Users count: $count');
      return count;
    } catch (e) {
      log('❌ Error counting users: $e');
      return 0;
    }
  }

  Future<int> getMenusCount() async {
    log('🔢 Counting menus...');
    // TODO: Implement when menu table exists
    log('⚠️ Menu table not yet implemented, returning 0');
    return 0;
  }

  Future<int> getCategoriesCount() async {
    log('🔢 Counting categories...');
    // TODO: Implement when category table exists
    log('⚠️ Category table not yet implemented, returning 0');
    return 0;
  }

  Future<int> getTablesCount() async {
    log('🔢 Counting tables...');
    // TODO: Implement when table entity exists
    log('⚠️ Table entity not yet implemented, returning 0');
    return 0;
  }

  // =========================== UTILITY METHODS ===========================

  Future<void> permanentlyDeleteUser(String id) async {
    log('🗑️ Permanently deleting user: $id');
    try {
      await (delete(usersLocalTable)..where((tbl) => tbl.id.equals(id))).go();
      log('✅ User permanently deleted');
    } catch (e) {
      log('❌ Error permanently deleting user: $e');
      rethrow;
    }
  }

  Future<void> clearAllUsers() async {
    log('🗑️ Clearing all users...');
    try {
      await delete(usersLocalTable).go();
      log('✅ All users cleared');
    } catch (e) {
      log('❌ Error clearing users: $e');
    }
  }

  Future<Map<String, int>> getSyncStats() async {
    try {
      final allUsers = await (select(usersLocalTable)).get();
      final needSync = allUsers.where((u) => u.needsSync).length;
      final localOnly = allUsers.where((u) => u.isLocalOnly).length;
      final deleted = allUsers.where((u) => u.isDeleted).length;
      final synced = allUsers.where((u) => !u.needsSync && !u.isDeleted).length;
      
      final stats = {
        'total': allUsers.length,
        'synced': synced,
        'needSync': needSync,
        'localOnly': localOnly,
        'deleted': deleted,
      };
      
      log('📊 Sync Stats: $stats');
      return stats;
    } catch (e) {
      log('❌ Error getting sync stats: $e');
      return {};
    }
  }
}