import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/services/splash_service.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashRepository {
  final SplashService _service;
  final AppDatabase _database;
  final NetworkInfo _networkInfo;

  SplashRepository(
    this._service,
    this._database,
    this._networkInfo,
  );

  Session? get currentSession => _service.currentSession;
  User? get currentUser => _service.currentUser;

  Future<UserRole?> getUserRole(String userId) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      
      if (isOnline) {
        // Online: fetch from Supabase via service
        final userData = await _service.getUserData(userId);
        if (userData == null) return null;

        final roleString = userData['role'] as String?;
        return _parseRole(roleString);
      } else {
        // Offline: get from local database if available
        // You can implement local user table cache if needed
        throw Exception('Cannot fetch user role in offline mode');
      }
    } catch (e) {
      print('❌ Error getting user role: $e');
      rethrow;
    }
  }

  UserRole? _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'cashier':
        return UserRole.cashier;
      default:
        return null;
    }
  }
}