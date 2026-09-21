import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/services.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// Sticky neomorphic segmented pill controller, e.g. [Past] [Live] [Upcoming].
class NeoSegmentedControl extends StatelessWidget {
  const NeoSegmentedControl({
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
      style: NeoTheme.insetStyle(radius: NeoRadii.pill),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
              child: Neumorphic(
                duration: const Duration(milliseconds: 200),
                style: NeoTheme.raisedStyle(
                  radius: NeoRadii.pill,
                  depth: active ? NeoDepth.chip : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: active ? NeoColors.logoTeal : NeoColors.textMuted,
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

/// Horizontal scrolling pill bar used for sport-category / gallery filters.
class NeoPillBar extends StatelessWidget {
  const NeoPillBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.icons,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<IconData?>? icons;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == selectedIndex;
          final icon = icons != null && i < icons!.length ? icons![i] : null;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(i);
            },
            child: Neumorphic(
              duration: const Duration(milliseconds: 200),
              style: NeoTheme.raisedStyle(
                radius: NeoRadii.pill,
                depth: active ? NeoDepth.pressed : NeoDepth.chip,
                color: active ? NeoColors.charcoal : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 15,
                      color: active ? NeoColors.onCharcoal : NeoColors.logoTeal,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: active
                          ? NeoColors.onCharcoal
                          : NeoColors.logoTeal.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
