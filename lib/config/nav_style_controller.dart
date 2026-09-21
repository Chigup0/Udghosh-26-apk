import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which bottom bar the shell renders.
enum NavStyle {
  /// The original solid pill dock. Untouched — this is exactly what shipped.
  classic,

  /// Translucent blurred bar that content scrolls underneath.
  liquidGlass;

  String get label =>
      this == NavStyle.classic ? 'Classic dock' : 'Liquid glass';

  String get description => this == NavStyle.classic
      ? 'Solid floating pill, opaque'
      : 'Frosted bar — content scrolls behind it';
}

/// Persisted bottom-bar preference. Same singleton shape as the other
/// controllers, so no state-management package is pulled in for it.
class NavStyleController extends ChangeNotifier {
  NavStyleController._();
  static final NavStyleController instance = NavStyleController._();

  static const _prefsKey = 'nav_style';

  NavStyle _style = NavStyle.classic;
  NavStyle get style => _style;

  bool get isGlass => _style == NavStyle.liquidGlass;

  /// Loads the saved preference. Call once from `main()` before `runApp`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _style = prefs.getString(_prefsKey) == NavStyle.liquidGlass.name
        ? NavStyle.liquidGlass
        : NavStyle.classic;
    notifyListeners();
  }

  Future<void> setStyle(NavStyle style) async {
    if (style == _style) return;
    _style = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, style.name);
  }
}
