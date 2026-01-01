import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

class Validator {
  ExistingEmail _existingEmail = ExistingEmail();
  String? ValidatorEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AuthErrorModel.emailEmpty().message;
    }
    
    if (!GetUtils.isEmail(email)) {
      return AuthErrorModel.invalidEmailFormat().message;
    }
    return null;
  }
  String? validatorName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return AuthErrorModel.nameEmpty().message;
    }
    return null;
  }
  String? validatorPassword(String? password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
    if (password == null || password.isEmpty) {
      return AuthErrorModel.passwordEmpty().message;
    }
    if (password.length < 6) {
      return AuthErrorModel.passwordTooShort().message;
    }
    if(!passwordRegex.hasMatch(password)){
      return AuthErrorModel.passwordTooWeak().message;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AuthErrorModel.confirmPassword().message;
    }
    if (value != password) {
      return AuthErrorModel.passwordDontMatch().message;
    }
    return null;
  }



}
