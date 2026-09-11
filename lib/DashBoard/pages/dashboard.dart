import 'package:flutter/material.dart';
import 'package:udghosh/GalleryPage/pages/gallery_screen.dart';
import 'package:udghosh/HomePage/pages/home_screen.dart';
import 'package:udghosh/MapPage/pages/map_screen.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/ProfilePage/pages/other_screen.dart';
import 'package:udghosh/SchedulePage/pages/matches_screen.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_app_bar.dart';
import 'package:udghosh/widgets/neo/neo_bottom_nav.dart';

/// Root shell: persistent [CustomAppBar] + floating [NeoBottomNav] over the
/// 5 main tabs (Home, Matches, Gallery, Map, Other). `IndexedStack` keeps
/// each tab's scroll position / polling timers alive across switches.
class DashBoard extends StatefulWidget {
  const DashBoard({super.key, this.index = 0});
  final int index;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  late int _index = widget.index;
  final int _matchesSportIndex = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.canvasMint,
      appBar: CustomAppBar(
        onNotificationTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoticesScreen()),
        ),
        onProfileTap: () => _goTo(4),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              onOpenMatches: () => _goTo(1),
              onOpenGallery: () => _goTo(2),
              onOpenMap: () => _goTo(3),
              onOpenNotices: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticesScreen()),
              ),
            ),
            MatchesScreen(initialSportIndex: _matchesSportIndex),
            const GalleryScreen(),
            const MapScreen(),
            const OtherScreen(),
          ],
        ),
      ),
      floatingActionButton: NeoBottomNav(index: _index, onTap: _goTo),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
