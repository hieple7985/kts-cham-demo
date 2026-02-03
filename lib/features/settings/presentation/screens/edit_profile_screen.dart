import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../models/settings_state.dart';
import '../providers/settings_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDirty = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _businessController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(settingsProvider).profile;
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _businessController = TextEditingController(text: profile.businessName);

    for (final c in [_nameController, _emailController, _phoneController, _businessController]) {
      c.addListener(() {
        if (_isDirty) return;
        setState(() => _isDirty = true);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bỏ thay đổi?', style: AppTextStyle.headline),
        content: Text('Bạn có thay đổi chưa lưu. Bạn muốn bỏ thay đổi không?', style: AppTextStyle.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Tiếp tục chỉnh', style: AppTextStyle.body)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Bỏ', style: AppTextStyle.body.copyWith(color: AppColors.dangerText))),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final next = UserProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      businessName: _businessController.text.trim(),
    );
    ref.read(settingsProvider.notifier).updateProfile(next);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật hồ sơ thành công!')));
    Navigator.pop(context);
  }

  Future<void> _pickAvatar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chọn avatar đang phát triển.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(settingsProvider).profile;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final ok = await _confirmDiscard();
        if (!ok) return;
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Chỉnh sửa hồ sơ', style: AppTextStyle.headline),
          backgroundColor: AppColors.surface,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Lưu', style: AppTextStyle.bodyStrong.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.s6),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      profile.fullName.isNotEmpty ? profile.fullName[0] : '?',
                      style: AppTextStyle.title2.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: AppTextStyle.body,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  TextFormField(
                    controller: _emailController,
                    style: AppTextStyle.body,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      if (!t.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  TextFormField(
                    controller: _phoneController,
                    style: AppTextStyle.body,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Vui lòng nhập SĐT' : null,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  TextFormField(
                    controller: _businessController,
                    style: AppTextStyle.body,
                    decoration: const InputDecoration(
                      labelText: 'Tên doanh nghiệp / Team',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
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
