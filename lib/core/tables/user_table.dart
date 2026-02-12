import 'package:drift/drift.dart';

@DataClassName('UsersLocal')
class UsersLocalTable extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().named('full_name')();
  TextColumn get email => text().nullable()();
  TextColumn get avatarUrl => text().nullable().named('avatar_url')();
  TextColumn get role => text().withDefault(const Constant('cashier'))();
  DateTimeColumn get createdAt => dateTime().nullable().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().nullable().named('updated_at')();
  DateTimeColumn get syncedAt => dateTime().nullable().named('synced_at')();
  BoolColumn get needsSync =>
      boolean().withDefault(const Constant(false)).named('needs_sync')();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false)).named('is_deleted')();

  // ✅ OFFLINE OPERATION TRACKING
  TextColumn get pendingOperation => text().nullable().named(
    'pending_operation',
  )(); // 'CREATE', 'UPDATE', 'DELETE'
  BoolColumn get isLocalOnly => boolean()
      .withDefault(const Constant(false))
      .named('is_local_only')(); // true if created offline
  TextColumn get tempPassword => text().nullable().named(
    'temp_password',
  )(); // Store password for offline creation

  @override
  Set<Column> get primaryKey => {id};
}
