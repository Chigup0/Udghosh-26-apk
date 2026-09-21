import 'package:flutter/material.dart';
import 'package:udghosh/theme/arena_theme.dart';
import 'arena_match_data.dart';
import 'arena_shapes.dart';
import 'arena_status_capsule.dart';

/// The tactile "tournament ticket" match card — chamfered credential
/// shell, header strip (stage + sport + status), duel split with a
/// recessed scoreboard cutout, and a venue/action footer strip.
class ArenaMatchCard extends StatelessWidget {
  final ArenaMatchData data;
  const ArenaMatchCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: ChamferedBox(
        chamfer: 8,
        padding: const EdgeInsets.all(ArenaSpace.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderStrip(data: data),
            const SizedBox(height: ArenaSpace.xs),
            _DuelSplit(data: data),
            const SizedBox(height: ArenaSpace.xs),
            Container(height: 1, color: ArenaColors.border),
            const SizedBox(height: ArenaSpace.xs),
            _FooterStrip(data: data),
          ],
        ),
      ),
    );
  }
}

class _HeaderStrip extends StatelessWidget {
  final ArenaMatchData data;
  const _HeaderStrip({required this.data});

  @override
  Widget build(BuildContext context) {
    final stageText = data.stageLabel != null && data.stageNumber != null
        ? '[ STAGE ${toRomanNumeral(data.stageNumber!)} // ${data.stageLabel!.toUpperCase()} ]'
        : '[ ${data.sport.toUpperCase()} ]';

    final centerTag = data.category != null && data.category!.trim().isNotEmpty
        ? '${data.sport.toUpperCase()} (${data.category!.toUpperCase()})'
        : data.sport.toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Text(
            stageText,
            overflow: TextOverflow.ellipsis,
            style: ArenaText.label(
              size: 9.5,
              color: ArenaColors.textDim,
              tracking: 0.6,
            ),
          ),
        ),
        const SizedBox(width: ArenaSpace.xs),
        Flexible(
          child: Text(
            centerTag,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: ArenaText.heading(size: 12.5),
          ),
        ),
        const SizedBox(width: ArenaSpace.xs),
        ArenaStatusCapsule(
          status: data.status,
          liveClock: data.liveClock,
          scheduledTime: data.scheduledTime,
        ),
      ],
    );
  }
}

class _DuelSplit extends StatelessWidget {
  final ArenaMatchData data;
  const _DuelSplit({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ArenaSpace.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _TeamBlock(
              name: data.teamLeft,
              alignEnd: false,
              momentum: data.scoreline?.momentum == 1,
            ),
          ),
          _ScoreboardCutout(data: data),
          Expanded(
            child: _TeamBlock(
              name: data.teamRight,
              alignEnd: true,
              momentum: data.scoreline?.momentum == 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final String name;
  final bool alignEnd;
  final bool momentum;
  const _TeamBlock({
    required this.name,
    required this.alignEnd,
    required this.momentum,
  });

  String get _code {
    final letters = name.replaceAll(RegExp(r'[^A-Z0-9 ]'), '').trim();
    if (letters.isEmpty) return '--';
    final words = letters.split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words.first.length <= 4
          ? words.first
          : words.first.substring(0, 4);
    }
    final initials = words.map((w) => w.isNotEmpty ? w[0] : '').join();
    return initials.length <= 4 ? initials : initials.substring(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final badge = ChamferedBox(
      chamfer: 5,
      fill: ArenaColors.surfaceRecessed,
      borderColor: momentum ? ArenaColors.volt : ArenaColors.border,
      borderWidth: momentum ? 1.5 : 1,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: 44,
        child: Center(
          child: Text(
            _code,
            style: ArenaText.mono(size: 13, color: ArenaColors.textPrimary),
          ),
        ),
      ),
    );

    final label = Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: ArenaText.body(
        size: 11,
        color: ArenaColors.textSecondary,
        weight: FontWeight.w700,
      ),
    );

    final momentumBar = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 5),
      height: 2,
      width: 44,
      color: momentum ? ArenaColors.volt : Colors.transparent,
    );

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [badge, const SizedBox(height: 4), label, momentumBar],
    );
  }
}

class _ScoreboardCutout extends StatelessWidget {
  final ArenaMatchData data;
  const _ScoreboardCutout({required this.data});

  @override
  Widget build(BuildContext context) {
    final scoreline = data.scoreline;
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      margin: const EdgeInsets.symmetric(horizontal: ArenaSpace.xs),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: ArenaColors.surfaceRecessed,
        border: Border.all(color: ArenaColors.border, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: scoreline == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.scheduledTime ?? '--:--',
                  style: ArenaText.mono(
                    size: 20,
                    color: ArenaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text('IST', style: ArenaText.label(size: 9, tracking: 1.2)),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      scoreline.left,
                      style: ArenaText.mono(
                        size: 22,
                        color: ArenaColors.textPrimary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: ArenaText.mono(
                          size: 18,
                          color: ArenaColors.textDim,
                        ),
                      ),
                    ),
                    Text(
                      scoreline.right,
                      style: ArenaText.mono(
                        size: 22,
                        color: ArenaColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (scoreline.leftSub != null ||
                    scoreline.rightSub != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scoreline.leftSub ?? '',
                        style: ArenaText.label(size: 8.5, tracking: 0.4),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        scoreline.rightSub ?? '',
                        style: ArenaText.label(size: 8.5, tracking: 0.4),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _FooterStrip extends StatelessWidget {
  final ArenaMatchData data;
  const _FooterStrip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 13,
              color: ArenaColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                data.venueTag != null
                    ? '${data.venue.toUpperCase()} // ${data.venueTag}'
                    : data.venue.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: ArenaText.label(
                  size: 10,
                  color: ArenaColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: ArenaSpace.xs),
            if (data.onAction != null)
              GestureDetector(
                onTap: data.onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ArenaColors.borderStrong,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '[ ${data.actionLabel} ]',
                    style: ArenaText.label(
                      size: 9.5,
                      color: ArenaColors.textPrimary,
                      tracking: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (data.microStats.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final s in data.microStats)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  color: ArenaColors.surfaceRecessed,
                  child: Text(
                    s,
                    style: ArenaText.mono(
                      size: 10,
                      color: ArenaColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (data.delayMinutes > 2) ...[
          const SizedBox(height: 6),
          Text(
            'DELAYED ${data.delayMinutes.toStringAsFixed(0)} MIN',
            style: ArenaText.label(
              size: 9.5,
              color: ArenaColors.live,
              tracking: 0.6,
            ),
          ),
        ],
      ],
    );
  }
}
