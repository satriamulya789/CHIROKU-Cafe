import 'dart:developer';

import 'package:chiroku_cafe/core/tables/session_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'chiroku_cafe.db');

    return await openDatabase(
      path,
      version: 2, // Incremented to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(SessionTable.createTableSQL);
    log('✅ Database created: chiroku_cafe.db');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      log('⬆️ Database upgrading from v$oldVersion to v$newVersion...');
      // Create session table if it doesn't exist
      await db.execute(SessionTable.createTableSQL);
      log('✅ Session table created during upgrade');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'chiroku_cafe.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    log('Database deleted');
  }
}
