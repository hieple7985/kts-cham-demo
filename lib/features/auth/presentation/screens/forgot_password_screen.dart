import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../widgets/cuca_auth_mascot.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneFormKey = GlobalKey<FormBuilderState>();
  final _emailFormKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _submit() async {
    final isPhone = _tabController.index == 0;
    final formKey = isPhone ? _phoneFormKey : _emailFormKey;

    if (formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      
      // Mock API
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPhone 
              ? 'Mã xác thực đã được gửi tới số điện thoại của bạn' 
              : 'Vui lòng kiểm tra email để đặt lại mật khẩu'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text('Quên mật khẩu', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Số điện thoại'),
                  Tab(text: 'Email'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Phone Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FormBuilder(
                      key: _phoneFormKey,
                      child: Column(
                        children: [
                          const CucaAuthMascot(pose: CucaAuthPose.wave, height: 100),
                          const SizedBox(height: 24),
                          const Text(
                            'Nhập số điện thoại đã đăng ký để nhận mã xác thực',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          FormBuilderTextField(
                            name: 'phone',
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              prefixIcon: Icon(Icons.phone_android),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Nhập số điện thoại'),
                              FormBuilderValidators.numeric(),
                              FormBuilderValidators.minLength(10),
                            ]),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Gửi mã OTP'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Email Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FormBuilder(
                      key: _emailFormKey,
                      child: Column(
                        children: [
                          const CucaAuthMascot(pose: CucaAuthPose.wave, height: 100),
                          const SizedBox(height: 24),
                          const Text(
                            'Nhập email đã đăng ký để nhận link đặt lại mật khẩu',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          FormBuilderTextField(
                            name: 'email',
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Nhập email'),
                              FormBuilderValidators.email(),
                            ]),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Gửi link xác thực'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
