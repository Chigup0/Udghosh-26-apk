import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/EventsPage/pages/event_detail_screen.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/config/fest_info.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/model2/theme/m2_style.dart';
import 'package:udghosh/model2/widgets/m2_match_card.dart';
import 'package:udghosh/model2/widgets/m2_widgets.dart';
import 'package:udghosh/models/event.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/widgets/app_lottie.dart';
import 'package:udghosh/widgets/press_scale.dart';
import 'package:url_launcher/url_launcher.dart';

/// Model 2 Home.
///
/// Same four fetches as Model 1 (live counts → hero match, events, informal
/// sports, gallery) with identical fallbacks; only the arrangement changes.
class M2Home extends StatefulWidget {
  const M2Home({
    super.key,
    required this.onOpenMatches,
    required this.onOpenGallery,
    required this.onOpenMap,
    required this.onOpenNotices,
  });

  final void Function({String? sport}) onOpenMatches;
  final VoidCallback onOpenGallery;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenNotices;

  @override
  State<M2Home> createState() => _M2HomeState();
}

class _M2HomeState extends State<M2Home> {
  MatchRecord? _liveMatch;
  String? _heroSport;
  Map<String, int> _counts = {};
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
    final counts = await ApiService.getTablesLength().catchError(
      (_) => <String, int>{},
    );
    final results = await Future.wait([
      _hero(counts),
      ApiService.getUpcomingEvents().catchError((_) => <Event>[]),
      ApiService.getInformalSports().catchError((_) => <Event>[]),
      ApiService.getGallery().catchError((_) => <GalleryItem>[]),
    ]);
    if (!mounted) return;
    setState(() {
      _counts = counts;
      _liveMatch = results[0] as MatchRecord?;
      _events = results[1] as List<Event>;
      _attractions = results[2] as List<Event>;
      _gallery = results[3] as List<GalleryItem>;
      _loading = false;
    });
  }

  Future<MatchRecord?> _hero(Map<String, int> counts) async {
    final known = counts.keys.where(AppConfig.sportTables.contains).toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    if (known.isEmpty) {
      _heroSport = null;
      return null;
    }
    _heroSport = known.first;
    try {
      final page = await ApiService.getLiveMatches(known.first, limit: 1);
      return page.items.isNotEmpty ? page.items.first : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  int get _liveTotal => _counts.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: NeoColors.waveTeal,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        children: [
          if (_attractions.isNotEmpty) ...[
            const M2SectionTitle('Major attractions'),
            _attractionsCarousel(),
            const SizedBox(height: 22),
          ],
          _statusBar(),
          const SizedBox(height: 18),
          if (_liveMatch != null)
            M2MatchCard(
              match: _liveMatch!,
              kind: M2CardKind.live,
              onTap: () => widget.onOpenMatches(sport: _heroSport),
            )
          else if (!_loading)
            M2Plinth(
              onTap: () => widget.onOpenMatches(),
              radius: M2.rCard,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  M2Well(
                    radius: 13,
                    padding: const EdgeInsets.all(11),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedChampion,
                      color: NeoColors.waveInk,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'No live match right now',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const AppLoader(size: 56, padding: 16),
          if (_counts.isNotEmpty) ...[
            const SizedBox(height: 22),
            const M2SectionTitle('Live right now'),
            _liveDials(),
          ],
          const SizedBox(height: 22),
          const M2SectionTitle('Upcoming events'),
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
              _eventRow(
                e.eventName,
                e.formattedTime,
                e.venue,
                onTap: () => _openEvent(e, EventFeed.upcomingEvent),
              ),
          const SizedBox(height: 22),
          const M2SectionTitle('Jump to'),
          _actionDeck(),
          if (_gallery.isNotEmpty) ...[
            const SizedBox(height: 22),
            M2SectionTitle(
              'Fest moments',
              action: 'See all',
              onAction: widget.onOpenGallery,
            ),
            _galleryMosaic(),
          ],
          const SizedBox(height: 26),
          const M2SectionTitle('Emergency contacts'),
          _contacts(),
          const SizedBox(height: 22),
          const M2SectionTitle('Follow the fest'),
          _channels(),
          const SizedBox(height: 26),
          Center(
            child: Text(
              "UDGHOSH '26  ·  IIT KANPUR",
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: NeoColors.textMuted,
              ),
            ),
          ),
          const NavSpacer(),
        ],
      ),
    );
  }

  void _openEvent(Event event, EventFeed feed) {
    if (event.id <= 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(initial: event, feed: feed),
      ),
    );
  }

  /// Headline strip: a live counter in an embossed readout beside the
  /// wordmark, so the first thing on screen is "how much is happening".
  Widget _statusBar() {
    return M2Plinth(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MATCH CENTRE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: NeoColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _liveTotal > 0 ? 'Games in play' : 'No games in play',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.logoTeal,
                  ),
                ),
              ],
            ),
          ),
          M2Readout(
            value: '$_liveTotal',
            size: 30,
            color: _liveTotal > 0 ? NeoColors.liveInk : NeoColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ],
      ),
    );
  }

  /// Each live sport as a convex dial with its count embossed beneath.
  Widget _liveDials() {
    final entries = _counts.entries.toList();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final entry = entries[i];
          return GestureDetector(
            onTap: () => widget.onOpenMatches(sport: entry.key),
            child: Neumorphic(
              style: M2.plinth(radius: 18, depth: M2.cardDepth),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Neumorphic(
                    style: M2.readout(radius: 999),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 4,
                    ),
                    child: Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.liveInk,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.sportLabel(entry.key),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      child: Neumorphic(
        style: M2.well(radius: 20, depth: -4),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
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
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (event.venue.isNotEmpty ||
                        event.formattedTime.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        [
                          event.formattedTime,
                          event.venue,
                        ].where((s) => s.isNotEmpty).join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
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
      ),
    );
  }

  Widget _actionDeck() {
    final actions = [
      (HugeIcons.strokeRoundedMapsLocation01, 'Campus map', widget.onOpenMap),
      (
        HugeIcons.strokeRoundedCalendar03,
        'Schedule',
        () => widget.onOpenMatches(),
      ),
      (HugeIcons.strokeRoundedMedal01, 'Results', () => widget.onOpenMatches()),
      (HugeIcons.strokeRoundedMegaphone01, 'Notices', widget.onOpenNotices),
    ];
    return M2Plinth(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: Column(
                children: [
                  M2Knob(
                    icon: action.$1,
                    onTap: action.$3,
                    size: 52,
                    color: NeoColors.waveInk,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    action.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _eventRow(
    String name,
    String time,
    String venue, {
    List<List<dynamic>>? icon,
    VoidCallback? onTap,
  }) {
    final meta = [time, venue].where((s) => s.isNotEmpty).join('  ·  ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: M2Plinth(
        onTap: onTap,
        radius: M2.rCard,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            M2Well(
              radius: 13,
              padding: const EdgeInsets.all(11),
              child: HugeIcon(
                icon: icon ?? HugeIcons.strokeRoundedCalendar03,
                color: NeoColors.waveInk,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: TextStyle(
                        fontSize: 11,
                        color: NeoColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight02,
                color: NeoColors.textMuted,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  /// "=|" mosaic: two stacked tiles on the left, one tall tile on the right —
  /// a fixed teaser rather than a scroll strip. Each tile sits in its own
  /// well, like a print set into the panel.
  Widget _galleryMosaic() {
    final photos = _gallery.take(3).toList();
    if (photos.length < 3) {
      return SizedBox(
        height: 150,
        child: Row(
          children: [
            for (var i = 0; i < photos.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
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
                const SizedBox(height: 12),
                Expanded(child: _galleryTile(photos[1])),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
        style: M2.well(radius: 18, depth: -4),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
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
                    size: 20,
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

  Widget _contacts() {
    return M2Plinth(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (final contact in FestInfo.emergencyContacts)
            GestureDetector(
              onTap: () => _open(contact.dialUri),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: contact.icon,
                      color: NeoColors.alert,
                      size: 18,
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
                        fontSize: 11.5,
                        color: NeoColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCall02,
                      color: NeoColors.waveInk,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _channels() {
    return GridView.count(
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
              style: M2.plinth(radius: 18, depth: M2.cardDepth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: channel.icon,
                    color: NeoColors.waveInk,
                    size: 21,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    channel.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
