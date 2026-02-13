import 'package:drift/drift.dart';

@DataClassName('TablesLocal')
class TablesLocalTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get capacity => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('available'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  // Offline sync fields
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocalOnly => boolean().withDefault(const Constant(false))();
  TextColumn get pendingOperation => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
