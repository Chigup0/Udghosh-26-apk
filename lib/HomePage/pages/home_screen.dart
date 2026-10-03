import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/config/fest_info.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/widgets/app_lottie.dart';
import 'package:udghosh/widgets/press_scale.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:udghosh/EventsPage/pages/event_detail_screen.dart';
import 'package:udghosh/config/app_config.dart';
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
  // "Informal sports" feed, rebranded on Home as the "Major attractions"
  // carousel — same backend endpoint, different presentation.
  List<Event> _attractions = [];
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
      _attractions = results[2] as List<Event>;
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
          if (_attractions.isNotEmpty) ...[
            _sectionHeader('Major attractions'),
            _attractionsCarousel(),
            const SizedBox(height: 24),
          ],
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
          if (_liveMatch != null)
            MatchCard(
              match: _liveMatch!,
              variant: MatchCardVariant.live,
              onTap: () => widget.onOpenMatches(sport: _heroSport),
            )
          else if (!_loading)
            NeoCard(
              onTap: () => widget.onOpenMatches(),
              child: Row(
                children: [
                  NeoInset(
                    radius: 14,
                    padding: const EdgeInsets.all(11),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedChampion,
                      color: NeoColors.waveInk,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No live match right now',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const AppLoader(size: 56, padding: 16),
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
          _sectionHeader('Upcoming events'),
          if (_loading)
            const AppLoader(size: 56, padding: 16)
          else if (_events.isEmpty)
            const AppStateView(
              anim: AppAnim.noFixtures,
              title: 'No events announced yet',
              compact: true,
            )
          else
            for (final e in _events.take(5))
              _eventCard(
                e.eventName,
                e.formattedTime,
                e.venue,
                onTap: () => _openEvent(e, EventFeed.upcomingEvent),
              ),
          const SizedBox(height: 20),
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
          // Only appears once there are real photos, so the home page never
          // carries an empty strip waiting to be filled.
          if (_gallery.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionHeader(
              'Fest moments',
              actionLabel: 'See all',
              onAction: widget.onOpenGallery,
            ),
            _galleryMosaic(),
          ],
          const SizedBox(height: 28),
          _footer(),
          const NavSpacer(),
        ],
      ),
    );
  }

  /// Big swipeable image cards for the fest's headline informal events —
  /// one per page, matching the source data's own order.
  Widget _attractionsCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.86,
        enlargeCenterPage: true,
        enableInfiniteScroll: _attractions.length > 1,
      ),
      items: [
        for (final e in _attractions.take(8)) _attractionCard(e),
      ],
    );
  }

  Widget _attractionCard(Event event) {
    return PressScale(
      onTap: () => _openEvent(event, EventFeed.informalSport),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (event.fullImageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: event.fullImageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: NeoColors.surfaceRecessed,
                ),
              )
            else
              Container(color: NeoColors.surfaceRecessed),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.4, 1],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (event.venue.isNotEmpty || event.formattedTime.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      [
                        event.formattedTime,
                        event.venue,
                      ].where((s) => s.isNotEmpty).join('  //  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "=|" mosaic: two stacked tiles on the left, one tall tile on the right.
  /// A fixed, glanceable teaser rather than a scroll strip — tapping any tile
  /// (or the extra-count badge) opens the Gallery tab.
  Widget _galleryMosaic() {
    final photos = _gallery.take(3).toList();
    if (photos.length < 3) {
      return SizedBox(
        height: 150,
        child: Row(
          children: [
            for (var i = 0; i < photos.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _galleryTile(photos[i])),
            ],
          ],
        ),
      );
    }
    final extra = _gallery.length - 3;
    return SizedBox(
      height: 168,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: _galleryTile(photos[0])),
                const SizedBox(height: 10),
                Expanded(child: _galleryTile(photos[1])),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _galleryTile(photos[2], badge: extra > 0 ? '+$extra' : null),
          ),
        ],
      ),
    );
  }

  Widget _galleryTile(GalleryItem photo, {String? badge}) {
    return PressScale(
      onTap: widget.onOpenGallery,
      child: Neumorphic(
        style: NeoTheme.raisedStyle(radius: 18, depth: NeoDepth.chip),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: photo.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: NeoColors.surfaceRecessed,
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedImage02,
                    color: NeoColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '$badge more',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
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
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: [
            for (final channel in FestInfo.channels)
              GestureDetector(
                onTap: () => _open(channel.url),
                child: Neumorphic(
                  style: NeoTheme.raisedStyle(
                    radius: NeoRadii.card,
                    depth: NeoDepth.chip,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: channel.icon,
                        color: NeoColors.waveInk,
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        channel.label,
                        style: TextStyle(
                          fontSize: 11.5,
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
            "Udghosh '26  |  IIT Kanpur",
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
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: NeoColors.textMuted),
        ],
      ),
    );
  }
}
