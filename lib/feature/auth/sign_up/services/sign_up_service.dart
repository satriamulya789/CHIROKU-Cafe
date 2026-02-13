import 'dart:developer';

import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/services/rate_limit_service.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final SupabaseClient supabase = Supabase.instance.client;
  final ExistingEmail _existingEmail = ExistingEmail();
  RateLimitService? _rateLimitService;

  /// Initialize rate limit service
  Future<void> _initRateLimitService() async {
    _rateLimitService ??= await RateLimitService.create();
  }

  /// Create user record in table 'users'
  Future<void> _createUserRecord({
    required String userId,
    required String email,
  }) async {
    try {
      await supabase.from(ApiConstant.usersTable).insert({
        'id': userId,
        'email': email.trim().toLowerCase(),
        'role': 'cashier',
        'created_at': DateTime.now().toIso8601String(),
      });

      log('User record created successfully');
    } catch (e) {
      log('Error creating user record');
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    // Initialize rate limit service
    await _initRateLimitService();

    // Check rate limit BEFORE any validation
    final rateLimitResult = await _rateLimitService!.checkSignUpRateLimit();
    if (!rateLimitResult.canProceed) {
      log(
        'Sign up rate limit exceeded. Remaining: ${rateLimitResult.remainingSeconds}s',
        name: 'SignUpService.signUp',
        level: 900,
      );
      throw AuthErrorModel.tooManySignUpAttempts(
        retryAfter: rateLimitResult.formattedRemainingTime,
      );
    }

    // Validation
    final emailExists = await _existingEmail.isEmailExists(email);
    if (emailExists) {
      // Track failed attempt
      await _rateLimitService!.trackSignUpAttempt(success: false);
      throw AuthErrorModel.emailAlreadyExists();
    }
    if (password.isEmpty) {
      throw AuthErrorModel.passwordEmpty();
    }
    if (email.isEmpty) {
      throw AuthErrorModel.emailEmpty();
    }
    if (password.length < 6) {
      throw AuthErrorModel.passwordTooShort();
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw AuthErrorModel.invalidEmailFormat();
    }

    try {
      final response = await supabase.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {'role': role},
      );

      final user = response.user;
      if (user != null) {
        await _createUserRecord(userId: user.id, email: email);

        // Success - reset rate limit counter
        await _rateLimitService!.trackSignUpAttempt(success: true);

        log(
          'User signed up successfully: ${user.email}',
          name: 'SignUpService.signUp',
          level: 800,
        );
      } else {
        // Track failed attempt if no user returned
        await _rateLimitService!.trackSignUpAttempt(success: false);
      }

      return response;
    } on AuthException catch (e) {
      // Track failed attempt for auth errors
      await _rateLimitService!.trackSignUpAttempt(success: false);

      // Check if it's a rate limit error from Supabase
      if (e.statusCode == '429') {
        log(
          'Supabase rate limit hit',
          name: 'SignUpService.signUp',
          level: 900,
        );
        throw AuthErrorModel.tooManySignUpAttempts();
      }

      log(
        'Auth exception during sign up',
        name: 'SignUpService.signUp',
        error: e,
        level: 1000,
      );
      rethrow;
    } catch (e) {
      // Track failed attempt for other errors
      await _rateLimitService!.trackSignUpAttempt(success: false);

      log(
        'Unknown error during sign up',
        name: 'SignUpService.signUp',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }
}
