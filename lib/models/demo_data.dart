import 'package:intl/intl.dart';
import 'package:udghosh/models/match_record.dart';
import 'package:udghosh/NoticePage/model/Notice.dart';

/// Fallback "sample" content shown when the backend returns an empty list,
/// so the app never looks broken on a fresh install / offline demo. Each
/// screen renders exactly one of these, clearly marked, per spec.
class DemoData {
  DemoData._();

  static String get _todayTime => DateFormat('HH:mm:ss').format(DateTime.now());
  static String get _today => DateTime.now().toIso8601String();

  static MatchRecord liveMatch([String sport = 'basketball']) {
    return MatchRecord.fromJson(sport, {
      'matchId': -1,
      'team1': 'Hall 5',
      'team2': 'Hall 9',
      'team1_score': 42,
      'team2_score': 38,
      'status': 'live',
      'venue': 'New SAC Courts // Court-02',
      'date': _today,
      'time': _todayTime,
      'active': 'Q3 08:42',
    });
  }

  static MatchRecord upcomingMatch([String sport = 'cricket']) {
    return MatchRecord.fromJson(sport, {
      'matchId': -2,
      'team1': 'IITK',
      'team2': 'IITB',
      'status': 'upcoming',
      'venue': 'Cricket Ground A',
      'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'time': '10:00:00',
    });
  }

  static MatchRecord completedMatch([String sport = 'football']) {
    return MatchRecord.fromJson(sport, {
      'matchId': -3,
      'team1': 'Hall 3',
      'team2': 'Hall 7',
      'team1_goals': 2,
      'team2_goals': 1,
      'winner': 1,
      'status': 'completed',
      'venue': 'Main Stadium',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'time': '16:00:00',
    });
  }

  static Notice notice() {
    final now = DateTime.now();
    return Notice(
      id: -1,
      title: 'Schedule Update',
      content: 'Football finals moved to 5 PM.',
      createdAt: now,
      updatedAt: now,
    );
  }
}
