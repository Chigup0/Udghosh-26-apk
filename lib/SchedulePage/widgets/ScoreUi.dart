import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../models/LiveMatchModel.dart';

Widget liveCricket(LiveNowMatchModel match, {bool compact = true}) {
  // double ball1 = double.parse(match.team1_overs);
  // double ball2 = double.parse(match.team2_overs);
  String team1Overs = match.team1_overs.toString();
  String team2Overs = match.team2_overs.toString();

  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            '${match.team1_score}/${match.team1_wickets}',
            16,
            FontWeight.w600,
            Colors.grey.shade700,
            1,
          ),
          const SizedBox(height: 5),
          customText(
            '$team1Overs/20',
            11,
            FontWeight.w600,
            Colors.grey.shade700,
            1.5,
          ),
        ],
      ),
      const SizedBox(width: 10),
      customText("VS", 16, FontWeight.w700, Colors.red.shade400, 1),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            '${match.team2_score}/${match.team2_wickets}',
            16,
            FontWeight.w600,
            Colors.grey.shade700,
            1,
          ),
          const SizedBox(height: 5),
          customText(
            '$team2Overs/20',
            11,
            FontWeight.w600,
            Colors.grey.shade700,
            1.5,
          ),
        ],
      ),
    ],
  );
}

Widget liveBasketball(LiveNowMatchModel match, {bool compact = true}) {
  return Row(
    children: [
      customText(
        match.team1Score,
        18,
        FontWeight.w600,
        Colors.grey.shade700,
        1,
      ),
      const SizedBox(width: 15),
      customText("VS", 18, FontWeight.w700, Colors.red.shade400, 1),
      const SizedBox(width: 15),
      customText(
        match.team2Score,
        18,
        FontWeight.w600,
        Colors.grey.shade700,
        1,
      ),
    ],
  );
}

Widget liveGoalGame(LiveNowMatchModel match, {bool compact = true}) {
  return Row(
    children: [
      customText(
        match.team1Goals,
        18,
        FontWeight.w600,
        Colors.grey.shade700,
        1,
      ),
      const SizedBox(width: 15),
      customText("VS", 18, FontWeight.w700, Colors.red.shade400, 1),
      const SizedBox(width: 15),
      customText(
        match.team2Goals,
        18,
        FontWeight.w600,
        Colors.grey.shade700,
        1,
      ),
    ],
  );
}

Widget liveSetSport(
  LiveNowMatchModel match,
  String activeSet, {
  String? title,
  Function(String)? onSetChanged,
  bool compact = true,
  bool result = false,
}) {
  if (compact) {
    if (result) {
      // Result mode - show sum of all wins for each team
      int team1Wins = 0;
      int team2Wins = 0;

      // Check each set to see who won
      List<List<String>> sets = [
        [match.set1Score1, match.set1Score2],
        [match.set2Score1, match.set2Score2],
        [match.set3Score1, match.set3Score2],
        [match.set4Score1, match.set4Score2],
        [match.set5Score1, match.set5Score2],
      ];

      for (var set in sets) {
        if (set[0].isNotEmpty && set[1].isNotEmpty) {
          int score1 = int.tryParse(set[0]) ?? 0;
          int score2 = int.tryParse(set[1]) ?? 0;

          if (score1 > score2) {
            team1Wins++;
          } else if (score2 > score1) {
            team2Wins++;
          }
        }
      }

      return Row(
        children: [
          customText(
            team1Wins.toString(),
            18,
            FontWeight.w600,
            Colors.grey.shade700,
            1,
          ),
          const SizedBox(width: 15),
          customText("VS", 18, FontWeight.w700, Colors.red.shade400, 1),
          const SizedBox(width: 15),
          customText(
            team2Wins.toString(),
            18,
            FontWeight.w600,
            Colors.grey.shade700,
            1,
          ),
        ],
      );
    } else {
      // Compact mode - only show the active set
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: getSetScore(match, activeSet),
      );
    }
  } else {
    // Non-compact mode - show chips + all set scores
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          // Set selection chips in strict 2x3 grid
          if (onSetChanged != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeSet,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    items: List.generate(5, (index) {
                      String setNumber = (index + 1).toString();
                      return DropdownMenuItem(
                        value: setNumber,
                        child: Text("Set $setNumber"),
                      );
                    }),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onSetChanged.call(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Active set score
          getSetScore(match, activeSet),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// Helper function to fetch score by set + team
Widget getSetScore(LiveNowMatchModel match, String activeSet) {
  switch (activeSet) {
    case '1':
      return setScore2("Set 1", match.set1Score1, match.set1Score2);
    case '2':
      return setScore2("Set 2", match.set2Score1, match.set2Score2);
    case '3':
      return setScore2("Set 3", match.set3Score1, match.set3Score2);
    case '4':
      return setScore2("Set 4", match.set4Score1, match.set4Score2);
    case '5':
      return setScore2("Set 5", match.set5Score1, match.set5Score2);
    default:
      return Container();
  }
}

Widget liveIndividualResult(LiveNowMatchModel match, {bool compact = true}) {
  String resultText = match.athleteResult.isEmpty
      ? ""
      : "Result: ${match.athleteResult}";

  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Athlete name box
          Container(
            alignment: Alignment.center,
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: customText(
              match.athlete,
              13,
              FontWeight.w700,
              Colors.grey.shade800,
              1,
            ),
          ),
          const SizedBox(height: 4),
          // Event + result
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                customText(
                  match.event,
                  13,
                  FontWeight.w600,
                  Colors.grey.shade700,
                  1.3,
                ),
                if (resultText.isNotEmpty)
                  customText(
                    resultText,
                    13,
                    FontWeight.w500,
                    Colors.grey.shade800,
                    1.2,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget liveChess(LiveNowMatchModel match, {bool compact = true}) {
  return Row(
    children: [
      Icon(Icons.emoji_events, size: 14),
      SizedBox(width: 6),
      customText(
        (match.winner != 0
                ? (match.winner == 1 ? match.player1 : match.player2)?.split(
                    " ",
                  )[0]
                : '') ??
            '',
        16,
        FontWeight.w600,
        Colors.green.shade700,
        1,
      ),
    ],
  );
}

Widget liveLifting(
  LiveNowMatchModel match, {
  bool isPowerlifting = false,
  bool compact = true,
}) {
  String title = isPowerlifting ? "Powerlifting" : "Weightlifting";

  String details = compact
      ? (isPowerlifting ? match.powerliftTotal : match.weightTotal)
      : (isPowerlifting
            ? "S: ${match.squatBest}  B: ${match.benchPressBest}  D: ${match.deadliftBest}\nTotal: ${match.powerliftTotal}"
            : "Sn: ${match.snatchBest}  CJ: ${match.cleanJerkBest}\nTotal: ${match.weightTotal}");

  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: customText(
              title,
              12,
              FontWeight.w700,
              Colors.grey.shade800,
              1,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget livePointsGame(
  LiveNowMatchModel match, {
  bool isTaekwondo = false,
  bool compact = true,
}) {
  return Row(
    children: [
      customText(
        isTaekwondo ? match.player1Points : match.team1Points,
        18,
        FontWeight.w600,
        Colors.grey.shade700,
        1,
      ),
      const SizedBox(width: 15),
      customText("VS", 18, FontWeight.w700, Colors.red.shade400, 1),
      const SizedBox(width: 15),
      customText(
        isTaekwondo ? match.player2Points : match.team2Points,
        18,
        FontWeight.w600,
        Colors.grey.shade700,
        1,
      ),
    ],
  );
}

Widget liveMatchScore(
  LiveNowMatchModel match, {
  bool compact = true,
  bool result = false,
  Function(String)? onSetChanged,
}) {
  switch (match.sport?.toLowerCase()) {
    case 'cricket':
      return liveCricket(match, compact: compact);
    case 'basketball':
      return liveBasketball(match, compact: compact);
    case 'hockey':
    case 'football':
      return liveGoalGame(match, compact: compact);
    case 'volleyball':
    case 'tabletennis':
    case 'lawntennis':
    case 'badminton':
    case 'squash':
      // For set-based sports, pick the active set from match.active
      return liveSetSport(
        match,
        match.active ?? '1',
        title: match.sport?.toLowerCase() == 'lawn tennis'
            ? activeSetTitle(match.active ?? '1')
            : null,
        onSetChanged: onSetChanged,
        compact: compact,
        result: result,
      );
    case 'athletics':
    case 'aquatics':
      return liveIndividualResult(match, compact: compact);
    case 'chess':
      return liveChess(match, compact: compact);
    case 'weightlifting':
      return liveLifting(match, compact: compact);
    case 'powerlifting':
      return liveLifting(match, isPowerlifting: true, compact: compact);
    case 'kabaddi':
    case 'khokho':
    case 'ultimatefrisbee':
      return livePointsGame(match, compact: compact);
    case 'taekwondo':
      return livePointsGame(match, isTaekwondo: true, compact: compact);
    default:
      return Text(
        'No Live Data',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      );
  }
}

// Optional helper for lawn tennis set titles
String activeSetTitle(String active) {
  switch (active) {
    case '1':
      return 'First Singles';
    case '2':
      return 'Doubles';
    case '3':
      return 'Reverse Singles';
    default:
      return 'Set $active';
  }
}
