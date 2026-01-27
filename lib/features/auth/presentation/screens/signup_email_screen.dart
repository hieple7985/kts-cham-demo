import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../onboarding/presentation/screens/import_contacts_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/cuca_auth_mascot.dart';
import 'login_email_screen.dart';

class SignupEmailScreen extends ConsumerStatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  ConsumerState<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends ConsumerState<SignupEmailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscureText = true;

  void _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final email = values['email'] as String;
      final password = values['password'] as String;

      await ref.read(authProvider.notifier).signupEmail(email, password);
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!)),
        );
        return;
      }

      if (authState.isAuthenticated) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ImportContactsScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng kiểm tra email để xác thực.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: CucaAuthMascot(
                  pose: authState.error != null ? CucaAuthPose.alert : CucaAuthPose.ready,
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Đăng ký bằng Email',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'email',
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Vui lòng nhập email'),
                        FormBuilderValidators.email(errorText: 'Email không hợp lệ'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Vui lòng nhập mật khẩu'),
                        FormBuilderValidators.minLength(6, errorText: 'Tối thiểu 6 ký tự'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'confirm_password',
                      obscureText: _obscureText,
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
              
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginEmailScreen()),
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
