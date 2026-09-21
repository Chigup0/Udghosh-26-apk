import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/services/auth_provider.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// Two-step Email + OTP login screen: enter email → 6-digit OTP → in.
/// Includes the `demo@gmail.com` / `123456` bypass for offline demos.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String _pendingEmail = '';
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = AppConfig.otpResendCooldown.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) t.cancel();
      });
    });
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthController.instance.requestOtp(email);
      setState(() {
        _otpSent = true;
        _pendingEmail = email;
      });
      _startCooldown();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) FocusScope.of(context).requestFocus(_otpFocus.first);
      });
    } on ApiException catch (e) {
      setState(() {
        if (e.statusCode == 404) {
          _error = 'Email not registered';
        } else if (e.statusCode == 429) {
          _error = 'Please wait 60s before requesting another OTP';
        } else {
          _error = 'Invalid request. ${e.message}';
        }
      });
    } catch (_) {
      setState(() => _error = 'Something went wrong. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() => _error = 'Enter the full 6-digit code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthController.instance.verifyOtp(_pendingEmail, otp);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() {
        _error = e.statusCode == 401
            ? 'Invalid or expired OTP'
            : 'Verification failed. ${e.message}';
      });
    } catch (_) {
      setState(() => _error = 'Something went wrong. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 46,
      height: 54,
      child: NeoInset(
        padding: EdgeInsets.zero,
        active: _otpControllers[index].text.isNotEmpty,
        child: Center(
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocus[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeoColors.logoTeal,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setState(() {});
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).requestFocus(_otpFocus[index + 1]);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(_otpFocus[index - 1]);
              }
              if (index == 5 && value.isNotEmpty) _verifyOtp();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.canvasMint,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NeoColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: NeoShadows.raised(),
                  ),
                  child: Image.asset(
                    'assets/logo/logo.png',
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.emoji_events_outlined,
                      size: 40,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _otpSent ? 'Verify your code' : 'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.logoTeal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _otpSent
                    ? 'Enter the 6-digit code sent to $_pendingEmail'
                    : 'Sign in with your email to unlock personalised schedules',
                textAlign: TextAlign.center,
                style: TextStyle(color: NeoColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 28),
              if (!_otpSent) ...[
                NeoInset(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: NeoColors.logoTeal,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'you@example.com',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use demo@gmail.com for guest bypass',
                  style: TextStyle(
                    color: NeoColors.textMuted.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                NeoPillButton(
                  label: 'SEND OTP',
                  loading: _loading,
                  onTap: _sendOtp,
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, _otpBox),
                ),
                const SizedBox(height: 14),
                Center(
                  child: _cooldownSeconds > 0
                      ? Text(
                          'Resend available in 00:${_cooldownSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: NeoColors.textMuted,
                            fontSize: 12,
                          ),
                        )
                      : TextButton(
                          onPressed: _loading ? null : _sendOtp,
                          child: Text(
                            'Resend code',
                            style: TextStyle(
                              color: NeoColors.waveInk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                NeoPillButton(
                  label: 'VERIFY & ENTER',
                  loading: _loading,
                  onTap: _verifyOtp,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _otpSent = false;
                      _error = null;
                      for (final c in _otpControllers) {
                        c.clear();
                      }
                    }),
                    child: Text(
                      'Change email',
                      style: TextStyle(color: NeoColors.textMuted),
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NeoColors.alert.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: NeoColors.alert,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
