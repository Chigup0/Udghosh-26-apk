import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

class _Venue {
  const _Venue(this.name, this.point, this.schedulePreview);
  final String name;
  final LatLng point;
  final String schedulePreview;
}

const _venues = [
  _Venue('Main Stadium', LatLng(26.506224127688213, 80.22945615864042),
      'Athletics finals // 4:00 PM  ·  Football final // 5:00 PM'),
  _Venue('Old SAC', LatLng(26.509668447573063, 80.23009338292336),
      'Table Tennis // 2:00 PM  ·  Badminton semis // 3:30 PM'),
  _Venue('New SAC', LatLng(26.5085011950421, 80.23300520800755),
      'Basketball // 6:00 PM  ·  Volleyball // 7:30 PM'),
];

/// Full-page interactive campus map with rounded venue marker badges and a
/// bottom sliding card previewing that venue's schedule.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  _Venue _selected = _venues.first;

  Widget _marker(_Venue venue) {
    final active = venue.name == _selected.name;
    return GestureDetector(
      onTap: () => setState(() => _selected = venue),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(26.5085011950421, 80.23300520800755),
              initialZoom: 15,
              minZoom: 14,
              maxZoom: 17,
            ),
            children: [
              TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
              MarkerLayer(
                markers: [
                  for (final v in _venues)
                    Marker(
                      point: v.point,
                      width: 120,
                      height: 66,
                      child: _marker(v),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 16,
            child: SafeArea(
              child: NeoCircleButtonBack(),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: NeoCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceRecessed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.stadium_rounded, color: NeoColors.waveTeal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selected.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: NeoColors.logoTeal, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selected.schedulePreview,
                          style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
                        ),
                      ],
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

class NeoCircleButtonBack extends StatelessWidget {
  const NeoCircleButtonBack({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return NeoCircleButton(
      onTap: () => Navigator.of(context).pop(),
      child: const Icon(Icons.arrow_back_rounded, color: NeoColors.logoTeal, size: 20),
    );
  }
}
