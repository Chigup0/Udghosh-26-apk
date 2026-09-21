import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/model2/theme/m2_style.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// Section heading: a gold tick, the title, and an optional trailing action.
class M2SectionTitle extends StatelessWidget {
  const M2SectionTitle(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: NeoColors.flameGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: NeoColors.textMuted,
              ),
            ),
          ),
          if (action != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    action!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.waveInk,
                    ),
                  ),
                  const SizedBox(width: 3),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight02,
                    color: NeoColors.waveInk,
                    size: 14,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Convex base plate. Sections sit on a plinth rather than floating.
class M2Plinth extends StatelessWidget {
  const M2Plinth({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = M2.rPanel,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = M2.plinth(radius: radius);
    if (onTap == null) {
      return Neumorphic(style: style, padding: padding, child: child);
    }
    return NeumorphicButton(
      onPressed: onTap,
      style: style,
      minDistance: M2.pressed,
      padding: padding,
      child: child,
    );
  }
}

/// Concave recess.
class M2Well extends StatelessWidget {
  const M2Well({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = M2.rWell,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: M2.well(radius: radius),
      padding: padding,
      child: child,
    );
  }
}

/// Embossed numeric readout — the only place big numbers are shown.
class M2Readout extends StatelessWidget {
  const M2Readout({
    super.key,
    required this.value,
    this.size = 26,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
  });

  final String value;
  final double size;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: M2.readout(),
      padding: padding,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: -0.5,
          color: color ?? NeoColors.logoTeal,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Convex circular button.
class M2Knob extends StatelessWidget {
  const M2Knob({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 20,
    this.color,
    this.badge = false,
  });

  final List<List<dynamic>> icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
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
            style: M2.knob(),
            minDistance: M2.pressed,
            padding: EdgeInsets.zero,
            child: Center(
              child: HugeIcon(
                icon: icon,
                size: iconSize,
                color: color ?? NeoColors.logoTeal,
              ),
            ),
          ),
          if (badge)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 9,
                height: 9,
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

/// A row of chips riding inside a recessed rail.
class M2ChipRail extends StatelessWidget {
  const M2ChipRail({
    super.key,
    required this.labels,
    required this.index,
    required this.onSelected,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: M2.rail(),
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final selected = i == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                child: Neumorphic(
                  style: M2.pill(
                    selected: selected,
                    color: selected ? NeoColors.flameGold : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? NeoColors.onGold
                            : NeoColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Two/three-way switch built as a recessed track with a raised slider.
class M2Switch extends StatelessWidget {
  const M2Switch({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: M2.rail(),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
              behavior: HitTestBehavior.opaque,
              child: Neumorphic(
                duration: const Duration(milliseconds: 180),
                style: M2
                    .pill(
                      selected: false,
                      color: selected ? NeoColors.surface : Colors.transparent,
                    )
                    .copyWith(depth: selected ? M2.cardDepth : 0),
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? NeoColors.logoTeal
                          : NeoColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Small status flag. Uses a well so it reads as stamped into the surface.
class M2Tag extends StatelessWidget {
  const M2Tag({
    super.key,
    required this.label,
    this.color,
    this.filled = false,
    this.dot = false,
  });

  final String label;
  final Color? color;
  final bool filled;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? NeoColors.textMuted;
    return Neumorphic(
      style: filled
          ? M2.pill(selected: false, color: NeoColors.flameGold)
          : M2.well(radius: 999, depth: -3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: filled ? NeoColors.onGold : tone,
            ),
          ),
        ],
      ),
    );
  }
}
