import 'package:chiroku_cafe/core/tables/session_table.dart';
import 'package:chiroku_cafe/core/tables/user_table.dart';
import 'package:chiroku_cafe/core/tables/menu_table.dart';
import 'package:chiroku_cafe/core/tables/category_table.dart';
import 'package:chiroku_cafe/core/tables/tables_local_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:developer';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    SessionTable,
    UsersLocalTable,
    MenuLocalTable,
    CategoryLocalTable,
    TablesLocalTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

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
        if (from < 8) {
          log('➕ Migrating to version 8: Creating menu and category tables');
          await m.createTable(menuLocalTable);
          await m.createTable(categoryLocalTable);
          log('✅ Menu and category tables created');
        }
        if (from < 9) {
          log('➕ Migrating to version 9: Creating tables local table');
          await m.createTable(tablesLocalTable);
          log('✅ Tables local table created');
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
    log(
      '💾 Upserting session: userId=$userId, role=$role, expiresAt=$expiresAt',
    );
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
      log(
        '🔍 Verification - Saved session: ${savedSession?.userId}, role=${savedSession?.role}',
      );
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
        log(
          '✅ Session found: userId=${session.userId}, role=${session.role}, expires=${session.expiresAt}',
        );
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

  Future<void> updateUserOffline(
    String id, {
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

      final pendingOp = user.isLocalOnly ? 'CREATE' : 'UPDATE';

      await (update(usersLocalTable)..where((tbl) => tbl.id.equals(id))).write(
        UsersLocalTableCompanion(
          fullName: fullName != null ? Value(fullName) : const Value.absent(),
          email: email != null ? Value(email) : const Value.absent(),
          role: role != null ? Value(role) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
          pendingOperation: Value(pendingOp),
        ),
      );
      log('✅ User updated offline (operation: $pendingOp)');
    } catch (e) {
      log('❌ Error updating user offline: $e');
      rethrow;
    }
  }

  Future<void> deleteUserOffline(String id) async {
    log('🗑️ Deleting user offline: $id');
    try {
      final user = await (select(
        usersLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (user == null) {
        throw Exception('User not found');
      }

      if (user.isLocalOnly) {
        await (delete(usersLocalTable)..where((tbl) => tbl.id.equals(id))).go();
        log('✅ Local-only user permanently deleted: $id');
      } else {
        await (update(
          usersLocalTable,
        )..where((tbl) => tbl.id.equals(id))).write(
          UsersLocalTableCompanion(
            isDeleted: const Value(true),
            needsSync: const Value(true),
            pendingOperation: const Value('DELETE'),
            updatedAt: Value(DateTime.now()),
          ),
        );
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
      final users = await (select(
        usersLocalTable,
      )..where((tbl) => tbl.needsSync.equals(true))).get();
      log('✅ Found ${users.length} users needing sync');
      for (final user in users) {
        log(
          '  📋 User: ${user.id} (${user.fullName}) - Operation: ${user.pendingOperation}',
        );
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
        final user = await (select(
          usersLocalTable,
        )..where((tbl) => tbl.id.equals(oldId))).getSingleOrNull();

        if (user != null) {
          await (delete(
            usersLocalTable,
          )..where((tbl) => tbl.id.equals(oldId))).go();

          await into(usersLocalTable).insert(
            UsersLocalTableCompanion.insert(
              id: newId,
              fullName: user.fullName,
              email: Value(user.email),
              avatarUrl: Value(user.avatarUrl),
              role: user.role.isNotEmpty
                  ? Value(user.role)
                  : const Value('cashier'),
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

          final verifyUser = await getUserById(newId);
          if (verifyUser != null) {
            log(
              '🔍 Verification: User exists with new ID: ${verifyUser.fullName}',
            );
          }
        }
      } else {
        await (update(
          usersLocalTable,
        )..where((tbl) => tbl.id.equals(oldId))).write(
          UsersLocalTableCompanion(
            needsSync: const Value(false),
            syncedAt: Value(DateTime.now()),
            isLocalOnly: const Value(false),
            pendingOperation: const Value.absent(),
            tempPassword: const Value.absent(),
          ),
        );
        log('✅ User marked as synced: $oldId');
      }
    } catch (e) {
      log('❌ Error marking user as synced: $e');
      rethrow;
    }
  }

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

  Future<List<UsersLocal>> getAllUsers() async {
    log('🔍 Getting all users...');
    try {
      final users =
          await (select(usersLocalTable)
                ..where((tbl) => tbl.isDeleted.equals(false))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.desc,
                  ),
                ]))
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
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<UsersLocal?> getUserById(String id) async {
    log('🔍 Getting user by ID: $id');
    try {
      final user = await (select(
        usersLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

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

  Future<int> getUsersCount() async {
    log('🔢 Counting users...');
    try {
      final users = await (select(
        usersLocalTable,
      )..where((tbl) => tbl.isDeleted.equals(false))).get();
      final count = users.length;
      log('✅ Users count: $count');
      return count;
    } catch (e) {
      log('❌ Error counting users: $e');
      return 0;
    }
  }

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

  // =========================== MENU METHODS ===========================

  Future<int> createMenuOffline({
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    String? localImagePath,
    bool isAvailable = true,
  }) async {
    log('📴 Creating menu offline: $name');

    try {
      final id = await into(menuLocalTable).insert(
        MenuLocalTableCompanion.insert(
          categoryId: categoryId,
          name: name,
          price: price,
          description: Value(description),
          imageUrl: Value(imageUrl),
          localImagePath: Value(localImagePath),
          stock: Value(stock),
          isAvailable: Value(isAvailable),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
          isLocalOnly: const Value(true),
          pendingOperation: const Value('CREATE'),
        ),
      );
      log('✅ Menu created offline with ID: $id');
      return id;
    } catch (e) {
      log('❌ Error creating menu offline: $e');
      rethrow;
    }
  }

  Future<void> updateMenuOffline(
    int id, {
    int? categoryId,
    String? name,
    double? price,
    String? description,
    int? stock,
    String? imageUrl,
    String? localImagePath,
    bool? isAvailable,
  }) async {
    log('✏️ Updating menu offline: $id');
    try {
      final menu = await getMenuById(id);
      if (menu == null) {
        throw Exception('Menu not found');
      }

      final pendingOp = menu.isLocalOnly ? 'CREATE' : 'UPDATE';

      await (update(menuLocalTable)..where((tbl) => tbl.id.equals(id))).write(
        MenuLocalTableCompanion(
          categoryId: categoryId != null
              ? Value(categoryId)
              : const Value.absent(),
          name: name != null ? Value(name) : const Value.absent(),
          price: price != null ? Value(price) : const Value.absent(),
          description: description != null
              ? Value(description)
              : const Value.absent(),
          stock: stock != null ? Value(stock) : const Value.absent(),
          imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
          localImagePath: localImagePath != null
              ? Value(localImagePath)
              : const Value.absent(),
          isAvailable: isAvailable != null
              ? Value(isAvailable)
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
          pendingOperation: Value(pendingOp),
        ),
      );
      log('✅ Menu updated offline (operation: $pendingOp)');
    } catch (e) {
      log('❌ Error updating menu offline: $e');
      rethrow;
    }
  }

  Future<void> deleteMenuOffline(int id) async {
    log('🗑️ Deleting menu offline: $id');
    try {
      final menu = await (select(
        menuLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (menu == null) {
        throw Exception('Menu not found');
      }

      if (menu.isLocalOnly) {
        await (delete(menuLocalTable)..where((tbl) => tbl.id.equals(id))).go();
        log('✅ Local-only menu permanently deleted: $id');
      } else {
        await (update(menuLocalTable)..where((tbl) => tbl.id.equals(id))).write(
          MenuLocalTableCompanion(
            isDeleted: const Value(true),
            needsSync: const Value(true),
            pendingOperation: const Value('DELETE'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        log('✅ Menu marked for deletion: $id');
      }
    } catch (e) {
      log('❌ Error deleting menu offline: $e');
      rethrow;
    }
  }

  Future<List<MenuLocal>> getMenusNeedingSync() async {
    log('🔄 Getting menus needing sync...');
    try {
      final menus = await (select(
        menuLocalTable,
      )..where((tbl) => tbl.needsSync.equals(true))).get();
      log('✅ Found ${menus.length} menus needing sync');
      return menus;
    } catch (e) {
      log('❌ Error getting menus needing sync: $e');
      return [];
    }
  }

  Future<void> markMenuAsSynced(int localId, {int? newId}) async {
    log(
      '✅ Marking menu as synced: $localId ${newId != null ? "-> $newId" : ""}',
    );
    try {
      if (newId != null && localId != newId) {
        final menu = await (select(
          menuLocalTable,
        )..where((tbl) => tbl.id.equals(localId))).getSingleOrNull();

        if (menu != null) {
          await (delete(
            menuLocalTable,
          )..where((tbl) => tbl.id.equals(localId))).go();

          await into(menuLocalTable).insert(
            MenuLocalTableCompanion.insert(
              id: Value(newId),
              categoryId: menu.categoryId,
              name: menu.name,
              price: menu.price,
              description: Value(menu.description),
              imageUrl: Value(menu.imageUrl),
              localImagePath: Value(menu.localImagePath),
              stock: Value(menu.stock),
              isAvailable: Value(menu.isAvailable),
              createdAt: Value(menu.createdAt),
              updatedAt: Value(menu.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isLocalOnly: const Value(false),
            ),
          );
          log('✅ Menu ID replaced: $localId -> $newId');
        }
      } else {
        await (update(
          menuLocalTable,
        )..where((tbl) => tbl.id.equals(localId))).write(
          MenuLocalTableCompanion(
            needsSync: const Value(false),
            syncedAt: Value(DateTime.now()),
            isLocalOnly: const Value(false),
            pendingOperation: const Value.absent(),
          ),
        );
        log('✅ Menu marked as synced: $localId');
      }
    } catch (e) {
      log('❌ Error marking menu as synced: $e');
      rethrow;
    }
  }

  Future<void> upsertMenu(MenuLocal menu) async {
    log('💾 Upserting menu from Supabase: ${menu.id} - ${menu.name}');
    try {
      await into(menuLocalTable).insertOnConflictUpdate(
        MenuLocalTableCompanion(
          id: Value(menu.id),
          categoryId: Value(menu.categoryId),
          name: Value(menu.name),
          price: Value(menu.price),
          description: Value(menu.description),
          imageUrl: Value(menu.imageUrl),
          stock: Value(menu.stock),
          isAvailable: Value(menu.isAvailable),
          createdAt: Value(menu.createdAt),
          updatedAt: Value(menu.updatedAt),
          syncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
          isDeleted: Value(menu.isDeleted),
          isLocalOnly: const Value(false),
        ),
      );
      log('✅ Menu upserted: ${menu.id}');
    } catch (e) {
      log('❌ Error upserting menu: $e');
      rethrow;
    }
  }

  Future<void> upsertMenus(List<MenuLocal> menusList) async {
    log('💾 Bulk upserting ${menusList.length} menus from Supabase...');
    try {
      await batch((batch) {
        for (final menu in menusList) {
          batch.insert(
            menuLocalTable,
            MenuLocalTableCompanion(
              id: Value(menu.id),
              categoryId: Value(menu.categoryId),
              name: Value(menu.name),
              price: Value(menu.price),
              description: Value(menu.description),
              imageUrl: Value(menu.imageUrl),
              stock: Value(menu.stock),
              isAvailable: Value(menu.isAvailable),
              createdAt: Value(menu.createdAt),
              updatedAt: Value(menu.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isDeleted: Value(menu.isDeleted),
              isLocalOnly: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      log('✅ Bulk upsert completed');
    } catch (e) {
      log('❌ Error bulk upserting menus: $e');
      rethrow;
    }
  }

  Future<List<MenuLocal>> getAllMenus() async {
    log('🔍 Getting all menus...');
    try {
      final menus =
          await (select(menuLocalTable)
                ..where((tbl) => tbl.isDeleted.equals(false))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.desc,
                  ),
                ]))
              .get();
      log('✅ Found ${menus.length} menus');
      return menus;
    } catch (e) {
      log('❌ Error getting menus: $e');
      return [];
    }
  }

  Stream<List<MenuLocal>> watchAllMenus() {
    log('👂 Setting up menus realtime watcher...');
    return (select(menuLocalTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<MenuLocal?> getMenuById(int id) async {
    log('🔍 Getting menu by ID: $id');
    try {
      final menu = await (select(
        menuLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (menu != null) {
        log('✅ Menu found: ${menu.name}');
      } else {
        log('❌ Menu not found: $id');
      }
      return menu;
    } catch (e) {
      log('❌ Error getting menu: $e');
      return null;
    }
  }

  Future<int> getMenusCount() async {
    log('🔢 Counting menus...');
    try {
      final menus = await (select(
        menuLocalTable,
      )..where((tbl) => tbl.isDeleted.equals(false))).get();
      final count = menus.length;
      log('✅ Menus count: $count');
      return count;
    } catch (e) {
      log('❌ Error counting menus: $e');
      return 0;
    }
  }

  Future<void> permanentlyDeleteMenu(int id) async {
    log('🗑️ Permanently deleting menu: $id');
    try {
      await (delete(menuLocalTable)..where((tbl) => tbl.id.equals(id))).go();
      log('✅ Menu permanently deleted');
    } catch (e) {
      log('❌ Error permanently deleting menu: $e');
      rethrow;
    }
  }

  // =========================== CATEGORY METHODS ===========================

  // OFFLINE CRUD OPERATIONS
  Future<int> createCategoryOffline({required String name}) async {
    log('📴 Creating category offline: $name');

    try {
      final id = await into(categoryLocalTable).insert(
        CategoryLocalTableCompanion.insert(
          name: name,
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      log('✅ Category created offline with ID: $id');
      return id;
    } catch (e) {
      log('❌ Error creating category offline: $e');
      rethrow;
    }
  }

  Future<void> updateCategoryOffline(int id, {String? name}) async {
    log('✏️ Updating category offline: $id');
    try {
      final category = await getCategoryById(id);
      if (category == null) {
        throw Exception('Category not found');
      }

      await (update(
        categoryLocalTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        CategoryLocalTableCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      log('✅ Category updated offline');
    } catch (e) {
      log('❌ Error updating category offline: $e');
      rethrow;
    }
  }

  Future<void> deleteCategoryOffline(int id) async {
    log('🗑️ Deleting category offline: $id');
    try {
      final category = await (select(
        categoryLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (category == null) {
        throw Exception('Category not found');
      }

      await (update(
        categoryLocalTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        CategoryLocalTableCompanion(
          isDeleted: const Value(true),
          needsSync: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      log('✅ Category marked for deletion: $id');
    } catch (e) {
      log('❌ Error deleting category offline: $e');
      rethrow;
    }
  }

  // SYNC QUEUE MANAGEMENT
  Future<List<CategoryLocal>> getCategoriesNeedingSync() async {
    log('🔄 Getting categories needing sync...');
    try {
      final categories = await (select(
        categoryLocalTable,
      )..where((tbl) => tbl.needsSync.equals(true))).get();
      log('✅ Found ${categories.length} categories needing sync');
      for (final category in categories) {
        log(
          '  📋 Category: ${category.id} (${category.name}) - Deleted: ${category.isDeleted}',
        );
      }
      return categories;
    } catch (e) {
      log('❌ Error getting categories needing sync: $e');
      return [];
    }
  }

  Future<void> markCategoryAsSynced(int localId, {int? newId}) async {
    log(
      '✅ Marking category as synced: $localId ${newId != null ? "-> $newId" : ""}',
    );
    try {
      if (newId != null && localId != newId) {
        final category = await (select(
          categoryLocalTable,
        )..where((tbl) => tbl.id.equals(localId))).getSingleOrNull();

        if (category != null) {
          await (delete(
            categoryLocalTable,
          )..where((tbl) => tbl.id.equals(localId))).go();

          await into(categoryLocalTable).insert(
            CategoryLocalTableCompanion.insert(
              id: Value(newId),
              name: category.name,
              createdAt: Value(category.createdAt),
              updatedAt: Value(category.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
            ),
          );
          log('✅ Category ID replaced: $localId -> $newId');
        }
      } else {
        await (update(
          categoryLocalTable,
        )..where((tbl) => tbl.id.equals(localId))).write(
          CategoryLocalTableCompanion(
            needsSync: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );
        log('✅ Category marked as synced: $localId');
      }
    } catch (e) {
      log('❌ Error marking category as synced: $e');
      rethrow;
    }
  }

  // SUPABASE SYNC OPERATIONS
  Future<void> upsertCategory(CategoryLocal category) async {
    log(
      '💾 Upserting category from Supabase: ${category.id} - ${category.name}',
    );
    try {
      await into(categoryLocalTable).insertOnConflictUpdate(
        CategoryLocalTableCompanion(
          id: Value(category.id),
          name: Value(category.name),
          createdAt: Value(category.createdAt),
          updatedAt: Value(category.updatedAt),
          syncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
          isDeleted: Value(category.isDeleted),
        ),
      );
      log('✅ Category upserted: ${category.id}');
    } catch (e) {
      log('❌ Error upserting category: $e');
      rethrow;
    }
  }

  Future<void> upsertCategories(List<CategoryLocal> categoriesList) async {
    log(
      '💾 Bulk upserting ${categoriesList.length} categories from Supabase...',
    );
    try {
      await batch((batch) {
        for (final category in categoriesList) {
          batch.insert(
            categoryLocalTable,
            CategoryLocalTableCompanion(
              id: Value(category.id),
              name: Value(category.name),
              createdAt: Value(category.createdAt),
              updatedAt: Value(category.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isDeleted: Value(category.isDeleted),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      log('✅ Bulk upsert completed');
    } catch (e) {
      log('❌ Error bulk upserting categories: $e');
      rethrow;
    }
  }

  // READ OPERATIONS
  Future<List<CategoryLocal>> getAllCategories() async {
    log('🔍 Getting all categories...');
    try {
      final categories =
          await (select(categoryLocalTable)
                ..where((tbl) => tbl.isDeleted.equals(false))
                ..orderBy([(t) => OrderingTerm(expression: t.name)]))
              .get();
      log('✅ Found ${categories.length} categories');
      return categories;
    } catch (e) {
      log('❌ Error getting categories: $e');
      return [];
    }
  }

  Stream<List<CategoryLocal>> watchAllCategories() {
    log('👂 Setting up categories realtime watcher...');
    return (select(categoryLocalTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<CategoryLocal?> getCategoryById(int id) async {
    log('🔍 Getting category by ID: $id');
    try {
      final category = await (select(
        categoryLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (category != null) {
        log('✅ Category found: ${category.name}');
      } else {
        log('❌ Category not found: $id');
      }
      return category;
    } catch (e) {
      log('❌ Error getting category: $e');
      return null;
    }
  }

  Future<int> getCategoriesCount() async {
    log('🔢 Counting categories...');
    try {
      final categories = await (select(
        categoryLocalTable,
      )..where((tbl) => tbl.isDeleted.equals(false))).get();
      final count = categories.length;
      log('✅ Categories count: $count');
      return count;
    } catch (e) {
      log('❌ Error counting categories: $e');
      return 0;
    }
  }

  Future<void> permanentlyDeleteCategory(int id) async {
    log('🗑️ Permanently deleting category: $id');
    try {
      await (delete(
        categoryLocalTable,
      )..where((tbl) => tbl.id.equals(id))).go();
      log('✅ Category permanently deleted');
    } catch (e) {
      log('❌ Error permanently deleting category: $e');
      rethrow;
    }
  }

  Future<void> clearAllCategories() async {
    log('🗑️ Clearing all categories...');
    try {
      await delete(categoryLocalTable).go();
      log('✅ All categories cleared');
    } catch (e) {
      log('❌ Error clearing categories: $e');
    }
  }

  // =========================== TABLES METHODS ===========================

  // OFFLINE CRUD OPERATIONS
  Future<int> createTableOffline({
    required String name,
    int capacity = 1,
    String status = 'available',
  }) async {
    log('📴 Creating table offline: $name');

    try {
      final id = await into(tablesLocalTable).insert(
        TablesLocalTableCompanion.insert(
          name: name,
          capacity: Value(capacity),
          status: Value(status),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
          isLocalOnly: const Value(true),
          pendingOperation: const Value('CREATE'),
        ),
      );
      log('✅ Table created offline with ID: $id');
      return id;
    } catch (e) {
      log('❌ Error creating table offline: $e');
      rethrow;
    }
  }

  Future<void> updateTableOffline(
    int id, {
    String? name,
    int? capacity,
    String? status,
  }) async {
    log('✏️ Updating table offline: $id');
    try {
      final table = await getTableById(id);
      if (table == null) {
        throw Exception('Table not found');
      }

      final pendingOp = table.isLocalOnly ? 'CREATE' : 'UPDATE';

      await (update(tablesLocalTable)..where((tbl) => tbl.id.equals(id))).write(
        TablesLocalTableCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          capacity: capacity != null ? Value(capacity) : const Value.absent(),
          status: status != null ? Value(status) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
          pendingOperation: Value(pendingOp),
        ),
      );
      log('✅ Table updated offline (operation: $pendingOp)');
    } catch (e) {
      log('❌ Error updating table offline: $e');
      rethrow;
    }
  }

  Future<void> deleteTableOffline(int id) async {
    log('🗑️ Deleting table offline: $id');
    try {
      final table = await (select(
        tablesLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (table == null) {
        throw Exception('Table not found');
      }

      if (table.isLocalOnly) {
        await (delete(
          tablesLocalTable,
        )..where((tbl) => tbl.id.equals(id))).go();
        log('✅ Local-only table permanently deleted: $id');
      } else {
        await (update(
          tablesLocalTable,
        )..where((tbl) => tbl.id.equals(id))).write(
          TablesLocalTableCompanion(
            isDeleted: const Value(true),
            needsSync: const Value(true),
            pendingOperation: const Value('DELETE'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        log('✅ Table marked for deletion: $id');
      }
    } catch (e) {
      log('❌ Error deleting table offline: $e');
      rethrow;
    }
  }

  // SYNC QUEUE MANAGEMENT
  Future<List<TablesLocal>> getTablesNeedingSync() async {
    log('🔄 Getting tables needing sync...');
    try {
      final tables = await (select(
        tablesLocalTable,
      )..where((tbl) => tbl.needsSync.equals(true))).get();
      log('✅ Found ${tables.length} tables needing sync');
      for (final table in tables) {
        log(
          '  📋 Table: ${table.id} (${table.name}) - Operation: ${table.pendingOperation}',
        );
      }
      return tables;
    } catch (e) {
      log('❌ Error getting tables needing sync: $e');
      return [];
    }
  }

  Future<void> markTableAsSynced(int localId, {int? newId}) async {
    log(
      '✅ Marking table as synced: $localId ${newId != null ? "-> $newId" : ""}',
    );
    try {
      if (newId != null && localId != newId) {
        final table = await (select(
          tablesLocalTable,
        )..where((tbl) => tbl.id.equals(localId))).getSingleOrNull();

        if (table != null) {
          await (delete(
            tablesLocalTable,
          )..where((tbl) => tbl.id.equals(localId))).go();

          await into(tablesLocalTable).insert(
            TablesLocalTableCompanion.insert(
              id: Value(newId),
              name: table.name,
              capacity: Value(table.capacity),
              status: Value(table.status),
              createdAt: Value(table.createdAt),
              updatedAt: Value(table.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isLocalOnly: const Value(false),
            ),
          );
          log('✅ Table ID replaced: $localId -> $newId');
        }
      } else {
        await (update(
          tablesLocalTable,
        )..where((tbl) => tbl.id.equals(localId))).write(
          TablesLocalTableCompanion(
            needsSync: const Value(false),
            syncedAt: Value(DateTime.now()),
            isLocalOnly: const Value(false),
            pendingOperation: const Value.absent(),
          ),
        );
        log('✅ Table marked as synced: $localId');
      }
    } catch (e) {
      log('❌ Error marking table as synced: $e');
      rethrow;
    }
  }

  // SUPABASE SYNC OPERATIONS
  Future<void> upsertTable(TablesLocal table) async {
    log('💾 Upserting table from Supabase: ${table.id} - ${table.name}');
    try {
      await into(tablesLocalTable).insertOnConflictUpdate(
        TablesLocalTableCompanion(
          id: Value(table.id),
          name: Value(table.name),
          capacity: Value(table.capacity),
          status: Value(table.status),
          createdAt: Value(table.createdAt),
          updatedAt: Value(table.updatedAt),
          syncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
          isDeleted: Value(table.isDeleted),
          isLocalOnly: const Value(false),
        ),
      );
      log('✅ Table upserted: ${table.id}');
    } catch (e) {
      log('❌ Error upserting table: $e');
      rethrow;
    }
  }

  Future<void> upsertTables(List<TablesLocal> tablesList) async {
    log('💾 Bulk upserting ${tablesList.length} tables from Supabase...');
    try {
      await batch((batch) {
        for (final table in tablesList) {
          batch.insert(
            tablesLocalTable,
            TablesLocalTableCompanion(
              id: Value(table.id),
              name: Value(table.name),
              capacity: Value(table.capacity),
              status: Value(table.status),
              createdAt: Value(table.createdAt),
              updatedAt: Value(table.updatedAt),
              syncedAt: Value(DateTime.now()),
              needsSync: const Value(false),
              isDeleted: Value(table.isDeleted),
              isLocalOnly: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      log('✅ Bulk upsert completed');
    } catch (e) {
      log('❌ Error bulk upserting tables: $e');
      rethrow;
    }
  }

  // READ OPERATIONS
  Future<List<TablesLocal>> getAllTables() async {
    log('🔍 Getting all tables...');
    try {
      final tables =
          await (select(tablesLocalTable)
                ..where((tbl) => tbl.isDeleted.equals(false))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.desc,
                  ),
                ]))
              .get();
      log('✅ Found ${tables.length} tables');
      return tables;
    } catch (e) {
      log('❌ Error getting tables: $e');
      return [];
    }
  }

  Stream<List<TablesLocal>> watchAllTables() {
    log('👂 Setting up tables realtime watcher...');
    return (select(tablesLocalTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<TablesLocal?> getTableById(int id) async {
    log('🔍 Getting table by ID: $id');
    try {
      final table = await (select(
        tablesLocalTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (table != null) {
        log('✅ Table found: ${table.name}');
      } else {
        log('❌ Table not found: $id');
      }
      return table;
    } catch (e) {
      log('❌ Error getting table: $e');
      return null;
    }
  }

  Future<void> permanentlyDeleteTable(int id) async {
    log('🗑️ Permanently deleting table: $id');
    try {
      await (delete(tablesLocalTable)..where((tbl) => tbl.id.equals(id))).go();
      log('✅ Table permanently deleted');
    } catch (e) {
      log('❌ Error permanently deleting table: $e');
      rethrow;
    }
  }

  Future<void> clearAllTables() async {
    log('🗑️ Clearing all tables...');
    try {
      await delete(tablesLocalTable).go();
      log('✅ All tables cleared');
    } catch (e) {
      log('❌ Error clearing tables: $e');
    }
  }

  Future<int> getTablesCount() async {
    log('🔢 Counting tables...');
    try {
      final tables = await (select(
        tablesLocalTable,
      )..where((tbl) => tbl.isDeleted.equals(false))).get();
      final count = tables.length;
      log('✅ Tables count: $count');
      return count;
    } catch (e) {
      log('❌ Error counting tables: $e');
      return 0;
    }
  }

  Future<Map<String, int>> getAdminStats() async {
    log('📊 Getting admin stats from local database...');
    try {
      final usersCount = await getUsersCount();
      final menusCount = await getMenusCount();
      final categoriesCount = await getCategoriesCount();
      final tablesCount = await getTablesCount();

      final stats = {
        'users': usersCount,
        'menus': menusCount,
        'categories': categoriesCount,
        'tables': tablesCount,
      };

      log('✅ Admin stats from local DB: $stats');
      return stats;
    } catch (e) {
      log('❌ Error getting admin stats: $e');
      return {'users': 0, 'menus': 0, 'categories': 0, 'tables': 0};
    }
  }

  // =========================== UTILITY METHODS ===========================

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
