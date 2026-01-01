import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextFieldType type;
  final String? Function(String?)? customValidator;
  final IconData? prefixIcon;
  final bool? obscureText;
  final RxBool? isPasswordVisible;
  final int? maxLines;
  final TextInputType? keyboardType;

  final Validator _validator = Validator();

  CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.type = TextFieldType.text,
    this.customValidator,
    this.prefixIcon,
    this.obscureText,
    this.isPasswordVisible,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.brownDark),
          // You can customize the color as needed,
        ),
        SizedBox(height: 8),
        _buildTextField(),
      ],
    );
  }

  Widget _buildTextField() {
    if (type == TextFieldType.password && isPasswordVisible != null) {
      return Obx(() => _textFormField());
    }
    return _textFormField();
  }

  //Text Field Widget
  Widget _textFormField() {
    return TextFormField(
      controller: controller,
      obscureText: _isObscured,
      keyboardType: _inputType,
      maxLines: type == TextFieldType.password ? 1 : maxLines,
      validator: customValidator ?? _defaultValidator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.label,
        filled: true,
        fillColor: AppColors.brownLight,
        prefixIcon: Icon(_iconPrefix, color: AppColors.brownNormal),
        suffixIcon: _iconSuffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  //password obscure text logic
  bool get _isObscured =>
      type == TextFieldType.password && isPasswordVisible != null
      ? isPasswordVisible!.value
      : false;

  //keyboard type
  TextInputType get _inputType {
    if (keyboardType != null) return keyboardType!;
    return switch (type) {
      TextFieldType.email => TextInputType.emailAddress,
      TextFieldType.phone => TextInputType.phone,
      TextFieldType.number => TextInputType.number,
      TextFieldType.name => TextInputType.name,
      _ => TextInputType.text,
    };
  }

  //Icon Data
  IconData get _iconPrefix {
    if (prefixIcon != null) return prefixIcon!;
    return switch (type) {
      TextFieldType.email => Icons.email_rounded,
      TextFieldType.password => Icons.lock_rounded,
      TextFieldType.name => Icons.person_3_rounded,
      TextFieldType.phone => Icons.phone_rounded,
      _ => Icons.text_fields_rounded,
    };
  }

  //Visibility toggle icon for password field

  Widget? get _iconSuffix {
    if (type == TextFieldType.password && isPasswordVisible != null) {
      return IconButton(
        icon: Icon(
          isPasswordVisible!.value
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: AppColors.brownNormal,
        ),
        onPressed: isPasswordVisible!.toggle,
      );
    }
    return null;
  }

  String? Function(String?)? get _defaultValidator {
    return switch (type) {
      TextFieldType.email => _validator.ValidatorEmail,
      TextFieldType.password => _validator.validatorPassword,
      TextFieldType.name => _validator.validatorName,
      _ =>
        (value) => value == null || value.isEmpty ? '$label is required' : null,
    };
  }

}
