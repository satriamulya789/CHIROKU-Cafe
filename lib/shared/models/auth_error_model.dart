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

  // ==================== Validation Errors ====================

  /// Error when name field is empty
  factory AuthErrorModel.nameEmpty() {
    return AuthErrorModel(
      message: 'Name must not be empty',
      code: 'name_empty',
      statusCode: 400,
    );
  }

  /// Error when name is too short (less than 3 characters)
  factory AuthErrorModel.nameTooShort() {
    return AuthErrorModel(
      message: 'Full name must be at least 3 characters',
      code: 'name_too_short',
      statusCode: 400,
    );
  }

  /// Error when name is too long (more than 50 characters)
  factory AuthErrorModel.nameTooLong() {
    return AuthErrorModel(
      message: 'Full name must not exceed 50 characters',
      code: 'name_too_long',
      statusCode: 400,
    );
  }

  /// Error when name contains invalid characters
  factory AuthErrorModel.nameInvalidCharacters() {
    return AuthErrorModel(
      message: 'Full name can only contain letters and spaces',
      code: 'name_invalid_characters',
      statusCode: 400,
    );
  }

  /// Error when name contains only spaces
  factory AuthErrorModel.nameOnlySpaces() {
    return AuthErrorModel(
      message: 'Full name cannot be only spaces',
      code: 'name_only_spaces',
      statusCode: 400,
    );
  }

  /// Error when avatar/profile photo is not selected
  factory AuthErrorModel.avatarNotSelected() {
    return AuthErrorModel(
      message: 'Please select a profile photo',
      code: 'avatar_not_selected',
      statusCode: 400,
    );
  }

  /// Error when email field is empty
  factory AuthErrorModel.emailEmpty() {
    return AuthErrorModel(
      message: 'Email must not be empty',
      code: 'email_empty',
      statusCode: 400,
    );
  }

  /// Error when password field is empty
  factory AuthErrorModel.passwordEmpty() {
    return AuthErrorModel(
      message: 'Password must not be empty',
      code: 'password_empty',
      statusCode: 400,
    );
  }

  /// Error when confirm password field is empty
  factory AuthErrorModel.confirmPasswordEmpty() {
    return AuthErrorModel(
      message: 'Confirm Password must not be empty',
      code: 'confirm_password_empty',
      statusCode: 400,
    );
  }

  /// Error when passwords do not match
  factory AuthErrorModel.passwordDontMatch() {
    return AuthErrorModel(
      message: 'Passwords do not match',
      code: 'passwords_do_not_match',
      statusCode: 400,
    );
  }

  /// Error when password is too short (less than 6 characters)
  factory AuthErrorModel.passwordTooShort() {
    return AuthErrorModel(
      message: 'Password must be at least 6 characters long.',
      code: 'password_too_short',
      statusCode: 400,
    );
  }

  /// Error when password doesn't meet complexity requirements
  factory AuthErrorModel.passwordTooWeak() {
    return AuthErrorModel(
      message:
          'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
      code: 'password_too_weak',
      statusCode: 400,
    );
  }

  /// Error when email format is invalid
  factory AuthErrorModel.invalidEmailFormat() {
    return AuthErrorModel(
      message: 'The email address format is invalid.',
      code: 'invalid_email_format',
      statusCode: 400,
    );
  }

  /// Error when failed to update password
  factory AuthErrorModel.updatePasswordFailed() {
    return AuthErrorModel(
      message: 'Failed to update password. Please try again.',
      code: 'update_password_failed',
      statusCode: 500,
    );
  }

  // ==================== Dashboard Errors ====================

  /// Error when failed to load dashboard data
  factory AuthErrorModel.failedLoadDashboard() {
    return AuthErrorModel(
      message: 'Failed to load dashboard data. Please try again.',
      code: 'failed_load_dashboard',
      statusCode: 500,
    );
  }

  /// Error when failed to load orders
  factory AuthErrorModel.failedLoadOrders() {
    return AuthErrorModel(
      message: 'Failed to load orders. Please try again.',
      code: 'failed_load_orders',
      statusCode: 500,
    );
  }

  // ==================== Authentication Errors ====================

  /// Error when email is already registered in the system
  factory AuthErrorModel.emailAlreadyExists() {
    return AuthErrorModel(
      message: 'The email address is already registered.',
      code: 'email_already_exists',
      statusCode: 409,
    );
  }

  /// Error when email is not found in the system
  factory AuthErrorModel.emailNotRegistered() {
    return AuthErrorModel(
      message: 'The email address is not registered.',
      code: 'email_not_registered',
      statusCode: 404,
    );
  }

  /// Error when user session has expired
  factory AuthErrorModel.sessionExpired() {
    return AuthErrorModel(
      message: 'Your session has expired. Please log in again.',
      code: 'session_expired',
      statusCode: 401,
    );
  }

  /// Success message when account is created successfully
  factory AuthErrorModel.accountCreatedSuccess() {
    return AuthErrorModel(
      message: 'Your account has been created successfully.',
      code: 'account_created_success',
      statusCode: 200,
    );
  }

   factory AuthErrorModel.signoutError() {
    return AuthErrorModel(
      message: 'Failed to sign out. Please try again.',
      code: 'signout_error',
      statusCode: 409,
    );
  }

  // succes mesege when user login
  factory AuthErrorModel.accountSignInSuccess() {
    return AuthErrorModel(
      message: 'Your sign in successfully.',
      code: 'account_sign_in_success',
      statusCode: 200,
    );
  }

  /// Error when failed to load user data
  factory AuthErrorModel.failedLoadUser() {
    return AuthErrorModel(
      message: 'Failed to load user data. Please try again.',
      code: 'failed_load_user',
      statusCode: 500,
    );
  }

   factory AuthErrorModel.loadUserSuccess() {
    return AuthErrorModel(
      message: 'User data loaded successfully.',
      code: 'load_user_success',
      statusCode: 200,
    );
  }

  // ==================== Avatar & Profile Errors ====================

  /// Success message when image is selected
  factory AuthErrorModel.imageSelectedSuccess() {
    return AuthErrorModel(
      message: 'Image selected successfully.',
      code: 'image_selected_success',
      statusCode: 200,
    );
  }

  /// Success message when photo is captured
  factory AuthErrorModel.photoCapturedSuccess() {
    return AuthErrorModel(
      message: 'Photo captured successfully.',
      code: 'photo_captured_success',
      statusCode: 200,
    );
  }

  /// Error when photo capture fails
  factory AuthErrorModel.capturePhotoFailed() {
    return AuthErrorModel(
      message: 'Photo capture failed.',
      code: 'photo_capture_failed',
      statusCode: 500,
    );
  }

  /// Success message when avatar is deleted
  factory AuthErrorModel.avatarDeletedSuccess() {
    return AuthErrorModel(
      message: 'Avatar deleted successfully.',
      code: 'avatar_deleted_success',
      statusCode: 200,
    );
  }

  /// Error when avatar upload fails
  factory AuthErrorModel.uploadAvatarFailed() {
    return AuthErrorModel(
      message: 'Failed to upload avatar. Please try again.',
      code: 'upload_avatar_failed',
      statusCode: 500,
    );
  }

  factory AuthErrorModel.uploadAvatarSuccess() {
    return AuthErrorModel(
      message: 'Avatar uploaded successfully.',
      code: 'upload_avatar_success',
      statusCode: 200,
    );
  }

  /// Error when avatar format is not valid
  factory AuthErrorModel.invalidAvatarFormat() {
    return AuthErrorModel(
      message: 'Invalid avatar format. Please upload a valid image file.',
      code: 'invalid_avatar_format',
      statusCode: 400,
    );
  }

  /// Error when avatar deletion fails
  factory AuthErrorModel.deleteAvatarFailed() {
    return AuthErrorModel(
      message: 'Failed to delete avatar. Please try again.',
      code: 'delete_avatar_failed',
      statusCode: 500,
    );
  }

  /// Error when profile update fails
  factory AuthErrorModel.updateProfileFailed() {
    return AuthErrorModel(
      message: 'Failed to update profile. Please try again.',
      code: 'update_profile_failed',
      statusCode: 500,
    );
  }

  // ==================== Network & Server Errors ====================

  /// Error when network connection is unavailable
  factory AuthErrorModel.networkError() {
    return AuthErrorModel(
      message:
          'A network error occurred. Please check your internet connection.',
      code: 'network_error',
      statusCode: null,
    );
  }

  /// Error when too many requests are made
  factory AuthErrorModel.tooManyRequests() {
    return AuthErrorModel(
      message: 'Too many requests. Please try again later.',
      code: 'too_many_requests',
      statusCode: 429,
    );
  }

  /// Error when request times out
  factory AuthErrorModel.requestTimeOut() {
    return AuthErrorModel(
      message: 'The request timed out. Please try again later.',
      code: 'timeout',
      statusCode: 408,
    );
  }

  /// Error when server encounters an internal error
  factory AuthErrorModel.internalServer() {
    return AuthErrorModel(
      message: 'An internal server error occurred. Please try again later.',
      code: 'internal_server_error',
      statusCode: 500,
    );
  }

  /// Error when an unknown error occurs
  factory AuthErrorModel.unknownError() {
    return AuthErrorModel(
      message: 'An unknown error occurred. Please try again later.',
      code: 'unknown_error',
      statusCode: null,
    );
  }

  // ==================== Exception Handler ====================

  /// Factory method to create AuthErrorModel from Supabase AuthException
  /// Automatically maps exception status codes and messages to appropriate error types
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
