import 'package:flutter/material.dart';
import 'package:udghosh/GalleryPage/pages/gallery_screen.dart';
import 'package:udghosh/HomePage/pages/home_screen.dart';
import 'package:udghosh/MapPage/pages/map_screen.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/ProfilePage/pages/other_screen.dart';
import 'package:udghosh/ProfilePage/pages/profile_screen.dart';
import 'package:udghosh/SchedulePage/pages/matches_screen.dart';
import 'package:udghosh/config/nav_style_controller.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_app_bar.dart';
import 'package:udghosh/widgets/nav/liquid_glass_nav.dart';
import 'package:udghosh/widgets/neo/neo_bottom_nav.dart';

/// Root shell: persistent [CustomAppBar] + floating [NeoBottomNav] over the
/// 5 main tabs (Home, Matches, Gallery, Map, Other). `IndexedStack` keeps
/// each tab's scroll position / polling timers alive across switches.
class DashBoard extends StatefulWidget {
  const DashBoard({super.key, this.index = 0});
  final int index;

  /// Survives the remount that a light/dark switch triggers, so toggling the
  /// theme leaves the user on the tab they were already looking at.
  static int lastIndex = 0;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  static const _matchesTab = 1;

  late int _index = widget.index;

  /// Lets Home drive the Matches tab's sport selection. The tab stays mounted
  /// inside the IndexedStack, so it is told to switch rather than rebuilt.
  final _matchesKey = GlobalKey<MatchesScreenState>();

  void _goTo(int index) => setState(() {
    _index = index;
    DashBoard.lastIndex = index;
  });

  void _openMatches({String? sport}) {
    _goTo(_matchesTab);
    if (sport == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _matchesKey.currentState?.selectSport(sport);
    });
  }

  void _openProfile() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
  );

  void _openNotices() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NoticesScreen()),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NavStyleController.instance,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final glass = NavStyleController.instance.isGlass;

    return Scaffold(
      backgroundColor: NeoColors.canvasMint,
      // Body runs to the bottom of the screen behind the bar. The classic dock
      // already floated over it; the glass bar needs it so there is something
      // to blur. Screens end with a NavSpacer so nothing hides underneath.
      extendBody: true,
      appBar: CustomAppBar(
        onNotificationTap: _openNotices,
        onProfileTap: _openProfile,
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onOpenMatches: _openMatches,
            onOpenGallery: () => _goTo(2),
            onOpenMap: () => _goTo(3),
            onOpenNotices: _openNotices,
          ),
          MatchesScreen(key: _matchesKey),
          const GalleryScreen(),
          const MapScreen(),
          const OtherScreen(),
        ],
      ),
      // Classic keeps its exact original mounting (a docked FAB) so it renders
      // identically; the glass bar is a real bottomNavigationBar.
      bottomNavigationBar: glass
          ? LiquidGlassNav(
              items: [
                for (final item in kNeoNavItems)
                  GlassNavItem(item.icon, item.label),
              ],
              index: _index,
              onTap: _goTo,
            )
          : null,
      floatingActionButton: glass
          ? null
          : NeoBottomNav(index: _index, onTap: _goTo),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
