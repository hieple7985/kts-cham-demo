import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_footer.dart';
import 'login_email_screen.dart';
import 'signup_email_screen.dart';

/// Welcome Screen for Web version
/// Focus: Email + Google login only
/// Phone/OTP auth moved to Android milestone (see issues #153-156)
class WelcomeScreen extends StatelessWidget {
  final String? errorMessage;

  const WelcomeScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            children: [
              // Error Banner
              if (errorMessage != null && errorMessage!.trim().isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s3),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    style: AppTextStyle.body.copyWith(color: AppColors.dangerText),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
              // Logo text
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'CUCA',
                  style: AppTextStyle.title1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Spacer(),

              // Mascot & Slogan
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mascot Image
                  SizedBox(
                    height: 280,
                    child: Image.asset(
                      AppAssets.cucaThumbsUp,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),

                  // Title
                  Text(
                    'CUCA - Trợ lý chăm khách',
                    style: AppTextStyle.title2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s3),

                  // Subtitle
                  Text(
                    'Giúp bạn không bỏ quên khách hàng quan trọng,\nnhắc chăm đúng lúc, đúng người.',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Spacer(),

              // Buttons - Web version: Email + Google login only
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginEmailScreen()),
                        );
                      },
                      child: Text(
                        'Đăng nhập bằng Email',
                        style: AppTextStyle.bodyStrong.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),

                  // Google Login Button (placeholder for future implementation)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement Google OAuth login
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đăng nhập bằng Google đang được phát triển'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login, size: 20),
                      label: Text(
                        'Đăng nhập bằng Google',
                        style: AppTextStyle.bodyStrong.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: AppTextStyle.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupEmailScreen()),
                          );
                        },
                        child: Text(
                          'Đăng ký ngay',
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Phone auth note - moved to Android
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    'Đăng nhập bằng SĐT đang phát triển cho phiên bản Android',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              // App footer (Web only)
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
