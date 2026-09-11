import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: NeoTheme.inset(radius: NeoRadii.pill),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? NeoColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(NeoRadii.pill),
                  boxShadow: active ? NeoShadows.raisedSmall() : const [],
                ),
                alignment: Alignment.center,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? NeoColors.charcoal : NeoColors.surface,
                borderRadius: BorderRadius.circular(NeoRadii.pill),
                boxShadow: active ? const [] : NeoShadows.raisedSmall(),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 15,
                      color: active
                          ? NeoColors.onCharcoal
                          : NeoColors.logoTeal,
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
