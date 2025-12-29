class SignInError {
  final String message;
  final String code;
  final int? statusCode;

  const SignInError({
    required this.message,
    required this.code,
    this.statusCode,
  });

  factory SignInError.emptyField() {
    return const SignInError(
      message: 'Email and password must not be empty',
      code: 'empty_field',
      statusCode: 400,
    );
  }

  factory SignInError.fromException(Object e) {
    final error = e.toString().toLowerCase();

    if (error.contains('network')) {
      return const SignInError(
        message: 'A network error occurred. Please check your internet connection.',
        code: 'network_error',
      );
    }

    if (error.contains('timeout')) {
      return const SignInError(
        message: 'The request timed out. Please try again later.',
        code: 'timeout',
        statusCode: 408,
      );
    }

    if (error.contains('unauthorized') || error.contains('401')) {
      return const SignInError(
        message: 'Invalid email or password.',
        code: 'unauthorized',
        statusCode: 401,
      );
    }

    if (error.contains('email not registered') ||
        error.contains('email not register') ||
        error.contains('user not found') ||
        error.contains('no user record')) {
      return const SignInError(
        message: 'The email address is not registered.',
        code: 'email_not_registered',
        statusCode: 404,
      );
    }

    if (error.contains('not found') || error.contains('404')) {
      return const SignInError(
        message: 'The requested resource was not found.',
        code: 'not_found',
        statusCode: 404,
      );
    }

    if (error.contains('internal server error') || error.contains('500')) {
      return const SignInError(
        message: 'An internal server error occurred. Please try again later.',
        code: 'internal_server_error',
        statusCode: 500,
      );
    }

    return const SignInError(
      message: 'Something went wrong. Please try again later.',
      code: 'unknown',
    );
  }

  String get title {
    switch (code) {
      case 'empty_field':
        return 'Validation Error';
      case 'network_error':
        return 'Network Error';
      case 'timeout':
        return 'Request Timeout';
      case 'unauthorized':
        return 'Login Failed';
      case 'email_not_registered':
        return 'Account Not Found';
      case 'internal_server_error':
        return 'Server Error';
      default:
        return 'Sign In Error';
    }
  }
}
