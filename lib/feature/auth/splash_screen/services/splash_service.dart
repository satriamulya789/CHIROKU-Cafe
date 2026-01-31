import 'dart:developer';

import 'package:chiroku_cafe/feature/auth/splash_screen/models/local_session_model.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/services/connectivity_service.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/services/local_session_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashService {
  final _supabase = Supabase.instance.client;
  final LocalSessionService _localSessionService = LocalSessionService();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      return await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  // Save current session to local database
  Future<void> saveSessionToLocal() async {
    try {
      final session = currentSession;
      final user = currentUser;

      if (session == null || user == null) {
        log('⚠️ No session to save (User or Session is null)');
        return;
      }

      log('📥 Saving session to local for user: ${user.id}...');

      // Fetch user role from Supabase
      Map<String, dynamic>? userData;
      try {
        userData = await getUserData(user.id);
      } catch (e) {
        log('❌ Error parsing user data for role: $e');
      }

      final role = userData?['role'] as String?;

      if (role == null) {
        log(
          '⚠️ Warning: Role is null for user ${user.id}. Session might be incomplete.',
        );
      } else {
        log('✅ Role fetched: $role');
      }

      log('🕒 Raw Supabase expiresAt: ${session.expiresAt}');

      final localSession = LocalSessionModel(
        userId: user.id,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: session.expiresAt != null
            ? session.expiresAt! *
                  1000 // Convert to milliseconds
            : null,
        userRole: role,
        userEmail: user.email,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _localSessionService.saveSession(localSession);
      log('✅ Session successfully saved to local database');

      // Verify immediately
      final savedSession = await _localSessionService.getSession();
      if (savedSession != null) {
        log(
          '🔍 Verification: Session found in DB with role: ${savedSession.userRole}',
        );
      } else {
        log('❌ Verification failed: Session NOT found in DB after save!');
      }
    } catch (e) {
      log('❌ Error saving session to local: $e');
    }
  }

  // Get session (online or offline)
  Future<LocalSessionModel?> getSession() async {
    final isOnline = await _connectivityService.checkConnection();
    log('Network Status: ${isOnline ? "ONLINE" : "OFFLINE"}');

    if (isOnline) {
      log('🌐 ONLINE MODE: Checking Supabase session...');

      // Check if Supabase has session
      if (currentSession != null && currentUser != null) {
        log('✅ Supabase session found. Saving to local...');

        // Save to local for offline use
        await saveSessionToLocal();

        // Return current session as LocalSessionModel
        final userData = await getUserData(currentUser!.id);
        final role = userData?['role'] as String?;

        return LocalSessionModel(
          userId: currentUser!.id,
          accessToken: currentSession!.accessToken,
          refreshToken: currentSession!.refreshToken,
          expiresAt: currentSession!.expiresAt != null
              ? currentSession!.expiresAt! * 1000
              : null,
          userRole: role,
          userEmail: currentUser!.email,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        log(
          'ℹ️ No active Supabase session found (Online). Fallback to local DB...',
        );
      }
    } else {
      log('📴 OFFLINE MODE: Fetching from local database...');
    }

    // Fallback to local session (Offline or Online but Supabase failed)
    final localSession = await _localSessionService.getSession();

    if (localSession != null) {
      log(
        '✅ Local session found for user: ${localSession.userId} (Role: ${localSession.userRole})',
      );
    } else {
      log('ℹ️ No local session found.');
    }

    return localSession;
  }

  // Clear all sessions (online and offline)
  Future<void> clearAllSessions() async {
    try {
      // Clear Supabase session
      await _supabase.auth.signOut();

      // Clear local session
      await _localSessionService.deleteSession();

      log('All sessions cleared');
    } catch (e) {
      log('Error clearing sessions: $e');
    }
  }
}
