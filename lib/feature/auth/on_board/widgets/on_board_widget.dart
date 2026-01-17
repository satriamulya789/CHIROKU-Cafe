import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/feature/auth/on_board/controller/on_board_controller.dart';
import 'package:chiroku_cafe/feature/auth/on_board/view/on_board_view.dart';

class OnBoardPages extends GetView<OnBoardController> {
  const OnBoardPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Obx(
            () => controller.pageIndex.value ==
                    controller.pages.length - 1
                ? const SizedBox()
                : TextButton(
                    onPressed: controller.skip,
                    child: Text(
                      "Skip",
                      style: AppTypography.appBarActionSmall.copyWith(
                        color: AppColors.brownDark,
                      ),
                    ),
                  ),
          ),
        ],
        title: Row(
          children: [
            Image.asset(AssetsConstant.logo, height: 45),
            const SizedBox(width: 6),
            Text(
              'Chiroku Cafe',
              style: AppTypography.appBarTitleLarge.copyWith(color: AppColors.brownDarkActive),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.pages.length,
                onPageChanged: controller.updateIndex,
                itemBuilder: (context, i) {
                  final item = controller.pages[i];
                  return OnBoardView(
                    image: item["image"]!,
                    title: item["title"]!,
                    subtitle: item["subtitle"]!,
                  );
                },
              ),
            ),

            /// INDICATOR
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: controller.pageIndex.value == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: controller.pageIndex.value == i
                          ? AppColors.brownNormal
                          : AppColors.brownLightActive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ANIMATED BUTTON
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: ElevatedButton(
                    key: ValueKey(controller.pageIndex.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brownDark,
                      foregroundColor: AppColors.brownLight,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.nextPage,
                    child: Text(
                      controller.pageIndex.value ==
                              controller.pages.length - 1
                          ? "Next"
                          : "Start",
                      style: AppTypography.button,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
