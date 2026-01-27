import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import 'otp_verification_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/cuca_auth_mascot.dart';
import 'signup_email_screen.dart';

class SignupPhoneScreen extends ConsumerStatefulWidget {
  const SignupPhoneScreen({super.key});

  @override
  ConsumerState<SignupPhoneScreen> createState() => _SignupPhoneScreenState();
}

class _SignupPhoneScreenState extends ConsumerState<SignupPhoneScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Clean phone number: remove spaces and dashes
      final rawPhone = _formKey.currentState?.value['phone'] as String? ?? '';
      final phone = rawPhone.replaceAll(RegExp(r'[\s\-]'), '');

      await ref.read(authProvider.notifier).requestPhoneOtp(phone);
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.dangerText,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneNumber: phone,
            isLogin: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Web platform doesn't support phone signup
    if (kIsWeb) {
      return _buildWebNotAvailable();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mascot
              CucaAuthMascot(
                pose: authState.error != null ? CucaAuthPose.alert : CucaAuthPose.ready,
                height: 180,
              ),
              const SizedBox(height: AppSpacing.s6),

              // Title
              Text(
                'Đăng ký tài khoản',
                style: AppTextStyle.title2,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Nhập số điện thoại để tạo tài khoản mới',
                style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s6),

              // Form
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'phone',
                      keyboardType: TextInputType.phone,
                      style: AppTextStyle.body,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        hintText: 'Ví dụ: 0912345678',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      // Remove spaces and dashes from input before validation
                      valueTransformer: (value) => value?.replaceAll(RegExp(r'[\s\-]'), ''),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Vui lòng nhập số điện thoại'),
                        FormBuilderValidators.numeric(errorText: 'Chỉ được nhập số'),
                        FormBuilderValidators.minLength(10, errorText: 'Số điện thoại không hợp lệ'),
                        FormBuilderValidators.maxLength(11, errorText: 'Số điện thoại không hợp lệ'),
                        (value) {
                          if (value != null && !value.startsWith('0')) {
                            return 'Số điện thoại phải bắt đầu bằng số 0';
                          }
                          return null;
                        }
                      ]),
                    ),
                  ],
                ),
              ),
              if (authState.error != null) ...[
                const SizedBox(height: AppSpacing.s3),
                Text(
                  authState.error!,
                  style: AppTextStyle.caption.copyWith(color: AppColors.dangerText),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.s6),

              // Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Tiếp tục',
                          style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.s4),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupEmailScreen()),
                        );
                      },
                child: Text(
                  'Hoặc đăng ký bằng Email',
                  style: AppTextStyle.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebNotAvailable() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            children: [
              const Spacer(),
              const CucaAuthMascot(pose: CucaAuthPose.alert, height: 180),
              const SizedBox(height: AppSpacing.s6),
              Text(
                'Đăng ký bằng SĐT không khả dụng trên Web',
                style: AppTextStyle.title2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Đăng ký bằng số điện thoại chỉ khả dụng trên ứng dụng mobile (Android).\n\nTrên phiên bản Web, vui lòng sử dụng Email để đăng ký.',
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupEmailScreen()),
                    );
                  },
                  child: Text(
                    'Đăng ký bằng Email',
                    style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
