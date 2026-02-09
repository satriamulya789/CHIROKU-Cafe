import 'package:chiroku_cafe/core/tables/session_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:developer';

part 'drift_database.g.dart';

@DriftDatabase(tables: [SessionTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
      },
    );
  }

  // Insert or update session (dengan role)
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
      
      // Verify save
      final savedSession = await getSession();
      log('🔍 Verification - Saved session: ${savedSession?.userId}, role=${savedSession?.role}');
    } catch (e) {
      log('❌ Error upserting session: $e');
      rethrow;
    }
  }

  // Get session
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
  
  // Delete session
  Future<void> deleteSession() async {
    log('🗑️ Deleting session from DB...');
    try {
      await delete(sessionTable).go();
      log('✅ Session deleted');
    } catch (e) {
      log('❌ Error deleting session: $e');
    }
  }

  // Check if session exists and valid
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
}