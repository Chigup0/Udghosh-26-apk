import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:udghosh/theme/neo_palette.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Udghosh app.
///
/// True neomorphism needs the canvas and the card surface to be the *same*
/// base tone so the shadow pair alone sculpts the shape — hence a single
/// warm paper-slate [base] rather than a tinted canvas behind white cards.
/// Depth and light-source maths are handled by `flutter_neumorphic_plus`;
/// this file only owns colour, radius and type.
///
/// Every colour that carries text is contrast-checked against [base]:
/// values noted below are WCAG ratios on `#EBEDF0`.
/// Colour tokens, resolved from the currently active [NeoPalette].
///
/// These are getters rather than constants so a theme switch re-reads them —
/// which is why call sites cannot wrap them in `const`.
class NeoColors {
  NeoColors._();

  /// The active palette. Swapped by the root widget before the tree rebuilds;
  /// nothing else should write to it.
  static NeoPalette palette = NeoPalette.light;

  static bool get isDark => palette.isDark;

  // Canvas + surfaces (identical by design — depth does the separating)
  static Color get base => palette.base;
  static Color get canvasMint => palette.base; // legacy alias
  static Color get surface => palette.surface;
  static Color get surfaceRecessed => palette.surfaceRecessed;

  // Shadow tones
  static Color get shadowDark => palette.shadowDark;
  static Color get shadowLight => palette.shadowLight;

  // Brand
  static Color get logoTeal => palette.logoTeal;
  static Color get waveTeal => palette.waveTeal;
  static Color get waveInk => palette.waveInk;
  static Color get flameGold => palette.flameGold;
  static Color get charcoal => palette.charcoal;

  // Status
  static Color get live => palette.live;
  static Color get liveInk => palette.liveInk;
  static Color get alert => palette.alert;
  static Color get alertFill => palette.alertFill;

  // Accent tints — each "ink" clears 4.5:1 on its palette's base
  static Color get goldInk => palette.goldInk;
  static Color get coral => palette.coral;
  static Color get coralInk => palette.coralInk;
  static Color get violet => palette.violet;
  static Color get violetInk => palette.violetInk;

  // Header gradient
  static Color get headerStart => palette.headerStart;
  static Color get headerEnd => palette.headerEnd;

  // Text
  static Color get textPrimary => palette.logoTeal;
  static Color get textMuted => palette.textMuted;
  static Color get onCharcoal => palette.onCharcoal;
  static Color get dockColor => palette.dockColor;
  static Color get onDock => palette.onDock;
  static Color get onGold => palette.onGold;
}

/// Depth presets, so every surface in the app extrudes by the same amount
/// instead of each screen inventing its own number.
class NeoDepth {
  NeoDepth._();

  static const double card = 5;
  static const double chip = 3;
  static const double button = 4;
  static const double pressed = -2;
  static const double inset = -3;

  static const double intensity = 0.85;
}

/// Legacy dual-shadow presets. Only the charcoal nav dock still uses these —
/// it is deliberately *not* neomorphic (it is the one opaque anchor element).
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
      color: Colors.black.withValues(alpha: 0.22),
      offset: const Offset(0, 8),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> none = [];
}

/// Corner radii used across the app.
class NeoRadii {
  NeoRadii._();
  static const double card = 20;
  static const double cardLarge = 24;
  static const double pill = 999;
  static const double chip = 12;
  static const double dock = 32;
}

class NeoTheme {
  NeoTheme._();

  /// Root neumorphic theme — owns the light-source vector every surface
  /// bevels against.
  static NeumorphicThemeData get neumorphic => NeumorphicThemeData(
    baseColor: NeoColors.base,
    accentColor: NeoColors.logoTeal,
    variantColor: NeoColors.waveTeal,
    shadowDarkColor: NeoColors.shadowDark,
    shadowLightColor: NeoColors.shadowLight,
    shadowDarkColorEmboss: NeoColors.shadowDark,
    shadowLightColorEmboss: NeoColors.shadowLight,
    defaultTextColor: NeoColors.logoTeal,
    lightSource: LightSource.topLeft,
    depth: NeoDepth.button,
    intensity: NeoDepth.intensity,
  );

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
    final base = NeoColors.isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: NeoColors.base,
      colorScheme: base.colorScheme.copyWith(
        primary: NeoColors.logoTeal,
        secondary: NeoColors.flameGold,
        surface: NeoColors.base,
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
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: NeoColors.waveTeal,
      ),
    );
  }

  // ------------------------------------------------------------------
  // Style helpers — one place to ask for "raised" / "pressed" geometry.
  // ------------------------------------------------------------------

  static NeumorphicStyle raisedStyle({
    double radius = NeoRadii.card,
    double depth = NeoDepth.card,
    Color? color,
  }) => NeumorphicStyle(
    depth: depth,
    intensity: NeoDepth.intensity,
    color: color ?? NeoColors.surface,
    lightSource: LightSource.topLeft,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  static NeumorphicStyle insetStyle({
    double radius = NeoRadii.chip,
    double depth = NeoDepth.inset,
    Color? color,
  }) => NeumorphicStyle(
    depth: depth,
    intensity: NeoDepth.intensity,
    color: color ?? NeoColors.surfaceRecessed,
    lightSource: LightSource.topLeft,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
  );

  static NeumorphicStyle circleStyle({double depth = NeoDepth.chip}) =>
      NeumorphicStyle(
        color: NeoColors.surface,
        depth: depth,
        intensity: NeoDepth.intensity,
        lightSource: LightSource.topLeft,
        boxShape: const NeumorphicBoxShape.circle(),
      );

  // ------------------------------------------------------------------
  // Legacy BoxDecoration helpers (nav dock + any remaining raw containers)
  // ------------------------------------------------------------------

  static BoxDecoration raised({
    double radius = NeoRadii.card,
    Color? color,
    Border? border,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: NeoShadows.raised(),
    border: border,
  );

  static BoxDecoration raisedSmall({
    double radius = NeoRadii.chip,
    Color? color,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: NeoShadows.raisedSmall(),
  );

  static BoxDecoration inset({
    double radius = NeoRadii.chip,
    Color? color,
    bool active = false,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: active
          ? NeoColors.waveTeal.withValues(alpha: 0.5)
          : NeoColors.logoTeal.withValues(alpha: 0.06),
      width: active ? 1.5 : 1,
    ),
  );

  static BoxDecoration dock() => BoxDecoration(
    color: NeoColors.dockColor,
    borderRadius: BorderRadius.circular(NeoRadii.dock),
    boxShadow: NeoShadows.floatingDock(),
  );
}
