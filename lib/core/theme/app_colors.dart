import 'package:flutter/material.dart';

/// Fluent 2 Design System Color Palette
/// Reference: https://fluent2.microsoft.design/
class AppColors {
  // ===========================
  // Brand Colors (Microsoft Blue)
  // ===========================
  static const Color primary = Color(0xFF0078D4); // Microsoft Blue
  static const Color primaryHover = Color(0xFF106EBE);
  static const Color primaryPressed = Color(0xFF005A9E);
  static const Color primaryDisabled = Color(0xFFF1F1F1);

  // ===========================
  // Neutral Colors (Gray Scale)
  // ===========================
  static const Color grey1 = Color(0xFF080708); // Near black
  static const Color grey2 = Color(0xFF201F1E);
  static const Color grey3 = Color(0xFF323130);
  static const Color grey4 = Color(0xFF484644);
  static const Color grey5 = Color(0xFF605E5C); // Secondary text
  static const Color grey6 = Color(0xFF797775);
  static const Color grey7 = Color(0xFF8A8886); // Disabled text
  static const Color grey8 = Color(0xFFA19F9D);
  static const Color grey9 = Color(0xFFBEBEBE);
  static const Color grey10 = Color(0xFFC8C6C4); // Border
  static const Color grey11 = Color(0xFFE1DFDD); // Divider
  static const Color grey12 = Color(0xFFF3F2F1); // Surface base
  static const Color grey13 = Color(0xFFFAF9F8); // Layer Alt (app bg)
  static const Color white = Color(0xFFFFFFFF);

  // ===========================
  // Background Colors
  // ===========================
  static const Color background = grey13; // App background
  static const Color surface = white; // Card/surface background
  static const Color surfaceSubtle = grey12;

  // ===========================
  // Text Colors
  // ===========================
  static const Color textPrimary = grey1;
  static const Color textSecondary = grey5;
  static const Color textDisabled = grey7;
  static const Color textOnBrand = white;
  static const Color textHint = grey7;

  // ===========================
  // Semantic Colors
  // ===========================
  // Danger (Error)
  static const Color dangerText = Color(0xFFA80000);
  static const Color dangerBg = Color(0xFFFDE7E9);
  static const Color dangerBgHover = Color(0xFFFADBD9);

  // Success
  static const Color successText = Color(0xFF107C10);
  static const Color successBg = Color(0xFFDFF6DD);

  // Warning
  static const Color warningText = Color(0xFF797775);
  static const Color warningBg = Color(0xFFFFF4CE);

  // Info
  static const Color infoText = Color(0xFF005A9E);
  static const Color infoBg = Color(0xFFF3F9FD);

  // ===========================
  // Customer Stage Colors
  // ===========================
  static const Color stageHot = Color(0xFFD13438); // Red
  static const Color stageWarm = Color(0xFFFFAA44); // Orange
  static const Color stageCold = Color(0xFF0078D4); // Blue
  static const Color stageWon = Color(0xFF107C10); // Green
  static const Color stageLost = grey7; // Grey

  // Stage backgrounds (20% opacity)
  static const Color stageHotBg = Color(0x33D13438); // 20% opacity
  static const Color stageWarmBg = Color(0x33FFAA44);
  static const Color stageColdBg = Color(0x330078D4);
  static const Color stageWonBg = Color(0x33107C10);

  // ===========================
  // Customer Type Colors
  // ===========================
  static const Color typeVIP = Color(0xFFFFB900); // Gold
  static const Color typeRegular = Color(0xFF0078D4); // Blue
  static const Color typePotential = Color(0xFF8764B8); // Purple

  // Type backgrounds (10% opacity)
  static const Color typeVIPBg = Color(0x1AFFB900); // 10% opacity
  static const Color typeRegularBg = Color(0x1A0078D4);
  static const Color typePotentialBg = Color(0x1A8764B8);

  // ===========================
  // UI Element Colors
  // ===========================
  static const Color divider = grey11; // Dividers, borders
  static const Color focusStroke = primary; // Focus ring
  static const Color overlay = Color(0x80000000); // 50% black overlay

  // ===========================
  // Legacy Aliases (for backward compatibility)
  // ===========================
  @Deprecated('Use primary instead')
  static const Color primaryDark = primaryPressed;

  @Deprecated('Use primary instead')
  static const Color primaryLight = Color(0xFF64B5F6);

  @Deprecated('Use stageWarm instead')
  static const Color secondary = stageWarm;

  @Deprecated('Use successText instead')
  static const Color success = successText;

  @Deprecated('Use dangerText instead')
  static const Color error = dangerText;

  @Deprecated('Use warningBg or warningText instead')
  static const Color warning = stageWarm;

  @Deprecated('Use primary instead')
  static const Color info = primary;

  @Deprecated('Use typeVIP instead')
  static const Color customerVIP = typeVIP;

  @Deprecated('Use typeRegular instead')
  static const Color customerRegular = typeRegular;

  @Deprecated('Use typePotential instead')
  static const Color customerPotential = typePotential;

  // Shimmer loading colors
  static const Color shimmerBase = grey12;
  static const Color shimmerHighlight = white;
}
