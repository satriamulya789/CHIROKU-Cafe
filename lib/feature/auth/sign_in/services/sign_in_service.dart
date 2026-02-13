import 'dart:developer';

import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/services/rate_limit_service.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/not_register_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInService {
  final SupabaseClient supabase = Supabase.instance.client;
  final _emailNotRegister = NotRegisterEmail();
  RateLimitService? _rateLimitService;
  // final _customSnackbar = CustomSnackbar();

  /// Initialize rate limit service
  Future<void> _initRateLimitService() async {
    _rateLimitService ??= await RateLimitService.create();
  }

  //sign in with email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // Initialize rate limit service
    await _initRateLimitService();

    // Check rate limit BEFORE any validation
    final rateLimitResult = await _rateLimitService!.checkLoginRateLimit();
    if (!rateLimitResult.canProceed) {
      log(
        'Login rate limit exceeded. Remaining: ${rateLimitResult.remainingSeconds}s',
        name: 'SignInService.signIn',
        level: 900,
      );
      throw AuthErrorModel.tooManyLoginAttempts(
        retryAfter: rateLimitResult.formattedRemainingTime,
      );
    }

    //validator
    final emailNotRegister = await _emailNotRegister.isEmailNotRegistered(
      email,
    );
    if (emailNotRegister) {
      // Track failed attempt
      await _rateLimitService!.trackLoginAttempt(success: false);
      throw AuthErrorModel.emailNotRegistered();
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
      // Sign in with Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      //check if user is null
      final user = response.user;
      if (user == null) {
        log('user not register');
        // Track failed attempt
        await _rateLimitService!.trackLoginAttempt(success: false);
        throw AuthErrorModel.emailNotRegistered();
      }

      // Success - reset rate limit counter
      await _rateLimitService!.trackLoginAttempt(success: true);
      log('Login successful, rate limit reset', name: 'SignInService.signIn');

      return response;
    } on AuthException catch (e) {
      // Track failed attempt for auth errors
      await _rateLimitService!.trackLoginAttempt(success: false);

      // Check if it's a rate limit error from Supabase
      if (e.statusCode == '429') {
        log(
          'Supabase rate limit hit',
          name: 'SignInService.signIn',
          level: 900,
        );
        throw AuthErrorModel.tooManyLoginAttempts();
      }

      log('Auth error during sign in', name: 'SignInService.signIn', error: e);
      rethrow;
    } catch (e) {
      // Track failed attempt for other errors
      await _rateLimitService!.trackLoginAttempt(success: false);
      log('Error sign in user', name: 'SignInService.signIn', error: e);
      rethrow;
    }
  }

  Future<UserRole?> getUserRole(String userId) async {
    try {
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return null;

      final roleString = userData['role'] as String?;

      if (roleString?.toLowerCase() == 'admin') {
        return UserRole.admin;
      } else if (roleString?.toLowerCase() == 'cashier') {
        return UserRole.cashier;
      }
      return null;
    } catch (e) {
      log('Failed to load user');
      rethrow;
    }
  }

  /// Get user data from database
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final data = await supabase
          .from(ApiConstant.usersTable)
          .select('id, email, full_name, role, avatar_url')
          .eq('id', userId)
          .single();

      return data;
    } catch (e) {
      log('Failed to load user');
      rethrow;
    }
  }

  /// Check if user session exists
  Future<bool> hasActiveSession() async {
    final session = supabase.auth.currentSession;
    return session != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
