import 'dart:async';
import 'package:flutter/material.dart';
import 'package:udghosh/theme/arena_theme.dart';

/// High-contrast broadcast ticker — cycles through operational alerts
/// (weather delays, venue changes, resumption times) one line at a time.
class ArenaBroadcastTicker extends StatefulWidget {
  final List<String> alerts;
  const ArenaBroadcastTicker({super.key, required this.alerts});

  @override
  State<ArenaBroadcastTicker> createState() => _ArenaBroadcastTickerState();
}

class _ArenaBroadcastTickerState extends State<ArenaBroadcastTicker> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.alerts.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        setState(() => _index = (_index + 1) % widget.alerts.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();
    return Container(
      color: ArenaColors.live,
      padding: const EdgeInsets.symmetric(
        horizontal: ArenaSpace.sm,
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(
            'ALERT',
            style: ArenaText.label(
              size: 10,
              color: Colors.black,
              tracking: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 12,
            color: Colors.black.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  widget.alerts[_index],
                  key: ValueKey(_index),
                  overflow: TextOverflow.ellipsis,
                  style: ArenaText.body(
                    size: 12,
                    color: Colors.black,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
