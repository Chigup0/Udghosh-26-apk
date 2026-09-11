import 'package:flutter/material.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'neo_container.dart';

enum MatchCardVariant { live, upcoming, completed }

String _abbrev(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '??';
  if (words.length == 1) {
    return words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase();
  }
  return (words.first[0] + words.elementAt(1)[0]).toUpperCase();
}

/// Tactile neomorphic match card used across Home and Matches. One widget
/// covers live / upcoming / completed via [variant] since the visual shell
/// (crest circles + recessed centre pill) is identical — only the centre
/// content and status chip change.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.variant,
    this.onTap,
    this.demo = false,
  });

  final MatchRecord match;
  final MatchCardVariant variant;
  final VoidCallback? onTap;
  final bool demo;

  Widget _crest(String label) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NeoColors.surfaceRecessed,
        shape: BoxShape.circle,
        border: Border.all(color: NeoColors.logoTeal.withValues(alpha: 0.08)),
      ),
      child: Text(
        _abbrev(label),
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: NeoColors.logoTeal,
        ),
      ),
    );
  }

  Widget _centre() {
    switch (variant) {
      case MatchCardVariant.live:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoInset(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text(
                match.scoreLine.isEmpty ? 'LIVE' : match.scoreLine,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.logoTeal,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 6),
            StatusCapsule(label: '● LIVE', color: NeoColors.live),
          ],
        );
      case MatchCardVariant.upcoming:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              match.formattedTime,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: NeoColors.logoTeal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              match.formattedDate,
              style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
            ),
          ],
        );
      case MatchCardVariant.completed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoInset(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text(
                match.scoreLine,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.logoTeal,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 6),
            StatusCapsule(label: 'FINAL', color: NeoColors.textMuted, dot: false),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCricketSecondRow = match.sport == 'cricket' &&
        match.scoreLineTeam2.isNotEmpty &&
        variant != MatchCardVariant.upcoming;
    final sets = match.setScores;

    return NeoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusCapsule(
                label: match.sportLabel.toUpperCase(),
                color: NeoColors.waveTeal,
                dot: false,
              ),
              const Spacer(),
              if (demo)
                Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.flameGold.withValues(alpha: 0.9),
                    letterSpacing: 0.6,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _crest(match.team1),
                    const SizedBox(height: 6),
                    Text(
                      match.team1.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                    if (showCricketSecondRow) ...[
                      const SizedBox(height: 4),
                      Text(
                        match.scoreLineTeam2.split(' (').first,
                        style: TextStyle(fontSize: 10, color: NeoColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(flex: 2, child: _centre()),
              Expanded(
                child: Column(
                  children: [
                    _crest(match.team2),
                    const SizedBox(height: 6),
                    Text(
                      match.team2.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (sets.isNotEmpty && variant != MatchCardVariant.upcoming) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final s in sets)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: NeoTheme.inset(radius: 10),
                    child: Text(
                      '${s.$1}-${s.$2}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (variant == MatchCardVariant.completed && match.resultLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                match.resultLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.flameGold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
          if (match.venue.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceRecessed,
                  borderRadius: BorderRadius.circular(NeoRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_rounded, size: 12, color: NeoColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      match.venue,
                      style: TextStyle(fontSize: 10, color: NeoColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
