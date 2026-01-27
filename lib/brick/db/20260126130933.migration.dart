// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260126130933_up = [
  InsertTable('User'),
  InsertColumn('full_name', Column.varchar, onTable: 'User'),
  InsertColumn('email', Column.varchar, onTable: 'User'),
  InsertColumn('avatar_url', Column.varchar, onTable: 'User'),
  InsertColumn('role', Column.varchar, onTable: 'User'),
  InsertColumn('created_at', Column.datetime, onTable: 'User'),
  InsertColumn('updated_at', Column.datetime, onTable: 'User'),
  InsertColumn('id', Column.varchar, onTable: 'User', unique: true),
  CreateIndex(columns: ['id'], onTable: 'User', unique: true)
];

const List<MigrationCommand> _migration_20260126130933_down = [
  DropTable('User'),
  DropColumn('full_name', onTable: 'User'),
  DropColumn('email', onTable: 'User'),
  DropColumn('avatar_url', onTable: 'User'),
  DropColumn('role', onTable: 'User'),
  DropColumn('created_at', onTable: 'User'),
  DropColumn('updated_at', onTable: 'User'),
  DropColumn('id', onTable: 'User'),
  DropIndex('index_User_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260126130933',
  up: _migration_20260126130933_up,
  down: _migration_20260126130933_down,
)
class Migration20260126130933 extends Migration {
  const Migration20260126130933()
    : super(
        version: 20260126130933,
        up: _migration_20260126130933_up,
        down: _migration_20260126130933_down,
      );
}
