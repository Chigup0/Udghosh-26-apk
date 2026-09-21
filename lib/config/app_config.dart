import 'package:hugeicons/hugeicons.dart';

/// Central runtime configuration for the Udghosh user app.
///
/// Keeping the base URL, demo-auth bypass credentials and the canonical
/// sport-table list in one place avoids the "magic string" drift that used
/// to exist across api.dart / utils.dart / individual screens.
class AppConfig {
  AppConfig._();

  /// Backend REST base URL. Swap this for staging/prod as needed.
  static const String baseUrl = "https://api.udghosh.org.in/api";

  /// Base URL for statically served assets (images etc.) returned by the API.
  static const String imgBaseUrl = "https://api.udghosh.org.in";

  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // ---------------------------------------------------------------------
  // Demo / guest bypass credentials — lets reviewers and offline demos in
  // without hitting the real OTP backend.
  // ---------------------------------------------------------------------
  static const String demoEmail = "demo@gmail.com";
  static const String demoOtp = "123456";
  static const int demoUserId = 999;
  static const String demoUserName = "Demo Athlete";

  static const Duration otpResendCooldown = Duration(seconds: 60);

  /// Page size for every paginated match feed. The backend defaults to 10
  /// and caps at 500; 20 fills a phone screen without over-fetching.
  static const int defaultPageSize = 20;

  /// Sentinel accepted by `GET /matches` (and only that endpoint) to fetch
  /// the schedule across every sport.
  static const String allSports = 'all';

  /// Canonical `sportTableName` values the backend understands. Order drives
  /// the sport-selector pill bar on the Matches screen.
  static const List<String> sportTables = [
    'cricket',
    'volleyball',
    'basketball',
    'hockey',
    'lawntennis',
    'tabletennis',
    'badminton',
    'chess',
    'football',
    'kabaddi',
    'khokho',
    'squash',
    'taekwondo',
    'ultimatefrisbee',
  ];

  /// Human-readable labels for the sport pill bar, keyed by table name.
  static const Map<String, String> sportLabels = {
    'cricket': 'Cricket',
    'volleyball': 'Volleyball',
    'basketball': 'Basketball',
    'hockey': 'Hockey',
    'lawntennis': 'Lawn Tennis',
    'tabletennis': 'Table Tennis',
    'badminton': 'Badminton',
    'chess': 'Chess',
    'football': 'Football',
    'kabaddi': 'Kabaddi',
    'khokho': 'Kho-Kho',
    'squash': 'Squash',
    'taekwondo': 'Taekwondo',
    'ultimatefrisbee': 'Ultimate Frisbee',
  };

  /// The backend ignores spaces, hyphens and case in sport names, so
  /// `Lawn Tennis`, `lawn-tennis` and `lawntennis` all collapse to the
  /// canonical table name.
  static String normalizeSport(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static String sportLabel(String table) {
    final key = normalizeSport(table);
    return sportLabels[key] ?? table.toUpperCase();
  }

  /// Glyph per sport, used wherever a sport needs a mark and no Lottie
  /// animation has been bundled for it yet. Hugeicons has no cricket, kabaddi,
  /// kho-kho, squash or taekwondo glyph, so those borrow the closest fit.
  static const Map<String, List<List<dynamic>>> sportGlyphs = {
    'cricket': HugeIcons.strokeRoundedBaseballBat,
    'volleyball': HugeIcons.strokeRoundedVolleyball,
    'basketball': HugeIcons.strokeRoundedBasketball01,
    'hockey': HugeIcons.strokeRoundedHockey,
    'lawntennis': HugeIcons.strokeRoundedTennisBall,
    'tabletennis': HugeIcons.strokeRoundedBadminton,
    'badminton': HugeIcons.strokeRoundedBadmintonShuttle,
    'chess': HugeIcons.strokeRoundedChessPawn,
    'football': HugeIcons.strokeRoundedFootball,
    'kabaddi': HugeIcons.strokeRoundedBoxingGlove,
    'khokho': HugeIcons.strokeRoundedRunningShoes,
    'squash': HugeIcons.strokeRoundedTennisBall,
    'taekwondo': HugeIcons.strokeRoundedBoxingGlove,
    'ultimatefrisbee': HugeIcons.strokeRoundedFrisbee,
  };

  /// Glyph for [table], falling back to a trophy for anything unrecognised.
  static List<List<dynamic>> sportGlyph(String table) =>
      sportGlyphs[normalizeSport(table)] ?? HugeIcons.strokeRoundedChampion;

  /// Sports rendered with discrete per-set scores (racquet sports).
  static const Set<String> setScoredSports = {
    'volleyball',
    'tabletennis',
    'lawntennis',
    'badminton',
    'squash',
  };

  /// Turns a possibly-relative image path returned by the backend into a
  /// full URL, or null if it's one of the known-broken `/uploads/...` paths.
  static String? resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('/uploads/')) return null; // known-broken placeholder
    return '$imgBaseUrl$raw';
  }
}
