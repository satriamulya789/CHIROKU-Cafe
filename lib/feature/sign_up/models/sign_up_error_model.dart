import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpErrorModel {
  final String message;
  final String code;
  final int? statusCode;

  SignUpErrorModel({
    required this.message,
    required this.code,
    required this.statusCode
  });

  factory SignUpErrorModel.emptyField() {
    return  SignUpErrorModel(
      message: 'Email and password must not be empty',
      code: 'empty_field',
      statusCode: 400,
    );
  }
  factory SignUpErrorModel.passwordTooShort() {
    return SignUpErrorModel(
      message: 'Password must be at least 6 characters long.',
      code: 'password_too_short',
      statusCode: 400,
    );
  }
  factory SignUpErrorModel.passwordTooWeak() {
    return SignUpErrorModel(
      message: 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
      code: 'password_too_weak',
      statusCode: 400,
    );
  }
  factory SignUpErrorModel.invalidEmailFormat() {
  return SignUpErrorModel(
    message: 'The email address format is invalid.',
    code: 'invalid_email_format',
    statusCode: 400,
  );
}
  factory SignUpErrorModel.emailAlreadyExists() {
    return SignUpErrorModel(
      message: 'The email address is already registered.',
      code: 'email_already_exists',
      statusCode: 409,
    );
  }
  factory SignUpErrorModel.invalidEmail() {
    return SignUpErrorModel(
      message: 'The email address is not valid.',
      code: 'invalid_email',
      statusCode: 400,
    );
  }

  factory SignUpErrorModel.networkError() {
    return SignUpErrorModel(
        message: 'A network error occurred. Please check your internet connection.',
        code: 'network_error',
        statusCode: null,
      );
  }

  factory SignUpErrorModel.unknownError() {
    return SignUpErrorModel(
      message: 'An unknown error occurred. Please try again later.',
      code: 'unknown_error',
      statusCode: null,
    );
  }

  factory SignUpErrorModel.internalServer(){
    return SignUpErrorModel(
        message: 'An internal server error occurred. Please try again later.',
        code: 'internal_server_error',
        statusCode: 500,
      );
  }

  factory SignUpErrorModel.requestTimeOut(){
    return SignUpErrorModel(
        message: 'The request timed out. Please try again later.',
        code: 'timeout',
        statusCode: 408,
    );
  }

  factory SignUpErrorModel.tooManyRequests() {
    return SignUpErrorModel(
      message: 'Too many requests. Please try again later.',
      code: 'too_many_requests',
      statusCode: 429,
    );
  }

  factory SignUpErrorModel.fromException(AuthException exception) {
    switch (exception.statusCode) {
      case 400:
        if (exception.message.contains('Invalid email')) {
          return SignUpErrorModel.invalidEmail();
        }
        return SignUpErrorModel.unknownError();
      case 409:
        return SignUpErrorModel.emailAlreadyExists();
      case 429:
        return SignUpErrorModel.tooManyRequests();
      case 500:
        return SignUpErrorModel.internalServer();
      default:
        return SignUpErrorModel.unknownError();
    }
  }
  
}