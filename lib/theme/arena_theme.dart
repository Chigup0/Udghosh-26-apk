import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the "Arcana Ascension" arena-pass visual system
/// (Udghosh '26, Edition XXII). Flat, dark, brutalist broadcast aesthetic —
/// no gradients, no emoji, hard 1px/1.5px borders, chamfered corners.
class ArenaColors {
  ArenaColors._();

  static const canvas = Color(0xFF0D0E12);
  static const surface = Color(0xFF16181F);
  static const surfaceRecessed = Color(0xFF0A0B0E);
  static const border = Color(0xFF2A2D3A);
  static const borderStrong = Color(0xFF3D4152);

  static const textPrimary = Color(0xFFF2F4F8);
  static const textSecondary = Color(0xFF7E8597);
  static const textDim = Color(0xFF4B5163);

  /// Momentum / active-indicator accent. Never used for brand chrome —
  /// reserved for "this side is currently ahead / serving" only.
  static const volt = Color(0xFFCCFF00);
  static const cyan = Color(0xFF00E5FF);

  /// The single LIVE signal color. Do not reuse elsewhere.
  static const live = Color(0xFFFF2E44);

  /// Sparingly used tier/medal accent for ascension-stage badges.
  static const tierGold = Color(0xFFE8B84B);
}

class ArenaSpace {
  ArenaSpace._();
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class ArenaText {
  ArenaText._();

  /// Ultra-condensed heavy display — screen titles, hero numerals.
  static TextStyle display({double size = 32, Color? color}) =>
      GoogleFonts.bebasNeue(
        fontSize: size,
        color: color ?? ArenaColors.textPrimary,
        letterSpacing: 0.4,
        height: 1.0,
      );

  /// Section headers / card sport tags.
  static TextStyle heading({double size = 15, Color? color}) =>
      GoogleFonts.bebasNeue(
        fontSize: size,
        color: color ?? ArenaColors.textPrimary,
        letterSpacing: 0.8,
        height: 1.1,
      );

  /// Uppercase micro-labels — eyebrows, badges, nav captions.
  static TextStyle label({
    double size = 10.5,
    Color? color,
    double? tracking,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    color: color ?? ArenaColors.textSecondary,
    fontWeight: FontWeight.w700,
    letterSpacing: tracking ?? 0.9,
    height: 1.2,
  );

  /// Body / team names / list rows.
  static TextStyle body({double size = 13, Color? color, FontWeight? weight}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        color: color ?? ArenaColors.textPrimary,
        fontWeight: weight ?? FontWeight.w600,
        height: 1.25,
      );

  /// Tabular numerals for scores, clocks, timestamps — never reflows.
  static TextStyle mono({double size = 15, Color? color, FontWeight? weight}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color ?? ArenaColors.textPrimary,
        fontWeight: weight ?? FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        height: 1.0,
      );
}

/// Converts a small stage/tier number into an uppercase roman numeral,
/// e.g. for `STAGE IV // QUARTER-FINAL` badges. Supports 1-49 (fest
/// round counts never exceed this).
String toRomanNumeral(int number) {
  const values = [40, 10, 9, 5, 4, 1];
  const symbols = ['XL', 'X', 'IX', 'V', 'IV', 'I'];
  var n = number;
  final out = StringBuffer();
  for (var i = 0; i < values.length; i++) {
    while (n >= values[i]) {
      out.write(symbols[i]);
      n -= values[i];
    }
  }
  return out.toString();
}
