import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_style.dart';

/// Fluent 2 Design System Theme
/// Reference: https://fluent2.microsoft.design/
class AppTheme {
  // ===========================
  // Light Theme
  // ===========================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.infoBg,
        onPrimaryContainer: AppColors.infoText,
        secondary: AppColors.stageWarm,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.warningBg,
        onSecondaryContainer: AppColors.warningText,
        error: AppColors.dangerText,
        onError: AppColors.white,
        errorContainer: AppColors.dangerBg,
        onErrorContainer: AppColors.dangerText,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
        outlineVariant: AppColors.grey10,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyle.headline,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r8Border,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      ),

      // Elevated Button (Primary Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s5, // 20
            vertical: AppSpacing.s4, // 16
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r6Border,
          ),
          textStyle: AppTextStyle.bodyStrong,
        ),
      ),

      // Outlined Button (Secondary Button)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s5,
            vertical: AppSpacing.s4,
          ),
          side: const BorderSide(
            color: AppColors.grey10,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r6Border,
          ),
          textStyle: AppTextStyle.bodyStrong,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s2,
          ),
          textStyle: AppTextStyle.bodyStrong,
        ),
      ),

      // Input Field
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s4,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: AppColors.grey10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: AppColors.grey10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: AppColors.dangerText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: AppColors.dangerText, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: BorderSide.none,
        ),
        labelStyle: AppTextStyle.caption,
        hintStyle: AppTextStyle.body.copyWith(
          color: AppColors.textHint,
        ),
        errorStyle: AppTextStyle.subtext.copyWith(
          color: AppColors.dangerText,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSubtle,
        disabledColor: AppColors.grey12,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s1,
        ),
        labelStyle: AppTextStyle.caption,
        secondaryLabelStyle: AppTextStyle.caption,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r4Border,
        ),
        side: BorderSide.none,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 6,
        shape: const CircleBorder(),
        extendedTextStyle: AppTextStyle.bodyStrong,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyle.subtextStrong,
        unselectedLabelStyle: AppTextStyle.subtext,
        type: BottomNavigationBarType.fixed,
        elevation: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        titleTextStyle: AppTextStyle.body,
        subtitleTextStyle: AppTextStyle.caption,
        leadingAndTrailingTextStyle: AppTextStyle.caption,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r8Border,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 20,
      ),

      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r12Border,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.r12),
          ),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey1,
        contentTextStyle: AppTextStyle.body.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r8Border,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===========================
  // Dark Theme
  // ===========================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: const Color(0xFF004275),
        onPrimaryContainer: const Color(0xFFD0E4FF),
        secondary: AppColors.stageWarm,
        onSecondary: AppColors.white,
        error: const Color(0xFFFF99A4),
        onError: const Color(0xFF68000F),
        background: const Color(0xFF202020),
        onBackground: const Color(0xFFEDEDEB),
        surface: const Color(0xFF2B2B2B),
        onSurface: const Color(0xFFEDEDEB),
        outline: const Color(0xFF4F4F4F),
        outlineVariant: const Color(0xFF2B2B2B),
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF202020),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFF2B2B2B),
        foregroundColor: const Color(0xFFEDEDEB),
        titleTextStyle: AppTextStyle.headline.copyWith(
          color: const Color(0xFFEDEDEB),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFEDEDEB),
          size: 24,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF2B2B2B),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r8Border,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: const Color(0xFF3A3A3A),
          disabledForegroundColor: const Color(0xFF757575),
          elevation: 0,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s5,
            vertical: AppSpacing.s4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r6Border,
          ),
          textStyle: AppTextStyle.bodyStrong,
        ),
      ),

      // Input Field
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s4,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: Color(0xFF4F4F4F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: Color(0xFF4F4F4F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.r6Border,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: AppTextStyle.caption.copyWith(
          color: const Color(0xFF999999),
        ),
        hintStyle: AppTextStyle.body.copyWith(
          color: const Color(0xFF757575),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF2B2B2B),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF999999),
        selectedLabelStyle: AppTextStyle.subtextStrong,
        unselectedLabelStyle: AppTextStyle.subtext,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
