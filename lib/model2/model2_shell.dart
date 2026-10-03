import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/MapPage/pages/map_screen.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/ProfilePage/pages/profile_screen.dart';
import 'package:udghosh/model2/pages/m2_gallery.dart';
import 'package:udghosh/model2/pages/m2_home.dart';
import 'package:udghosh/model2/pages/m2_matches.dart';
import 'package:udghosh/model2/pages/m2_more.dart';
import 'package:udghosh/config/nav_style_controller.dart';
import 'package:udghosh/model2/theme/m2_style.dart';
import 'package:udghosh/model2/widgets/m2_widgets.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/nav/liquid_glass_nav.dart';

class _Destination {
  const _Destination(this.icon, this.label);
  final List<List<dynamic>> icon;
  final String label;
}

final _destinations = [
  _Destination(HugeIcons.strokeRoundedHome01, 'Home'),
  _Destination(HugeIcons.strokeRoundedChampion, 'Matches'),
  _Destination(HugeIcons.strokeRoundedImage02, 'Gallery'),
  _Destination(HugeIcons.strokeRoundedMapsLocation01, 'Map'),
  _Destination(HugeIcons.strokeRoundedMoreHorizontal, 'More'),
];

/// Model 2 shell.
///
/// Runs the same five destinations on the same controllers as Model 1 — the
/// difference is entirely presentational: a floating header bar and a dock
/// built as a recessed track with a single convex knob that slides between
/// positions, rather than five separate buttons.
class Model2Shell extends StatefulWidget {
  const Model2Shell({super.key});

  /// Preserved across the remount a theme change triggers.
  static int lastIndex = 0;

  @override
  State<Model2Shell> createState() => _Model2ShellState();
}

class _Model2ShellState extends State<Model2Shell> {
  late int _index = Model2Shell.lastIndex;
  final _matchesKey = GlobalKey<M2MatchesState>();

  void _goTo(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _index = index;
      Model2Shell.lastIndex = index;
    });
  }

  void _openMatches({String? sport}) {
    _goTo(1);
    if (sport == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _matchesKey.currentState?.selectSport(sport);
    });
  }

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
      backgroundColor: NeoColors.base,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  M2Home(
                    onOpenMatches: _openMatches,
                    onOpenGallery: () => _goTo(2),
                    onOpenMap: () => _goTo(3),
                    onOpenNotices: _openNotices,
                  ),
                  M2Matches(key: _matchesKey),
                  const M2Gallery(),
                  const MapScreen(),
                  const M2More(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: glass
          ? LiquidGlassNav(
              items: [
                for (final d in _destinations) GlassNavItem(d.icon, d.label),
              ],
              index: _index,
              onTap: _goTo,
            )
          : _dock(),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Neumorphic(
            style: M2.knob(depth: M2.cardDepth),
            padding: const EdgeInsets.all(7),
            child: SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: FractionallySizedBox(
                  widthFactor: 0.74,
                  heightFactor: 0.74,
                  child: Image.asset(
                    'assets/logo/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => HugeIcon(
                      icon: HugeIcons.strokeRoundedChampion,
                      color: NeoColors.logoTeal,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'UDGHOSH ',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          height: 1.1,
                          color: NeoColors.logoTeal,
                        ),
                      ),
                      TextSpan(
                        text: "'26",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          height: 1.1,
                          color: NeoColors.flameGold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _destinations[_index].label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: NeoColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          M2Knob(
            icon: HugeIcons.strokeRoundedNotification01,
            onTap: _openNotices,
            size: 44,
            iconSize: 19,
          ),
          const SizedBox(width: 10),
          M2Knob(
            icon: HugeIcons.strokeRoundedUserCircle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            size: 44,
            iconSize: 19,
          ),
        ],
      ),
    );
  }

  /// A recessed track with one convex knob that travels to the selected slot.
  /// The moving knob is what makes the dock read as a physical control rather
  /// than five independent buttons.
  Widget _dock() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Neumorphic(
        style: M2.well(radius: 999, depth: -6),
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / _destinations.length;
            return SizedBox(
              height: 56,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: slot * _index,
                    top: 0,
                    bottom: 0,
                    width: slot,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Neumorphic(
                        style: M2.pill(
                          selected: false,
                          color: NeoColors.flameGold,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_destinations.length, (i) {
                      final active = i == _index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _goTo(i),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 220),
                              scale: active ? 1.06 : 1,
                              child: HugeIcon(
                                icon: _destinations[i].icon,
                                size: 21,
                                strokeWidth: active ? 2.4 : 1.8,
                                color: active
                                    ? NeoColors.onGold
                                    : NeoColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
