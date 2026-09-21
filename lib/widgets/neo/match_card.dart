import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'neo_container.dart';

enum MatchCardVariant { live, upcoming, completed }

String _abbrev(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '??';
  if (words.length == 1) {
    return words.first
        .substring(0, words.first.length.clamp(0, 2))
        .toUpperCase();
  }
  return (words.first[0] + words.elementAt(1)[0]).toUpperCase();
}

Future<void> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    return Neumorphic(
      style: NeoTheme.circleStyle(),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        child: Text(
          _abbrev(label),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: NeoColors.logoTeal,
          ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.logoTeal,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 6),
            StatusCapsule(
              label: 'LIVE',
              color: NeoColors.liveInk,
              dotColor: NeoColors.live,
            ),
          ],
        );
      case MatchCardVariant.upcoming:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              match.formattedTime,
              style: TextStyle(
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.logoTeal,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 6),
            StatusCapsule(
              label: 'FINAL',
              color: NeoColors.textMuted,
              dot: false,
            ),
          ],
        );
    }
  }

  /// Venue caption. Becomes a tappable chip when the backend supplied a map
  /// link for this match.
  Widget _venueChip() {
    final locationUrl = match.locationUrl;
    final chip = NeoInset(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      radius: NeoRadii.pill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.place_rounded,
            size: 12,
            color: locationUrl != null
                ? NeoColors.waveInk
                : NeoColors.textMuted,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              match.venue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: locationUrl != null
                    ? NeoColors.waveInk
                    : NeoColors.textMuted,
                fontWeight: locationUrl != null ? FontWeight.w700 : null,
              ),
            ),
          ),
          if (locationUrl != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 10, color: NeoColors.waveInk),
          ],
        ],
      ),
    );

    if (locationUrl == null) return chip;
    return GestureDetector(onTap: () => _openUrl(locationUrl), child: chip);
  }

  @override
  Widget build(BuildContext context) {
    final showCricketSecondRow =
        match.sport == 'cricket' &&
        match.scoreLineTeam2.isNotEmpty &&
        variant != MatchCardVariant.upcoming;
    final sets = match.setScores;
    final streamUrl = match.liveStreamUrl;

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
                color: NeoColors.waveInk,
                dot: false,
              ),
              if (match.category.isNotEmpty) ...[
                const SizedBox(width: 6),
                StatusCapsule(
                  label: match.category.toUpperCase(),
                  color: NeoColors.textMuted,
                  dot: false,
                ),
              ],
              const Spacer(),
              if (demo) const _GoldTag(label: 'DEMO'),
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
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                    if (showCricketSecondRow) ...[
                      const SizedBox(height: 4),
                      Text(
                        match.scoreLineTeam2.split(' (').first,
                        style: TextStyle(
                          fontSize: 10,
                          color: NeoColors.textMuted,
                        ),
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
                      style: TextStyle(
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
                  NeoInset(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    radius: 10,
                    child: Text(
                      '${s.$1}-${s.$2}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (variant == MatchCardVariant.completed &&
              match.resultLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(child: _GoldTag(label: match.resultLabel.toUpperCase())),
          ],
          if (streamUrl != null) ...[
            const SizedBox(height: 12),
            NeoPillButton(
              label: 'WATCH LIVE',
              icon: Icons.play_circle_fill_rounded,
              background: NeoColors.base,
              foreground: NeoColors.alert,
              onTap: () => _openUrl(streamUrl),
            ),
          ],
          if (match.venue.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(child: _venueChip()),
          ],
        ],
      ),
    );
  }
}

/// Gold is the brand highlight but only clears 2.1:1 on the base, so it is
/// always used as a *fill* behind charcoal text (6.9:1) — never as text.
class _GoldTag extends StatelessWidget {
  const _GoldTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NeoColors.flameGold,
        borderRadius: BorderRadius.circular(NeoRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: NeoColors.onGold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
