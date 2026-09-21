import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:udghosh/config/campus_places.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// One row in the map search results.
class MapSearchHit {
  const MapSearchHit({
    required this.name,
    required this.subtitle,
    required this.point,
    required this.glyph,
    required this.isVenue,
    this.place,
  });

  final String name;
  final String subtitle;
  final LatLng point;
  final List<List<dynamic>> glyph;

  /// Fest venues rank above campus places and are marked in the list.
  final bool isVenue;
  final CampusPlace? place;
}

/// Ranked lookup over fest venues and campus places.
///
/// Matching is local and synchronous — the whole index is 269 rows already in
/// memory, so there is nothing to debounce and no request to race.
class MapSearch {
  MapSearch._();

  static List<MapSearchHit> query(
    String raw, {
    required List<MapSearchHit> venues,
    bool includePlaces = true,
    int limit = 25,
  }) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final scored = <(int, MapSearchHit)>[];

    void consider(MapSearchHit hit) {
      final name = hit.name.toLowerCase();
      final int score;
      if (name == q) {
        score = 0;
      } else if (name.startsWith(q)) {
        score = 1;
      } else if (_startsWithWord(name, q)) {
        // "sac" should find "Old SAC" and "New SAC", not just prefixes.
        score = 2;
      } else if (name.contains(q)) {
        score = 3;
      } else if (hit.subtitle.toLowerCase().contains(q)) {
        score = 4;
      } else {
        return;
      }
      // Venues outrank places at equal relevance: this is a fest app.
      scored.add((score * 2 + (hit.isVenue ? 0 : 1), hit));
    }

    for (final v in venues) {
      consider(v);
    }
    if (includePlaces) {
      for (final p in CampusPlaces.places) {
        consider(
          MapSearchHit(
            name: p.name,
            subtitle: p.category.label,
            point: p.point,
            glyph: p.category.glyph,
            isVenue: false,
            place: p,
          ),
        );
      }
    }

    scored.sort((a, b) {
      final byScore = a.$1.compareTo(b.$1);
      return byScore != 0 ? byScore : a.$2.name.compareTo(b.$2.name);
    });
    return [for (final e in scored.take(limit)) e.$2];
  }

  static bool _startsWithWord(String name, String q) {
    for (final word in name.split(RegExp(r'[\s/,()-]+'))) {
      if (word.startsWith(q)) return true;
    }
    return false;
  }
}

/// Search field + results sheet that floats over the map.
class MapSearchBar extends StatelessWidget {
  const MapSearchBar({
    super.key,
    required this.controller,
    required this.results,
    required this.onChanged,
    required this.onClear,
    required this.onSelected,
    required this.focusNode,
  });

  final TextEditingController controller;
  final List<MapSearchHit> results;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<MapSearchHit> onSelected;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoCard(
          radius: NeoRadii.pill,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.logoTeal,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    hintText: 'Search halls, messes, venues…',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: NeoColors.textMuted,
                    ),
                  ),
                ),
              ),
              if (hasQuery)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: NeoColors.textMuted,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasQuery) ...[
          const SizedBox(height: 8),
          NeoCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Text(
                      'Nothing on campus matches "${controller.text.trim()}"',
                      style: TextStyle(
                        fontSize: 12,
                        color: NeoColors.textMuted,
                      ),
                    ),
                  )
                : ConstrainedBox(
                    // Caps the sheet so the map stays visible behind it.
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final hit = results[i];
                        return GestureDetector(
                          onTap: () => onSelected(hit),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: hit.glyph,
                                  color: hit.isVenue
                                      ? NeoColors.flameGold
                                      : NeoColors.waveInk,
                                  size: 17,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hit.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: NeoColors.logoTeal,
                                        ),
                                      ),
                                      Text(
                                        hit.isVenue
                                            ? 'Fest venue'
                                            : hit.subtitle,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: NeoColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight02,
                                  color: NeoColors.textMuted,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}
