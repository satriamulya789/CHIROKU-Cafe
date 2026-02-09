import 'package:drift/drift.dart';

@DataClassName('SessionLocal')
class SessionTable extends Table {
  TextColumn get userId => text()();
  TextColumn get accessToken => text()();
  TextColumn get refreshToken => text()();
  TextColumn get role => text()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}