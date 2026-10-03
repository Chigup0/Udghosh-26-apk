import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:udghosh/MapPage/widgets/map_search.dart';
import 'package:udghosh/config/campus_places.dart';
import 'package:udghosh/config/feature_controller.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

class _Venue {
  const _Venue(this.name, this.point, this.schedulePreview);
  final String name;
  final LatLng point;
  final String schedulePreview;
}

const _venues = [
  _Venue(
    'Main Stadium',
    LatLng(26.506224127688213, 80.22945615864042),
    'Athletics finals // 4:00 PM  ·  Football final // 5:00 PM',
  ),
  _Venue(
    'Old SAC',
    LatLng(26.509668447573063, 80.23009338292336),
    'Table Tennis // 2:00 PM  ·  Badminton semis // 3:30 PM',
  ),
  _Venue(
    'New SAC',
    LatLng(26.5085011950421, 80.23300520800755),
    'Basketball // 6:00 PM  ·  Volleyball // 7:30 PM',
  ),
];

/// Bounding box of the campus, used to frame the opening view and the
/// recentre action.
final _campusBounds = LatLngBounds(
  const LatLng(26.4995, 80.2195),
  const LatLng(26.5215, 80.2400),
);

/// Full-page interactive campus map.
///
/// Fest venues are always shown. On top of those, ~270 campus places from
/// OpenStreetMap can be layered in — toggled by
/// [FeatureController.campusPlaces], so the map reverts exactly to the original
/// three-venue view when it is off.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Below this zoom the pins overlap into unreadable clutter.
  static const double _placesMinZoom = 15;

  /// Hard ceiling on drawn pins. flutter_map has no clustering here, and a few
  /// hundred markers at once turns panning into a slideshow.
  static const int _maxPins = 80;

  final MapController _map = MapController();

  _Venue _selectedVenue = _venues.first;
  CampusPlace? _selectedPlace;
  PlaceCategory? _filter;

  /// Pins for the current camera. Computed when movement settles rather than
  /// inside `build`, so a pan does not re-filter 269 places every frame.
  List<CampusPlace> _pins = const [];

  /// Camera updates are throttled. `onPositionChanged` fires on *every* frame
  /// of a drag or pinch, and calling setState from there rebuilt the map and
  /// all of its markers per frame — which is what made panning unusable.
  Timer? _cameraSettle;

  /// Only the major set is pinned by default — every ground and food outlet,
  /// the halls, the campus landmarks. The rest stay searchable and can be
  /// switched on from the places menu.
  bool _majorOnly = true;
  double _zoom = 16;
  bool _ready = false;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  List<MapSearchHit> _results = const [];

  /// Search starts collapsed into a circular button; tapping it expands the
  /// field in place. The places menu is the sibling circular button.
  bool _searchExpanded = false;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    CampusPlaces.load().then((_) {
      if (mounted) {
        setState(() {
          _ready = true;
          // Re-run any query typed while the asset was still loading.
          _runSearch(_searchController.text);
        });
        _recomputePins();
      }
    });
  }

  @override
  void dispose() {
    _cameraSettle?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Fest venues, as search rows.
  List<MapSearchHit> get _venueHits => [
    for (final v in _venues)
      MapSearchHit(
        name: v.name,
        subtitle: v.schedulePreview,
        point: v.point,
        glyph: HugeIcons.strokeRoundedChampion,
        isVenue: true,
      ),
  ];

  void _runSearch(String value) {
    _results = MapSearch.query(
      value,
      venues: _venueHits,
      // With the layer off, only fest venues are searchable — matching what
      // is actually drawn on the map.
      includePlaces: _placesOn,
    );
  }

  void _onSearchChanged(String value) => setState(() => _runSearch(value));

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _results = const []);
  }

  void _expandSearch() {
    setState(() {
      _searchExpanded = true;
      _menuOpen = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _collapseSearch() {
    _searchFocus.unfocus();
    setState(() {
      _searchExpanded = false;
      _searchController.clear();
      _results = const [];
    });
  }

  void _toggleMenu() => setState(() {
    _menuOpen = !_menuOpen;
    if (_menuOpen) _searchFocus.unfocus();
  });

  /// Centres on a hit and selects it, so the detail card names what you found.
  void _goToHit(MapSearchHit hit) {
    _searchFocus.unfocus();
    setState(() {
      _searchExpanded = false;
      _menuOpen = false;
      if (hit.isVenue) {
        _selectedPlace = null;
        _selectedVenue = _venues.firstWhere(
          (v) => v.name == hit.name,
          orElse: () => _selectedVenue,
        );
      } else {
        _selectedPlace = hit.place;
        // Clear any category filter that would hide the pin we just flew to.
        if (_filter != null && hit.place?.category != _filter) _filter = null;
        // A minor place is not pinned by default; reveal it rather than
        // flying to an empty patch of map.
        if (hit.place?.major == false) _majorOnly = false;
      }
      _results = const [];
    });
    _searchController.clear();
    // Zoom past the pin threshold so the result is actually visible.
    _map.move(hit.point, 17);
  }

  bool get _placesOn =>
      FeatureController.instance.campusPlaces && CampusPlaces.places.isNotEmpty;

  /// Coalesces a burst of camera events into a single state update.
  void _onCameraChanged() {
    _cameraSettle?.cancel();
    _cameraSettle = Timer(const Duration(milliseconds: 140), () {
      if (mounted) _recomputePins();
    });
  }

  void _recomputePins() {
    final camera = _map.camera;
    final zoom = camera.zoom;
    final next = _computePins(camera.visibleBounds, zoom);
    // Only rebuild when something actually changed, so a nudge that moves no
    // pins costs nothing.
    if (zoom == _zoom && _sameIds(next, _pins)) return;
    setState(() {
      _zoom = zoom;
      _pins = next;
    });
  }

  /// Places inside the viewport, filtered and capped.
  List<CampusPlace> _computePins(LatLngBounds bounds, double zoom) {
    if (!_placesOn || zoom < _placesMinZoom) return const [];
    final out = <CampusPlace>[];
    for (final place in CampusPlaces.places) {
      if (_majorOnly && !place.major) continue;
      if (_filter != null && place.category != _filter) continue;
      if (!bounds.contains(place.point)) continue;
      out.add(place);
      if (out.length >= _maxPins) break;
    }
    return out;
  }

  static bool _sameIds(List<CampusPlace> a, List<CampusPlace> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _zoomBy(double delta) {
    final camera = _map.camera;
    _map.move(camera.center, (camera.zoom + delta).clamp(13.0, 19.0));
    _onCameraChanged();
  }

  void _recentre() {
    _map.fitCamera(
      CameraFit.bounds(
        bounds: _campusBounds,
        padding: const EdgeInsets.all(28),
      ),
    );
    _onCameraChanged();
  }

  void _setFilter(PlaceCategory? category) {
    setState(() {
      _filter = category;
      _menuOpen = false;
    });
    _recomputePins();
  }

  Widget _venueMarker(_Venue venue) {
    final active = venue.name == _selectedVenue.name && _selectedPlace == null;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedVenue = venue;
        _selectedPlace = null;
      }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active ? NeoColors.charcoal : NeoColors.surface,
              borderRadius: BorderRadius.circular(NeoRadii.pill),
              boxShadow: NeoShadows.raisedSmall(),
            ),
            child: Text(
              venue.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: active ? NeoColors.onCharcoal : NeoColors.logoTeal,
              ),
            ),
          ),
          Icon(
            Icons.location_on_rounded,
            color: active ? NeoColors.flameGold : NeoColors.waveTeal,
            size: 26,
          ),
        ],
      ),
    );
  }

  /// Campus pins are deliberately smaller and quieter than the venue badges —
  /// the fest venues must stay the loudest thing on the map.
  Widget _placeMarker(CampusPlace place) {
    final active = _selectedPlace?.id == place.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlace = place),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? NeoColors.flameGold : NeoColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? NeoColors.onGold.withValues(alpha: 0.35)
                : NeoColors.waveTeal.withValues(alpha: 0.45),
            width: 1.4,
          ),
          boxShadow: NeoShadows.raisedSmall(),
        ),
        child: HugeIcon(
          icon: place.category.glyph,
          size: 14,
          color: active ? NeoColors.onGold : NeoColors.waveInk,
        ),
      ),
    );
  }

  /// Vertical list of fest venues and, when the campus-places layer is on,
  /// its categories and depth toggle — everything that used to live in a
  /// horizontal chip row now lives here, behind the menu button.
  Widget _placesMenu() {
    final categories = _placesOn
        ? CampusPlaces.categoriesIn(majorOnly: _majorOnly)
        : const <PlaceCategory>[];
    final total = _majorOnly
        ? CampusPlaces.majorCount
        : CampusPlaces.places.length;
    return NeoCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final v in _venueHits)
                _menuRow(
                  icon: HugeIcons.strokeRoundedChampion,
                  label: v.name,
                  tint: NeoColors.flameGold,
                  onTap: () => _goToHit(v),
                ),
              if (categories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: Text(
                    'CAMPUS PLACES',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: NeoColors.textMuted,
                    ),
                  ),
                ),
                _menuRow(
                  icon: HugeIcons.strokeRoundedGridView,
                  label: 'All places ($total)',
                  tint: NeoColors.waveTeal,
                  selected: _filter == null,
                  onTap: () => _setFilter(null),
                ),
                for (final category in categories)
                  _menuRow(
                    icon: category.glyph,
                    label:
                        '${category.label} '
                        '(${CampusPlaces.countOf(category, majorOnly: _majorOnly)})',
                    tint: NeoColors.waveTeal,
                    selected: _filter == category,
                    onTap: () => _setFilter(category),
                  ),
                _menuRow(
                  icon: _majorOnly
                      ? HugeIcons.strokeRoundedViewOffSlash
                      : HugeIcons.strokeRoundedEye,
                  label: _majorOnly ? 'Major only' : 'Showing all',
                  tint: NeoColors.flameGold,
                  onTap: () {
                    setState(() => _majorOnly = !_majorOnly);
                    _recomputePins();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuRow({
    required List<List<dynamic>> icon,
    required String label,
    required Color tint,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        color: selected
            ? NeoColors.surfaceRecessed.withValues(alpha: 0.6)
            : Colors.transparent,
        child: Row(
          children: [
            HugeIcon(icon: icon, color: tint, size: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.logoTeal,
                ),
              ),
            ),
            if (selected)
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: NeoColors.waveInk,
                size: 15,
              ),
          ],
        ),
      ),
    );
  }

  /// Search / menu buttons in the top bar — same shell as [_mapButton] but
  /// without its bottom-stack top padding, and able to show an active tint.
  Widget _topCircleButton(
    List<List<dynamic>> icon,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return NeoCircleButton(
      size: 44,
      onTap: onTap,
      child: HugeIcon(
        icon: icon,
        color: active ? NeoColors.flameGold : NeoColors.logoTeal,
        size: 18,
      ),
    );
  }

  Widget _mapButton(List<List<dynamic>> icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: NeoCircleButton(
        size: 40,
        onTap: onTap,
        child: HugeIcon(icon: icon, color: NeoColors.logoTeal, size: 17),
      ),
    );
  }

  Widget _detailCard() {
    final place = _selectedPlace;
    final isPlace = place != null;
    return NeoCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NeoColors.surfaceRecessed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: isPlace
                ? HugeIcon(
                    icon: place.category.glyph,
                    color: NeoColors.waveInk,
                    size: 21,
                  )
                : Icon(Icons.stadium_rounded, color: NeoColors.waveTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPlace ? place.name : _selectedVenue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: NeoColors.logoTeal,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPlace
                      ? '${place.category.label}'
                            '${place.surveyed ? '  ·  surveyed' : '  ·  OpenStreetMap'}'
                      : _selectedVenue.schedulePreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
                ),
              ],
            ),
          ),
          if (isPlace)
            GestureDetector(
              onTap: () => setState(() => _selectedPlace = null),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: NeoColors.textMuted,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FeatureController.instance,
      builder: (context, _) {
        final zoomedOut = _placesOn && _ready && _zoom < _placesMinZoom;

        return Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: const LatLng(
                  26.5085011950421,
                  80.23300520800755,
                ),
                initialZoom: 16,
                minZoom: 13,
                // OSM serves to 19; building-level pins need the headroom.
                maxZoom: 19,
                initialCameraFit: CameraFit.bounds(
                  bounds: _campusBounds,
                  padding: const EdgeInsets.all(28),
                ),
                onMapReady: _recomputePins,
                // Throttled: this fires on every frame of a drag.
                onPositionChanged: (_, __) => _onCameraChanged(),
                onTap: (_, __) {
                  _searchFocus.unfocus();
                  if (_selectedPlace == null &&
                      _results.isEmpty &&
                      !_menuOpen &&
                      !_searchExpanded) {
                    return;
                  }
                  setState(() {
                    _selectedPlace = null;
                    _results = const [];
                    _menuOpen = false;
                    _searchExpanded = false;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // OSM blocks requests that do not identify themselves. Both
                  // lines matter: `userAgentPackageName` is what flutter_map
                  // uses to build its own UA, and the explicit header supplies
                  // the contact address OSM's tile usage policy asks for.
                  // (`additionalOptions` is URL-template substitution, NOT
                  // headers — it cannot set a User-Agent.)
                  userAgentPackageName: 'in.ac.iitk.udghosh.app',
                  // NOT const: flutter_map calls putIfAbsent on this map to
                  // inject its own UA, and an unmodifiable literal throws
                  // "Cannot modify unmodifiable map" on first paint.
                  tileProvider: NetworkTileProvider(
                    headers: {
                      'User-Agent':
                          'UdghoshFestivalApp/1.0 (contact: tech@udghosh.org.in)',
                    },
                  ),
                  // Holds the previous level on screen while the new one
                  // loads, instead of flashing empty grey tiles.
                  keepBuffer: 3,
                ),
                if (_pins.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      for (final place in _pins)
                        Marker(
                          key: ValueKey(place.id),
                          point: place.point,
                          width: 30,
                          height: 30,
                          child: _placeMarker(place),
                        ),
                    ],
                  ),
                // Venue badges layer last so they draw above the campus pins.
                MarkerLayer(
                  markers: [
                    for (final v in _venues)
                      Marker(
                        point: v.point,
                        width: 120,
                        height: 66,
                        // Puts the pin tip on the coordinate. The default
                        // (centre) floated the badge so the tip pointed about
                        // half its height below the real venue.
                        alignment: Alignment.topCenter,
                        child: _venueMarker(v),
                      ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    // ODbL requires the attribution to travel with the data.
                    TextSourceAttribution(
                      _placesOn
                          ? 'OpenStreetMap contributors · ODbL'
                          : 'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        NeoCircleButtonBack(),
                        if (Navigator.of(context).canPop())
                          const SizedBox(width: 8),
                        if (_searchExpanded)
                          Expanded(
                            child: MapSearchBar(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              results: _results,
                              onChanged: _onSearchChanged,
                              onClear: _clearSearch,
                              onSelected: _goToHit,
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 10),
                        if (_searchExpanded)
                          _topCircleButton(
                            HugeIcons.strokeRoundedCancel01,
                            _collapseSearch,
                          )
                        else ...[
                          _topCircleButton(
                            HugeIcons.strokeRoundedSearch01,
                            _expandSearch,
                          ),
                          const SizedBox(width: 10),
                          _topCircleButton(
                            HugeIcons.strokeRoundedMenu01,
                            _toggleMenu,
                            active: _menuOpen,
                          ),
                        ],
                      ],
                    ),
                    if (_menuOpen && !_searchExpanded) ...[
                      const SizedBox(height: 10),
                      _placesMenu(),
                    ],
                  ],
                ),
              ),
            ),
            // The pin layer has a zoom threshold, so there needs to be a
            // reliable way to cross it without fighting a pinch gesture.
            Positioned(
              right: 16,
              bottom: NavMetrics.gutter(context) + 92,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mapButton(HugeIcons.strokeRoundedPlusSign, () => _zoomBy(1)),
                  _mapButton(
                    HugeIcons.strokeRoundedMinusSign,
                    () => _zoomBy(-1),
                  ),
                  _mapButton(HugeIcons.strokeRoundedLocation01, _recentre),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: NavMetrics.gutter(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (zoomedOut)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _zoomBy(1.5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: NeoColors.charcoal,
                            borderRadius: BorderRadius.circular(NeoRadii.pill),
                          ),
                          child: Text(
                            'Tap to zoom in for campus places',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.onCharcoal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  _detailCard(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class NeoCircleButtonBack extends StatelessWidget {
  const NeoCircleButtonBack({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return NeoCircleButton(
      onTap: () => Navigator.of(context).pop(),
      child: Icon(
        Icons.arrow_back_rounded,
        color: NeoColors.logoTeal,
        size: 20,
      ),
    );
  }
}
