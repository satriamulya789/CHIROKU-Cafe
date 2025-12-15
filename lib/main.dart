import 'package:chiroku_cafe/app.dart';
import 'package:chiroku_cafe/config/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
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
