import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Optional extras the user can switch off.
///
/// Anything here is additive: turning a flag off must leave the app exactly as
/// it was before the feature existed, never in a degraded state.
class FeatureController extends ChangeNotifier {
  FeatureController._();
  static final FeatureController instance = FeatureController._();

  static const _campusPlacesKey = 'feature_campus_places';

  bool _campusPlaces = true;

  /// Whether the campus place pins (OSM data) are drawn on the map.
  /// Off leaves only the three fest venue markers, which is the original map.
  bool get campusPlaces => _campusPlaces;

  /// Loads saved flags. Call once from `main()` before `runApp`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _campusPlaces = prefs.getBool(_campusPlacesKey) ?? true;
    notifyListeners();
  }

  Future<void> setCampusPlaces(bool value) async {
    if (value == _campusPlaces) return;
    _campusPlaces = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_campusPlacesKey, value);
  }
}
