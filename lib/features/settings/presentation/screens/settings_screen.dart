import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/presentation/widgets/cuca_mascot.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../models/settings_state.dart';
import '../providers/settings_provider.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String _formatTimeOfDay(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _syncRemoteSettings(WidgetRef ref, SettingsState state) async {
    if (!AppConfig.useSupabaseAuth) return;

    final session = SupabaseConfig.client.auth.currentSession;
    final token = session?.accessToken;
    if (token == null || token.isEmpty) return;

    final client = ref.read(nodeApiClientProvider);

    final dndStart = state.quietHours.enabled ? _formatTimeOfDay(state.quietHours.start) : '21:00';
    final dndEnd = state.quietHours.enabled ? _formatTimeOfDay(state.quietHours.end) : '08:00';

    await client.updateMySettings(
      accessToken: token,
      notificationPreferences: {
        'push_enabled': state.notifyCare,
        'email_enabled': state.notifyDailySummary,
        'dnd_start': dndStart,
        'dnd_end': dndEnd,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);

    // Get profile data from auth provider (real data, not mock)
    final user = authState.user;
    final profileFullName = user?['full_name'] as String? ?? state.profile.fullName;
    final profileEmail = user?['email'] as String? ?? state.profile.email;
    final profilePhone = (user?['phone_number'] as String? ?? user?['phone'] as String?) ??
        state.profile.phone;
    final profileInitial = profileFullName.isNotEmpty ? profileFullName[0] : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cài đặt', style: AppTextStyle.headline),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Profile Summary
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              color: AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        profileInitial,
                        style: AppTextStyle.headline.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profileFullName, style: AppTextStyle.bodyStrong),
                        const SizedBox(height: AppSpacing.s1),
                        Text(profileEmail, style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.s1),
                        Text(profilePhone, style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.grey7),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          
          // Notification Section
          _buildSectionHeader('Thông báo'),
          _buildSwitchTile(
            context,
            title: 'Nhắc nhở chăm sóc khách',
            value: state.notifyCare,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).setNotifyCare(v);
              unawaited(_syncRemoteSettings(ref, ref.read(settingsProvider)));
            },
          ),
          _buildSwitchTile(
            context,
            title: 'Tổng kết ngày',
            value: state.notifyDailySummary,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).setNotifyDailySummary(v);
              unawaited(_syncRemoteSettings(ref, ref.read(settingsProvider)));
            },
          ),
          _buildSwitchTile(
            context,
            title: 'Gợi ý từ AI',
            value: state.notifyAiSuggestions,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).setNotifyAiSuggestions(v);
              // Backend UserSettings currently does not support per-type AI toggle; keep local-only for now.
            },
          ),
          ListTile(
            leading: const Icon(Icons.bedtime_outlined),
            title: const Text('Không làm phiền'),
            subtitle: Text(state.quietHours.enabled
                ? '${state.quietHours.start.format(context)} – ${state.quietHours.end.format(context)}'
                : 'Tắt'),
            trailing: Switch(
              value: state.quietHours.enabled,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setQuietEnabled(v);
                unawaited(_syncRemoteSettings(ref, ref.read(settingsProvider)));
              },
            ),
            onTap: () async {
              if (!state.quietHours.enabled) return;
              final start = await showTimePicker(context: context, initialTime: state.quietHours.start);
              if (!context.mounted) return;
              if (start != null) {
                ref.read(settingsProvider.notifier).setQuietStart(start);
              }
              final end = await showTimePicker(context: context, initialTime: state.quietHours.end);
              if (!context.mounted) return;
              if (end != null) {
                ref.read(settingsProvider.notifier).setQuietEnd(end);
              }
              unawaited(_syncRemoteSettings(ref, ref.read(settingsProvider)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Gửi thử thông báo'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã gửi thử thông báo.')),
              );
            },
          ),
          const Divider(),
          
          // Account Section
          _buildSectionHeader('Tài khoản & Bảo mật'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Gói sử dụng'),
            subtitle: Text('${state.subscription.planName} • còn ${state.subscription.daysLeft} ngày'),
            trailing: Text('Nâng cấp', style: AppTextStyle.bodyStrong.copyWith(color: AppColors.primary)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng nâng cấp sẽ có trong phiên bản sau.')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Row(
              children: [
                const CucaMascot(pose: CucaPose.hint, height: 40, width: 40, animate: false),
                const SizedBox(width: AppSpacing.s2),
                Expanded(child: Text('Gói Free hiện tại đáp ứng đầy đủ tính năng.', style: AppTextStyle.caption)),
              ],
            ),
          ),
          const Divider(),
          
          // Support
          _buildSectionHeader('Hỗ trợ'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Về CUCA'),
            trailing: Text('v1.0.0', style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Điều khoản sử dụng'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển.')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Chính sách bảo mật'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển.')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Liên hệ hỗ trợ'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển.')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            subtitle: Text(state.language == 'vi' ? 'Tiếng Việt' : state.language),
            onTap: () => _showLanguageSheet(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Múi giờ'),
            subtitle: Text(state.timezone),
            onTap: () => _showTimezoneSheet(context, ref),
          ),
          const SizedBox(height: 24),
          
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: OutlinedButton(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.dangerText),
                foregroundColor: AppColors.dangerText,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Đăng xuất', style: AppTextStyle.bodyStrong),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s4, AppSpacing.s3, AppSpacing.s4, 0),
            child: TextButton(
              onPressed: () => _requestDeleteAccount(context),
              child: Text('Yêu cầu xóa tài khoản', style: AppTextStyle.body.copyWith(color: AppColors.dangerText)),
            ),
          ),
          
          const SizedBox(height: 24),
          Center(
            child: Image.asset(
              AppAssets.cucaHeadset,
              height: 80,
              color: AppColors.grey7.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s4, AppSpacing.s2, AppSpacing.s4, AppSpacing.s2),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyle.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: AppTextStyle.body),
      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      activeThumbColor: AppColors.primary,
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đăng xuất', style: AppTextStyle.headline),
        content: Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?', style: AppTextStyle.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: AppTextStyle.body)),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: Text('Đăng xuất', style: AppTextStyle.bodyStrong.copyWith(color: AppColors.dangerText)),
          ),
        ],
      ),
    );
  }

  void _requestDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yêu cầu xóa tài khoản', style: AppTextStyle.headline),
        content: Text('Yêu cầu xóa tài khoản sẽ được xử lý trong vòng 30 ngày.', style: AppTextStyle.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: AppTextStyle.body)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu xóa tài khoản.')));
            },
            child: Text('Gửi', style: AppTextStyle.bodyStrong.copyWith(color: AppColors.dangerText)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Tiếng Việt', style: AppTextStyle.body),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('vi');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('English', style: AppTextStyle.body),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneSheet(BuildContext context, WidgetRef ref) {
    const zones = ['Asia/Ho_Chi_Minh', 'Asia/Bangkok', 'Asia/Singapore'];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final z in zones)
              ListTile(
                title: Text(z, style: AppTextStyle.body),
                onTap: () {
                  ref.read(settingsProvider.notifier).setTimezone(z);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
