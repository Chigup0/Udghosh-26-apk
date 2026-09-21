import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/model2/theme/m2_style.dart';
import 'package:udghosh/model2/widgets/m2_widgets.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:url_launcher/url_launcher.dart';

enum M2CardKind { live, upcoming, completed }

String _abbrev(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '??';
  if (words.length == 1) {
    return words.first
        .substring(0, words.first.length.clamp(0, 3))
        .toUpperCase();
  }
  return (words.first[0] + words.elementAt(1)[0]).toUpperCase();
}

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Model 2's scoreboard.
///
/// Laid out as a physical panel: crests are convex knobs, the score is a deep
/// emboss, and the meta strip sits in a recess along the bottom. Reads exactly
/// the same [MatchRecord] getters as Model 1, so the data and the per-sport
/// score logic are untouched.
class M2MatchCard extends StatelessWidget {
  const M2MatchCard({
    super.key,
    required this.match,
    required this.kind,
    this.onTap,
    this.demo = false,
  });

  final MatchRecord match;
  final M2CardKind kind;
  final VoidCallback? onTap;
  final bool demo;

  Widget _crest(String name) {
    return Column(
      children: [
        Neumorphic(
          style: M2.knob(depth: M2.cardDepth),
          child: SizedBox(
            width: 54,
            height: 54,
            child: Center(
              child: Text(
                _abbrev(name),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: NeoColors.logoTeal,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: NeoColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _centre() {
    switch (kind) {
      case M2CardKind.live:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            M2Readout(
              value: match.scoreLine.isEmpty ? '—' : match.scoreLine,
              size: match.scoreLine.length > 9 ? 17 : 24,
            ),
            const SizedBox(height: 10),
            M2Tag(label: 'LIVE', color: NeoColors.liveInk, dot: true),
          ],
        );
      case M2CardKind.upcoming:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            M2Readout(value: match.formattedTime, size: 17),
            const SizedBox(height: 8),
            Text(
              match.formattedDate,
              style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
            ),
          ],
        );
      case M2CardKind.completed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            M2Readout(
              value: match.scoreLine.isEmpty ? '—' : match.scoreLine,
              size: match.scoreLine.length > 9 ? 16 : 22,
            ),
            const SizedBox(height: 10),
            M2Tag(label: 'FULL TIME'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sets = match.setScores;
    final stream = match.liveStreamUrl;
    final location = match.locationUrl;
    final secondInnings =
        match.sport == 'cricket' &&
        match.scoreLineTeam2.isNotEmpty &&
        kind != M2CardKind.upcoming;

    return M2Plinth(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                match.sportLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: NeoColors.waveInk,
                ),
              ),
              if (match.category.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '· ${match.category}',
                  style: TextStyle(fontSize: 10.5, color: NeoColors.textMuted),
                ),
              ],
              const Spacer(),
              if (demo) M2Tag(label: 'DEMO', filled: true),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _crest(match.team1)),
              Expanded(flex: 2, child: _centre()),
              Expanded(child: _crest(match.team2)),
            ],
          ),
          if (secondInnings) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${match.team1}  ${match.scoreLine}   ·   '
                '${match.team2}  ${match.scoreLineTeam2}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: NeoColors.textMuted),
              ),
            ),
          ],
          if (sets.isNotEmpty && kind != M2CardKind.upcoming) ...[
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < sets.length; i++)
                  M2Well(
                    radius: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SET ${i + 1}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: NeoColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sets[i].$1}-${sets[i].$2}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.logoTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (kind == M2CardKind.completed && match.resultLabel.isNotEmpty) ...[
            const SizedBox(height: 14),
            Center(
              child: M2Tag(
                label: match.resultLabel.toUpperCase(),
                filled: true,
              ),
            ),
          ],
          if (stream != null) ...[
            const SizedBox(height: 14),
            NeumorphicButton(
              onPressed: () => _open(stream),
              style: M2.pill(selected: false),
              minDistance: M2.pressed,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedPlayCircle,
                    color: NeoColors.alert,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WATCH LIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: NeoColors.alert,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (match.venue.isNotEmpty) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: location == null ? null : () => _open(location),
              behavior: HitTestBehavior.opaque,
              child: M2Well(
                radius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedMapsLocation01,
                      color: location != null
                          ? NeoColors.waveInk
                          : NeoColors.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: location != null
                              ? NeoColors.waveInk
                              : NeoColors.textMuted,
                        ),
                      ),
                    ),
                    if (location != null)
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight02,
                        color: NeoColors.waveInk,
                        size: 13,
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
