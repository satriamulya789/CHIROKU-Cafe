import 'dart:developer';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService {
  final AppDatabase database;
  final NetworkInfo networkInfo;
  final SupabaseClient supabase;

  SessionService({
    required this.database,
    required this.networkInfo,
    required this.supabase,
  });

  /// Save session to local database with role fetching
  Future<void> saveSessionToDb(Session session) async {
    log('💾 Saving session to DB...');
    try {
      final userId = session.user.id;
      
      // Check existing session first
      final existingSession = await database.getSession();
      String role = existingSession?.role ?? 'cashier';
      
      try {
        log('📡 Fetching user role from Supabase...');
        final response = await supabase
            .from('users')
            .select('role')
            .eq('id', userId)
            .single()
            .timeout(const Duration(seconds: 5));
        
        role = response['role'] as String? ?? role;
        log('✅ User role fetched: $role');
      } catch (e) {
        log('⚠️ Error fetching role: $e');
        if (existingSession != null) {
          log('ℹ️ Using existing role: ${existingSession.role}');
          role = existingSession.role;
        } else {
          log('ℹ️ Using default role: $role');
        }
      }

      log('💾 Saving to database: userId=$userId, role=$role');
      await database.upsertSession(
        userId: userId,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        role: role,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
      );
      log('✅ Session saved successfully');
      
      // Verify save
      final savedSession = await database.getSession();
      log('🔍 Verification - Session in DB: userId=${savedSession?.userId}, role=${savedSession?.role}');
    } catch (e) {
      log('❌ Error saving session: $e');
    }
  }

  /// Setup auth state listener
  Future<void> setupAuthStateListener() async {
    log('👂 Setting up auth state listener...');
    
    final isOnline = await networkInfo.isConnected;
    
    // Check current session immediately
    final currentSession = supabase.auth.currentSession;
    if (currentSession != null) {
      log('🔐 Current session exists on startup: ${currentSession.user.id}');
      if (isOnline) {
        await saveSessionToDb(currentSession);
      } else {
        log('📴 Offline - keeping existing local session');
        final localSession = await database.getSession();
        if (localSession == null) {
          log('⚠️ No local session found, creating from Supabase session...');
          await database.upsertSession(
            userId: currentSession.user.id,
            accessToken: currentSession.accessToken,
            refreshToken: currentSession.refreshToken ?? '',
            role: 'cashier',
            expiresAt: DateTime.fromMillisecondsSinceEpoch(currentSession.expiresAt! * 1000),
          );
        }
      }
    } else {
      log('❌ No current session on startup');
      if (isOnline) {
        log('🗑️ Online - No Supabase session, checking local...');
        final localSession = await database.getSession();
        if (localSession != null) {
          log('🔄 Attempting to restore session from local...');
          try {
            await supabase.auth.setSession(localSession.refreshToken);
            await Future.delayed(const Duration(milliseconds: 500));
            
            final restoredSession = supabase.auth.currentSession;
            if (restoredSession != null) {
              log('✅ Session restored from local storage');
              await saveSessionToDb(restoredSession);
            } else {
              log('❌ Failed to restore session');
              await database.deleteSession();
            }
          } catch (e) {
            log('❌ Cannot restore session: $e');
            await database.deleteSession();
          }
        }
      } else {
        log('📴 Offline - keeping local session');
      }
    }
    
    // Listen to auth changes
    supabase.auth.onAuthStateChange.listen((data) async {
      final isCurrentlyOnline = await networkInfo.isConnected;
      
      log('🔔 Auth state changed: event=${data.event}, online=$isCurrentlyOnline');
      final session = data.session;
      
      if (!isCurrentlyOnline) {
        log('📴 Offline - ignoring auth state change');
        return;
      }
      
      if (session != null) {
        log('🔐 Auth State: User logged in - ${session.user.id}');
        
        final localSession = await database.getSession();
        if (localSession != null && localSession.userId != session.user.id) {
          log('🔄 Different user detected, clearing old session...');
          await database.deleteSession();
        }
        
        await saveSessionToDb(session);
      } else {
        log('🚪 Auth State: User logged out');
        try {
          await database.deleteSession();
          log('✅ Local session cleared');
        } catch (e) {
          log('❌ Error clearing session: $e');
        }
      }
    });
  }

  /// Setup network listener for session sync
  void setupNetworkListener() {
    log('👂 Setting up network listener...');
    
    networkInfo.onConnectivityChanged.listen((isConnected) async {
      log('🌐 Network status changed: isConnected=$isConnected');
      
      if (isConnected) {
        log('🌐 Network: Back online, syncing session...');
        
        final currentSession = supabase.auth.currentSession;
        if (currentSession != null) {
          await saveSessionToDb(currentSession);
        }
      } else {
        log('📴 Network: Offline mode - keeping local session');
      }
    });
  }
}