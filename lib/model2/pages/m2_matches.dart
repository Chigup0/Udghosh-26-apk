import 'dart:async';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/model2/widgets/m2_match_card.dart';
import 'package:udghosh/model2/widgets/m2_widgets.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/widgets/app_lottie.dart';

/// Model 2 Matches.
///
/// Identical behaviour to Model 1: same three feeds, same 20s live poll, same
/// debounced search, same pagination rules (page advances only on success).
class M2Matches extends StatefulWidget {
  const M2Matches({super.key});

  @override
  M2MatchesState createState() => M2MatchesState();
}

class M2MatchesState extends State<M2Matches> {
  static const _tabs = ['Results', 'Live', 'Fixtures'];
  static const _liveTab = 1;
  static const _upcomingTab = 2;

  int _sportIndex = 0;
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

  /// Focuses a sport from outside the screen (the Home hero taps through).
  void selectSport(String sportTable) {
    final i = AppConfig.sportTables.indexOf(
      AppConfig.normalizeSport(sportTable),
    );
    if (i < 0 || i == _sportIndex) return;
    _searchDebounce?.cancel();
    setState(() => _sportIndex = i);
    _reload();
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

  M2CardKind get _kind {
    switch (_tabIndex) {
      case _liveTab:
        return M2CardKind.live;
      case _upcomingTab:
        return M2CardKind.upcoming;
      default:
        return M2CardKind.completed;
    }
  }

  String get _emptyTitle {
    switch (_tabIndex) {
      case _liveTab:
        return 'Nothing live right now';
      case _upcomingTab:
        return 'No upcoming fixtures';
      default:
        return 'No completed matches yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final empty = _items.isEmpty;
    final showEmpty = empty && _search.isEmpty && !_loading;
    final showNoResults = empty && _search.isNotEmpty && !_loading;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            children: [
              M2ChipRail(
                labels: AppConfig.sportTables
                    .map(AppConfig.sportLabel)
                    .toList(),
                index: _sportIndex,
                onSelected: (i) {
                  setState(() => _sportIndex = i);
                  _reload();
                },
              ),
              const SizedBox(height: 12),
              M2Well(
                radius: 999,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: NeoColors.textMuted,
                      size: 17,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: _submitSearch,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: NeoColors.logoTeal,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          hintText: 'Search team, venue or category',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: NeoColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: _clearSearchField,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: NeoColors.textMuted,
                          size: 15,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              M2Switch(
                labels: _tabs,
                index: _tabIndex,
                onChanged: (i) {
                  setState(() => _tabIndex = i);
                  _reload();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                children: [
                  if (_failure != null && !empty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _failure!.message,
                        style: TextStyle(color: NeoColors.alert, fontSize: 12),
                      ),
                    ),
                  if (_loading && empty)
                    const AppLoader()
                  else if (_failure != null && empty)
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
                  else if (showEmpty)
                    AppStateView(
                      anim: AppAnim.noFixtures,
                      sport: _sport,
                      title: _emptyTitle,
                      compact: true,
                    )
                  else
                    for (final match in _items) ...[
                      M2MatchCard(match: match, kind: _kind),
                      const SizedBox(height: 14),
                    ],
                  if (_loadingMore) const AppLoader(size: 44, padding: 8),
                  const NavSpacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
