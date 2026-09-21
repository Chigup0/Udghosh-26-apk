import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// One destination in the glass bar.
class GlassNavItem {
  const GlassNavItem(this.icon, this.label);
  final List<List<dynamic>> icon;
  final String label;
}

/// Bottom bar built on `liquid_glass_widgets`' [GlassTabBar].
///
/// The package renders real Apple-style liquid glass through a fragment
/// shader — refraction, specular highlight, chromatic aberration and a
/// selection indicator that stretches between tabs — rather than the plain
/// `BackdropFilter` blur this used to be.
///
/// Two things it needs from the shell, both already in place: the body must
/// run edge to edge underneath it (`extendBody: true`) so there is something
/// to refract, and screens end with a `NavSpacer` so content clears it.
///
/// Colours are driven from [NeoColors], so the bar re-tints with all six
/// themes instead of being locked to one look.
class LiquidGlassNav extends StatelessWidget {
  const LiquidGlassNav({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GlassTabBar.bottom(
      selectedIndex: index,
      onTabSelected: (i) {
        HapticFeedback.lightImpact();
        onTap(i);
      },
      tabs: [
        for (final item in items)
          GlassTab(
            icon: HugeIcon(icon: item.icon, size: 22, strokeWidth: 1.8),
            activeIcon: HugeIcon(icon: item.icon, size: 22, strokeWidth: 2.4),
            label: item.label,
            semanticLabel: item.label,
            glowColor: NeoColors.flameGold,
          ),
      ],
      // Gold selection pill with charcoal glyphs — the same pairing the
      // classic dock uses, so switching styles does not restyle the brand.
      indicatorColor: NeoColors.flameGold,
      selectedIconColor: NeoColors.onGold,
      selectedLabelColor: NeoColors.onGold,
      unselectedIconColor: NeoColors.logoTeal.withValues(alpha: 0.62),
      unselectedLabelColor: NeoColors.textMuted,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      // Clearer glass than the package default: a thinner body, less blur and
      // a barely-there tint, so the map and cards underneath stay readable
      // through the bar instead of being milked out.
      settings: LiquidGlassSettings(
        glassColor: NeoColors.isDark
            ? const Color(0x1AFFFFFF)
            : const Color(0x26FFFFFF),
        thickness: 13,
        blur: 3,
        // Default 1.0 fully applies the tint alpha; the package notes ~0.4 as
        // the light-mode figure for parity with the premium 3D path.
        standardOpacityMultiplier: 0.45,
        whitenStrength: NeoColors.isDark ? 0.0 : 0.06,
        lightIntensity: 0.55,
        chromaticAberration: 0.012,
      ),
      iconSize: 22,
      labelFontSize: 10,
      barHeight: 62,
      horizontalPadding: 16,
      verticalPadding: 12,
      // Softer than the package default: a 1.15 pop on a five-tab bar reads
      // as a jolt at this width.
      magnification: 1.08,
      pressScale: 1.03,
    );
  }
}
