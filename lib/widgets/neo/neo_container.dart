import 'package:flutter/material.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// A pillowy, raised neomorphic surface. This is the base building block
/// for every card in the app — wrap content in it instead of hand-rolling
/// `BoxDecoration`s so the shadow pair stays consistent everywhere.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.radius = NeoRadii.card,
    this.color = NeoColors.surface,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.small = false,
  });

  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: small
          ? NeoTheme.raisedSmall(radius: radius, color: color)
          : NeoTheme.raised(radius: radius, color: color),
      child: child,
    );

    if (onTap == null) return content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// A recessed/pushed-in surface — used for score tracks, OTP digit boxes,
/// segmented-control rails and search fields.
class NeoInset extends StatelessWidget {
  const NeoInset({
    super.key,
    required this.child,
    this.radius = NeoRadii.chip,
    this.color = NeoColors.surfaceRecessed,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.active = false,
  });

  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsetsGeometry padding;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: NeoTheme.inset(radius: radius, color: color, active: active),
      child: child,
    );
  }
}

/// Circular neomorphic icon/avatar button (44x44 by the spec) used for the
/// notification bell and profile avatar in the app bar.
class NeoCircleButton extends StatelessWidget {
  const NeoCircleButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 44,
    this.badge = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Ink(
                  decoration: BoxDecoration(
                    color: NeoColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: NeoShadows.raisedSmall(),
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
          if (badge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: NeoColors.alert,
                  shape: BoxShape.circle,
                  border: Border.all(color: NeoColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A chunky pill button — used for CTAs like "SEND OTP" and "LOGOUT".
class NeoPillButton extends StatelessWidget {
  const NeoPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.foreground = NeoColors.onCharcoal,
    this.background = NeoColors.charcoal,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Color foreground;
  final Color background;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(NeoRadii.pill),
        boxShadow: NeoShadows.raisedSmall(),
      ),
      child: loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(foreground),
              ),
            )
          : Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(NeoRadii.pill),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: loading ? null : onTap, child: child),
      ),
    );
  }
}

/// Small status pill, e.g. "● LIVE (Q3 08:42)" or "FINAL".
class StatusCapsule extends StatelessWidget {
  const StatusCapsule({
    super.key,
    required this.label,
    this.color = NeoColors.live,
    this.dot = true,
  });

  final String label;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(NeoRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
