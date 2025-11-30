import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security Service for handling sensitive data and app security
class SecurityService extends ChangeNotifier {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _walletAddressKey = 'secure_wallet_address';
  static const String _sessionTokenKey = 'secure_session_token';
  static const String _userIdKey = 'secure_user_id';
  static const String _lastLoginKey = 'last_login_timestamp';
  static const String _failedAttemptsKey = 'failed_login_attempts';
  static const String _lockoutTimeKey = 'lockout_time';

  // Security constants
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);

  bool _isLocked = false;
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;

  bool get isLocked => _isLocked;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutEndTime => _lockoutEndTime;

  SecurityService() {
    _initializeSecurity();
  }

  Future<void> _initializeSecurity() async {
    await _checkLockoutStatus();
  }

  /// Hash sensitive data using SHA-256
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a secure random token
  static String generateSecureToken({int length = 32}) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Store sensitive data securely
  Future<void> storeSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error storing secure data: $e');
    }
  }

  /// Retrieve sensitive data securely
  Future<String?> getSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Error reading secure data: $e');
      return null;
    }
  }

  /// Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting secure data: $e');
    }
  }

  /// Clear all secure storage
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing secure data: $e');
    }
  }

  /// Store wallet address securely
  Future<void> storeWalletAddress(String address) async {
    await storeSecureData(_walletAddressKey, address);
  }

  /// Get stored wallet address
  Future<String?> getStoredWalletAddress() async {
    return await getSecureData(_walletAddressKey);
  }

  /// Create and store session token
  Future<String> createSession(String userId) async {
    final token = generateSecureToken();
    await storeSecureData(_sessionTokenKey, token);
    await storeSecureData(_userIdKey, userId);
    await storeSecureData(_lastLoginKey, DateTime.now().toIso8601String());
    return token;
  }

  /// Validate session
  Future<bool> validateSession() async {
    final token = await getSecureData(_sessionTokenKey);
    if (token == null) return false;

    final lastLoginStr = await getSecureData(_lastLoginKey);
    if (lastLoginStr == null) return false;

    final lastLogin = DateTime.parse(lastLoginStr);
    final now = DateTime.now();

    // Check if session has expired
    if (now.difference(lastLogin) > sessionTimeout) {
      await clearSession();
      return false;
    }

    return true;
  }

  /// Clear session data
  Future<void> clearSession() async {
    await deleteSecureData(_sessionTokenKey);
    await deleteSecureData(_userIdKey);
    await deleteSecureData(_lastLoginKey);
  }

  /// Record failed login attempt
  Future<void> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, _failedAttempts);

    if (_failedAttempts >= maxFailedAttempts) {
      _lockoutEndTime = DateTime.now().add(lockoutDuration);
      await prefs.setString(
        _lockoutTimeKey,
        _lockoutEndTime!.toIso8601String(),
      );
      _isLocked = true;
    }

    notifyListeners();
  }

  /// Reset failed attempts on successful login
  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = 0;
    _isLocked = false;
    _lockoutEndTime = null;
    await prefs.setInt(_failedAttemptsKey, 0);
    await prefs.remove(_lockoutTimeKey);
    notifyListeners();
  }

  /// Check if account is locked out
  Future<void> _checkLockoutStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;

    final lockoutTimeStr = prefs.getString(_lockoutTimeKey);
    if (lockoutTimeStr != null) {
      _lockoutEndTime = DateTime.parse(lockoutTimeStr);
      final now = DateTime.now();

      if (now.isBefore(_lockoutEndTime!)) {
        _isLocked = true;
      } else {
        // Lockout period has passed
        await resetFailedAttempts();
      }
    }

    notifyListeners();
  }

  /// Get remaining lockout time
  Duration? getRemainingLockoutTime() {
    if (_lockoutEndTime == null) return null;
    final remaining = _lockoutEndTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Validate input to prevent injection attacks
  static bool isValidInput(String input) {
    // Check for common SQL injection patterns
    final sqlPattern = RegExp(
      r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|TRUNCATE)\b)',
      caseSensitive: false,
    );

    // Check for special characters that could be used for injection
    final hasDangerousChars =
        input.contains("'") ||
        input.contains('"') ||
        input.contains(';') ||
        input.contains('--');

    // Check for script injection
    final scriptPattern = RegExp(
      r'<script|javascript:|on\w+\s*=',
      caseSensitive: false,
    );

    return !sqlPattern.hasMatch(input) &&
        !hasDangerousChars &&
        !scriptPattern.hasMatch(input);
  }

  /// Sanitize user input
  static String sanitizeInput(String input) {
    String result = input;
    result = result.replaceAll('<', '');
    result = result.replaceAll('>', '');
    result = result.replaceAll('"', '');
    result = result.replaceAll("'", '');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    return result.trim();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailPattern.hasMatch(email);
  }

  /// Validate password strength
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 6) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?:{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Mask sensitive data for display
  static String maskWalletAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Mask email for display
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  /// Check if running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Log security event (only in debug mode)
  static void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      debugPrint('SECURITY: $event');
      if (details != null) {
        debugPrint('   Details: $details');
      }
    }
  }
}

enum PasswordStrength { weak, medium, strong }

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
