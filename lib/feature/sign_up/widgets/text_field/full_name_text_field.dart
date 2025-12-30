import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FullNameTextField extends StatelessWidget {
  final TextEditingController controller;

  const FullNameTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: AppTypography.label.copyWith(color: AppColors.brownDark),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AuthErrorModel.nameEmpty().message;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            filled: true,
            hintStyle: AppTypography.label,
            fillColor: AppColors.brownLight,
            prefixIcon: Icon(Icons.person_3_rounded,color: AppColors.brownNormal,),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
