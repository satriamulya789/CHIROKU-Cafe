import 'package:drift/drift.dart';

@DataClassName('CategoryLocal')
class CategoryLocalTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();
  DateTimeColumn get syncedAt => dateTime().nullable().named('synced_at')();
  
  BoolColumn get needsSync => boolean().withDefault(const Constant(false)).named('needs_sync')();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false)).named('is_deleted')();
}