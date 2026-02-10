import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../onboarding/presentation/screens/import_contacts_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/cuca_auth_mascot.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  final String phone;
  final String? initialOtp;

  const CreatePasswordScreen({
    super.key,
    required this.phone,
    this.initialOtp,
  });

  @override
  ConsumerState<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscureText = true;
  late TextEditingController _otpController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: widget.initialOtp ?? '');
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final password = _formKey.currentState!.value['password'] as String;
      final otp = _otpController.text;

      if (otp.isEmpty || otp.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập mã OTP (6 số)'),
            backgroundColor: AppColors.dangerText,
          ),
        );
        return;
      }

      // Call real signup API
      await ref.read(authProvider.notifier).signupPhone(
        widget.phone,
        otp,
        password,
      );

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

      if (authState.isAuthenticated) {
        // Navigate to onboarding
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ImportContactsScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
              const CucaAuthMascot(pose: CucaAuthPose.ready, height: 120),
              const SizedBox(height: AppSpacing.s6),

              Text(
                'Tạo mật khẩu',
                style: AppTextStyle.title2,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                'Thiết lập mật khẩu cho ${widget.phone}',
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s6),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // OTP Input (pre-filled from previous step)
                    FormBuilderTextField(
                      name: 'otp',
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Mã OTP',
                        hintText: 'Nhập mã OTP đã được gửi',
                        prefixIcon: const Icon(Icons.sms),
                        helperText: widget.initialOtp != null
                            ? 'OTP đã được điền tự động từ bước trước'
                            : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Vui lòng nhập mã OTP'),
                        FormBuilderValidators.minLength(6, errorText: 'Mã OTP có 6 số'),
                        FormBuilderValidators.maxLength(6, errorText: 'Mã OTP có 6 số'),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.s4),

                    FormBuilderTextField(
                      name: 'password',
                      obscureText: _obscureText,
                      style: AppTextStyle.body,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Nhập mật khẩu'),
                        FormBuilderValidators.minLength(6, errorText: 'Tối thiểu 6 ký tự'),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    FormBuilderTextField(
                      name: 'confirm_password',
                      obscureText: _obscureText,
                      style: AppTextStyle.body,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != _formKey.currentState?.fields['password']?.value) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s6),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Hoàn tất đăng ký',
                          style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.s2),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const ImportContactsScreen()),
                          (route) => false,
                        );
                      },
                child: Text(
                  'Bỏ qua bước này',
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
