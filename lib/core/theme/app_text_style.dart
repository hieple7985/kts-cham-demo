import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Fluent 2 Design System Typography Scale
/// Reference: https://fluent2.microsoft.design/
class AppTextStyle {
  // ===========================
  // Fluent 2 Typography Styles
  // ===========================

  /// Display - 40px, Semibold - Hero headings
  static const TextStyle display = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 48 / 40, // 1.2 line height
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Title 1 - 32px, Semibold - Page titles
  static const TextStyle title1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32, // 1.25
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Title 2 - 28px, Semibold - Large section titles
  static const TextStyle title2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28, // 1.29
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Title 3 - 22px, Semibold - Section titles
  static const TextStyle title3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22, // 1.27
    color: AppColors.textPrimary,
  );

  /// Headline - 20px, Semibold - Card titles
  static const TextStyle headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20, // 1.4
    color: AppColors.textPrimary,
  );

  /// Body Large - 18px, Regular - Emphasized body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 26 / 18, // 1.44
    color: AppColors.textPrimary,
  );

  /// Body Strong - 16px, Semibold - Strong body
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16, // 1.375
    color: AppColors.textPrimary,
  );

  /// Body - 16px, Regular - Default body text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16, // 1.375
    color: AppColors.textPrimary,
  );

  /// Caption - 14px, Regular - Secondary text
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14, // 1.43
    color: AppColors.textSecondary,
  );

  /// Caption Strong - 14px, Semibold - Emphasized secondary
  static const TextStyle captionStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14, // 1.43
    color: AppColors.textPrimary,
  );

  /// Subtext - 12px, Regular - Helper text
  static const TextStyle subtext = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12, // 1.33
    color: AppColors.textSecondary,
  );

  /// Subtext Strong - 12px, Semibold - Emphasized helper
  static const TextStyle subtextStrong = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12, // 1.33
    color: AppColors.textPrimary,
  );

  // ===========================
  // Semantic Text Styles
  // ===========================

  /// Primary text (headers, important content)
  static const TextStyle primary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Secondary text (supporting content)
  static const TextStyle secondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Disabled text
  static const TextStyle disabled = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDisabled,
  );

  /// On-brand text (white text on colored backgrounds)
  static const TextStyle onBrand = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnBrand,
  );

  // ===========================
  // Helper Methods
  // ===========================

  /// Copy style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Copy style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Copy style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

/// TextTheme extension for Fluent 2
extension AppTextThemeExtension on TextTheme {
  TextStyle get displayLarge => AppTextStyle.display;
  TextStyle get displayMedium => AppTextStyle.title1;
  TextStyle get displaySmall => AppTextStyle.title2;
  TextStyle get headlineLarge => AppTextStyle.headline;
  TextStyle get headlineMedium => AppTextStyle.title3;
  TextStyle get titleLarge => AppTextStyle.bodyLarge;
  TextStyle get titleMedium => AppTextStyle.bodyStrong;
  TextStyle get titleSmall => AppTextStyle.body;
  TextStyle get bodyLarge => AppTextStyle.body;
  TextStyle get bodyMedium => AppTextStyle.caption;
  TextStyle get bodySmall => AppTextStyle.subtext;
  TextStyle get labelLarge => AppTextStyle.captionStrong;
  TextStyle get labelMedium => AppTextStyle.subtextStrong;
}
