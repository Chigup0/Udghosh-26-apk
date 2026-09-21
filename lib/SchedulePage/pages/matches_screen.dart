import 'dart:async';
import 'package:flutter/material.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/models/demo_data.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/match_card.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';
import 'package:udghosh/widgets/app_lottie.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/widgets/neo/neo_selectors.dart';

/// Matches tab: sport selector + search + [Past][Live][Upcoming] feed.
///
/// All three tabs are paginated (the backend caps a page at 500 and defaults
/// to 10, so the page size is passed explicitly). Live re-polls page 1 every
/// 20s. Each tab renders one demo card instead of an empty state so the
/// screen never looks broken pre-launch.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key, this.initialSportIndex = 0});
  final int initialSportIndex;

  @override
  MatchesScreenState createState() => MatchesScreenState();
}

class MatchesScreenState extends State<MatchesScreen> {
  static const _tabs = ['Past', 'Live', 'Upcoming'];
  static const _liveTab = 1;
  static const _upcomingTab = 2;

  late int _sportIndex = widget.initialSportIndex.clamp(
    0,
    AppConfig.sportTables.length - 1,
  );
  int _tabIndex = _liveTab;

  final _searchController = TextEditingController();
  String _search = '';
  Timer? _searchDebounce;

  List<MatchRecord> _items = [];
  int _page = 1;
  bool _hasMore = false;
  bool _loading = false;
  bool _loadingMore = false;
  ApiException? _failure;
  Timer? _pollTimer;

  /// Bumped on every fetch. A response whose id no longer matches the latest
  /// request is discarded, so a slow reply for "cri" cannot land after "cric"
  /// and repaint the list with stale results.
  int _requestId = 0;

  String get _sport => AppConfig.sportTables[_sportIndex];

  @override
  void initState() {
    super.initState();
    _reload();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_tabIndex == _liveTab) _reload(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<Paged<MatchRecord>> _fetch(int page) {
    final search = _search.isEmpty ? null : _search;
    switch (_tabIndex) {
      case _liveTab:
        return ApiService.getLiveMatches(_sport, search: search, page: page);
      case _upcomingTab:
        return ApiService.getUpcomingMatches(
          _sport,
          search: search,
          page: page,
        );
      default:
        return ApiService.getCompletedMatches(
          _sport,
          search: search,
          page: page,
        );
    }
  }

  /// Loads page 1 and replaces the list. [silent] keeps the existing cards on
  /// screen (used by the live poll) instead of flashing a spinner.
  Future<void> _reload({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    final id = ++_requestId;
    try {
      final result = await _fetch(1);
      if (!mounted || id != _requestId) return;
      setState(() {
        _items = result.items;
        _page = 1;
        _hasMore = result.hasMore;
        _failure = null;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) setState(() => _failure = e);
    } catch (_) {
      if (mounted && id == _requestId) {
        setState(
          () => _failure = ApiException(0, 'Could not reach the server'),
        );
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _loading = false);
    }
  }

  /// Appends the next page. The page counter only advances once the request
  /// succeeds, so a failed fetch retries the same page instead of skipping it.
  Future<void> _loadMore() async {
    if (!_hasMore || _loading || _loadingMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    final id = ++_requestId;
    try {
      final result = await _fetch(nextPage);
      if (!mounted || id != _requestId) return;
      setState(() {
        _items = [..._items, ...result.items];
        _page = nextPage;
        _hasMore = result.hasMore;
        _failure = null;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) setState(() => _failure = e);
    } catch (_) {
      if (mounted && id == _requestId) {
        setState(
          () => _failure = ApiException(0, 'Could not load more matches'),
        );
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _loadingMore = false);
    }
  }

  /// Focuses a sport from outside the screen (the Home hero card taps
  /// through to whichever sport is actually live).
  void selectSport(String sportTable) {
    final i = AppConfig.sportTables.indexOf(
      AppConfig.normalizeSport(sportTable),
    );
    if (i < 0 || i == _sportIndex) return;
    _searchDebounce?.cancel();
    setState(() => _sportIndex = i);
    _reload();
  }

  void _onSportChanged(int i) {
    _searchDebounce?.cancel();
    setState(() => _sportIndex = i);
    _reload();
  }

  void _onTabChanged(int i) {
    _searchDebounce?.cancel();
    setState(() => _tabIndex = i);
    _reload();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    // Rebuild now so the clear button appears on the first keystroke rather
    // than 400ms later; the fetch itself stays debounced.
    setState(() {});
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || value.trim() == _search) return;
      setState(() => _search = value.trim());
      _reload();
    });
  }

  /// Clears the field and, if a search was active, refetches unfiltered.
  void _clearSearchField() {
    _searchDebounce?.cancel();
    _searchController.clear();
    final wasSearching = _search.isNotEmpty;
    // Always rebuilds: the clear button lives on this widget, not the
    // TextField, so clearing the controller alone would leave it on screen.
    setState(() => _search = '');
    if (wasSearching) _reload();
  }

  /// Submits immediately, skipping the debounce — but not if nothing changed.
  void _submitSearch(String value) {
    _searchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == _search) return;
    setState(() => _search = trimmed);
    _reload();
  }

  MatchCardVariant get _variant {
    switch (_tabIndex) {
      case _liveTab:
        return MatchCardVariant.live;
      case _upcomingTab:
        return MatchCardVariant.upcoming;
      default:
        return MatchCardVariant.completed;
    }
  }

  MatchRecord _demoMatch() {
    switch (_tabIndex) {
      case _liveTab:
        return DemoData.liveMatch(_sport);
      case _upcomingTab:
        return DemoData.upcomingMatch(_sport);
      default:
        return DemoData.completedMatch(_sport);
    }
  }

  Widget _searchField() {
    return NeoInset(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: NeoColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _submitSearch,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: NeoColors.logoTeal,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search team, venue or category',
                hintStyle: TextStyle(fontSize: 13, color: NeoColors.textMuted),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearchField,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: NeoColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A search that legitimately matches nothing should say so rather than
    // show a demo card that looks like a result.
    final isEmpty = _items.isEmpty;
    final showDemo = isEmpty && _search.isEmpty && !_loading;
    final showNoResults = isEmpty && _search.isNotEmpty && !_loading;

    return RefreshIndicator(
      onRefresh: _reload,
      color: NeoColors.waveTeal,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: [
            NeoPillBar(
              labels: AppConfig.sportTables.map(AppConfig.sportLabel).toList(),
              selectedIndex: _sportIndex,
              onSelected: _onSportChanged,
            ),
            const SizedBox(height: 12),
            _searchField(),
            const SizedBox(height: 12),
            NeoSegmentedControl(
              labels: _tabs,
              index: _tabIndex,
              onChanged: _onTabChanged,
            ),
            const SizedBox(height: 16),
            // A failed refresh while cards are already on screen shows a thin
            // banner instead of wiping the list the user was reading.
            if (_failure != null && !isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _failure!.message,
                  style: TextStyle(color: NeoColors.alert, fontSize: 12),
                ),
              ),
            if (_loading && isEmpty)
              const AppLoader()
            else if (_failure != null && isEmpty)
              AppStateView(
                anim: _failure!.isOffline
                    ? AppAnim.offline
                    : AppAnim.serverDown,
                title: _failure!.isOffline
                    ? 'You are offline'
                    : 'Scores are unavailable',
                message: _failure!.isOffline
                    ? 'Connect to the internet to see live scores and '
                          'fixtures.'
                    : _failure!.message,
                onRetry: _failure!.isRetryable ? () => _reload() : null,
              )
            else if (showNoResults)
              AppStateView(
                anim: AppAnim.noResults,
                title: 'No matches found',
                message:
                    'Nothing matches "$_search" in '
                    '${AppConfig.sportLabel(_sport)}.',
                compact: true,
              )
            else if (showDemo)
              MatchCard(match: _demoMatch(), variant: _variant, demo: true)
            else
              for (final match in _items) ...[
                MatchCard(match: match, variant: _variant),
                const SizedBox(height: 12),
              ],
            if (_loadingMore) const AppLoader(size: 44, padding: 8),
            const NavSpacer(),
          ],
        ),
      ),
    );
  }
}
