import 'package:flutter/material.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/models/demo_data.dart';
import 'package:udghosh/models/event.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/match_card.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// Home tab: live hero, sport-count strip, quick actions, upcoming events.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenMatches,
    required this.onOpenGallery,
    required this.onOpenMap,
    required this.onOpenNotices,
  });

  final VoidCallback onOpenMatches;
  final VoidCallback onOpenGallery;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenNotices;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MatchRecord? _liveMatch;
  Map<String, int> _tablesLength = {};
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getLiveMatches('cricket').catchError((_) => <MatchRecord>[]),
      ApiService.getTablesLength().catchError((_) => <String, int>{}),
      ApiService.getUpcomingEvents().catchError((_) => <Event>[]),
    ]);
    if (!mounted) return;
    final liveMatches = results[0] as List<MatchRecord>;
    setState(() {
      _liveMatch = liveMatches.isNotEmpty ? liveMatches.first : null;
      _tablesLength = results[1] as Map<String, int>;
      _events = results[2] as List<Event>;
      _loading = false;
    });
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: NeoColors.flameGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: NeoColors.logoTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NeoColors.surface,
                shape: BoxShape.circle,
                boxShadow: NeoShadows.raisedSmall(),
              ),
              child: Icon(icon, color: NeoColors.waveTeal, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: NeoColors.logoTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: NeoColors.waveTeal,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'MATCH ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.logoTeal,
                  ),
                ),
                TextSpan(
                  text: 'HIGHLIGHTS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.surface,
                    shadows: [
                      Shadow(color: NeoColors.shadowDark, offset: Offset(1, 2), blurRadius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.onOpenMatches,
            child: MatchCard(
              match: _liveMatch ?? DemoData.liveMatch('basketball'),
              variant: MatchCardVariant.live,
              demo: _liveMatch == null,
            ),
          ),
          const SizedBox(height: 20),
          if (_tablesLength.isNotEmpty) ...[
            _sectionHeader('Live right now'),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tablesLength.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final entry = _tablesLength.entries.elementAt(i);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: NeoTheme.raisedSmall(radius: NeoRadii.pill),
                    alignment: Alignment.center,
                    child: Text(
                      '${AppConfig.sportLabel(entry.key)} · ${entry.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          _sectionHeader('Quick actions'),
          NeoCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                _quickAction(Icons.map_rounded, 'Campus\nMap', widget.onOpenMap),
                _quickAction(Icons.leaderboard_rounded, 'Standings', widget.onOpenMatches),
                _quickAction(Icons.schedule_rounded, 'Schedule', widget.onOpenMatches),
                _quickAction(Icons.campaign_rounded, 'Notices', widget.onOpenNotices),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionHeader('Upcoming events'),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: NeoColors.waveTeal)),
            )
          else if (_events.isEmpty)
            _eventCard('Opening Ceremony', '18:00', 'Main Stadium', demo: true)
          else
            for (final e in _events.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _eventCard(e.eventName, e.formattedTime, e.venue),
              ),
        ],
      ),
    );
  }

  Widget _eventCard(String name, String time, String venue, {bool demo = false}) {
    return NeoCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: NeoColors.surfaceRecessed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event_rounded, color: NeoColors.waveTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: NeoColors.logoTeal),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time  //  $venue',
                  style: TextStyle(fontSize: 12, color: NeoColors.textMuted),
                ),
              ],
            ),
          ),
          if (demo)
            Text(
              'DEMO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: NeoColors.flameGold.withValues(alpha: 0.9),
              ),
            ),
        ],
      ),
    );
  }
}
