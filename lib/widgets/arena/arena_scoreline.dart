import 'package:udghosh/SchedulePage/models/LiveMatchModel.dart';

/// Normalized two-sided scoreline resolved from the sport-specific fields
/// on [LiveNowMatchModel], so the arena match card can render one
/// consistent recessed scoreboard regardless of sport.
class ArenaScoreline {
  final String left;
  final String right;
  final String? leftSub;
  final String? rightSub;

  /// 0 = even/no lead, 1 = left side ahead, 2 = right side ahead.
  final int momentum;

  const ArenaScoreline({
    required this.left,
    required this.right,
    this.leftSub,
    this.rightSub,
    this.momentum = 0,
  });
}

int _leadOf(String a, String b) {
  final x = int.tryParse(a) ?? 0;
  final y = int.tryParse(b) ?? 0;
  if (x > y) return 1;
  if (y > x) return 2;
  return 0;
}

(int, int) _setWins(LiveNowMatchModel m) {
  var w1 = 0, w2 = 0;
  final sets = [
    [m.set1Score1, m.set1Score2],
    [m.set2Score1, m.set2Score2],
    [m.set3Score1, m.set3Score2],
    [m.set4Score1, m.set4Score2],
    [m.set5Score1, m.set5Score2],
  ];
  for (final s in sets) {
    final a = int.tryParse(s[0]) ?? 0;
    final b = int.tryParse(s[1]) ?? 0;
    if (a > b) w1++;
    if (b > a) w2++;
  }
  return (w1, w2);
}

/// Set-score strings for the footer micro-stats row, e.g. `21-18`.
/// Only sets where both sides have posted a score are included.
List<String> resolveSetMicroStats(LiveNowMatchModel m) {
  final sets = [
    [m.set1Score1, m.set1Score2],
    [m.set2Score1, m.set2Score2],
    [m.set3Score1, m.set3Score2],
    [m.set4Score1, m.set4Score2],
    [m.set5Score1, m.set5Score2],
  ];
  return [
    for (final s in sets)
      if ((int.tryParse(s[0]) ?? 0) + (int.tryParse(s[1]) ?? 0) > 0) '${s[0]}-${s[1]}',
  ];
}

ArenaScoreline resolveScoreline(LiveNowMatchModel m) {
  switch (m.sport?.toLowerCase()) {
    case 'cricket':
      return ArenaScoreline(
        left: '${m.team1_score ?? 0}/${m.team1_wickets ?? 0}',
        right: '${m.team2_score ?? 0}/${m.team2_wickets ?? 0}',
        leftSub: '${m.team1_overs} OV',
        rightSub: '${m.team2_overs} OV',
        momentum: m.active == '1'
            ? 1
            : m.active == '2'
                ? 2
                : 0,
      );
    case 'basketball':
      return ArenaScoreline(
        left: m.team1Score,
        right: m.team2Score,
        momentum: _leadOf(m.team1Score, m.team2Score),
      );
    case 'hockey':
    case 'football':
      return ArenaScoreline(
        left: m.team1Goals,
        right: m.team2Goals,
        momentum: _leadOf(m.team1Goals, m.team2Goals),
      );
    case 'kabaddi':
    case 'khokho':
    case 'ultimatefrisbee':
      return ArenaScoreline(
        left: m.team1Points,
        right: m.team2Points,
        momentum: _leadOf(m.team1Points, m.team2Points),
      );
    case 'taekwondo':
      return ArenaScoreline(
        left: m.player1Points,
        right: m.player2Points,
        momentum: _leadOf(m.player1Points, m.player2Points),
      );
    case 'volleyball':
    case 'tabletennis':
    case 'lawntennis':
    case 'badminton':
    case 'squash':
      final wins = _setWins(m);
      return ArenaScoreline(
        left: wins.$1.toString(),
        right: wins.$2.toString(),
        leftSub: 'SETS',
        rightSub: 'SETS',
        momentum: wins.$1 == wins.$2 ? 0 : (wins.$1 > wins.$2 ? 1 : 2),
      );
    case 'chess':
      return ArenaScoreline(
        left: m.winner == 1 ? '1' : '0',
        right: m.winner == 2 ? '1' : '0',
        momentum: m.winner ?? 0,
      );
    default:
      return const ArenaScoreline(left: '–', right: '–');
  }
}
