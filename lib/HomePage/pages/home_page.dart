import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils.dart';
import '../widgets/ConnectWithUs.dart';
import '../widgets/ContactUs.dart';
import '../widgets/CopyrightFooter.dart';
import '../widgets/GalleryHighLight.dart';
import '../widgets/MapWidget.dart';
import '../widgets/Sports.dart';
import '../../EventsPage/EventsComponent.dart';
import '../../EventsPage/InformalSportComponent.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onTap, required this.onTapSchedule});
  final Function() onTap;
  final Function(int) onTapSchedule;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int animationDuration = 700;
  bool isStaffMeet = false;
  void checkForMeetType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool meetType = prefs.getBool('isStaff') ?? false;
    setState(() {
      isStaff = meetType;
      isStaffMeet = meetType;
    });
  }

  @override
  void initState() {
    super.initState();
    checkForMeetType();
    // Trigger collapse after a short delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        expanded = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(950),
        child: AnimatedContainer(
          height: expanded ? size.height : 150,
          decoration: BoxDecoration(color: Color.fromARGB(255, 3, 1, 6)),
          duration: Duration(milliseconds: animationDuration),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 3, 1, 6),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(color: Color.fromARGB(255, 3, 1, 6)),
              child: Stack(
                children: [
                  // Subtle background pattern
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 600),
                      opacity: expanded ? 0.03 : 0.01,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF00F5FF).withOpacity(0.02),
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: EdgeInsets.only(top: 45, left: 30, right: 20),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: animationDuration),
                      child: expanded
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo with subtle border when expanded - BIGGER
                                AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: animationDuration,
                                  ),
                                  padding: EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color(0xFF00F5FF).withOpacity(0.2),
                                      width: 1,
                                    ),
                                    color: Color(0xFF00F5FF).withOpacity(0.05),
                                  ),
                                  child: Image.asset(
                                    'assets/logo/logo.png',
                                    height: 85, // Increased from 70
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                SizedBox(height: 25),

                                // Title section - expanded with BIGGER fonts
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/logo/typeface.png',
                                      height: 50, // Increased from 70
                                      fit: BoxFit.contain,
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      "SPORTS FESTIVAL",
                                      style: TextStyle(
                                        fontFamily: globalFontFamily,
                                        fontSize: 15, // Increased from 13
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.7),
                                        letterSpacing: 1.8,
                                      ),
                                    ),

                                    SizedBox(height: 18),

                                    // Year and institution - expanded with BIGGER fonts
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                16, // Slightly increased
                                            vertical: 8, // Slightly increased
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFF00F5FF,
                                            ).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Color(
                                                0xFF00F5FF,
                                              ).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            "2025",
                                            style: TextStyle(
                                              fontFamily: globalFontFamily,
                                              fontSize: 14, // Increased from 12
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF00F5FF),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 15),

                                        Container(
                                          height: 22, // Slightly increased
                                          width: 1,
                                          color: Colors.white.withOpacity(0.2),
                                        ),

                                        SizedBox(width: 15),

                                        Text(
                                          "IIT KANPUR",
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize: 14, // Increased from 12
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: animationDuration,
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                    'assets/logo/logo.png',
                                    height: 80, // Increased from 30
                                    width: 40, // Increased from 30
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                SizedBox(width: 16),

                                // Text content - collapsed with BIGGER fonts
                                Image.asset(
                                  'assets/logo/typeface.png',
                                  height: 60, // Increased from 70
                                  fit: BoxFit.contain,
                                ),
                                Container(width: 40),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Container(
        decoration: containerDecoration,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Main Content
                AnimatedOpacity(
                  duration: Duration(milliseconds: animationDuration),
                  opacity: expanded ? 0 : 1,
                  child: Column(
                    children: [
                      // LiveNowHighLight(),
                      const SizedBox(height: 20),
                      EventsCarouselPortrait(),
                      const SizedBox(height: 30),
                      SportChips(onTap: widget.onTapSchedule),
                      InformalCarouselPortrait(),
                      GalleryHighLight(onTap: widget.onTap),
                      const SizedBox(height: 30),
                      const MapWidget(),
                      const SizedBox(height: 30),
                      const ContactUs(),
                      const SizedBox(height: 30),
                      Divider(color: darkYellowColor),
                      ConnectWithUs(),
                      Divider(color: darkYellowColor),
                      const SizedBox(height: 20),
                      const CopyrightFooter(),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
