import 'package:chiroku_cafe/app.dart';
import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/env/env.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_session_offline_repository.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/repositories/admin_edit_user_repositories.dart';
import 'package:chiroku_cafe/shared/services/session_service.dart';
import 'package:chiroku_cafe/shared/services/sync_service.dart';
import 'package:chiroku_cafe/utils/functions/image_cache_helper.dart';
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
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Initialize NetworkInfo and Supabase client
  final networkInfo = NetworkInfoImpl(Connectivity());
  final supabase = Supabase.instance.client;

  // Initialize DatabaseHelper FIRST
  await Get.putAsync(() => DatabaseHelper().init(), permanent: true);
  log('✅ DatabaseHelper initialized');

  // Get database from DatabaseHelper
  final dbHelper = Get.find<DatabaseHelper>();
  final database = dbHelper.database;

  // Register permanent dependencies
  Get.put<AppDatabase>(database, permanent: true);
  Get.put<NetworkInfo>(networkInfo, permanent: true);
  log('✅ Dependencies registered');

  // Initialize image cache
  try {
    final cacheInfo = await ImageCacheHelper.getCacheInfo();
    log('📦 Cache info: $cacheInfo');
  } catch (e) {
    log('⚠️ Cache initialization warning: $e');
  }

  // Initialize SessionRepository
  final sessionRepository = SessionRepository(
    supabase: supabase,
    database: database,
    networkInfo: networkInfo,
  );
  Get.put<SessionRepository>(sessionRepository, permanent: true);
  log('✅ SessionRepository registered');

  // Initialize SessionService
  final sessionService = SessionService(
    database: database,
    networkInfo: networkInfo,
    supabase: supabase,
  );
  Get.put<SessionService>(sessionService, permanent: true);
  log('✅ SessionService registered');

  // Initialize UserRepositories
  final userRepositories = UserRepositories();
  Get.put<UserRepositories>(userRepositories, permanent: true);
  log('✅ UserRepositories registered');

  // Check current session in DB on startup
  final existingSession = await database.getSession();
  if (existingSession != null) {
    log('📱 Startup - Existing session in DB: ${existingSession.userId}, role=${existingSession.role}');
  } else {
    log('📱 Startup - No existing session in DB');
  }

  // Setup Auth State Listener
  await sessionService.setupAuthStateListener();
  log('✅ Auth state listener setup');

  // Setup Network Listener
  sessionService.setupNetworkListener();
  log('✅ Network listener setup');

  // Initialize Sync Service
  Get.put(
    SyncService(database: database, networkInfo: networkInfo),
    permanent: true,
  );
  log('✅ Sync Service initialized');

  runApp(const MyApp());
}