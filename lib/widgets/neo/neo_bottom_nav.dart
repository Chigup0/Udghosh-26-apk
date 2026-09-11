import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udghosh/theme/neo_theme.dart';

class NeoNavItem {
  const NeoNavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

const List<NeoNavItem> kNeoNavItems = [
  NeoNavItem(Icons.home_rounded, 'Home'),
  NeoNavItem(Icons.sports_cricket_rounded, 'Matches'),
  NeoNavItem(Icons.photo_library_rounded, 'Gallery'),
  NeoNavItem(Icons.map_rounded, 'Map'),
  NeoNavItem(Icons.grid_view_rounded, 'Other'),
];

/// Floating, rounded bottom navigation pill dock with 5 tabs.
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(kNeoNavItems.length, (i) {
            final item = kNeoNavItems[i];
            final active = i == index;
            return Expanded(
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
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? NeoColors.flameGold
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(NeoRadii.pill),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: active
                            ? NeoColors.charcoal
                            : NeoColors.onCharcoal.withValues(alpha: 0.55),
                      ),
                      if (active) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.charcoal,
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
