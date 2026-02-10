import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../data/mock_auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/mascot_widget.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLogin;
  final bool isSignup;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isLogin = true,
    this.isSignup = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _repository = MockAuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify() async {
    if (_pinController.text.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isSignup) {
        // For signup, we don't login immediately, just verify OTP then let user set password
        // But for Prototype 1.4, we might just "Login" or go to "Create Password"
        // Let's assume verifying OTP logs them in for now or finishes 1.4 flow.

        // Simulating Verify OTP success for Signup
        await Future.delayed(const Duration(seconds: 1));
        if (_pinController.text != '123456')
          throw Exception('Mã OTP không đúng');

        // Go to Home or Onboarding
        if (mounted) {
          // TODO: Navigate to S1.10 Onboarding
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Xác thực thành công! (Prototype: Done Signup Flow)')),
          );
          // Navigator.of(context).pushReplacement(...)
        }
      } else {
        // Login Flow (1.2)
        await _repository.verifyOtpAndLogin(
            widget.phoneNumber, _pinController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );
          // TODO: Navigate to Home (S2)
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1.8 Error State Mascot
            if (_errorMessage != null)
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: MascotWidget(pose: MascotPose.alert),
              ),

            const Text(
              'Nhập mã xác thực',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã OTP đã được gửi đến số ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            Pinput(
              length: 6,
              controller: _pinController,
              onCompleted: (_) => _verify(),
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _errorMessage != null ? Colors.red : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              errorText: _errorMessage, // Show inline error
              forceErrorState: _errorMessage != null,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Xác nhận',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
