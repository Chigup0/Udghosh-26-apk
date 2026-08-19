import 'package:flutter/material.dart';
import 'package:udghosh/SchedulePage/widgets/ScoreUi.dart';
import 'package:udghosh/SchedulePage/widgets/widgets.dart';
import '../../utils.dart';
import '../../widgets/widgets.dart';
import '../models/LiveMatchModel.dart';
import '../pages/live_page.dart';
import '../pages/schedule_page.dart';

class CompletedMatchCard extends StatelessWidget {
  final LiveNowMatchModel match;
  const CompletedMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String? category = match.category?.toUpperCase();
    double horizontalPadding = size.width > 620
        ? 100
        : size.width > 500
        ? 50
        : 16;

    String team1 = match.team1!.toUpperCase();
    String team2 = match.team2!.toUpperCase();

    switch (match.sport?.toLowerCase()) {
      case 'badminton':
      case 'taekwondo':
      case 'chess':
      case 'squash':
        team1 = match.player1!.toUpperCase();
        team2 = match.player2!.toUpperCase();
    }
print(match.winner);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LivePage(match: match)),
        );
      },
      child: ClipPath(
        clipper: OctagonClipper3(padding: 18 + horizontalPadding),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: size.width - horizontalPadding * 2,
              decoration: BoxDecoration(color: Colors.grey.shade400),
              margin: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: horizontalPadding,
              ),
              child: ClipPath(
                clipper: OctagonClipper3(padding: 12),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 24,
                      bottom: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        verticalLogoWithCollegeName(
                          team1,
                          45,
                          45,
                          ringColor: match.winner == 1
                              ? Colors.amberAccent
                              : Colors.grey.shade400,
                        ),
                        Column(
                          children: [
                            liveMatchScore(match, result: true),
                            SizedBox(height: 6),
                            match.sport?.toLowerCase() == 'chess'
                                ? Container()
                                : Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      customText(
                                        match.winner != 0 ? (match.winner == 1 ? team1 : team2).split(" ")[0] : 'Tie',
                                        12,
                                        FontWeight.w600,
                                        Colors.green.shade700,
                                        1,
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        verticalLogoWithCollegeName(
                          team2,
                          45,
                          45,
                          ringColor: match.winner == 2
                              ? Colors.amberAccent
                              : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                ClipPath(
                  clipper: OctagonClipper3(padding: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    color: Colors.grey.shade400,
                    child: customText(
                      match.matchDate,
                      12,
                      FontWeight.w600,
                      whiteColor,
                      1,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: customText(
                    category!,
                    12,
                    FontWeight.w600,
                    Colors.white,
                    1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget liveCricket() {
    String team1overs = match.team1_overs.toString();
    String team2overs = match.team2_overs.toString();
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              '${match.team1_score}/${match.team1_wickets.toString()}',
              16,
              FontWeight.w600,
              Colors.grey.shade700,
              1,
            ),
            const SizedBox(height: 5),
            customText(
              '$team1overs/20',
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
              '${match.team2_score.toString()}/${match.team2_wickets.toString()}',
              16,
              FontWeight.w600,
              Colors.grey.shade700,
              1,
            ),
            const SizedBox(height: 5),
            customText(
              '${team2overs}/20',
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

  Widget liveHockey() {
    return Row(
      children: [
        customText(
          match.team1Goals.toString(),
          18,
          FontWeight.w600,
          Colors.grey.shade700,
          1,
        ),
        const SizedBox(width: 15),
        customText("VS", 18, FontWeight.w700, Colors.red.shade400, 1),
        const SizedBox(width: 15),
        customText(
          match.team2Goals.toString(),
          18,
          FontWeight.w600,
          Colors.grey.shade700,
          1,
        ),
      ],
    );
  }

  Widget liveBasketball() {
    return Row(
      children: [
        customText(
          match.team1Score.toString(),
          18,
          FontWeight.w600,
          Colors.grey.shade700,
          1,
        ),
        const SizedBox(width: 15),
        customText("VS", 18, FontWeight.w700, Colors.red.shade400, 1),
        const SizedBox(width: 15),
        customText(
          match.team2Score.toString(),
          18,
          FontWeight.w600,
          Colors.grey.shade700,
          1,
        ),
      ],
    );
  }

  Widget liveVolleyball() {
    int score1 = 0;
    int score2 = 0;
    if (double.parse(match.set1Score1) > double.parse(match.set1Score2)) {
      score1++;
    } else if (double.parse(match.set1Score1) <
        double.parse(match.set1Score2)) {
      score2++;
    }
    if (double.parse(match.set2Score1) > double.parse(match.set2Score2)) {
      score1++;
    } else if (double.parse(match.set2Score1) <
        double.parse(match.set2Score2)) {
      score2++;
    }
    if (double.parse(match.set3Score1) > double.parse(match.set3Score2)) {
      score1++;
    } else if (double.parse(match.set3Score1) <
        double.parse(match.set3Score2)) {
      score2++;
    }
    if (double.parse(match.set4Score1) > double.parse(match.set4Score2)) {
      score1++;
    } else if (double.parse(match.set4Score1) <
        double.parse(match.set4Score2)) {
      score2++;
    }
    if (double.parse(match.set5Score1) > double.parse(match.set5Score2)) {
      score1++;
    } else if (double.parse(match.set5Score1) <
        double.parse(match.set5Score2)) {
      score2++;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: customText(
        score1.toString() + " : " + score2.toString(),
        18,
        FontWeight.w800,
        Colors.grey.shade900,
        1,
      ),
    );
  }
}

Widget athletePerformer(String position, String college) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5, left: 40),
    child: Row(
      // mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: darkYellowColor),
          ),
          child: customText(position, 11, FontWeight.w500, darkYellowColor, 1),
        ),
        const SizedBox(width: 10),
        TeamLogo(teamName: college, size: 35),
        const SizedBox(width: 10),
        customText(college, 16, FontWeight.w800, Colors.grey.shade700, 1),
      ],
    ),
  );
}

Widget chessCollegePlayer(String college) {
  return Container(
    width: 60,
    alignment: Alignment.center,
    child: Column(
      children: [
        TeamLogo(teamName: college, size: 35),
        customText(
          college.toUpperCase(),
          9,
          FontWeight.w900,
          Colors.grey.shade800,
          1.9,
        ),
      ],
    ),
  );
}
