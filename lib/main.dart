import 'package:chiroku_cafe/app.dart';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/env/env.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_session_offline_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('🚀 Starting app initialization...');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up Firebase Cloud Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Initialize Dependencies
  final database = AppDatabase();
  final networkInfo = NetworkInfoImpl(Connectivity());
  final supabase = Supabase.instance.client;

  // Register permanent dependencies
  Get.put<AppDatabase>(database, permanent: true);
  Get.put<NetworkInfo>(networkInfo, permanent: true);
  log('✅ Dependencies registered');

  // ✅ Initialize SessionRepository (centralized session management)
  final sessionRepository = SessionRepository(
    supabase: supabase,
    database: database,
    networkInfo: networkInfo,
  );
  Get.put<SessionRepository>(sessionRepository, permanent: true);
  log('✅ SessionRepository registered');

  // Check current session in DB on startup
  final existingSession = await database.getSession();
  if (existingSession != null) {
    log('📱 Startup - Existing session in DB: ${existingSession.userId}, role=${existingSession.role}');
  } else {
    log('📱 Startup - No existing session in DB');
  }

  // Setup Auth State Listener (using SessionRepository logic)
  await _setupAuthStateListener(database, networkInfo);
  log('✅ Auth state listener setup');

  // Setup Network Listener for session sync (using SessionRepository)
  _setupNetworkListener(networkInfo);
  log('✅ Network listener setup');

  runApp(const MyApp());
}

Future<void> _setupAuthStateListener(AppDatabase database, NetworkInfo networkInfo) async {
  final supabase = Supabase.instance.client;
  
  log('👂 Setting up auth state listener...');
  
  // Check if online first
  final isOnline = await networkInfo.isConnected;
  
  // Check current session immediately
  final currentSession = supabase.auth.currentSession;
  if (currentSession != null) {
    log('🔐 Current session exists on startup: ${currentSession.user.id}');
    if (isOnline) {
      await _saveSessionToDb(database, currentSession);
    } else {
      log('📴 Offline - keeping existing local session');
      // Verify local session exists
      final localSession = await database.getSession();
      if (localSession == null) {
        log('⚠️ No local session found, creating from Supabase session...');
        // Even offline, save basic session data
        await database.upsertSession(
          userId: currentSession.user.id,
          accessToken: currentSession.accessToken,
          refreshToken: currentSession.refreshToken ?? '',
          role: 'cashier', // Will be updated when online
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
        // Try to restore session from local
        log('🔄 Attempting to restore session from local...');
        try {
          await supabase.auth.setSession(localSession.refreshToken);
          
          // Wait for auth state to update
          await Future.delayed(const Duration(milliseconds: 500));
          
          final restoredSession = supabase.auth.currentSession;
          if (restoredSession != null) {
            log('✅ Session restored from local storage');
            await _saveSessionToDb(database, restoredSession);
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
      
      // Check if different user
      final localSession = await database.getSession();
      if (localSession != null && localSession.userId != session.user.id) {
        log('🔄 Different user detected, clearing old session...');
        await database.deleteSession();
      }
      
      // Save new/updated session
      await _saveSessionToDb(database, session);
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

Future<void> _saveSessionToDb(AppDatabase database, Session session) async {
  log('💾 Saving session to DB...');
  try {
    final supabase = Supabase.instance.client;
    final userId = session.user.id;
    
    // Check existing session first
    final existingSession = await database.getSession();
    String role = existingSession?.role ?? 'cashier'; // Use existing role as fallback
    
    try {
      log('📡 Fetching user role from Supabase...');
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single()
          .timeout(const Duration(seconds: 5)); // Add timeout
      
      role = response['role'] as String? ?? role; // Only update if successful
      log('✅ User role fetched: $role');
    } catch (e) {
      log('⚠️ Error fetching role: $e');
      // If there's an existing session, keep its role
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

void _setupNetworkListener(NetworkInfo networkInfo) {
  log('👂 Setting up network listener...');
  
  // Listen to network changes
  networkInfo.onConnectivityChanged.listen((isConnected) async {
    log('🌐 Network status changed: isConnected=$isConnected');
    
    if (isConnected) {
      log('🌐 Network: Back online, syncing session...');
      
      // ✅ Use SessionRepository for centralized session sync
      try {
        final sessionRepository = Get.find<SessionRepository>();
        await sessionRepository.syncSessionOnline();
      } catch (e) {
        log('❌ Error accessing SessionRepository: $e');
      }
    } else {
      log('📴 Network: Offline mode - keeping local session');
    }
  });
}