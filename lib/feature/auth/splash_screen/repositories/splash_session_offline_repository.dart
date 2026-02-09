import 'dart:developer';

import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionRepository {
  final SupabaseClient supabase;
  final AppDatabase database;
  final NetworkInfo networkInfo;

  SessionRepository({
    required this.supabase,
    required this.database,
    required this.networkInfo,
  });

  /// Get current session dengan offline support
  /// Returns SessionLocal dari database (memiliki role info)
  Future<SessionLocal?> getCurrentSessionLocal() async {
    try {
      final isOnline = await networkInfo.isConnected;
      log('📡 SessionRepository.getCurrentSessionLocal: isOnline=$isOnline');

      if (isOnline) {
        // Online: sync dari Supabase ke local
        final session = supabase.auth.currentSession;
        log('🌐 Online session: ${session?.user.id}');
        
        if (session != null) {
          try {
            // Sync session to local (with different user check)
            await _syncSessionToLocal(session);
          } catch (dbError) {
            log('⚠️ Database error (non-critical): $dbError');
            // Continue even if DB operation fails
          }
        } else {
          log('❌ No Supabase session found online');
          // Try to restore from local session
          final localSession = await database.getSession();
          if (localSession != null && localSession.expiresAt.isAfter(DateTime.now())) {
            log('🔄 Attempting to restore session from local...');
            try {
              await supabase.auth.setSession(localSession.refreshToken);
              
              // Wait for auth state to update
              await Future.delayed(const Duration(milliseconds: 500));
              
              final restoredSession = supabase.auth.currentSession;
              if (restoredSession != null) {
                log('✅ Session restored successfully');
                await _syncSessionToLocal(restoredSession);
              }
            } catch (e) {
              log('❌ Failed to restore session: $e');
            }
          }
        }
      } else {
        // Offline: ambil dari local database
        log('📴 Offline mode - checking local DB...');
      }
      
      // Return from local DB (works for both online and offline)
      final localSession = await database.getSession();
      
      if (localSession != null) {
        log('✅ Local session found: userId=${localSession.userId}, role=${localSession.role}');
        return localSession;
      } else {
        log('❌ No local session found');
        return null;
      }
    } catch (e) {
      log('❌ SessionRepository.getCurrentSessionLocal Error: $e');
      return null;
    }
  }

  /// Get current session (returns Supabase Session format)
  /// Useful for API calls that need Supabase session
  Future<Session?> getCurrentSession() async {
    try {
      final isOnline = await networkInfo.isConnected;
      log('📡 SessionRepository.getCurrentSession: isOnline=$isOnline');

      if (isOnline) {
        // Online: ambil dari Supabase
        final session = supabase.auth.currentSession;
        log('🌐 Online session: ${session?.user.id}');
        
        if (session != null) {
          try {
            await _syncSessionToLocal(session);
          } catch (dbError) {
            log('⚠️ Database error (non-critical): $dbError');
          }
        } else {
          // Try to restore from local
          final localSession = await database.getSession();
          if (localSession != null && localSession.expiresAt.isAfter(DateTime.now())) {
            log('🔄 Attempting to restore session from local...');
            try {
              await supabase.auth.setSession(localSession.refreshToken);
              await Future.delayed(const Duration(milliseconds: 500));
              final restoredSession = supabase.auth.currentSession;
              if (restoredSession != null) {
                log('✅ Session restored successfully');
                return restoredSession;
              }
            } catch (e) {
              log('❌ Failed to restore session: $e');
            }
          }
        }
        return session;
      } else {
        // Offline: convert local session to Supabase Session format
        log('📴 Offline mode - checking local DB...');
        
        try {
          final localSession = await database.getSession();
          
          if (localSession != null) {
            log('✅ Local session found: userId=${localSession.userId}, role=${localSession.role}');
            log('✅ Using cached session (offline mode)');
            
            // Convert to Supabase Session
            return Session(
              accessToken: localSession.accessToken,
              refreshToken: localSession.refreshToken,
              expiresIn: localSession.expiresAt.millisecondsSinceEpoch ~/ 1000,
              tokenType: 'bearer',
              user: User(
                id: localSession.userId,
                appMetadata: {},
                userMetadata: {'role': localSession.role},
                aud: 'authenticated',
                createdAt: localSession.createdAt.toIso8601String(),
              ),
            );
          } else {
            log('❌ No local session found');
          }
        } catch (dbError) {
          log('❌ Database error while getting session: $dbError');
        }
        
        return null;
      }
    } catch (e) {
      log('❌ SessionRepository.getCurrentSession Error: $e');
      return null;
    }
  }

  /// Get user role (with offline fallback)
  Future<String> getUserRole(String userId) async {
    try {
      final isOnline = await networkInfo.isConnected;
      
      if (isOnline) {
        try {
          log('📡 Fetching role from Supabase...');
          final response = await supabase
              .from('users')
              .select('role')
              .eq('id', userId)
              .single()
              .timeout(const Duration(seconds: 5));
          
          final role = response['role'] as String? ?? 'cashier';
          log('✅ Role fetched: $role');
          
          // Update local session with correct role
          final localSession = await database.getSession();
          if (localSession != null && localSession.role != role) {
            log('🔄 Updating local session role: ${localSession.role} -> $role');
            await database.upsertSession(
              userId: localSession.userId,
              accessToken: localSession.accessToken,
              refreshToken: localSession.refreshToken,
              role: role,
              expiresAt: localSession.expiresAt,
            );
          }
          
          return role;
        } catch (e) {
          log('⚠️ Error fetching role from Supabase: $e');
        }
      }
      
      // Fallback to local
      log('📴 Using local role');
      final localSession = await database.getSession();
      return localSession?.role ?? 'cashier';
    } catch (e) {
      log('❌ getUserRole Error: $e');
      return 'cashier';
    }
  }

  /// Get role from local session (untuk offline mode)
  Future<String?> getRoleFromLocal() async {
    try {
      log('🔍 Getting role from local DB...');
      final localSession = await database.getSession();
      final role = localSession?.role;
      log('✅ Role from local: $role');
      return role;
    } catch (e) {
      log('❌ getRoleFromLocal Error: $e');
      return null;
    }
  }

  /// Sync session to local (handle different user)
  Future<void> _syncSessionToLocal(Session session) async {
    try {
      final localSession = await database.getSession();
      
      // Check if different user
      if (localSession != null && localSession.userId != session.user.id) {
        log('🔄 Different user detected: ${localSession.userId} -> ${session.user.id}');
        log('🗑️ Clearing old session...');
        await database.deleteSession();
      }
      
      // Check if need to update
      if (localSession == null ||
          localSession.userId != session.user.id ||
          localSession.accessToken != session.accessToken) {
        
        log('💾 Syncing session to local DB...');
        
        // Get role from Supabase (with fallback to existing role)
        final role = await _getUserRoleFromSupabase(
          session.user.id,
          fallbackRole: localSession?.role,
        );
        
        // Save to local
        await _saveSessionToLocal(session, role);
        log('✅ Session synced to local DB');
      } else {
        log('✅ Local session already up-to-date');
      }
    } catch (e) {
      log('❌ Error syncing session to local: $e');
      rethrow;
    }
  }

  /// Sync session saat kembali online
  Future<void> syncSessionOnline() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        log('📴 Cannot sync - offline');
        return;
      }

      log('🔄 Syncing session online...');
      final supabaseSession = supabase.auth.currentSession;
      
      if (supabaseSession != null) {
        try {
          await _syncSessionToLocal(supabaseSession);
          log('✅ Session synced successfully');
        } catch (syncError) {
          log('⚠️ Sync error (non-critical): $syncError');
        }
      } else {
        // No Supabase session, try restore from local
        final localSession = await database.getSession();
        if (localSession != null) {
          log('🔄 Attempting to restore session...');
          try {
            await supabase.auth.setSession(localSession.refreshToken);
            
            // Wait for auth state
            await Future.delayed(const Duration(milliseconds: 500));
            
            final restored = supabase.auth.currentSession;
            if (restored != null) {
              log('✅ Session restored from local');
              await _syncSessionToLocal(restored);
            } else {
              log('❌ Failed to restore - clearing invalid session');
              await database.deleteSession();
            }
          } catch (e) {
            log('❌ Cannot restore session: $e');
            log('🗑️ Clearing invalid local session');
            await database.deleteSession();
          }
        } else {
          log('✅ No sessions to sync');
        }
      }
    } catch (e) {
      log('❌ syncSessionOnline Error: $e');
    }
  }

  /// Private: get user role dari Supabase (with fallback)
  Future<String> _getUserRoleFromSupabase(String userId, {String? fallbackRole}) async {
    try {
      log('📡 Fetching role for user=$userId from Supabase...');
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single()
          .timeout(const Duration(seconds: 5));
      
      final role = response['role'] as String? ?? fallbackRole ?? 'cashier';
      log('✅ Role fetched: $role');
      return role;
    } catch (e) {
      log('❌ _getUserRoleFromSupabase Error: $e');
      
      // Use fallback role if available
      if (fallbackRole != null) {
        log('ℹ️ Using fallback role: $fallbackRole');
        return fallbackRole;
      }
      
      log('ℹ️ Using default role: cashier');
      return 'cashier';
    }
  }

  /// Private: simpan session ke local database
  Future<void> _saveSessionToLocal(Session session, String role) async {
    try {
      log('💾 Saving session to local: userId=${session.user.id}, role=$role');
      await database.upsertSession(
        userId: session.user.id,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        role: role,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
      );
      log('✅ Session saved to local DB');
      
      // Verify save
      final savedSession = await database.getSession();
      if (savedSession != null) {
        log('🔍 Verification: userId=${savedSession.userId}, role=${savedSession.role}');
      } else {
        log('⚠️ Verification failed - no session in DB');
      }
    } catch (e) {
      log('❌ _saveSessionToLocal Error: $e');
      rethrow;
    }
  }

  /// Logout (hapus session) - HANYA saat user explicitly logout
  Future<void> logout() async {
    try {
      log('🚪 User initiated logout...');
      
      // Always try to sign out from Supabase
      final isOnline = await networkInfo.isConnected;
      if (isOnline) {
        try {
          await supabase.auth.signOut();
          log('✅ Signed out from Supabase');
        } catch (signOutError) {
          log('⚠️ Error signing out from Supabase: $signOutError');
        }
      } else {
        log('📴 Offline - will clear local session only');
      }
      
      // Always clear local session when user explicitly logout
      try {
        await database.deleteSession();
        log('✅ Local session deleted');
      } catch (deleteError) {
        log('❌ Error deleting local session: $deleteError');
      }
    } catch (e) {
      log('❌ logout Error: $e');
    }
  }

  /// Clear session (both online and offline) - Alias for logout
  Future<void> clearSession() async {
    await logout();
  }
}