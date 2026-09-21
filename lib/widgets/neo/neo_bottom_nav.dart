import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/theme/neo_theme.dart';

class NeoNavItem {
  const NeoNavItem(this.icon, this.label);

  /// A Hugeicons stroke glyph. The set is stroke-only, so the selected tab is
  /// distinguished by a heavier stroke rather than by a filled variant.
  final List<List<dynamic>> icon;
  final String label;
}

final List<NeoNavItem> kNeoNavItems = [
  NeoNavItem(HugeIcons.strokeRoundedHome01, 'Home'),
  // A trophy reads for all 14 sports; a cricket bat did not.
  NeoNavItem(HugeIcons.strokeRoundedChampion, 'Matches'),
  NeoNavItem(HugeIcons.strokeRoundedImage02, 'Gallery'),
  NeoNavItem(HugeIcons.strokeRoundedMapsLocation01, 'Map'),
  NeoNavItem(HugeIcons.strokeRoundedMoreHorizontal, 'More'),
];

/// Floating, rounded bottom navigation pill dock with 5 tabs.
///
/// The active tab expands to show its label. The label is held to a single
/// line and scaled down if the pill is narrow, so "Matches" can never wrap.
class NeoBottomNav extends StatelessWidget {
  const NeoBottomNav({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: NeoTheme.dock(),
        child: Row(
          children: List.generate(kNeoNavItems.length, (i) {
            final item = kNeoNavItems[i];
            final active = i == index;
            return Expanded(
              // The selected tab gets more room so its label fits on one line
              // while the other four shrink to their icons.
              flex: active ? 3 : 2,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(i);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? NeoColors.flameGold : Colors.transparent,
                    borderRadius: BorderRadius.circular(NeoRadii.pill),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: item.icon,
                        size: 22,
                        strokeWidth: active ? 2.4 : 1.8,
                        color: active
                            ? NeoColors.onGold
                            : NeoColors.onDock.withValues(alpha: 0.6),
                      ),
                      if (active) ...[
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.onGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
