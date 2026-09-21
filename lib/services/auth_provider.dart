import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/services/api_service.dart';

/// App-wide auth/session state.
///
/// This is a plain singleton `ChangeNotifier` (no external state-management
/// package pulled in) — widgets rebuild on it via [ListenableBuilder]. It
/// owns local persistence, the demo/guest bypass, and the OTP resend
/// cooldown so screens stay thin.
class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  int? _id;
  String? _email;
  String? _name;
  bool _restoring = true;

  DateTime? _cooldownStartedAt;

  bool get isLoggedIn => _email != null;
  bool get isRestoring => _restoring;
  String? get email => _email;
  String? get name => _name;
  int? get id => _id;

  String get initials {
    final source = (_name?.trim().isNotEmpty ?? false)
        ? _name!
        : (_email ?? '?');
    return source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();
  }

  /// Loads any persisted session on app start. Call once from `main()`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('auth_id');
    final email = prefs.getString('auth_email');
    final name = prefs.getString('auth_name');
    _id = id;
    _email = email;
    _name = name;
    _restoring = false;
    notifyListeners();
  }

  Duration? get cooldownRemaining {
    if (_cooldownStartedAt == null) return null;
    final elapsed = DateTime.now().difference(_cooldownStartedAt!);
    final remaining = AppConfig.otpResendCooldown - elapsed;
    if (remaining.isNegative) return null;
    return remaining;
  }

  /// Step 1 — request an OTP. Bypasses the network for the demo account so
  /// reviewers / offline demos can proceed without backend access.
  Future<void> requestOtp(String email) async {
    final trimmed = email.trim();
    if (trimmed.toLowerCase() == AppConfig.demoEmail) {
      _cooldownStartedAt = DateTime.now();
      notifyListeners();
      return;
    }
    await ApiService.requestOtp(trimmed);
    _cooldownStartedAt = DateTime.now();
    notifyListeners();
  }

  /// Step 2 — verify the OTP and persist the session on success.
  Future<void> verifyOtp(String email, String otp) async {
    final trimmed = email.trim();
    if (trimmed.toLowerCase() == AppConfig.demoEmail &&
        otp.trim() == AppConfig.demoOtp) {
      await _saveSession(
        AppConfig.demoUserId,
        AppConfig.demoEmail,
        AppConfig.demoUserName,
      );
      return;
    }

    final data = await ApiService.verifyOtp(trimmed, otp.trim());
    final user = (data['user'] ?? data['player'] ?? data) as Map;
    await _saveSession(
      int.tryParse('${user['id'] ?? 0}') ?? 0,
      (user['email'] ?? trimmed).toString(),
      (user['name'] ?? '').toString(),
    );
  }

  Future<void> _saveSession(int id, String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auth_id', id);
    await prefs.setString('auth_email', email);
    await prefs.setString('auth_name', name);
    _id = id;
    _email = email;
    _name = name;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_id');
    await prefs.remove('auth_email');
    await prefs.remove('auth_name');
    _id = null;
    _email = null;
    _name = null;
    notifyListeners();
  }
}
