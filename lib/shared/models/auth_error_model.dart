import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorModel {
  final String message;
  final String code;
  final int? statusCode;

  AuthErrorModel({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  factory AuthErrorModel.nameEmpty() {
    return AuthErrorModel(
      message: 'Name must not be empty',
      code: 'name_empty',
      statusCode: 400,
    );
  }
  factory AuthErrorModel.emailEmpty() {
    return AuthErrorModel(
      message: 'Email must not be empty',
      code: 'empty_field',
      statusCode: 400,
    );
  }
  factory AuthErrorModel.passwordEmpty() {
    return AuthErrorModel(
      message: 'Password must not be empty',
      code: 'empty_field',
      statusCode: 400,
    );
  }

  factory AuthErrorModel.emailAlreadyExists() {
    return AuthErrorModel(
      message: 'The email address is already registered.',
      code: 'email_already_exists',
      statusCode: 409,
    );
  }

  factory AuthErrorModel.emailNotRegistered() {
    return AuthErrorModel(
      message: 'The email address is not registered.',
      code: 'email_not_registered',
      statusCode: 404,
    );
  }

  factory AuthErrorModel.passwordTooShort() {
    return AuthErrorModel(
      message: 'Password must be at least 6 characters long.',
      code: 'password_too_short',
      statusCode: 400,
    );
  }

  factory AuthErrorModel.passwordTooWeak() {
    return AuthErrorModel(
      message:
          'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
      code: 'password_too_weak',
      statusCode: 400,
    );
  }

  factory AuthErrorModel.networkError() {
    return AuthErrorModel(
      message:
          'A network error occurred. Please check your internet connection.',
      code: 'network_error',
      statusCode: null,
    );
  }

  factory AuthErrorModel.tooManyRequests() {
    return AuthErrorModel(
      message: 'Too many requests. Please try again later.',
      code: 'too_many_requests',
      statusCode: 429,
    );
  }

  factory AuthErrorModel.requestTimeOut() {
    return AuthErrorModel(
      message: 'The request timed out. Please try again later.',
      code: 'timeout',
      statusCode: 408,
    );
  }

  factory AuthErrorModel.internalServer() {
    return AuthErrorModel(
      message: 'An internal server error occurred. Please try again later.',
      code: 'internal_server_error',
      statusCode: 500,
    );
  }

  factory AuthErrorModel.invalidEmailFormat() {
    return AuthErrorModel(
      message: 'The email address format is invalid.',
      code: 'invalid_email_format',
      statusCode: 400,
    );
  }

  factory AuthErrorModel.unknownError() {
    return AuthErrorModel(
      message: 'An unknown error occurred. Please try again later.',
      code: 'unknown_error',
      statusCode: null,
    );
  }

  factory AuthErrorModel.sessionExpired() {
    return AuthErrorModel(
      message: 'Your session has expired. Please log in again.',
      code: 'session_expired',
      statusCode: 401,
    );
  }

  factory AuthErrorModel.successAccount(){
    return AuthErrorModel(
      message: 'Your account has been created successfully.',
      code: 'success_account',
      statusCode: 200,
    );
  }

  /// Factory method to create AuthErrorModel from AuthException
  factory AuthErrorModel.fromException(AuthException exception) {
    final statusCode = exception.statusCode;
    final message = exception.message.toLowerCase();

    // Handle based on status code
    switch (statusCode) {
      case '400':
        if (message.contains('invalid') && message.contains('email')) {
          return AuthErrorModel.invalidEmailFormat();
        }
        if (message.contains('password') && message.contains('short')) {
          return AuthErrorModel.passwordTooShort();
        }
        if (message.contains('password') && message.contains('weak')) {
          return AuthErrorModel.passwordTooWeak();
        }
        return AuthErrorModel.unknownError();

      case '401':
        if (message.contains('not registered') ||
            message.contains('not found')) {
          return AuthErrorModel.emailNotRegistered();
        }
        return AuthErrorModel.unknownError();

      case '404':
        return AuthErrorModel.emailNotRegistered();

      case '408':
        return AuthErrorModel.requestTimeOut();

      case '409':
        if (message.contains('already') || message.contains('exists')) {
          return AuthErrorModel.emailAlreadyExists();
        }
        return AuthErrorModel.unknownError();

      case '429':
        return AuthErrorModel.tooManyRequests();

      case '500':
        return AuthErrorModel.internalServer();

      default:
        // Check message content for specific errors
        if (message.contains('network')) {
          return AuthErrorModel.networkError();
        }
        if (message.contains('timeout')) {
          return AuthErrorModel.requestTimeOut();
        }
        if (message.contains('already registered') ||
            message.contains('user already registered')) {
          return AuthErrorModel.emailAlreadyExists();
        }
        return AuthErrorModel.unknownError();
    }
  }
}
