import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udghosh/ProfilePage/models/ParticipantModel.dart';
import 'package:udghosh/GalleryPage/pages/gallery_page.dart';
import 'package:udghosh/HomePage/pages/home_page.dart';
import 'package:udghosh/SchedulePage/pages/schedule_page.dart';
import 'package:udghosh/TeamsPage/pages/teams_page.dart';
import 'package:udghosh/NoticePage/pages/notice_page.dart';
import 'package:udghosh/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/nav_button.dart';
import 'FancyBottomNav.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key, required this.index});
  final int index;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int index = 0;
  int defaultSportIndex = -1;
  bool isLoggedIn = false;
  double navBarTextSize = 15;
  double iconSize = 22;

  late ParticipantModel savedPlayer;
  void setGalleryPage() {
    setState(() {
      index = 2;
    });
  }

  void setSchedulePage(sportIndex) {
    setState(() {
      index = 1;
      defaultSportIndex = sportIndex;
    });
  }

  Future<void> setProfilePage() async {
    ParticipantModel player = await initialisePlayer();
    setState(() {
      index = 5;
      isLoggedIn = true;
      savedPlayer = player;
    });
  }

  Future<ParticipantModel> initialisePlayer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ParticipantModel player = ParticipantModel(
      id: prefs.getString('id') ?? '',
      name: prefs.getString('name') ?? '',
      email: prefs.getString('email') ?? '',
      gender: prefs.getString('gender') ?? '',
      sport: prefs.getString('sport') ?? '',
      team: prefs.getString('team') ?? '',
      id_generation: prefs.getString('id_generation') ?? '',
      hall_name: prefs.getString('hall_name') ?? '',
    );
    return player;
  }

  Future<bool> checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    isStaff = prefs.getBool('isStaff') ?? false;
    if (isLoggedIn) {
      ParticipantModel player = await initialisePlayer();
      setState(() {
        savedPlayer = player;
      });
    }
    return isLoggedIn;
  }

  @override
  void initState() {
    index = widget.index;
    checkLoginState().then(
      (value) => setState(() {
        isLoggedIn = value;
      }),
    );
    super.initState();
  }

  Widget customStyledNavButton(int ind, String text, dynamic icon) {
    return NavButton(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          index = ind;
        });
      },
      isActive: index == ind,
      text: text,
      textSize: navBarTextSize,
      icon: icon,
      iconSize: iconSize,
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: (index == 0)
            ? HomePage(onTap: setGalleryPage, onTapSchedule: setSchedulePage)
            : (index == 1)
            ? SchedulePage(defaultIndex: defaultSportIndex)
            : (index == 2)
            ? GalleryPage()
            : (index == 3)
            ? TeamsPage()
            : (index == 4)
            ? NoticesPage(key: const ValueKey(4))
            : Container(),
        floatingActionButton: FancyBottomNav(
          index: index,
          onTap: (ind) {
            setState(() => index = ind);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
