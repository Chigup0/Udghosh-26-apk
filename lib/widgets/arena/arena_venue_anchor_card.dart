import 'package:flutter/material.dart';
import 'package:udghosh/theme/arena_theme.dart';
import 'arena_shapes.dart';

class ArenaVenueBlock {
  final String name;
  final int activeMatches;
  final Rect plan;
  const ArenaVenueBlock({
    required this.name,
    required this.activeMatches,
    required this.plan,
  });
}

/// Interactive campus venue anchor — a schematic architectural preview
/// (not a live map tile) with active-match counters per block, and a
/// primary action that opens the full interactive map.
class ArenaVenueAnchorCard extends StatelessWidget {
  final List<ArenaVenueBlock> venues;
  final VoidCallback onExpand;

  const ArenaVenueAnchorCard({
    super.key,
    required this.venues,
    required this.onExpand,
  });

  int get _totalMatches => venues.fold(0, (sum, v) => sum + v.activeMatches);

  @override
  Widget build(BuildContext context) {
    return ChamferedBox(
      chamfer: 10,
      padding: const EdgeInsets.all(ArenaSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('CAMPUS GRID', style: ArenaText.heading(size: 14)),
              const Spacer(),
              const Icon(
                Icons.radio_button_checked,
                size: 10,
                color: ArenaColors.live,
              ),
              const SizedBox(width: 6),
              Text(
                '$_totalMatches MATCHES // ${venues.length} VENUES',
                style: ArenaText.label(size: 9.5, tracking: 0.5),
              ),
            ],
          ),
          const SizedBox(height: ArenaSpace.sm),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: ArenaColors.surfaceRecessed,
                border: Border.all(color: ArenaColors.border, width: 1),
              ),
              child: CustomPaint(painter: _CampusPlanPainter(venues: venues)),
            ),
          ),
          const SizedBox(height: ArenaSpace.sm),
          Wrap(
            spacing: ArenaSpace.sm,
            runSpacing: 6,
            children: [
              for (final v in venues)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      color: v.activeMatches > 0
                          ? ArenaColors.live
                          : ArenaColors.textDim,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      v.name.toUpperCase(),
                      style: ArenaText.label(
                        size: 9.5,
                        color: ArenaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: ArenaSpace.sm),
          GestureDetector(
            onTap: onExpand,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: Border.all(color: ArenaColors.borderStrong, width: 1),
              ),
              child: Text(
                '[ EXPAND INTERACTIVE FEST MAP ]',
                style: ArenaText.label(
                  size: 10.5,
                  color: ArenaColors.textPrimary,
                  tracking: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flat schematic plan — rectangular blocks for each venue, sized/positioned
/// by the caller-supplied unit-space [ArenaVenueBlock.plan] rects.
class _CampusPlanPainter extends CustomPainter {
  final List<ArenaVenueBlock> venues;
  _CampusPlanPainter({required this.venues});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = ArenaColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final v in venues) {
      final rect = Rect.fromLTWH(
        v.plan.left * size.width,
        v.plan.top * size.height,
        v.plan.width * size.width,
        v.plan.height * size.height,
      );
      final active = v.activeMatches > 0;
      canvas.drawRect(
        rect,
        Paint()
          ..color = (active ? ArenaColors.live : ArenaColors.textDim)
              .withValues(alpha: 0.12),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = active ? ArenaColors.live : ArenaColors.borderStrong,
      );
      if (active) {
        canvas.drawCircle(rect.center, 3, Paint()..color = ArenaColors.live);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CampusPlanPainter oldDelegate) =>
      oldDelegate.venues != venues;
}
