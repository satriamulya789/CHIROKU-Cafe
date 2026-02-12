import 'package:drift/drift.dart';

@DataClassName('MenuLocal')
class MenuLocalTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().named('category_id')();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable().named('image_url')();
  TextColumn get localImagePath => text().nullable().named('local_image_path')();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true)).named('is_available')();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();
  DateTimeColumn get syncedAt => dateTime().nullable().named('synced_at')();
  
  // Offline operation fields
  BoolColumn get needsSync => boolean().withDefault(const Constant(false)).named('needs_sync')();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false)).named('is_deleted')();
  BoolColumn get isLocalOnly => boolean().withDefault(const Constant(false)).named('is_local_only')();
  TextColumn get pendingOperation => text().nullable().named('pending_operation')(); // CREATE, UPDATE, DELETE
}