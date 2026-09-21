import 'package:flutter/material.dart';
import 'package:udghosh/config/nav_style_controller.dart';

/// How much room the bottom bar takes.
class NavMetrics {
  NavMetrics._();

  /// Height of the classic floating pill, including its own margins.
  static const double classicHeight = 78;

  /// Height the glass bar occupies: GlassTabBar.bottom's pill plus the
  /// vertical padding configured in [LiquidGlassNav] (62 + 12 top + 12 bottom).
  static const double glassHeight = 86;

  static double barHeight(NavStyle style) =>
      style == NavStyle.classic ? classicHeight : glassHeight;

  /// Space a scrollable must leave at its bottom so the last item clears the
  /// bar *and* the system gesture inset. Screens render this as [NavSpacer]
  /// rather than baking a magic number into their padding.
  static double gutter(BuildContext context) {
    final style = NavStyleController.instance.style;
    final systemInset = MediaQuery.viewPaddingOf(context).bottom;
    return barHeight(style) + systemInset + 14;
  }
}

/// Empty box appended as the last child of a scrollable, so content can be
/// scrolled clear of the bottom bar instead of ending underneath it.
///
/// The body now runs edge to edge behind the bar (which is what lets the glass
/// style actually have something to blur), so without this the final card would
/// sit permanently under the nav.
class NavSpacer extends StatelessWidget {
  const NavSpacer({super.key, this.extra = 0});

  /// Additional space on top of the measured gutter.
  final double extra;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NavStyleController.instance,
      builder: (context, _) =>
          SizedBox(height: NavMetrics.gutter(context) + extra),
    );
  }
}
