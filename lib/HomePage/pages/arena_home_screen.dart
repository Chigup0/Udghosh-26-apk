import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:udghosh/HomePage/widgets/MapWidget.dart' show MapPage;
import 'package:udghosh/SchedulePage/models/LiveMatchModel.dart';
import 'package:udghosh/SchedulePage/models/MatchesModel.dart';
import 'package:udghosh/theme/arena_theme.dart';
import 'package:udghosh/utils.dart' show imageLinks;
import 'package:udghosh/widgets/arena/arena_broadcast_ticker.dart';
import 'package:udghosh/widgets/arena/arena_gallery_bento.dart';
import 'package:udghosh/widgets/arena/arena_match_card.dart';
import 'package:udghosh/widgets/arena/arena_match_data.dart';
import 'package:udghosh/widgets/arena/arena_quick_action_tile.dart';
import 'package:udghosh/widgets/arena/arena_status_capsule.dart';
import 'package:udghosh/widgets/arena/arena_venue_anchor_card.dart';

/// Festival Command Center — the "Arcana Ascension" home screen for
/// Udghosh '26, Edition XXII. Wires the arena component set (match card,
/// status capsule, quick-action ribbon, ticker, venue anchor, gallery
/// bento) into the exact vertical hierarchy from the design brief.
///
/// Accepts real feeds via [liveMatches] / [upcomingMatches] once wired to
/// the schedule API — falls back to representative sample fixtures so the
/// screen renders a realistic filled state on its own.
class ArenaHomeScreen extends StatefulWidget {
  final List<LiveNowMatchModel>? liveMatches;
  final List<UpcomingMatchesModel>? upcomingMatches;
  final int unreadAnnouncements;
  final VoidCallback? onOpenGallery;
  final VoidCallback? onOpenProfile;
  final void Function(LiveNowMatchModel match)? onOpenMatch;

  /// Extra scroll clearance for a docked bottom nav bar that floats over
  /// the content (e.g. [FancyBottomNav]'s centerDocked FAB).
  final double bottomInset;

  const ArenaHomeScreen({
    super.key,
    this.liveMatches,
    this.upcomingMatches,
    this.unreadAnnouncements = 3,
    this.onOpenGallery,
    this.onOpenProfile,
    this.onOpenMatch,
    this.bottomInset = 0,
  });

  @override
  State<ArenaHomeScreen> createState() => _ArenaHomeScreenState();
}

const _sportFilters = [
  'ALL',
  'CRICKET',
  'FOOTBALL',
  'BASKETBALL',
  'BADMINTON',
  'TRACK & FIELD',
];

class _ArenaHomeScreenState extends State<ArenaHomeScreen> {
  int _filterIndex = 0;

  late final List<LiveNowMatchModel> _liveMatches =
      widget.liveMatches ?? _sampleLiveMatches();
  late final List<UpcomingMatchesModel> _upcomingMatches =
      widget.upcomingMatches ?? _sampleUpcomingMatches();

  void _comingSoon(String feature) =>
      Fluttertoast.showToast(msg: '$feature — coming soon');

  @override
  Widget build(BuildContext context) {
    final hero = _liveMatches.isNotEmpty ? _liveMatches.first : null;
    final feed = _filterIndex == 0
        ? _liveMatches
        : _liveMatches
              .where(
                (m) =>
                    (m.sport ?? '').toUpperCase() ==
                    _sportFilters[_filterIndex],
              )
              .toList();

    return Scaffold(
      backgroundColor: ArenaColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _AppBar(
              unread: widget.unreadAnnouncements,
              onBell: () => _comingSoon('Announcements'),
              onAvatar: widget.onOpenProfile ?? () => _comingSoon('Profile'),
            ),
            if (hero != null) ...[
              const SizedBox(height: ArenaSpace.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
                child: _SectionEyebrow(
                  text: 'THE APEX TRIAL // HIGHEST STAKES LIVE',
                ),
              ),
              const SizedBox(height: ArenaSpace.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
                child: ArenaMatchCard(
                  data: ArenaMatchData.fromLive(
                    hero,
                    status: ArenaMatchStatus.live,
                    stageNumber: 4,
                    stageLabel: 'QUARTER-FINAL',
                    venueTag: 'COURT-02',
                    onAction: () => widget.onOpenMatch?.call(hero),
                    onTap: () => widget.onOpenMatch?.call(hero),
                  ),
                ),
              ),
            ],
            const SizedBox(height: ArenaSpace.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
              child: Row(
                children: [
                  ArenaQuickActionTile(
                    icon: Icons.map_outlined,
                    label: 'CAMPUS MAP\n/ ARENAS',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapPage()),
                    ),
                  ),
                  const SizedBox(width: ArenaSpace.xxs),
                  ArenaQuickActionTile(
                    icon: Icons.emoji_events_outlined,
                    label: 'MEDAL\nTALLY',
                    onTap: () => _comingSoon('Medal tally'),
                  ),
                  const SizedBox(width: ArenaSpace.xxs),
                  ArenaQuickActionTile(
                    icon: Icons.bolt_outlined,
                    label: 'ORDER\nOF PLAY',
                    onTap: () => _comingSoon('Order of play'),
                  ),
                  const SizedBox(width: ArenaSpace.xxs),
                  ArenaQuickActionTile(
                    icon: Icons.gavel_outlined,
                    label: 'RULE\nBOOKS',
                    onTap: () => _comingSoon('Rulebooks'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ArenaSpace.lg),
            ArenaBroadcastTicker(
              alerts: const [
                'WEATHER ALERT: LAWN TENNIS DELAYED 15 MIN // FOOTBALL SEMI-FINAL RESUMES AT 17:00 ON MAIN OVAL',
                'VENUE CHANGE: BADMINTON FINALS MOVED TO NEW SAC COURT 2, 16:00 IST',
              ],
            ),
            const SizedBox(height: ArenaSpace.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
              child: ArenaVenueAnchorCard(
                venues: const [
                  ArenaVenueBlock(
                    name: 'Main Stadium',
                    activeMatches: 2,
                    plan: Rect.fromLTWH(0.08, 0.55, 0.34, 0.32),
                  ),
                  ArenaVenueBlock(
                    name: 'Old SAC',
                    activeMatches: 1,
                    plan: Rect.fromLTWH(0.48, 0.15, 0.22, 0.28),
                  ),
                  ArenaVenueBlock(
                    name: 'New SAC Courts',
                    activeMatches: 1,
                    plan: Rect.fromLTWH(0.72, 0.5, 0.22, 0.4),
                  ),
                ],
                onExpand: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapPage()),
                ),
              ),
            ),
            const SizedBox(height: ArenaSpace.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
              child: _SectionEyebrow(text: 'ASCENSION FEED // ONGOING DUELS'),
            ),
            const SizedBox(height: ArenaSpace.xs),
            SizedBox(
              height: 34,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
                scrollDirection: Axis.horizontal,
                itemCount: _sportFilters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: ArenaSpace.xs),
                itemBuilder: (context, i) {
                  final selected = i == _filterIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _filterIndex = i),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? ArenaColors.textPrimary
                            : ArenaColors.surface,
                        border: Border.all(
                          color: selected
                              ? ArenaColors.textPrimary
                              : ArenaColors.border,
                        ),
                      ),
                      child: Text(
                        _sportFilters[i],
                        style: ArenaText.label(
                          size: 10.5,
                          tracking: 0.6,
                          color: selected
                              ? ArenaColors.canvas
                              : ArenaColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: ArenaSpace.sm),
            if (feed.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
                child: Text(
                  'NO ONGOING DUELS IN THIS CATEGORY',
                  style: ArenaText.label(size: 11),
                ),
              )
            else
              ...feed.map(
                (m) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ArenaSpace.sm,
                    0,
                    ArenaSpace.sm,
                    ArenaSpace.xs,
                  ),
                  child: ArenaMatchCard(
                    data: ArenaMatchData.fromLive(
                      m,
                      status: ArenaMatchStatus.live,
                      onAction: () => widget.onOpenMatch?.call(m),
                      onTap: () => widget.onOpenMatch?.call(m),
                    ),
                  ),
                ),
              ),
            if (_upcomingMatches.isNotEmpty) ...[
              const SizedBox(height: ArenaSpace.xs),
              ..._upcomingMatches.map(
                (m) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ArenaSpace.sm,
                    0,
                    ArenaSpace.sm,
                    ArenaSpace.xs,
                  ),
                  child: ArenaMatchCard(
                    data: ArenaMatchData.fromUpcoming(
                      m,
                      onAction: () =>
                          _comingSoon('Reminder for match ${m.matchId}'),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: ArenaSpace.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
              child: _SectionEyebrow(text: 'THE GALLERY // SHUTTER FEED'),
            ),
            const SizedBox(height: ArenaSpace.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ArenaSpace.sm),
              child: ArenaGalleryBento(
                imageUrls: imageLinks.take(3).toList(),
                onOpenGallery: widget.onOpenGallery ?? () {},
              ),
            ),
            SizedBox(height: ArenaSpace.xl + widget.bottomInset),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final int unread;
  final VoidCallback onBell;
  final VoidCallback onAvatar;
  const _AppBar({
    required this.unread,
    required this.onBell,
    required this.onAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ArenaSpace.sm,
        ArenaSpace.xs,
        ArenaSpace.sm,
        ArenaSpace.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("UDGHOSH '26", style: ArenaText.display(size: 30)),
                Text(
                  'EDITION XXII // ASCENSION',
                  style: ArenaText.label(size: 10, tracking: 1.4),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBell,
            child: Padding(
              padding: const EdgeInsets.only(right: ArenaSpace.md),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: ArenaColors.textPrimary,
                    size: 24,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        color: ArenaColors.live,
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: ArenaText.mono(size: 9, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onAvatar,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ArenaColors.surface,
                border: Border.all(color: ArenaColors.borderStrong, width: 1),
              ),
              child: Text('G', style: ArenaText.heading(size: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String text;
  const _SectionEyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: ArenaColors.live),
        const SizedBox(width: 8),
        Text(text, style: ArenaText.label(size: 10.5, tracking: 1.0)),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Sample fixtures — representative of the real schedule payload shape
// (see LiveMatchModel.fromJson / MatchesModel.fromJson). Replace with the
// live schedule feed once this screen is wired into the dashboard.
// ---------------------------------------------------------------------

List<LiveNowMatchModel> _sampleLiveMatches() => [
  LiveNowMatchModel.fromJson({
    'matchId': 101,
    'sport': 'basketball',
    'category': "men's",
    'team1': 'Hall 5',
    'team2': 'Hall 9',
    'team1_score': 42,
    'team2_score': 38,
    'venue': 'New SAC Courts',
    'date': '2026-09-10',
    'time': '15:30:00',
    'status': 'live',
  }),
  LiveNowMatchModel.fromJson({
    'matchId': 102,
    'sport': 'football',
    'category': "men's",
    'team1': 'Hall 3',
    'team2': 'Hall 11',
    'team1_goals': 1,
    'team2_goals': 1,
    'venue': 'Main Ground',
    'date': '2026-09-10',
    'time': '16:00:00',
    'status': 'live',
  }),
  LiveNowMatchModel.fromJson({
    'matchId': 103,
    'sport': 'badminton',
    'category': "women's",
    'player1': 'Hall 6',
    'player2': 'Hall 10',
    'active': '2',
    'set1_score1': 21,
    'set1_score2': 18,
    'set2_score1': 19,
    'set2_score2': 21,
    'venue': 'Old SAC',
    'date': '2026-09-10',
    'time': '16:30:00',
    'status': 'live',
  }),
];

List<UpcomingMatchesModel> _sampleUpcomingMatches() => [
  UpcomingMatchesModel.fromJson({
    'matchId': 201,
    'sport': 'Cricket',
    'category': "Men's",
    'team1': 'Hall 7',
    'team2': 'Hall 12',
    'venue': 'Cricket Ground',
    'date': '2026-09-10',
    'time': '18:00:00',
    'athleteType': '',
  }),
];
