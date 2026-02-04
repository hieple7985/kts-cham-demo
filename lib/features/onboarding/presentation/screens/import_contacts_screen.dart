import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import 'notification_permission_screen.dart';
import '../../../auth/presentation/widgets/cuca_auth_mascot.dart';

class ImportContactsScreen extends StatefulWidget {
  const ImportContactsScreen({super.key});

  @override
  State<ImportContactsScreen> createState() => _ImportContactsScreenState();
}

class _ImportContactsScreenState extends State<ImportContactsScreen> {
  bool _isLoading = false;
  bool _hasContactsPermission = false;
  final Set<int> _selectedIndexes = <int>{};

  final List<Map<String, String>> _mockContacts = const [
    {'name': 'Nguyễn Văn A', 'phone': '0901234567'},
    {'name': 'Trần Thị B', 'phone': '0912345678'},
    {'name': 'Lê Văn C', 'phone': '0923456789'},
    {'name': 'Phạm Thị D', 'phone': '0934567890'},
    {'name': 'Hoàng Văn E', 'phone': '0945678901'},
    {'name': 'Võ Thị F', 'phone': '0956789012'},
    {'name': 'Đặng Văn G', 'phone': '0967890123'},
    {'name': 'Bùi Thị H', 'phone': '0978901234'},
  ];

  void _importContacts() async {
    setState(() => _isLoading = true);

    // Mock import delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã nhập ${_selectedIndexes.length} liên hệ thành công!'),
          backgroundColor: AppColors.successText,
        ),
      );

      _nextStep();
    }
  }

  void _nextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPermissionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web platform doesn't support device contacts import
    if (kIsWeb) {
      return _buildWebNotAvailable();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: _hasContactsPermission
              ? _buildContactsSelection()
              : _buildPermissionRequest(),
        ),
      ),
    );
  }

  Widget _buildWebNotAvailable() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            children: [
              const Spacer(),
              const CucaAuthMascot(pose: CucaAuthPose.alert, height: 200),
              const SizedBox(height: AppSpacing.s6),
              Text(
                'Tính năng không khả dụng trên Web',
                style: AppTextStyle.title2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Nhập danh bạ từ thiết bị chỉ khả dụng trên ứng dụng mobile (Android/iOS).\n\nTrên phiên bản Web, bạn có thể thêm khách hàng thủ công.',
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    'Tiếp tục',
                    style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Column(
      children: [
        const Spacer(),
        const CucaAuthMascot(pose: CucaAuthPose.ready, height: 200),
        const SizedBox(height: AppSpacing.s6),
        Text(
          'Cho phép truy cập danh bạ',
          style: AppTextStyle.title2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          'Cho phép truy cập danh bạ để chọn khách hàng từ liên hệ của bạn.',
          textAlign: TextAlign.center,
          style: AppTextStyle.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _hasContactsPermission = true),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.lock_open),
            label: Text(
              'Cho phép',
              style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        TextButton(
          onPressed: _nextStep,
          child: Text(
            'Bỏ qua, tôi sẽ thêm sau',
            style: AppTextStyle.body.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s2),
        const Center(child: CucaAuthMascot(pose: CucaAuthPose.wave, height: 120)),
        const SizedBox(height: AppSpacing.s3),
        Text(
          'Chọn khách hàng để nhập',
          style: AppTextStyle.title3,
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Đã chọn: ${_selectedIndexes.length}',
          style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s3),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s2),
              itemCount: _mockContacts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contact = _mockContacts[index];
                final selected = _selectedIndexes.contains(index);

                return CheckboxListTile(
                  value: selected,
                  onChanged: _isLoading
                      ? null
                      : (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIndexes.add(index);
                            } else {
                              _selectedIndexes.remove(index);
                            }
                          });
                        },
                  title: Text(
                    contact['name'] ?? '',
                    style: AppTextStyle.bodyStrong,
                  ),
                  subtitle: Text(
                    contact['phone'] ?? '',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: AppSpacing.s1,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.s3),
                  Text('Đang nhập danh bạ...'),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedIndexes.length == _mockContacts.length) {
                            _selectedIndexes.clear();
                          } else {
                            _selectedIndexes
                              ..clear()
                              ..addAll(List<int>.generate(_mockContacts.length, (i) => i));
                          }
                        });
                      },
                      child: Text(
                        _selectedIndexes.length == _mockContacts.length ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
                        style: AppTextStyle.bodyStrong.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedIndexes.isEmpty ? null : _importContacts,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        'Nhập (${_selectedIndexes.length})',
                        style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s2),
              TextButton(
                onPressed: _nextStep,
                child: Text(
                  'Bỏ qua, tôi sẽ thêm sau',
                  style: AppTextStyle.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
