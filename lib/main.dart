import 'package:chiroku_cafe/config/pages/pages.dart';
import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/env/env.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _requestNotificationPermission(BuildContext context) async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Notification Permission'),
          content: const Text('To receive notifications, please enable notification permission in your device settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission(context);
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chiroku Cafe',
      initialRoute: AppRoutes.onboard,
      getPages: Pages.routes,
    );
  }
}