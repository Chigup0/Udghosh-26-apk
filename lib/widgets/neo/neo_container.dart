import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// A raised neumorphic surface — the base building block for every card.
///
/// Backed by `flutter_neumorphic_plus`, so the bevel is computed from the
/// theme's light-source vector rather than a hand-rolled shadow pair.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.radius = NeoRadii.card,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.small = false,
  });

  final Widget child;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final style = NeoTheme.raisedStyle(
      radius: radius,
      depth: small ? NeoDepth.chip : NeoDepth.card,
      color: color,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: NeumorphicButton(
          onPressed: onTap,
          style: style,
          minDistance: NeoDepth.pressed,
          padding: padding.resolve(TextDirection.ltr),
          child: child,
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Neumorphic(
        style: style,
        padding: padding.resolve(TextDirection.ltr),
        child: child,
      ),
    );
  }
}

/// A recessed surface — score tracks, OTP digits, search fields, chip rails.
/// Rendered with a negative depth so content reads as physically pressed
/// into the surface behind it.
class NeoInset extends StatelessWidget {
  const NeoInset({
    super.key,
    required this.child,
    this.radius = NeoRadii.chip,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.active = false,
  });

  final Widget child;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeoTheme.insetStyle(
        radius: radius,
        // An active field presses in a little further — the only state cue
        // needed now that depth is doing the work a border used to.
        depth: active ? NeoDepth.inset - 1 : NeoDepth.inset,
        color: color,
      ),
      padding: padding.resolve(TextDirection.ltr),
      child: child,
    );
  }
}

/// Circular neumorphic icon/avatar button (44×44) used for the app bar's
/// bell and profile avatar.
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
          NeumorphicButton(
            onPressed: onTap,
            style: NeoTheme.circleStyle(),
            minDistance: NeoDepth.pressed,
            padding: EdgeInsets.zero,
            child: Center(child: child),
          ),
          if (badge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: NeoColors.alertFill,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A chunky pill CTA — "SEND OTP", "LOGOUT", "WATCH LIVE".
class NeoPillButton extends StatelessWidget {
  const NeoPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.foreground,
    this.background,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;

  /// Both default to the charcoal-on-light CTA pair of the active palette.
  final Color? foreground;
  final Color? background;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final foreground = this.foreground ?? NeoColors.onCharcoal;
    final background = this.background ?? NeoColors.charcoal;
    return NeumorphicButton(
      onPressed: loading ? null : onTap,
      minDistance: NeoDepth.pressed,
      style: NeoTheme.raisedStyle(
        radius: NeoRadii.pill,
        depth: NeoDepth.button,
        color: background,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: SizedBox(
        width: expand ? double.infinity : null,
        child: loading
            ? Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(foreground),
                  ),
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
      ),
    );
  }
}

/// Small status pill, e.g. "● LIVE" or "FINAL".
///
/// [color] carries the *text*, so it must clear 4.5:1 on the base; [dotColor]
/// is decorative and may be the brighter sibling tone.
class StatusCapsule extends StatelessWidget {
  const StatusCapsule({
    super.key,
    required this.label,
    this.color,
    this.dotColor,
    this.dot = true,
  });

  final String label;

  /// Defaults to the palette's live-status ink.
  final Color? color;
  final Color? dotColor;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? NeoColors.liveInk;
    return Neumorphic(
      style: NeoTheme.insetStyle(radius: NeoRadii.pill, depth: -2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor ?? color,
                shape: BoxShape.circle,
              ),
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
