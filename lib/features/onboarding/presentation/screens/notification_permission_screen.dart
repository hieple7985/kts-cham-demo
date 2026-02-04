import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/config/app_prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../home/presentation/screens/app_shell_screen.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    await AppPrefs.setDidOnboard(true);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AppShellScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 200,
                child: Image.asset(AppAssets.cucaHeadset, fit: BoxFit.contain),
              ),
              const SizedBox(height: AppSpacing.s6),

              Text(
                'Đừng bỏ lỡ lịch chăm sóc',
                style: AppTextStyle.title2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Cho phép CUCA gửi thông báo nhắc nhở bạn khi đến lịch hẹn hoặc có khách hàng cần quan tâm.',
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
                  onPressed: () => _finish(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    'Cho phép thông báo',
                    style: AppTextStyle.bodyStrong.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              TextButton(
                onPressed: () => _finish(context),
                child: Text(
                  'Để sau',
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
