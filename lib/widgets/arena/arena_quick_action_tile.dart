import 'package:flutter/material.dart';
import 'package:udghosh/theme/arena_theme.dart';

/// One dense, tactile tile in the Fest Navigation Strip — solid surface,
/// 1px border, monochrome vector icon, bold micro-label.
class ArenaQuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ArenaQuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: ArenaColors.surface,
            border: Border.all(color: ArenaColors.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: ArenaColors.textPrimary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: ArenaText.label(size: 9.5, color: ArenaColors.textSecondary, tracking: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
