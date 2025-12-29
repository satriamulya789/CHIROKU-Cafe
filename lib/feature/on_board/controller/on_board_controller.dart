import 'package:chiroku_cafe/config/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/constant/assets_constant.dart';

class OnBoardController extends GetxController {
  final PageController pageController = PageController();

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
      Get.toNamed(AppRoutes.signIn);
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void skip() {
    Get.toNamed(AppRoutes.signIn);
  }
}
