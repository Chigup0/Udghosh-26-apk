import 'dart:async';
import 'package:flutter/material.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/models/demo_data.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/match_card.dart';
import 'package:udghosh/widgets/neo/neo_selectors.dart';

/// Matches tab: sport selector + [Past][Live][Upcoming] segmented feed.
///
/// Live polls every 20s while visible; Upcoming paginates; Results loads
/// completed matches newest-first. Every tab renders one demo card instead
/// of an empty state so the screen never looks broken pre-launch.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key, this.initialSportIndex = 0});
  final int initialSportIndex;

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  static const _tabs = ['Past', 'Live', 'Upcoming'];

  late int _sportIndex = widget.initialSportIndex.clamp(
    0,
    AppConfig.sportTables.length - 1,
  );
  int _tabIndex = 1;

  final Map<String, List<MatchRecord>> _live = {};
  final Map<String, List<MatchRecord>> _upcoming = {};
  final Map<String, List<MatchRecord>> _completed = {};
  final Map<String, int> _upcomingPage = {};
  final Map<String, bool> _upcomingHasMore = {};
  bool _loading = false;
  String? _error;
  Timer? _pollTimer;

  String get _sport => AppConfig.sportTables[_sportIndex];

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_tabIndex == 1) _load(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    setState(() => _error = null);
    try {
      switch (_tabIndex) {
        case 1: // Live
          final data = await ApiService.getLiveMatches(_sport);
          _live[_sport] = data;
          break;
        case 2: // Upcoming
          final page = _upcomingPage[_sport] ?? 1;
          final data = await ApiService.getUpcomingMatches(_sport, page: page);
          final existing = _upcoming[_sport] ?? [];
          _upcoming[_sport] = page == 1 ? data : [...existing, ...data];
          _upcomingHasMore[_sport] = data.length >= 10;
          break;
        default: // Past / Results
          final data = await ApiService.getCompletedMatches(_sport);
          _completed[_sport] = data;
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not reach the server';
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onSportChanged(int i) {
    setState(() => _sportIndex = i);
    _load();
  }

  void _onTabChanged(int i) {
    setState(() => _tabIndex = i);
    _load();
  }

  void _loadMoreUpcoming() {
    if (_upcomingHasMore[_sport] != true || _loading) return;
    _upcomingPage[_sport] = (_upcomingPage[_sport] ?? 1) + 1;
    _load();
  }

  List<Widget> _cardsForCurrentTab() {
    switch (_tabIndex) {
      case 1:
        final matches = _live[_sport] ?? [];
        if (matches.isEmpty) {
          return [MatchCard(match: DemoData.liveMatch(_sport), variant: MatchCardVariant.live, demo: true)];
        }
        return matches
            .map((m) => MatchCard(match: m, variant: MatchCardVariant.live))
            .toList();
      case 2:
        final matches = _upcoming[_sport] ?? [];
        if (matches.isEmpty) {
          return [MatchCard(match: DemoData.upcomingMatch(_sport), variant: MatchCardVariant.upcoming, demo: true)];
        }
        return matches
            .map((m) => MatchCard(match: m, variant: MatchCardVariant.upcoming))
            .toList();
      default:
        final matches = _completed[_sport] ?? [];
        if (matches.isEmpty) {
          return [MatchCard(match: DemoData.completedMatch(_sport), variant: MatchCardVariant.completed, demo: true)];
        }
        return matches
            .map((m) => MatchCard(match: m, variant: MatchCardVariant.completed))
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cardsForCurrentTab();
    return RefreshIndicator(
      onRefresh: () => _load(),
      color: NeoColors.waveTeal,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (_tabIndex == 2 &&
              n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            _loadMoreUpcoming();
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            NeoPillBar(
              labels: AppConfig.sportTables.map(AppConfig.sportLabel).toList(),
              selectedIndex: _sportIndex,
              onSelected: _onSportChanged,
            ),
            const SizedBox(height: 14),
            NeoSegmentedControl(
              labels: _tabs,
              index: _tabIndex,
              onChanged: _onTabChanged,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: NeoColors.alert, fontSize: 12),
                ),
              ),
            if (_loading && cards.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator(color: NeoColors.waveTeal)),
              )
            else
              for (final card in cards) ...[
                card,
                const SizedBox(height: 12),
              ],
            if (_tabIndex == 2 && _loading && cards.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
      ),
    );
  }
}
