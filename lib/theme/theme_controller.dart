import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udghosh/theme/neo_palette.dart';

/// The themes a user can pick in Settings.
///
/// [light], [dark] and [system] are the original three and are unchanged.
/// [theme4] and [theme5] are the bold, solid-surface additions.
enum AppTheme {
  light,
  dark,
  system,
  theme4,
  theme5,
  theme6;

  String get label {
    switch (this) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
      case AppTheme.theme4:
        return 'Theme 4';
      case AppTheme.theme5:
        return 'Theme 5';
      case AppTheme.theme6:
        return 'Theme 6';
    }
  }

  String get description {
    switch (this) {
      case AppTheme.light:
        return 'Soft neumorphic paper-slate';
      case AppTheme.dark:
        return 'Soft neumorphic dark slate';
      case AppTheme.system:
        return 'Follows your device setting';
      case AppTheme.theme4:
        return 'Bold & Solid — aqua canvas, white cards';
      case AppTheme.theme5:
        return 'Rich & Opaque — deep petroleum';
      case AppTheme.theme6:
        return 'Midnight Orchid — violet, cyan & hot pink';
    }
  }

  /// The palette this theme paints with. [system] is the only one that has to
  /// ask the platform, so it takes the current device brightness.
  NeoPalette paletteFor(Brightness platformBrightness) {
    switch (this) {
      case AppTheme.light:
        return NeoPalette.light;
      case AppTheme.dark:
        return NeoPalette.dark;
      case AppTheme.system:
        return platformBrightness == Brightness.dark
            ? NeoPalette.dark
            : NeoPalette.light;
      case AppTheme.theme4:
        return NeoPalette.boldSolid;
      case AppTheme.theme5:
        return NeoPalette.richOpaque;
      case AppTheme.theme6:
        return NeoPalette.midnightOrchid;
    }
  }
}

/// App-wide theme preference.
///
/// A plain singleton `ChangeNotifier` with its own persistence, so no
/// state-management package is pulled in just for this.
/// Screens never listen to it directly — the root widget does, and the active
/// [NeoPalette] is swapped before the tree rebuilds.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'theme_mode';

  AppTheme _theme = AppTheme.system;
  AppTheme get theme => _theme;

  /// Loads the saved preference. Call once from `main()` before `runApp`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = _decode(prefs.getString(_prefsKey));
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    if (theme == _theme) return;
    _theme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, theme.name);
  }

  NeoPalette paletteFor(Brightness platformBrightness) =>
      _theme.paletteFor(platformBrightness);

  bool isDarkFor(Brightness platformBrightness) =>
      paletteFor(platformBrightness).isDark;

  String get label => _theme.label;

  /// Older builds stored `ThemeMode.name`, which overlaps with the first three
  /// values, so those keep working unchanged.
  static AppTheme _decode(String? raw) {
    for (final theme in AppTheme.values) {
      if (theme.name == raw) return theme;
    }
    return AppTheme.system;
  }
}
