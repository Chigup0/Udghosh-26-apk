import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils.dart';

class FancyBottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const FancyBottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 3, 1, 6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, "Home", Icons.home),
          _buildNavItem(1, "Matches", Icons.sports_soccer),
          _buildNavItem(2, "Gallery", Icons.photo_library_rounded),
          _buildNavItem(3, "Teams", Icons.people_alt_rounded),
          _buildNavItem(4, "Notices", Icons.notifications),
        ],
      ),
    );
  }

  Widget _buildNavItem(int ind, String text, dynamic icon) {
    final bool isActive = index == ind;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(ind);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blueAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: isActive ? 26 : 22,
              color: isActive ? Colors.blueAccent : Colors.grey.shade400,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
                child: Text(text),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
