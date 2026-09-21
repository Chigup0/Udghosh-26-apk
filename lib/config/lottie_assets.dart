import 'package:flutter/services.dart';

/// The animated states the app can show.
enum AppAnim {
  /// Spinner shown while a request is in flight.
  loader,

  /// No network connection at all.
  offline,

  /// Reached the server but it failed (5xx / unreachable host).
  serverDown,

  /// Request succeeded, list is legitimately empty.
  empty,

  /// Nothing scheduled — no upcoming fixtures for this sport.
  noFixtures,

  /// Gallery has no photos yet.
  noPhotos,

  /// Search returned nothing.
  noResults,
}

/// Resolves Lottie files at runtime.
///
/// Flutter throws if `Lottie.asset` is given a path that is not bundled, so
/// every lookup here is checked against the real asset manifest first. That
/// makes the whole set **drop-in**: add a JSON file with one of the documented
/// names, run `flutter pub get`, and it starts being used — no code change. Any
/// name that is still missing returns null, and the widgets fall back to their
/// icon-based state, which looks deliberate rather than broken.
///
/// Expected filenames, all directly inside `assets/lottie/` (that folder is
/// already registered in pubspec, and Flutter's directory entries are *not*
/// recursive — so subfolders would need their own pubspec line):
///
/// * per sport — `sport_cricket.json`, `sport_football.json`, … using the
///   canonical `AppConfig.sportTables` name
/// * shared sport fallback — `sport_generic.json`
/// * states — `state_offline.json`, `state_server_down.json`,
///   `state_empty.json`, `state_no_fixtures.json`, `state_no_photos.json`,
///   `state_no_results.json`
/// * loader — `state_loader.json`
class LottieAssets {
  LottieAssets._();

  static const String _dir = 'assets/lottie/';

  static Set<String> _bundled = const {};
  static bool _ready = false;

  /// Reads the asset manifest once. Call from `main()` before `runApp`.
  ///
  /// Failure here is never fatal: the app just falls back to icon states.
  static Future<void> warmUp() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _bundled = manifest
          .listAssets()
          .where((a) => a.startsWith(_dir) && a.endsWith('.json'))
          .toSet();
    } catch (_) {
      _bundled = const {};
    }
    _ready = true;
  }

  static bool get isReady => _ready;

  /// Everything the app found, for diagnostics.
  static Set<String> get bundled => _bundled;

  static String? _first(List<String> candidates) {
    for (final path in candidates) {
      if (_bundled.contains(path)) return path;
    }
    return null;
  }

  /// Animation for [sport], falling back to the shared sport animation.
  /// [sport] is a canonical `AppConfig.sportTables` value.
  static String? sport(String sport) =>
      _first(['${_dir}sport_$sport.json', '${_dir}sport_generic.json']);

  /// True when this sport has art of its own rather than the shared fallback.
  static bool hasOwnSportAnim(String sport) =>
      _bundled.contains('${_dir}sport_$sport.json');

  /// Animation for a state.
  ///
  /// Each looks for its own `state_*.json` first, then falls back to one of the
  /// five files already in `assets/lottie/loading/`. Those five were bundled
  /// under "loading" but only one is a spinner — the others are idle/empty
  /// illustrations ("Order history empty", "sleeping", "fantoma", "Paperplane"),
  /// so they are reused here where they actually fit.
  static String? state(AppAnim anim) {
    switch (anim) {
      case AppAnim.loader:
        return _first([
          '${_dir}state_loader.json',
          '${_dir}loading/loading2.json',
          '${_dir}loading/loading.json',
        ]);
      case AppAnim.offline:
        return _first([
          '${_dir}state_offline.json',
          '${_dir}loading/loading.json', // Paperplane — "couldn't get through"
        ]);
      case AppAnim.serverDown:
        return _first([
          '${_dir}state_server_down.json',
          '${_dir}loading/2.json', // fantoma — nobody home
        ]);
      case AppAnim.empty:
        return _first([
          '${_dir}state_empty.json',
          '${_dir}loading/1.json', // "Order history empty"
        ]);
      case AppAnim.noFixtures:
        return _first([
          '${_dir}state_no_fixtures.json',
          '${_dir}loading/3.json', // "sleeping" — nothing on today
        ]);
      case AppAnim.noPhotos:
        return _first(['${_dir}state_no_photos.json', '${_dir}loading/1.json']);
      case AppAnim.noResults:
        return _first([
          '${_dir}state_no_results.json',
          '${_dir}loading/1.json',
        ]);
    }
  }
}
