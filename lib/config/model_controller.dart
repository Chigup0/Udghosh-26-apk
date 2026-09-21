import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which UI shell the app renders.
///
/// Both models run on exactly the same services, models and controllers —
/// `ApiService`, `AuthController`, `ThemeController`, `MatchRecord`. Only the
/// presentation differs, so switching models never changes what the app can
/// do, what it fetches, or what is stored.
enum AppModel {
  /// The shipped soft-neumorphic UI. Frozen — nothing here is modified.
  one,

  /// A fully re-worked neumorphic shell that uses the whole depth vocabulary:
  /// concave wells, convex knobs, embossed readouts and pressed states.
  two;

  String get label => this == AppModel.one ? 'Model 1' : 'Model 2';

  String get description => this == AppModel.one
      ? 'Original layout — cards and a pill dock'
      : 'Sculpted neumorphism — wells, knobs & embossed readouts';
}

/// Persisted choice of UI shell.
class ModelController extends ChangeNotifier {
  ModelController._();
  static final ModelController instance = ModelController._();

  static const _prefsKey = 'app_model';

  AppModel _model = AppModel.one;
  AppModel get model => _model;

  bool get isModelTwo => _model == AppModel.two;

  /// Loads the saved choice. Call once from `main()` before `runApp`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _model = raw == AppModel.two.name ? AppModel.two : AppModel.one;
    notifyListeners();
  }

  Future<void> setModel(AppModel model) async {
    if (model == _model) return;
    _model = model;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, model.name);
  }
}
