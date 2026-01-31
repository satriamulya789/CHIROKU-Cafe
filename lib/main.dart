import 'dart:developer';

import 'package:chiroku_cafe/app.dart';
import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/env/env.dart';

import 'package:chiroku_cafe/shared/services/connectivity_service.dart';
import 'package:chiroku_cafe/shared/services/avatar_cache_service.dart';
import 'package:chiroku_cafe/shared/services/offline_user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();

  // print('Handling a background message: ${message.messageId}');
  // print('Message data: ${message.data}');
  // print('Message notification: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper().database;
  log('✅ Database initialized');

  // Initialize connectivity service
  Get.put(ConnectivityService());
  log('✅ Connectivity service initialized');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Set up Firebase Cloud Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize offline services
  Get.put(ConnectivityService());
  Get.put(AvatarCacheService());
  Get.put(OfflineUserService());
  runApp(const MyApp());
}
