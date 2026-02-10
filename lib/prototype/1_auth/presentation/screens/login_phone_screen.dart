import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_auth_repository.dart';
import '../widgets/mascot_widget.dart';
import 'otp_verification_screen.dart';
import 'login_email_screen.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
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
        // 1.2 Phone Login Flow: Send OTP
        await _repository.sendOtp(phone);

        if (mounted) {
          // Navigate to OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phone,
                isLogin: true,
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
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1.8 Error State with Mascot
            MascotWidget(
              pose: _errorMessage != null ? MascotPose.alert : MascotPose.ready,
              height: 150,
              width: 150,
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            FormBuilder(
              key: _formKey,
              child: FormBuilderTextField(
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
                  FormBuilderValidators.numeric(errorText: 'Chỉ nhập số'),
                  FormBuilderValidators.minLength(10,
                      errorText: 'SĐT không hợp lệ'),
                ]),
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
                    : const Text('Gửi mã OTP',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // 1.3 Navigate to Email Login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginEmailScreen()),
                );
              },
              child: const Text('Hoặc đăng nhập bằng Email'),
            ),
          ],
        ),
      ),
    );
  }
}
