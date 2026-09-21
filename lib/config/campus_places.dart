import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

/// Buckets the campus places are grouped into.
enum PlaceCategory {
  hostel,
  academic,
  food,
  sports,
  services,
  shop,
  bank,
  health,
  transport,
  utility,
  stay,
  other;

  static PlaceCategory parse(String raw) {
    for (final c in PlaceCategory.values) {
      if (c.name == raw) return c;
    }
    return PlaceCategory.other;
  }

  String get label {
    switch (this) {
      case PlaceCategory.hostel:
        return 'Halls';
      case PlaceCategory.academic:
        return 'Academic';
      case PlaceCategory.food:
        return 'Food';
      case PlaceCategory.sports:
        return 'Sports';
      case PlaceCategory.services:
        return 'Services';
      case PlaceCategory.shop:
        return 'Shops';
      case PlaceCategory.bank:
        return 'Banks';
      case PlaceCategory.health:
        return 'Health';
      case PlaceCategory.transport:
        return 'Transport';
      case PlaceCategory.utility:
        return 'Utilities';
      case PlaceCategory.stay:
        return 'Stay';
      case PlaceCategory.other:
        return 'Other';
    }
  }

  List<List<dynamic>> get glyph {
    switch (this) {
      case PlaceCategory.hostel:
        return HugeIcons.strokeRoundedBuilding03;
      case PlaceCategory.academic:
        return HugeIcons.strokeRoundedBook02;
      case PlaceCategory.food:
        return HugeIcons.strokeRoundedRestaurant02;
      case PlaceCategory.sports:
        return HugeIcons.strokeRoundedChampion;
      case PlaceCategory.services:
        return HugeIcons.strokeRoundedOffice;
      case PlaceCategory.shop:
        return HugeIcons.strokeRoundedShoppingBag01;
      case PlaceCategory.bank:
        return HugeIcons.strokeRoundedBank;
      case PlaceCategory.health:
        return HugeIcons.strokeRoundedHospital01;
      case PlaceCategory.transport:
        return HugeIcons.strokeRoundedBus01;
      case PlaceCategory.utility:
        return HugeIcons.strokeRoundedDroplet;
      case PlaceCategory.stay:
        return HugeIcons.strokeRoundedHotel01;
      case PlaceCategory.other:
        return HugeIcons.strokeRoundedMapPinpoint01;
    }
  }
}

/// One mapped place on campus.
class CampusPlace {
  const CampusPlace({
    required this.id,
    required this.name,
    required this.point,
    required this.category,
    required this.surveyed,
    required this.major,
  });

  final String id;
  final String name;
  final LatLng point;
  final PlaceCategory category;

  /// True for the handful of points hand-surveyed rather than taken from OSM.
  final bool surveyed;

  /// Whether this is a place worth pinning by default — every ground and food
  /// outlet, the halls, the campus landmarks. Minor places (staff housing
  /// blocks, individual labs, ATMs, parks) stay in the data and remain
  /// searchable, but are off the map unless the user asks for them.
  final bool major;

  static CampusPlace? fromJson(Map<String, dynamic> j) {
    final lat = (j['lat'] as num?)?.toDouble();
    final lon = (j['lon'] as num?)?.toDouble();
    final name = (j['n'] ?? '').toString();
    if (lat == null || lon == null || name.isEmpty) return null;
    return CampusPlace(
      id: (j['id'] ?? name).toString(),
      name: name,
      point: LatLng(lat, lon),
      category: PlaceCategory.parse((j['c'] ?? 'other').toString()),
      surveyed: j['s'] == 'survey',
      major: j['r'] == 'major',
    );
  }
}

/// Campus place index, loaded once from the bundled asset.
///
/// Data is OpenStreetMap under **ODbL**, extracted from the OSM dumps in
/// `github.com/ni5arga/iitk` plus that project's hand-surveyed points. ODbL
/// requires the attribution to travel with the data, so [attribution] is shown
/// on the map rather than being dropped.
class CampusPlaces {
  CampusPlaces._();

  static const String assetPath = 'assets/data/campus_places.json';

  static List<CampusPlace> _places = const [];
  static String _attribution = '';
  static bool _loaded = false;

  /// Everything in the index, major and minor.
  static List<CampusPlace> get places => _places;

  /// The default map set.
  static List<CampusPlace> get majorPlaces =>
      _places.where((p) => p.major).toList(growable: false);

  static int get majorCount => _places.where((p) => p.major).length;
  static String get attribution => _attribution;
  static bool get isLoaded => _loaded;

  /// Categories present in the given set, ordered by how many places they
  /// hold, so the filter bar matches what is actually pinned.
  static List<PlaceCategory> categoriesIn({bool majorOnly = true}) {
    final counts = <PlaceCategory, int>{};
    for (final p in _places) {
      if (majorOnly && !p.major) continue;
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    final keys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return keys;
  }

  static int countOf(PlaceCategory category, {bool majorOnly = true}) => _places
      .where((p) => p.category == category && (!majorOnly || p.major))
      .length;

  /// Loads the asset once. Safe to call repeatedly; failure leaves the list
  /// empty and the map simply shows no extra pins.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _attribution = (decoded['attribution'] ?? '').toString();
        final list = decoded['places'];
        if (list is List) {
          _places = list
              .whereType<Map>()
              .map((e) => CampusPlace.fromJson(e.cast<String, dynamic>()))
              .whereType<CampusPlace>()
              .toList(growable: false);
        }
      }
    } catch (_) {
      _places = const [];
    }
    _loaded = true;
  }
}
