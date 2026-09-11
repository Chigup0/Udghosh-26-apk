import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Soft-Neomorphism / Claymorphism design tokens for the Udghosh app.
///
/// Palette is built around the teal-and-gold Udghosh mark: a warm mint
/// canvas, pillowy white cards with a dual light/dark shadow pair, and a
/// dark charcoal floating pill for navigation. No gradients, no emoji.
class NeoColors {
  NeoColors._();

  // Canvas
  static const Color canvasMint = Color(0xFFDDF4EE);
  static const Color canvasCoral = Color(0xFFFFEFE8);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRecessed = Color(0xFFF0F6F5);

  // Brand accents
  static const Color logoTeal = Color(0xFF0E4B54);
  static const Color waveTeal = Color(0xFF1C91A3);
  static const Color flameGold = Color(0xFFE5B26E);
  static const Color charcoal = Color(0xFF1A1D24);

  // Status
  static const Color live = Color(0xFF10B981);
  static const Color alert = Color(0xFFFF5964);

  // Text
  static const Color textPrimary = logoTeal;
  static const Color textMuted = Color(0xFF5C7C7D);
  static const Color onCharcoal = Color(0xFFF5F7F7);

  // Shadow tones (used with the exact offsets/blur the brand spec calls for)
  static const Color shadowLight = Colors.white;
  static const Color shadowDark = Color(0x180E4249);
}

/// Reusable dual-shadow presets so every card in the app extrudes the same
/// amount instead of each screen inventing its own numbers.
class NeoShadows {
  NeoShadows._();

  static List<BoxShadow> raised({double intensity = 1}) => [
    BoxShadow(
      color: NeoColors.shadowLight.withValues(alpha: 0.9),
      offset: const Offset(-5, -5),
      blurRadius: 10 * intensity,
    ),
    BoxShadow(
      color: NeoColors.shadowDark,
      offset: const Offset(5, 7),
      blurRadius: 16 * intensity,
    ),
  ];

  /// Softer, closer shadow for small tappable elements (pills, chips).
  static List<BoxShadow> raisedSmall() => [
    BoxShadow(
      color: NeoColors.shadowLight.withValues(alpha: 0.85),
      offset: const Offset(-3, -3),
      blurRadius: 6,
    ),
    BoxShadow(
      color: NeoColors.shadowDark,
      offset: const Offset(3, 4),
      blurRadius: 9,
    ),
  ];

  static List<BoxShadow> floatingDock() => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      offset: const Offset(0, 8),
      blurRadius: 20,
    ),
  ];

  /// No shadow list for a pressed/inset container — the "inset" look is
  /// produced by a darker fill + a thin inner-facing gradient border instead
  /// of an actual inset shadow (Flutter can't natively render true inset
  /// shadows without a shader), which reads correctly at these radii.
  static const List<BoxShadow> none = [];
}

/// Corner radii used across the neomorphic system.
class NeoRadii {
  NeoRadii._();
  static const double card = 24;
  static const double cardLarge = 28;
  static const double pill = 999;
  static const double chip = 18;
  static const double dock = 32;
}

class NeoTheme {
  NeoTheme._();

  static TextTheme _textTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: NeoColors.logoTeal,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: NeoColors.logoTeal,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: NeoColors.logoTeal,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NeoColors.textMuted,
      ),
    );
  }

  static ThemeData get themeData {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: NeoColors.canvasMint,
      colorScheme: base.colorScheme.copyWith(
        primary: NeoColors.waveTeal,
        secondary: NeoColors.flameGold,
        surface: NeoColors.surface,
        error: NeoColors.alert,
      ),
      textTheme: _textTheme(base.textTheme),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NeoColors.waveTeal,
      ),
    );
  }

  /// Raised, extruded surface: pure white pillowy card.
  static BoxDecoration raised({
    double radius = NeoRadii.card,
    Color color = NeoColors.surface,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: NeoShadows.raised(),
      border: border,
    );
  }

  static BoxDecoration raisedSmall({
    double radius = NeoRadii.chip,
    Color color = NeoColors.surface,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: NeoShadows.raisedSmall(),
    );
  }

  /// Recessed/pressed surface used for score tracks, chip rails and OTP
  /// boxes — a flat darker neutral with no outward shadow so it reads as
  /// "pushed into" the card behind it.
  static BoxDecoration inset({
    double radius = NeoRadii.chip,
    Color color = NeoColors.surfaceRecessed,
    bool active = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: active
            ? NeoColors.waveTeal.withValues(alpha: 0.5)
            : NeoColors.logoTeal.withValues(alpha: 0.06),
        width: active ? 1.5 : 1,
      ),
    );
  }

  static BoxDecoration dock() {
    return BoxDecoration(
      color: NeoColors.charcoal,
      borderRadius: BorderRadius.circular(NeoRadii.dock),
      boxShadow: NeoShadows.floatingDock(),
    );
  }
}
