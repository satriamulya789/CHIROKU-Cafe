import 'dart:developer';
import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/tables/session_table.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/models/local_session_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalSessionService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save session to local database
  Future<void> saveSession(LocalSessionModel session) async {
    try {
      final db = await _dbHelper.database;
      
      // Delete existing session first
      await deleteSession();
      
      // Insert new session
      await db.insert(
        SessionTable.tableName,
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      log('✅ Session saved to local database: ${session.userId}');
    } catch (e) {
      log('❌ Error saving session: $e');
      rethrow;
    }
  }

  // Get session from local database
  Future<LocalSessionModel?> getSession() async {
    try {
      final db = await _dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        SessionTable.tableName,
        orderBy: '${SessionTable.columnUpdatedAt} DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        log('ℹ️ No local session found');
        return null;
      }

      final session = LocalSessionModel.fromMap(maps.first);
      log('✅ Local session retrieved: ${session.userId}');
      
      // Check if session is expired
      if (session.isExpired) {
        log('⚠️ Local session expired, deleting...');
        await deleteSession();
        return null;
      }
      
      return session;
    } catch (e) {
      log('❌ Error getting session: $e');
      return null;
    }
  }

  // Delete session from local database
  Future<void> deleteSession() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(SessionTable.tableName);
      log('🗑️ Local session deleted');
    } catch (e) {
      log('❌ Error deleting session: $e');
    }
  }

  // Update session role
  Future<void> updateSessionRole(String userId, String role) async {
    try {
      final db = await _dbHelper.database;
      
      await db.update(
        SessionTable.tableName,
        {
          SessionTable.columnUserRole: role,
          SessionTable.columnUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        where: '${SessionTable.columnUserId} = ?',
        whereArgs: [userId],
      );
      
      log('✅ Session role updated: $role');
    } catch (e) {
      log('❌ Error updating session role: $e');
    }
  }

  // Check if session exists
  Future<bool> hasSession() async {
    final session = await getSession();
    return session != null;
  }
}