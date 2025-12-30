import 'package:chiroku_cafe/app.dart';
import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiConstant.supabaseUrl,
    anonKey: ApiConstant.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chiroku Cafe',
      initialRoute: AppRoutes.onboard,
      getPages: AppPages.routes,
    );
  }
}
