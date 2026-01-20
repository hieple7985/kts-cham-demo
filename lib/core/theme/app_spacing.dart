import 'package:flutter/widgets.dart';

/// Fluent 2 Design System Spacing Constants
/// Based on 4pt grid system
/// Reference: https://fluent2.microsoft.design/
class AppSpacing {
  // ===========================
  // 4pt Base Spacing Scale
  // ===========================
  static const double s0 = 0;
  static const double s1 = 4; // Ultra tight
  static const double s2 = 8; // Tight spacing
  static const double s3 = 12; // Compact
  static const double s4 = 16; // Standard spacing
  static const double s5 = 20; // Medium
  static const double s6 = 24; // Large
  static const double s7 = 28; // XL
  static const double s8 = 32; // XXL
  static const double s9 = 40; // Section spacing
  static const double s10 = 48; // Container spacing
  static const double s11 = 64; // Hero spacing
  static const double s12 = 80; // Page margins

  // Edge Insets shortcuts (not const due to EdgeInsets methods)
  static final EdgeInsets p0 = EdgeInsets.all(s0);
  static final EdgeInsets p1 = EdgeInsets.all(s1);
  static final EdgeInsets p2 = EdgeInsets.all(s2);
  static final EdgeInsets p3 = EdgeInsets.all(s3);
  static final EdgeInsets p4 = EdgeInsets.all(s4);
  static final EdgeInsets p6 = EdgeInsets.all(s6);

  // Horizontal padding
  static final EdgeInsets pH2 = EdgeInsets.symmetric(horizontal: s2);
  static final EdgeInsets pH3 = EdgeInsets.symmetric(horizontal: s3);
  static final EdgeInsets pH4 = EdgeInsets.symmetric(horizontal: s4);
  static final EdgeInsets pH6 = EdgeInsets.symmetric(horizontal: s6);

  // Vertical padding
  static final EdgeInsets pV2 = EdgeInsets.symmetric(vertical: s2);
  static final EdgeInsets pV3 = EdgeInsets.symmetric(vertical: s3);
  static final EdgeInsets pV4 = EdgeInsets.symmetric(vertical: s4);
  static final EdgeInsets pV6 = EdgeInsets.symmetric(vertical: s6);

  // Screen padding (standard)
  static final EdgeInsets screen = EdgeInsets.symmetric(horizontal: s4);
  static final EdgeInsets screenV = EdgeInsets.symmetric(vertical: s4);

  // Card padding
  static final EdgeInsets card = EdgeInsets.all(s4);

  // List item padding
  static final EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: s4,
    vertical: s3,
  );
}

/// Fluent 2 Design System Border Radius Constants
/// Reference: https://fluent2.microsoft.design/
class AppRadius {
  static const double r0 = 0;
  static const double r2 = 2; // Subtle dividers
  static const double r4 = 4; // Small elements
  static const double r6 = 6; // Inputs, small buttons
  static const double r8 = 8; // Standard buttons, cards
  static const double r12 = 12; // Large cards, panels
  static const double r16 = 16; // XL cards, modals
  static const double r20 = 20; // Pills
  static const double r28 = 28; // FAB

  // BorderRadius shortcuts
  static const BorderRadius r2Border = BorderRadius.all(Radius.circular(r2));
  static const BorderRadius r4Border = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius r6Border = BorderRadius.all(Radius.circular(r6));
  static const BorderRadius r8Border = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius r12Border = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius r16Border = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius r20Border = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius r28Border = BorderRadius.all(Radius.circular(r28));

  // Circle
  static final BorderRadius circle = BorderRadius.circular(500);

  // Common shapes
  static final ShapeBorder buttonShape = RoundedRectangleBorder(
    borderRadius: r6Border,
  );

  static final ShapeBorder cardShape = RoundedRectangleBorder(
    borderRadius: r8Border,
  );

  static final ShapeBorder inputShape = RoundedRectangleBorder(
    borderRadius: r6Border,
  );
}
