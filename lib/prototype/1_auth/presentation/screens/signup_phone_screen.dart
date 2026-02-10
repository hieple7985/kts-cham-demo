import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_auth_repository.dart';
import '../widgets/mascot_widget.dart';
import 'otp_verification_screen.dart';
import 'signup_email_screen.dart';

class SignupPhoneScreen extends StatefulWidget {
  const SignupPhoneScreen({super.key});

  @override
  State<SignupPhoneScreen> createState() => _SignupPhoneScreenState();
}

class _SignupPhoneScreenState extends State<SignupPhoneScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _repository = MockAuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  void _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final phone = _formKey.currentState?.value['phone'] as String;

      try {
        // 1.4 Phone Signup Flow: Check exists then Send OTP
        await _repository.sendOtp(phone);

        if (mounted) {
          // Navigate to OTP with isSignup context
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phone,
                isSignup: true,
              ),
            ),
          );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            MascotWidget(
              pose: _errorMessage != null ? MascotPose.alert : MascotPose.ready,
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name:
                        'name', // Asking for name upfront or later? S1.4 says OTP -> Create Password.
                    // Let's keep it simple: Just Phone first, or Name + Phone.
                    // To follow Schema, we need Full Name. Let's ask for it now.
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: FormBuilderValidators.required(
                        errorText: 'Vui lòng nhập họ tên'),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'phone',
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: const Icon(Icons.phone_android),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Vui lòng nhập SĐT'),
                      FormBuilderValidators.minLength(10,
                          errorText: 'SĐT không hợp lệ'),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tiếp tục',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignupEmailScreen()),
                );
              },
              child: const Text('Đăng ký bằng Email'),
            ),
          ],
        ),
      ),
    );
  }
}
