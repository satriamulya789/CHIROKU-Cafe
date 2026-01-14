import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnBoardController extends GetxController {
  final supabase = Supabase.instance.client;
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;

    if (session != null && user != null) {
      // User sudah login, ambil role dan navigate
      final role = await _getUserRole(user.id);

      if (role == UserRole.admin) {
        Get.offAllNamed(AppRoutes.bottomBarAdmin);
      } else if (role == UserRole.cashier) {
        Get.offAllNamed(AppRoutes.bottomBarCashier);
      }
      // Jika role null atau tidak dikenali, tetap di onboarding
    }
  }

  /// Get user role from database
  Future<UserRole?> _getUserRole(String userId) async {
    try {
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return null;

      final roleString = userData['role'] as String?;
      if (roleString == 'admin') return UserRole.admin;
      if (roleString == 'cashier') return UserRole.cashier;
      return null;
    } catch (e) {
      return null;
    }
  }

  final pages = [
    {
      "image": AssetsConstant.onboard1,
      "title": "Easy Payments",
      "subtitle": "Fast and secure transaction process for your customers.",
    },
    {
      "image": AssetsConstant.onboard2,
      "title": "Order Tracking",
      "subtitle": "Manage orders efficiently and in an organized way.",
    },
    {
      "image": AssetsConstant.onboard3,
      "title": "Best Coffee",
      "subtitle": "Deliver the best experience with premium coffee quality.",
    },
  ];

  RxInt pageIndex = 0.obs;

  void updateIndex(int index) {
    pageIndex.value = index;
  }

  void nextPage() {
    if (pageIndex.value == pages.length - 1) {
      Get.toNamed(AppRoutes.signUp);
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void skip() {
    Get.toNamed(AppRoutes.signUp);
  }
}
