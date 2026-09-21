import 'package:flutter/material.dart';

/// One complete set of colour tokens.
///
/// Two instances exist — [light] and [dark]. `NeoColors` reads whichever is
/// active, so screens keep referring to `NeoColors.logoTeal` and switch
/// automatically. Contrast ratios in the comments are measured against that
/// palette's own [base].
@immutable
class NeoPalette {
  const NeoPalette({
    required this.base,
    required this.surface,
    required this.surfaceRecessed,
    required this.shadowDark,
    required this.shadowLight,
    required this.logoTeal,
    required this.waveTeal,
    required this.waveInk,
    required this.flameGold,
    required this.goldInk,
    required this.charcoal,
    required this.dockColor,
    required this.onDock,
    required this.live,
    required this.liveInk,
    required this.alert,
    required this.alertFill,
    required this.coral,
    required this.coralInk,
    required this.violet,
    required this.violetInk,
    required this.headerStart,
    required this.headerEnd,
    required this.textMuted,
    required this.onCharcoal,
    required this.onGold,
    required this.isDark,
  });

  /// Page background.
  final Color base;

  /// Card fill. Equal to [base] in the neumorphic themes so the shadow pair
  /// alone sculpts a card; a separate, contrasting tone in the bold themes.
  final Color surface;

  /// Inset fill — score tracks, OTP boxes, chip rails.
  final Color surfaceRecessed;

  final Color shadowDark;
  final Color shadowLight;

  /// Primary ink. Named for the logo teal it is in light mode; in dark mode
  /// it becomes the light foreground, because every screen uses it as
  /// "the colour body text and headings are".
  final Color logoTeal;
  final Color waveTeal;
  final Color waveInk;
  final Color flameGold;
  final Color goldInk;

  /// Primary CTA fill.
  final Color charcoal;

  /// Bottom-nav dock fill. Split from [charcoal] because the bold themes use
  /// a bright brand colour for buttons, which would be far too loud for a
  /// persistent dock — the dock stays the calm anchor of the screen.
  final Color dockColor;
  final Color onDock;
  final Color live;
  final Color liveInk;
  final Color alert;
  final Color alertFill;
  final Color coral;
  final Color coralInk;
  final Color violet;
  final Color violetInk;
  final Color headerStart;
  final Color headerEnd;
  final Color textMuted;
  final Color onCharcoal;
  final Color onGold;
  final bool isDark;

  /// Warm paper-slate. Canvas and card surface share one tone so the
  /// neumorphic shadow pair alone sculpts every shape.
  static const NeoPalette light = NeoPalette(
    base: Color(0xFFEBEDF0),
    surface: Color(0xFFEBEDF0),
    surfaceRecessed: Color(0xFFEBEDF0),
    shadowDark: Color(0x99A3B1C6), // #A3B1C6 @ 60%
    shadowLight: Color(0xFFFFFFFF),
    logoTeal: Color(0xFF0A3641), // 11.07:1
    waveTeal: Color(0xFF1B8A99), // 3.48:1 — icons/UI only
    waveInk: Color(0xFF12707D), // 4.92:1
    flameGold: Color(0xFFD49B53), // 2.08:1 — fills only
    goldInk: Color(0xFF8A5A1E), // 5.03:1
    charcoal: Color(0xFF1A1D24),
    dockColor: Color(0xFF1A1D24),
    onDock: Color(0xFFF5F7F7),
    live: Color(0xFF10B981), // decorative dot
    liveInk: Color(0xFF0A7050), // 5.20:1
    alert: Color(0xFFBE2F38), // 4.90:1
    alertFill: Color(0xFFFF5964),
    coral: Color(0xFFE8705A),
    coralInk: Color(0xFFB03A28), // 5.14:1
    violet: Color(0xFF6C63C4),
    violetInk: Color(0xFF5B51B5), // 5.44:1
    headerStart: Color(0xFF0A3641),
    headerEnd: Color(0xFF12707D), // white on this end: 5.77:1
    textMuted: Color(0xFF55666D), // 5.10:1
    onCharcoal: Color(0xFFF5F7F7),
    onGold: Color(0xFF1A1D24), // 6.92:1 on gold
    isDark: false,
  );

  /// Dark slate — deliberately not black: neumorphism needs headroom above
  /// and below the base for the shadow pair to read as a bevel.
  static const NeoPalette dark = NeoPalette(
    base: Color(0xFF23262B),
    surface: Color(0xFF23262B),
    surfaceRecessed: Color(0xFF23262B),
    shadowDark: Color(0xE614161A),
    shadowLight: Color(0xFF313740),
    logoTeal: Color(0xFFE8EDEF), // 12.86:1 — primary ink
    waveTeal: Color(0xFF3FB6C6), // 6.30:1
    waveInk: Color(0xFF6FD3E0), // 8.72:1
    flameGold: Color(0xFFE0A85F), // 7.18:1
    goldInk: Color(0xFFE3B172), // 7.80:1
    charcoal: Color(0xFF15181D),
    dockColor: Color(0xFF15181D),
    onDock: Color(0xFFF5F7F7),
    live: Color(0xFF34D399),
    liveInk: Color(0xFF3DD9A0), // 8.41:1
    alert: Color(0xFFFF7A82), // 6.04:1
    alertFill: Color(0xFFFF5964),
    coral: Color(0xFFE8705A),
    coralInk: Color(0xFFF08E7A), // 6.40:1
    violet: Color(0xFF8F86E0),
    violetInk: Color(0xFFA79EF0), // 6.35:1
    headerStart: Color(0xFF0E4C58),
    headerEnd: Color(0xFF17798A), // white on this end: 5.07:1
    textMuted: Color(0xFF9AA7AE), // 6.15:1
    onCharcoal: Color(0xFFF5F7F7),
    onGold: Color(0xFF1A1D24), // 7.98:1 on gold
    isDark: true,
  );

  /// Theme 4 — "Bold & Solid". Saturated aqua canvas with chunky white cards
  /// and hard edge separation. Deliberately not neumorphic: [surface] differs
  /// from [base] and the shadow is a single dark drop rather than a bevel
  /// pair. Ratios below are measured on the white card fill.
  static const NeoPalette boldSolid = NeoPalette(
    base: Color(0xFF7AD8C8), // Aqua Mint canvas
    surface: Color(0xFFFFFFFF), // Crisp Milk card
    surfaceRecessed: Color(0xFFEAF7F4),
    shadowDark: Color(0x38072B33),
    shadowLight: Color(0xFFFFFFFF),
    logoTeal: Color(0xFF072B33), // Abyssal Navy — 14.97:1 (8.90:1 on canvas)
    waveTeal: Color(0xFF0B7285), // Ocean Teal — 5.59:1
    waveInk: Color(0xFF0B7285), // 5.59:1
    flameGold: Color(0xFFE89C38), // Marigold — fills only (2.27:1)
    goldInk: Color(0xFF8A5A1E), // 5.90:1
    charcoal: Color(0xFF0B7285), // Ocean Teal drives primary buttons
    dockColor: Color(0xFF072B33), // Abyssal Navy anchor
    onDock: Color(0xFFFFFFFF),
    live: Color(0xFF10B981),
    liveInk: Color(0xFF0A7050), // 6.09:1
    alert: Color(0xFFBE2F38), // 5.75:1
    alertFill: Color(0xFFFF5964),
    coral: Color(0xFFE8705A),
    coralInk: Color(0xFFB03A28), // 6.03:1
    violet: Color(0xFF6C63C4),
    violetInk: Color(0xFF5B51B5), // 6.38:1
    headerStart: Color(0xFF0B7285),
    headerEnd: Color(0xFF072B33),
    textMuted: Color(0xFF3F6068), // 6.81:1
    onCharcoal: Color(0xFFFFFFFF), // white on Ocean Teal — 5.59:1
    onGold: Color(0xFF072B33), // navy on Marigold — 6.59:1
    isDark: false,
  );

  /// Theme 5 — "Rich & Opaque". Deep petroleum canvas with solid petrol-slate
  /// cards, zero washed-out tinting. Ratios measured on the card fill.
  static const NeoPalette richOpaque = NeoPalette(
    base: Color(0xFF081E24), // Solid Petroleum canvas
    surface: Color(0xFF12333B), // Petrol Slate card
    surfaceRecessed: Color(0xFF0C2831),
    shadowDark: Color(0xCC03090C),
    shadowLight: Color(0xFF1B4551),
    logoTeal: Color(0xFFFFFFFF), // Pure White ink — 13.44:1
    waveTeal: Color(0xFF00B4D8), // Electric Teal — 5.45:1
    waveInk: Color(0xFF00B4D8), // 5.45:1
    flameGold: Color(0xFFF5A524), // Bright Topaz — 6.59:1
    goldInk: Color(0xFFF5A524), // 6.59:1
    charcoal: Color(0xFF00B4D8), // Electric Teal drives action buttons
    dockColor: Color(0xFF12333B), // Petrol Slate anchor
    onDock: Color(0xFFFFFFFF),
    live: Color(0xFF00E5A0),
    liveInk: Color(0xFF00E5A0), // 8.14:1
    alert: Color(0xFFFF6B74), // 4.87:1
    alertFill: Color(0xFFFF5964),
    coral: Color(0xFFE8705A),
    coralInk: Color(0xFFF08E7A), // 5.67:1
    violet: Color(0xFF8F86E0),
    violetInk: Color(0xFFA79EF0), // 5.63:1
    headerStart: Color(0xFF0B4653),
    headerEnd: Color(0xFF00B4D8),
    textMuted: Color(0xFF9FB8C0), // 6.46:1
    onCharcoal: Color(0xFF052028), // dark on Electric Teal — 6.85:1
    onGold: Color(0xFF072B33), // navy on Topaz — 7.34:1
    isDark: true,
  );

  /// Theme 6 — "Midnight Orchid". A moody obsidian-violet canvas with
  /// electric cyan and hot-pink accents: the one theme that is unapologetically
  /// night-time. Ratios measured on the card fill.
  static const NeoPalette midnightOrchid = NeoPalette(
    base: Color(0xFF12101E), // obsidian violet canvas
    surface: Color(0xFF1E1A31), // violet slate card
    surfaceRecessed: Color(0xFF171429),
    shadowDark: Color(0xCC07060F),
    shadowLight: Color(0xFF2C2647),
    logoTeal: Color(0xFFF3EFFF), // primary ink — 14.91:1
    waveTeal: Color(0xFF7CE7FF), // electric cyan — 11.81:1
    waveInk: Color(0xFF7CE7FF), // 11.81:1
    flameGold: Color(0xFFFF5CA8), // hot pink badge fill — 5.89:1
    goldInk: Color(0xFFFF5CA8), // 5.89:1
    charcoal: Color(0xFF7C3AED), // violet CTA — white on it 5.70:1
    dockColor: Color(0xFF0B0916), // near-black anchor
    onDock: Color(0xFFF3EFFF),
    live: Color(0xFF3DF5B0),
    liveInk: Color(0xFF3DF5B0), // 11.93:1
    alert: Color(0xFFFF6B8A), // 6.19:1
    alertFill: Color(0xFFFF4D7D),
    coral: Color(0xFFFF8A6B),
    coralInk: Color(0xFFFFA98F), // 9.08:1
    violet: Color(0xFFB57BFF),
    violetInk: Color(0xFFC9A6FF), // 8.32:1
    headerStart: Color(0xFF3A1D6E),
    headerEnd: Color(0xFF9D3BA8), // white on this end: 5.79:1
    textMuted: Color(0xFFA79BC4), // 6.52:1
    onCharcoal: Color(0xFFFFFFFF),
    onGold: Color(0xFF1A0E19), // 6.56:1 on hot pink
    isDark: true,
  );
}
