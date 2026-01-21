import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CropImageDocumentationView extends StatelessWidget {
  const CropImageDocumentationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crop Image Feature',
          style: AppTypography.h6.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.brownNormal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to Use:', style: AppTypography.h6),
            const SizedBox(height: 16),
            _buildStep('1. Inject CropImageService into your Controller.'),
            _buildStep('2. Call service.processImage() for Crop & WebP.'),
            _buildStep(
              '3. Ensure UCropActivity is registered in AndroidManifest.',
            ),
            const Spacer(),
            Center(
              child: Text(
                'This feature is active in Profile & Menu Management',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.brownNormal,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
