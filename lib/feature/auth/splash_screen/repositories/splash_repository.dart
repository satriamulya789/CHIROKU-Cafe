import 'package:chiroku_cafe/feature/auth/splash_screen/models/local_session_model.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/services/splash_service.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashRepository {
  final SplashService _service;

  SplashRepository(this._service);

  Session? get currentSession => _service.currentSession;
  User? get currentUser => _service.currentUser;

  // Get session (online or offline)
  Future<LocalSessionModel?> getSession() async {
    return await _service.getSession();
  }

// Get user role from session
  UserRole? getUserRoleFromSession(LocalSessionModel session) {
    final roleString = session.userRole;
    
    if (roleString == 'admin') return UserRole.admin;
    if (roleString == 'cashier') return UserRole.cashier;
    
    return null;
  }

   // Clear all sessions
  Future<void> clearAllSessions() async {
    await _service.clearAllSessions();
  }

  // Future<UserRole?> getUserRole(String userId) async {
  //   final userData = await _service.getUserData(userId);
  //   if (userData == null) return null;

  //   final roleString = userData['role'] as String?;
  //   if (roleString == 'admin') return UserRole.admin;
  //   if (roleString == 'cashier') return UserRole.cashier;
  //   return null;
  // }
}
