import 'package:flutter/material.dart';
import 'package:udghosh/SchedulePage/widgets/widgets.dart';
import '../../utils.dart';
import '../../widgets/widgets.dart';
import '../models/LiveMatchModel.dart';
import '../pages/live_page.dart';
import '../pages/schedule_page.dart';
import 'UpcomingMatchCard.dart';
import 'ScoreUi.dart';

class LiveMatchCard extends StatelessWidget {
  final LiveNowMatchModel match;
  const LiveMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String? locationUrl = locationVenueMap[match.sport?.toLowerCase()];
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
              decoration: BoxDecoration(color: Colors.red.shade400),
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
                        verticalLogoWithCollegeName(team1, 45, 45),
                        Column(
                          children: [
                            liveMatchScore(match),
                            const SizedBox(height: 3),
                            (match.sport?.toLowerCase() == 'cricket')
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.sports_cricket_rounded,
                                        color: Colors.green.shade700,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 8),
                                      customText(
                                        match.active == '1' ? team1 : team2,
                                        11,
                                        FontWeight.w600,
                                        Colors.grey.shade700,
                                        2,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        verticalLogoWithCollegeName(team2, 45, 45),
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
                    color: Colors.red.shade400,
                    child: customText(
                      'Live',
                      14,
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
                    10,
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
}
