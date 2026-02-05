import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';

/// App footer showing version, build time, and copyright
/// Only visible on Web platform
class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  String _version = '0.4.0'; // Default version from pubspec.yaml
  String _buildDate = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    if (!kIsWeb) return;

    try {
      final info = await PackageInfo.fromPlatform();
      final buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: '');
      final buildTime = String.fromEnvironment('BUILD_TIME', defaultValue: '');

      if (mounted) {
        setState(() {
          _version = info.version;
          _buildDate = buildTime.isNotEmpty ? '$buildDate $buildTime' : buildDate;
        });
      }
    } catch (_) {
      // Keep default version if package_info fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show footer on web
    if (!kIsWeb) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.grey10, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Phiên bản $_version${_buildDate.isNotEmpty ? ' • $_buildDate' : ''}',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            '© 2026 by kientaoso.com',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
