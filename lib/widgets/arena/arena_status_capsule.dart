import 'package:flutter/material.dart';
import 'package:udghosh/theme/arena_theme.dart';

enum ArenaMatchStatus { live, scheduled, completed }

/// The solid status capsule from the match card header strip:
/// LIVE (red fill, pulsing dot), SCHEDULED (neutral technical badge,
/// start time) or COMPLETED (muted dark badge, "FT").
class ArenaStatusCapsule extends StatelessWidget {
  final ArenaMatchStatus status;
  final String? liveClock;
  final String? scheduledTime;

  const ArenaStatusCapsule({
    super.key,
    required this.status,
    this.liveClock,
    this.scheduledTime,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ArenaMatchStatus.live:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(color: ArenaColors.live),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PulsingDot(color: Colors.white),
              const SizedBox(width: 5),
              Text(
                'LIVE',
                style: ArenaText.label(
                  size: 10.5,
                  color: Colors.white,
                  tracking: 1.1,
                ),
              ),
              if (liveClock != null) ...[
                const SizedBox(width: 6),
                Container(
                  width: 1,
                  height: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 6),
                Text(
                  liveClock!,
                  style: ArenaText.mono(size: 11, color: Colors.white),
                ),
              ],
            ],
          ),
        );
      case ArenaMatchStatus.scheduled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ArenaColors.surfaceRecessed,
            border: Border.all(color: ArenaColors.border, width: 1),
          ),
          child: Text(
            scheduledTime ?? '--:--',
            style: ArenaText.mono(size: 11, color: ArenaColors.textSecondary),
          ),
        );
      case ArenaMatchStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(color: ArenaColors.borderStrong),
          child: Text(
            'FT',
            style: ArenaText.label(size: 10.5, color: ArenaColors.textPrimary),
          ),
        );
    }
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
