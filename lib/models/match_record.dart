import 'package:intl/intl.dart';
import 'package:udghosh/config/app_config.dart';

/// Generic wrapper around one match JSON payload.
///
/// The backend has a different column set per sport (goals vs wickets vs
/// per-set scores vs points), so rather than modelling 14 separate classes
/// this reads straight from the raw map and exposes sport-aware helpers for
/// rendering. Every getter is defensive: a missing/null field never throws.
class MatchRecord {
  MatchRecord(this.sport, this.json);

  final String sport;
  final Map<String, dynamic> json;

  factory MatchRecord.fromJson(String sport, Map<String, dynamic> json) =>
      MatchRecord(sport, json);

  int get matchId => int.tryParse('${json['matchId'] ?? json['id']}') ?? -1;

  /// Side 1 / side 2 display names. The live and completed feeds use
  /// `player1`/`player2` for the individual sports (badminton, squash,
  /// taekwondo, chess) while `/matches` always sends `team1`/`team2`.
  String get team1 => (json['team1'] ?? json['player1'] ?? 'Team 1').toString();
  String get team2 => (json['team2'] ?? json['player2'] ?? 'Team 2').toString();

  String get venue => (json['venue'] ?? '').toString();
  String get status => (json['status'] ?? '').toString().toLowerCase();

  /// Category label such as "Men" / "Women", or empty when unset.
  String get category => (json['category'] ?? '').toString();

  /// Stream link, or null while there is no broadcast for this match.
  String? get liveStreamUrl => _url('liveStreamUrl');

  /// Map link for the venue, or null.
  String? get locationUrl => _url('locationUrl');

  String? _url(String key) {
    final raw = json[key]?.toString().trim();
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    if (!raw.startsWith('http')) return null;
    return raw;
  }

  /// `null` while the match is live, then `1` / `2` for the winning side and
  /// `0` for a draw. Kept nullable so "no result yet" and "drawn" stay
  /// distinguishable.
  int? get winner {
    final raw = json['winner'];
    if (raw == null) return null;
    return int.tryParse('$raw');
  }

  String get sportLabel => AppConfig.sportLabel(sport);

  /// Combined, locale-safe date parse. Falls back gracefully so a bad date
  /// string never crashes the list.
  DateTime? get _date {
    final raw = json['date'];
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String get formattedDate {
    final d = _date;
    if (d == null) return '';
    return DateFormat('d MMM').format(d);
  }

  /// Backend sends "HH:MM:SS" — render as a clean 12-hour clock.
  String get formattedTime {
    final raw = json['time']?.toString();
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateFormat('HH:mm:ss').parse(raw);
      return DateFormat('h:mm a').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  int _int(String key) => int.tryParse('${json[key] ?? 0}') ?? 0;
  String _str(String key) => (json[key] ?? '').toString();

  /// Short scoreline used on live/result cards, tailored per sport.
  String get scoreLine {
    switch (sport) {
      case 'cricket':
        // Overs arrive as strings, e.g. "12.3".
        final overs = _str('team1_overs');
        return '${_int('team1_score')}/${_int('team1_wickets')}'
            '${overs.isNotEmpty ? ' ($overs ov)' : ''}';
      case 'football':
      case 'hockey':
        return '${_int('team1_goals')} - ${_int('team2_goals')}';
      case 'basketball':
        return '${_int('team1_score')} - ${_int('team2_score')}';
      case 'kabaddi':
      case 'khokho':
      case 'ultimatefrisbee':
        return '${_int('team1_points')} - ${_int('team2_points')}';
      case 'taekwondo':
        return '${_int('player1_points')} - ${_int('player2_points')}';
      case 'chess':
        // The backend owns the notation ("1-0", "½-½"); fall back to the
        // running point tally while `result` is still unset.
        final result = _str('result').trim();
        if (result.isNotEmpty) return result;
        return '${_int('team1_points')} - ${_int('team2_points')}';
      default:
        if (AppConfig.setScoredSports.contains(sport)) {
          return setScores.map((s) => '${s.$1}-${s.$2}').join('  ');
        }
        return '';
    }
  }

  /// Team 2 half of the scoreline for sports rendered as two separate stat
  /// blocks (cricket's second innings).
  String get scoreLineTeam2 {
    if (sport == 'cricket') {
      final overs = _str('team2_overs');
      return '${_int('team2_score')}/${_int('team2_wickets')}'
          '${overs.isNotEmpty ? ' ($overs ov)' : ''}';
    }
    return '';
  }

  /// Non-zero, non-null per-set scores for racquet sports, in order.
  /// Sets that were never played come back as 0/null and are hidden.
  List<(int, int)> get setScores {
    final sets = <(int, int)>[];
    for (var i = 1; i <= 5; i++) {
      final a = json['set${i}_score1'];
      final b = json['set${i}_score2'];
      if (a == null && b == null) continue;
      final ai = int.tryParse('$a') ?? 0;
      final bi = int.tryParse('$b') ?? 0;
      if (ai == 0 && bi == 0) continue;
      sets.add((ai, bi));
    }
    return sets;
  }

  /// Result caption for a finished match. Empty while the match has no
  /// outcome yet, so a live card never claims a draw.
  String get resultLabel {
    switch (winner) {
      case 1:
        return '$team1 won';
      case 2:
        return '$team2 won';
      case 0:
        return 'Draw';
      default:
        return '';
    }
  }
}
