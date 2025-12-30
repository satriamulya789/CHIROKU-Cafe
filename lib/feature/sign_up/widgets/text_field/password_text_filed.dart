import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordTextFiled extends StatelessWidget {
  final TextEditingController controller;
  final RxBool isHidden;

  const PasswordTextFiled({
    super.key,
    required this.controller,
    required this.isHidden,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: AppTypography.label.copyWith(color: AppColors.brownDark),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isHidden.value,
            validator: _validator,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: AppTypography.label,
              filled: true,
              fillColor: AppColors.brownLight,
              prefixIcon: const Icon(
                Icons.lock_rounded,
                color: AppColors.brownNormal,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.brownNormal,
                ),
                onPressed: isHidden.toggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return AuthErrorModel.passwordTooShort().message;
    }
    return null;
  }
}
