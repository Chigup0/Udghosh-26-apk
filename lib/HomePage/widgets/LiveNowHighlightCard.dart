import 'package:flutter/material.dart';
import 'package:udghosh/utils.dart';
import '../../SchedulePage/models/LiveMatchModel.dart';
import '../../SchedulePage/pages/live_page.dart';
import '../../widgets/widgets.dart';

class LiveNowCard extends StatelessWidget {
  const LiveNowCard({super.key, required this.match});
  final LiveNowMatchModel match;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LivePage(match: match)),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Left side (team/player/athlete)
              Expanded(
                flex: 3,
                child: Text(
                  getLeftName(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),

              // Score widget (center)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: getScoreWidget(),
              ),

              // Right side (team/player/athlete)
              Expanded(
                flex: 3,
                child: Text(
                  getRightName(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getLeftName() {
    String team = match.team1!.toUpperCase();

    switch (match.sport?.toLowerCase()) {
      case 'badminton':
      case 'taekwondo':
      case 'chess':
      case 'squash':
        team = match.player1!.toUpperCase();
    }
    return team;
  }

  String getRightName() {
    String team = match.team2!.toUpperCase();

    switch (match.sport?.toLowerCase()) {
      case 'badminton':
      case 'taekwondo':
      case 'chess':
      case 'squash':
        team = match.player2!.toUpperCase();
    }
    return team;
  }

  /// Returns the score widget based on sport
  Widget getScoreWidget() {
    final sport = match.sport!.toLowerCase();

    // Set-based sports
    if ([
      "volleyball",
      "tabletennis",
      "squash",
      "lawntennis",
      "badminton",
    ].contains(sport)) {
      return liveSetSport(match);
    }

    // Goal-based sports
    if (["hockey", "football"].contains(sport)) {
      return scoreBox(match.team1Goals, match.team2Goals, ':');
    }

    // Score-based sports
    if (["basketball"].contains(sport)) {
      return scoreBox(match.team1Score, match.team2Score, ':');
    }

    // Cricket
    if (sport == "cricket") {
      return scoreBox(
        "${match.team1_score} - ${match.team1_wickets} / ${match.team1_overs}\n${match.team2_score} - ${match.team2_wickets} / ${match.team2_overs}",
        '',
        '',
      );
    }

    // Points-based team sports
    if (["kabaddi", "khokho", "ultimatefrisbee"].contains(sport)) {
      return scoreBox(match.team1Points, match.team2Points, ':');
    }

    // Individual sports
    if (sport == "weightlifting") {
      return scoreBox(match.weightTotal, '', '');
    }
    if (sport == "powerlifting") {
      return scoreBox(match.powerliftTotal, '', '');
    }
    if (sport == "taekwondo") {
      return scoreBox(match.player1Points, match.player2Points, ':');
    }
    if (sport == "chess") {
      return scoreBox("vs", '', '');
    }
    // if (sport == "athletics") {
    //   return scoreBox(
    //     "${match.first}, ${match.second}, ${match.third}",
    //     '',
    //     match.athleteType,
    //   );
    // }
    // if (sport == "aquatics") {
    //   return scoreBox(match.athlete, match.athleteResult, match.event);
    // }

    return Container();
  }

  /// Generic live score widget for set-based sports
  Widget liveSetSport(LiveNowMatchModel m) {
    String active = m.active ?? '1';
    String score1 = active == '1'
        ? m.set1Score1
        : active == '2'
        ? m.set2Score1
        : active == '3'
        ? m.set3Score1
        : active == '4'
        ? m.set4Score1
        : m.set5Score1;
    String score2 = active == '1'
        ? m.set1Score2
        : active == '2'
        ? m.set2Score2
        : active == '3'
        ? m.set3Score2
        : active == '4'
        ? m.set4Score2
        : m.set5Score2;

    String label = '';
    if (m.sport!.toLowerCase() == "lawn tennis") {
      label = active == '1'
          ? 'First Singles'
          : active == '2'
          ? 'Doubles'
          : 'Reverse Singles';
    } else if (m.sport!.toLowerCase() == "badminton") {
      label = "Set $active";
    } else {
      label = "SET $active";
    }

    return scoreBox(score1, score2, label);
  }

  /// Generic score box
  Widget scoreBox(String score1, String score2, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: customText(
              score1,
              14,
              FontWeight.bold,
              Colors.blue.shade700,
              1,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: customText(
                label,
                10,
                FontWeight.w600,
                Colors.blue.shade700,
                1,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (score2.isNotEmpty)
            Flexible(
              fit: FlexFit.loose,
              child: customText(
                score2,
                14,
                FontWeight.bold,
                Colors.blue.shade700,
                1,
              ),
            ),
        ],
      ),
    );
  }
}
