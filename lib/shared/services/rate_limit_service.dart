import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola rate limiting di sisi client
/// Mencegah spam request sebelum mencapai server
class RateLimitService {
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _loginLastAttemptKey = 'login_last_attempt';
  static const String _loginLockoutUntilKey = 'login_lockout_until';

  static const String _signUpAttemptsKey = 'signup_attempts';
  static const String _signUpLastAttemptKey = 'signup_last_attempt';
  static const String _signUpLockoutUntilKey = 'signup_lockout_until';

  // Rate limit configuration
  static const int maxLoginAttempts = 5; // 5 attempts
  static const int maxSignUpAttempts = 3; // 3 attempts
  static const int timeWindowMinutes = 5; // dalam 5 menit

  // Exponential backoff durations (in seconds)
  static const List<int> lockoutDurations = [
    30, // 30 seconds
    60, // 1 minute
    300, // 5 minutes
    900, // 15 minutes
  ];

  final SharedPreferences _prefs;

  RateLimitService(this._prefs);

  /// Factory method untuk create instance
  static Future<RateLimitService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return RateLimitService(prefs);
  }

  // ==================== Login Rate Limiting ====================

  /// Check apakah login masih dalam rate limit
  /// Returns: (canProceed, remainingTime, attemptsLeft)
  Future<RateLimitResult> checkLoginRateLimit() async {
    return _checkRateLimit(
      attemptsKey: _loginAttemptsKey,
      lastAttemptKey: _loginLastAttemptKey,
      lockoutUntilKey: _loginLockoutUntilKey,
      maxAttempts: maxLoginAttempts,
      actionName: 'login',
    );
  }

  /// Track login attempt
  Future<void> trackLoginAttempt({required bool success}) async {
    await _trackAttempt(
      attemptsKey: _loginAttemptsKey,
      lastAttemptKey: _loginLastAttemptKey,
      lockoutUntilKey: _loginLockoutUntilKey,
      success: success,
      maxAttempts: maxLoginAttempts,
      actionName: 'login',
    );
  }

  /// Reset login attempts (dipanggil setelah successful login)
  Future<void> resetLoginAttempts() async {
    await _resetAttempts(
      attemptsKey: _loginAttemptsKey,
      lastAttemptKey: _loginLastAttemptKey,
      lockoutUntilKey: _loginLockoutUntilKey,
    );
    log('Login attempts reset', name: 'RateLimitService');
  }

  // ==================== Sign Up Rate Limiting ====================

  /// Check apakah sign up masih dalam rate limit
  Future<RateLimitResult> checkSignUpRateLimit() async {
    return _checkRateLimit(
      attemptsKey: _signUpAttemptsKey,
      lastAttemptKey: _signUpLastAttemptKey,
      lockoutUntilKey: _signUpLockoutUntilKey,
      maxAttempts: maxSignUpAttempts,
      actionName: 'signup',
    );
  }

  /// Track sign up attempt
  Future<void> trackSignUpAttempt({required bool success}) async {
    await _trackAttempt(
      attemptsKey: _signUpAttemptsKey,
      lastAttemptKey: _signUpLastAttemptKey,
      lockoutUntilKey: _signUpLockoutUntilKey,
      success: success,
      maxAttempts: maxSignUpAttempts,
      actionName: 'signup',
    );
  }

  /// Reset sign up attempts
  Future<void> resetSignUpAttempts() async {
    await _resetAttempts(
      attemptsKey: _signUpAttemptsKey,
      lastAttemptKey: _signUpLastAttemptKey,
      lockoutUntilKey: _signUpLockoutUntilKey,
    );
    log('Sign up attempts reset', name: 'RateLimitService');
  }

  // ==================== Private Helper Methods ====================

  /// Generic rate limit checker
  Future<RateLimitResult> _checkRateLimit({
    required String attemptsKey,
    required String lastAttemptKey,
    required String lockoutUntilKey,
    required int maxAttempts,
    required String actionName,
  }) async {
    final now = DateTime.now();

    // Check if currently locked out
    final lockoutUntil = _prefs.getString(lockoutUntilKey);
    if (lockoutUntil != null) {
      final lockoutTime = DateTime.parse(lockoutUntil);
      if (now.isBefore(lockoutTime)) {
        final remainingSeconds = lockoutTime.difference(now).inSeconds;
        log(
          'Action $actionName is locked out for $remainingSeconds seconds',
          name: 'RateLimitService',
        );
        return RateLimitResult(
          canProceed: false,
          remainingSeconds: remainingSeconds,
          attemptsLeft: 0,
          isLockedOut: true,
        );
      } else {
        // Lockout expired, reset
        await _resetAttempts(
          attemptsKey: attemptsKey,
          lastAttemptKey: lastAttemptKey,
          lockoutUntilKey: lockoutUntilKey,
        );
      }
    }

    // Get current attempts
    final attempts = _prefs.getInt(attemptsKey) ?? 0;
    final lastAttemptStr = _prefs.getString(lastAttemptKey);

    // Check if time window has passed
    if (lastAttemptStr != null) {
      final lastAttempt = DateTime.parse(lastAttemptStr);
      final minutesSinceLastAttempt = now.difference(lastAttempt).inMinutes;

      if (minutesSinceLastAttempt >= timeWindowMinutes) {
        // Time window passed, reset attempts
        await _resetAttempts(
          attemptsKey: attemptsKey,
          lastAttemptKey: lastAttemptKey,
          lockoutUntilKey: lockoutUntilKey,
        );
        return RateLimitResult(
          canProceed: true,
          remainingSeconds: 0,
          attemptsLeft: maxAttempts,
          isLockedOut: false,
        );
      }
    }

    // Check if exceeded max attempts
    if (attempts >= maxAttempts) {
      // Calculate lockout duration based on number of violations
      final lockoutIndex = (attempts - maxAttempts).clamp(
        0,
        lockoutDurations.length - 1,
      );
      final lockoutSeconds = lockoutDurations[lockoutIndex];
      final lockoutUntilTime = now.add(Duration(seconds: lockoutSeconds));

      await _prefs.setString(
        lockoutUntilKey,
        lockoutUntilTime.toIso8601String(),
      );

      log(
        'Rate limit exceeded for $actionName. Locked out for $lockoutSeconds seconds',
        name: 'RateLimitService',
        level: 900,
      );

      return RateLimitResult(
        canProceed: false,
        remainingSeconds: lockoutSeconds,
        attemptsLeft: 0,
        isLockedOut: true,
      );
    }

    // Can proceed
    final attemptsLeft = maxAttempts - attempts;
    return RateLimitResult(
      canProceed: true,
      remainingSeconds: 0,
      attemptsLeft: attemptsLeft,
      isLockedOut: false,
    );
  }

  /// Track an attempt
  Future<void> _trackAttempt({
    required String attemptsKey,
    required String lastAttemptKey,
    required String lockoutUntilKey,
    required bool success,
    required int maxAttempts,
    required String actionName,
  }) async {
    if (success) {
      // Reset on success
      await _resetAttempts(
        attemptsKey: attemptsKey,
        lastAttemptKey: lastAttemptKey,
        lockoutUntilKey: lockoutUntilKey,
      );
      return;
    }

    // Increment attempts on failure
    final currentAttempts = _prefs.getInt(attemptsKey) ?? 0;
    final newAttempts = currentAttempts + 1;

    await _prefs.setInt(attemptsKey, newAttempts);
    await _prefs.setString(lastAttemptKey, DateTime.now().toIso8601String());

    log(
      'Tracked $actionName attempt: $newAttempts/$maxAttempts',
      name: 'RateLimitService',
    );
  }

  /// Reset attempts
  Future<void> _resetAttempts({
    required String attemptsKey,
    required String lastAttemptKey,
    required String lockoutUntilKey,
  }) async {
    await _prefs.remove(attemptsKey);
    await _prefs.remove(lastAttemptKey);
    await _prefs.remove(lockoutUntilKey);
  }

  /// Clear all rate limit data (untuk testing/debugging)
  Future<void> clearAllRateLimits() async {
    await resetLoginAttempts();
    await resetSignUpAttempts();
    log('All rate limits cleared', name: 'RateLimitService');
  }
}

/// Result dari rate limit check
class RateLimitResult {
  final bool canProceed;
  final int remainingSeconds;
  final int attemptsLeft;
  final bool isLockedOut;

  RateLimitResult({
    required this.canProceed,
    required this.remainingSeconds,
    required this.attemptsLeft,
    required this.isLockedOut,
  });

  /// Format remaining time untuk display ke user
  String get formattedRemainingTime {
    if (remainingSeconds < 60) {
      return '$remainingSeconds detik';
    } else if (remainingSeconds < 3600) {
      final minutes = (remainingSeconds / 60).ceil();
      return '$minutes menit';
    } else {
      final hours = (remainingSeconds / 3600).ceil();
      return '$hours jam';
    }
  }

  @override
  String toString() {
    return 'RateLimitResult(canProceed: $canProceed, remainingSeconds: $remainingSeconds, '
        'attemptsLeft: $attemptsLeft, isLockedOut: $isLockedOut)';
  }
}
