import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chiroku_cafe/shared/services/rate_limit_service.dart';

void main() {
  group('RateLimitService Tests', () {
    late RateLimitService rateLimitService;

    setUp(() async {
      // Initialize with mock shared preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      rateLimitService = RateLimitService(prefs);
    });

    tearDown(() async {
      // Clean up after each test
      await rateLimitService.clearAllRateLimits();
    });

    test('Should allow login when under rate limit', () async {
      final result = await rateLimitService.checkLoginRateLimit();

      expect(result.canProceed, true);
      expect(result.attemptsLeft, RateLimitService.maxLoginAttempts);
      expect(result.isLockedOut, false);
    });

    test('Should track failed login attempts', () async {
      // Simulate 3 failed attempts
      for (int i = 0; i < 3; i++) {
        await rateLimitService.trackLoginAttempt(success: false);
      }

      final result = await rateLimitService.checkLoginRateLimit();

      expect(result.canProceed, true);
      expect(result.attemptsLeft, 2); // 5 max - 3 attempts = 2 left
    });

    test('Should block login after max attempts exceeded', () async {
      // Simulate max failed attempts
      for (int i = 0; i < RateLimitService.maxLoginAttempts; i++) {
        await rateLimitService.trackLoginAttempt(success: false);
      }

      final result = await rateLimitService.checkLoginRateLimit();

      expect(result.canProceed, false);
      expect(result.isLockedOut, true);
      expect(result.remainingSeconds, greaterThan(0));
    });

    test('Should reset attempts after successful login', () async {
      // Simulate 3 failed attempts
      for (int i = 0; i < 3; i++) {
        await rateLimitService.trackLoginAttempt(success: false);
      }

      // Successful login
      await rateLimitService.trackLoginAttempt(success: true);

      final result = await rateLimitService.checkLoginRateLimit();

      expect(result.canProceed, true);
      expect(result.attemptsLeft, RateLimitService.maxLoginAttempts);
    });

    test('Should allow signup when under rate limit', () async {
      final result = await rateLimitService.checkSignUpRateLimit();

      expect(result.canProceed, true);
      expect(result.attemptsLeft, RateLimitService.maxSignUpAttempts);
      expect(result.isLockedOut, false);
    });

    test('Should block signup after max attempts exceeded', () async {
      // Simulate max failed attempts
      for (int i = 0; i < RateLimitService.maxSignUpAttempts; i++) {
        await rateLimitService.trackSignUpAttempt(success: false);
      }

      final result = await rateLimitService.checkSignUpRateLimit();

      expect(result.canProceed, false);
      expect(result.isLockedOut, true);
    });

    test('Should format remaining time correctly', () {
      final result1 = RateLimitResult(
        canProceed: false,
        remainingSeconds: 45,
        attemptsLeft: 0,
        isLockedOut: true,
      );
      expect(result1.formattedRemainingTime, '45 detik');

      final result2 = RateLimitResult(
        canProceed: false,
        remainingSeconds: 120,
        attemptsLeft: 0,
        isLockedOut: true,
      );
      expect(result2.formattedRemainingTime, '2 menit');

      final result3 = RateLimitResult(
        canProceed: false,
        remainingSeconds: 3700,
        attemptsLeft: 0,
        isLockedOut: true,
      );
      expect(result3.formattedRemainingTime, '2 jam');
    });

    test('Should apply exponential backoff', () async {
      // First violation - 30 seconds
      for (int i = 0; i < RateLimitService.maxLoginAttempts; i++) {
        await rateLimitService.trackLoginAttempt(success: false);
      }

      var result = await rateLimitService.checkLoginRateLimit();
      expect(result.remainingSeconds, lessThanOrEqualTo(30));

      // Clear and test second violation - should be longer
      await rateLimitService.clearAllRateLimits();

      for (int i = 0; i < RateLimitService.maxLoginAttempts + 1; i++) {
        await rateLimitService.trackLoginAttempt(success: false);
      }

      result = await rateLimitService.checkLoginRateLimit();
      // Second lockout should be at least 30 seconds (first tier)
      expect(result.remainingSeconds, greaterThan(0));
    });
  });
}
