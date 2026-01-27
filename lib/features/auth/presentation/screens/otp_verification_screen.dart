import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/config/app_prefs.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../home/presentation/screens/app_shell_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_welcome_screen.dart';
import 'create_password_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/cuca_auth_mascot.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool isLogin;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isLogin = true,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  int _resendCooldownSeconds = 0;
  bool get _canResend => _resendCooldownSeconds <= 0;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldownSeconds = 30);
    Future.doWhile(() async {
      if (!mounted) return false;
      if (_resendCooldownSeconds <= 0) return false;
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldownSeconds -= 1);
      return _resendCooldownSeconds > 0;
    });
  }

  void _verifyOtp() async {
    if (_pinController.text.length != 6) return;

    if (widget.isLogin) {
      // LOGIN FLOW: Call API to verify OTP and login
      await ref.read(authProvider.notifier).loginPhone(widget.phoneNumber, _pinController.text);

      final authState = ref.read(authProvider);
      if (!mounted) return;

      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.dangerText,
          ),
        );
        return;
      }

      if (authState.isAuthenticated) {
        final target = AppPrefs.didOnboard
            ? const AppShellScreen()
            : const OnboardingWelcomeScreen();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => target),
          (route) => false,
        );
      }
    } else {
      // SIGNUP FLOW: Navigate to CreatePasswordScreen with OTP
      // Don't call API here - let CreatePasswordScreen handle the full signup
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePasswordScreen(
            phone: widget.phoneNumber,
            initialOtp: _pinController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final mascotPose = authState.isLoading
        ? CucaAuthPose.wave
        : (authState.error != null ? CucaAuthPose.alert : CucaAuthPose.ready);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Xác thực OTP', style: AppTextStyle.headline),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            children: [
              CucaAuthMascot(pose: mascotPose, height: 120),
              const SizedBox(height: AppSpacing.s6),
              Text(
                'Nhập mã OTP đã gửi đến',
                style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                widget.phoneNumber,
                style: AppTextStyle.title1,
              ),
              if (!AppConfig.useSupabaseAuth) ...[
                const SizedBox(height: AppSpacing.s2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: AppSpacing.s1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OTP mặc định là 123456',
                    style: AppTextStyle.caption.copyWith(color: AppColors.infoText),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s6),

              Pinput(
                length: 6,
                controller: _pinController,
                onCompleted: (pin) => _verifyOtp(),
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: AppTextStyle.title3,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: AppTextStyle.title3,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s6),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _verifyOtp,
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          'Xác nhận',
                          style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.s4),
              TextButton(
                onPressed: authState.isLoading || !_canResend
                    ? null
                    : () async {
                        await ref.read(authProvider.notifier).requestPhoneOtp(widget.phoneNumber);
                        if (!context.mounted) return;
                        final nextState = ref.read(authProvider);
                        if (nextState.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(nextState.error!),
                              backgroundColor: AppColors.dangerText,
                            ),
                          );
                          return;
                        }
                        _startResendCooldown();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã gửi lại mã OTP')),
                        );
                      },
                child: Text(
                  _canResend ? 'Gửi lại mã' : 'Gửi lại mã sau ${_resendCooldownSeconds}s',
                  style: AppTextStyle.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
