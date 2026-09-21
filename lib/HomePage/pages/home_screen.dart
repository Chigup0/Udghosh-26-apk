import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/config/fest_info.dart';
import 'package:udghosh/widgets/app_lottie.dart';
import 'package:udghosh/widgets/press_scale.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:udghosh/EventsPage/pages/event_detail_screen.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/models/demo_data.dart';
import 'package:udghosh/models/event.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/match_card.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// Home tab: live hero, sport-count strip, quick actions, upcoming events
/// and informal sports.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenMatches,
    required this.onOpenGallery,
    required this.onOpenMap,
    required this.onOpenNotices,
  });

  /// Jumps to the Matches tab, optionally focusing a specific sport table.
  final void Function({String? sport}) onOpenMatches;
  final VoidCallback onOpenGallery;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenNotices;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MatchRecord? _liveMatch;
  String? _heroSport;
  Map<String, int> _tablesLength = {};
  List<Event> _events = [];
  List<Event> _informalSports = [];
  List<GalleryItem> _gallery = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // Which sports are live has to come back before the hero can be fetched —
    // there is no "live match across all sports" endpoint, so the counts
    // decide which sport to ask for.
    final counts = await ApiService.getTablesLength().catchError(
      (_) => <String, int>{},
    );

    final results = await Future.wait([
      _fetchHeroMatch(counts),
      ApiService.getUpcomingEvents().catchError((_) => <Event>[]),
      ApiService.getInformalSports().catchError((_) => <Event>[]),
      ApiService.getGallery().catchError((_) => <GalleryItem>[]),
    ]);

    if (!mounted) return;
    setState(() {
      _tablesLength = counts;
      _liveMatch = results[0] as MatchRecord?;
      _events = results[1] as List<Event>;
      _informalSports = results[2] as List<Event>;
      _gallery = results[3] as List<GalleryItem>;
      _loading = false;
    });
  }

  /// Picks the busiest live sport and pulls its top match for the hero card.
  Future<MatchRecord?> _fetchHeroMatch(Map<String, int> counts) async {
    final known = counts.keys.where(AppConfig.sportTables.contains).toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    if (known.isEmpty) {
      _heroSport = null;
      return null;
    }
    final sport = known.first;
    _heroSport = sport;
    try {
      final page = await ApiService.getLiveMatches(sport, limit: 1);
      return page.items.isNotEmpty ? page.items.first : null;
    } catch (_) {
      return null;
    }
  }

  void _openEvent(Event event, EventFeed feed) {
    if (event.id <= 0) return; // demo row
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(initial: event, feed: feed),
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: NeoColors.flameGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Expanded, so a trailing action sits on the right edge instead of
          // hugging the title.
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: NeoColors.textMuted,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.waveInk,
                    ),
                  ),
                  const SizedBox(width: 2),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight02,
                    color: NeoColors.waveInk,
                    size: 15,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// [tint] is the decorative wash behind the glyph; [ink] carries the glyph
  /// and clears 4.5:1 on the base.
  Widget _quickAction(
    List<List<dynamic>> icon,
    String label,
    VoidCallback onTap, {
    required Color tint,
    required Color ink,
  }) {
    return Expanded(
      child: Column(
        children: [
          NeumorphicButton(
            onPressed: onTap,
            minDistance: NeoDepth.pressed,
            style: NeoTheme.circleStyle(depth: NeoDepth.button).copyWith(
              color: Color.alphaBlend(
                tint.withValues(alpha: 0.16),
                NeoColors.base,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: HugeIcon(icon: icon, color: ink, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: NeoColors.logoTeal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: NeoColors.waveTeal,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          RichText(
            text: TextSpan(
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
                    color: NeoColors.waveInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          MatchCard(
            match: _liveMatch ?? DemoData.liveMatch('basketball'),
            variant: MatchCardVariant.live,
            demo: _liveMatch == null,
            onTap: () => widget.onOpenMatches(sport: _heroSport),
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
                  return GestureDetector(
                    onTap: () => widget.onOpenMatches(sport: entry.key),
                    child: Neumorphic(
                      style: NeoTheme.raisedStyle(
                        radius: NeoRadii.pill,
                        depth: NeoDepth.chip,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
                        child: Text(
                          '${AppConfig.sportLabel(entry.key)} · ${entry.value}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: NeoColors.logoTeal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          _sectionHeader('Quick actions'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                _quickAction(
                  HugeIcons.strokeRoundedMapsLocation01,
                  'Campus\nMap',
                  widget.onOpenMap,
                  tint: NeoColors.waveTeal,
                  ink: NeoColors.waveInk,
                ),
                _quickAction(
                  HugeIcons.strokeRoundedMedal01,
                  'Standings',
                  () => widget.onOpenMatches(),
                  tint: NeoColors.flameGold,
                  ink: NeoColors.goldInk,
                ),
                _quickAction(
                  HugeIcons.strokeRoundedCalendar03,
                  'Schedule',
                  () => widget.onOpenMatches(),
                  tint: NeoColors.violet,
                  ink: NeoColors.violetInk,
                ),
                _quickAction(
                  HugeIcons.strokeRoundedMegaphone01,
                  'Notices',
                  widget.onOpenNotices,
                  tint: NeoColors.coral,
                  ink: NeoColors.coralInk,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionHeader('Upcoming events'),
          if (_loading)
            const AppLoader(size: 56, padding: 16)
          else if (_events.isEmpty)
            _eventCard(
              'Opening Ceremony',
              '18:00',
              'Main Stadium',
              demo: true,
              onTap: null,
            )
          else
            for (final e in _events.take(5))
              _eventCard(
                e.eventName,
                e.formattedTime,
                e.venue,
                onTap: () => _openEvent(e, EventFeed.upcomingEvent),
              ),
          if (_informalSports.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionHeader('Informal sports'),
            for (final e in _informalSports.take(5))
              _eventCard(
                e.eventName,
                e.formattedTime,
                e.venue,
                icon: HugeIcons.strokeRoundedFootball,
                ink: NeoColors.coralInk,
                onTap: () => _openEvent(e, EventFeed.informalSport),
              ),
          ],
          // Only appears once there are real photos, so the home page never
          // carries an empty strip waiting to be filled.
          if (_gallery.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionHeader(
              'Fest moments',
              actionLabel: 'See all',
              onAction: widget.onOpenGallery,
            ),
            _galleryStrip(),
          ],
          const SizedBox(height: 28),
          _footer(),
          const NavSpacer(),
        ],
      ),
    );
  }

  /// Horizontal photo strip. Tapping any tile opens the Gallery tab rather
  /// than a one-off viewer, so the strip reads as a window into that tab.
  Widget _galleryStrip() {
    final photos = _gallery.take(8).toList();
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => PressScale(
          onTap: widget.onOpenGallery,
          child: Neumorphic(
            style: NeoTheme.raisedStyle(radius: 16, depth: NeoDepth.chip),
            child: SizedBox(
              width: 148,
              child: CachedNetworkImage(
                imageUrl: photos[i].imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedImage02,
                    color: NeoColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Closing block: campus helplines first (the thing someone needs in a
  /// hurry), then the fest's official channels.
  Widget _footer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('Emergency contacts'),
        NeoCard(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          child: Column(
            children: [
              for (final contact in FestInfo.emergencyContacts)
                GestureDetector(
                  onTap: () => _open(contact.dialUri),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: contact.icon,
                          color: NeoColors.alert,
                          size: 19,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            contact.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.logoTeal,
                            ),
                          ),
                        ),
                        Text(
                          contact.number,
                          style: TextStyle(
                            fontSize: 12,
                            color: NeoColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCall02,
                          color: NeoColors.waveInk,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _sectionHeader('Follow the fest'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final channel in FestInfo.channels)
              GestureDetector(
                onTap: () => _open(channel.url),
                child: Neumorphic(
                  style: NeoTheme.raisedStyle(
                    radius: NeoRadii.pill,
                    depth: NeoDepth.chip,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: channel.icon,
                        color: NeoColors.waveInk,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        channel.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: NeoColors.logoTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Udghosh '26  //  IIT Kanpur",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NeoColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _eventCard(
    String name,
    String time,
    String venue, {
    bool demo = false,
    List<List<dynamic>>? icon,
    Color? ink,
    VoidCallback? onTap,
  }) {
    final subtitle = [time, venue].where((s) => s.isNotEmpty).join('  //  ');

    return NeoCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          NeoInset(
            radius: 14,
            padding: const EdgeInsets.all(11),
            child: HugeIcon(
              icon: icon ?? HugeIcons.strokeRoundedCalendar03,
              color: ink ?? NeoColors.waveInk,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: NeoColors.logoTeal,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: NeoColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (demo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NeoColors.flameGold,
                borderRadius: BorderRadius.circular(NeoRadii.pill),
              ),
              child: Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.onGold,
                ),
              ),
            )
          else if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: NeoColors.textMuted),
        ],
      ),
    );
  }
}
