import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:udghosh/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:math';

List<String> splitName(String name) => name.split(' ');

Widget customText(
  String text,
  double fontSize,
  FontWeight fontWeight,
  Color color,
  double? height,
) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: globalFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1,
    ),
    overflow: TextOverflow.ellipsis,
  );
}

Widget pageTitleText(String text) {
  return customText(text, 42, FontWeight.w600, lightTextColor, 1);
}

class OctagonClipper extends CustomClipper<Path> {
  final double padding;
  OctagonClipper({required this.padding});
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    // const double padding = 20; // Adjust this value to modify the octagon cut

    path.moveTo(0, 0); // Top-left cut
    path.lineTo(width - padding, 0); // Top-right cut
    path.lineTo(width, padding); // Right-top cut
    path.lineTo(width, height); // Right-bottom cut
    path.lineTo(padding, height); // Bottom-left cut
    path.lineTo(0, height - padding); // Left-bottom cut
    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget setScore(String setCount, String score1, String score2) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: customText(
            "Set $setCount",
            11,
            FontWeight.w700,
            Colors.grey.shade800,
            1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              customText(
                score1,
                14,
                FontWeight.w700,
                Colors.grey.shade800,
                1.4,
              ),
              customText(" : ", 13, FontWeight.w700, Colors.grey.shade700, 1.4),
              customText(score2, 14, FontWeight.w700, Colors.grey.shade800, 1),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget setScore2(String setCount, String score1, String score2) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: customText(
            setCount,
            11,
            FontWeight.w700,
            Colors.grey.shade800,
            1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              customText(
                score1,
                14,
                FontWeight.w700,
                Colors.grey.shade800,
                1.4,
              ),
              customText(" : ", 13, FontWeight.w700, Colors.grey.shade700, 1.4),
              customText(score2, 14, FontWeight.w700, Colors.grey.shade800, 1),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget score2(String score1, String score2) {
  return Container(
    width: 100,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        customText(score1, 14, FontWeight.w900, Colors.grey.shade900, 1.4),
        customText(" : ", 13, FontWeight.w700, Colors.grey.shade700, 1.4),
        customText(score2, 14, FontWeight.w900, Colors.grey.shade900, 1.4),
      ],
    ),
  );
}

void errorSnackMsg(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void successSnackMsg(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void enlargeCoreTeamCard(BuildContext context, dynamic data) {
  List<String> names = splitName(data['Name'] ?? 'Unknown');
  String linkedinUrl = data['Linkedin'] ?? 'na';
  String phoneNumber = data['phone'] ?? 'na';
  String email = data['Email'] ?? 'na';

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E), // dark background
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: data['img'],
                  imageBuilder: (context, imageProvider) => Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(child: Image(image: imageProvider)),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),

                // Profile picture with neon glow
                const SizedBox(height: 20),

                // Name
                Text(
                  names.join(' ').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Position
                Text(
                  formatName(data['Position'] ?? 'Unknown'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent.shade200,
                  ),
                ),
                const SizedBox(height: 10),

                // Email
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['Email'] ?? 'N/A',
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Social buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (instagramUrl != 'na')
                    //   _socialButton(
                    //     icon: FontAwesomeIcons.instagram,
                    //     gradient: const LinearGradient(
                    //       colors: [Color(0xFF833AB4), Color(0xFFFCAF45)],
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //     ),
                    //     url: instagramUrl,
                    //   ),
                    // if (facebookUrl != 'na') const SizedBox(width: 16),
                    // if (facebookUrl != 'na')
                    //   _socialButton(
                    //     icon: FontAwesomeIcons.facebook,
                    //     gradient: const LinearGradient(
                    //       colors: [Colors.blue, Colors.lightBlueAccent],
                    //     ),
                    //     url: facebookUrl,
                    //   ),
                    if (linkedinUrl != 'na') const SizedBox(width: 16),
                    if (linkedinUrl != 'na')
                      _socialButton(
                        icon: FontAwesomeIcons.linkedin,
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlue],
                        ),
                        url: linkedinUrl,
                      ),
                    if (phoneNumber != 'na') const SizedBox(width: 16),
                    if (phoneNumber != 'na')
                      _socialButton(
                        icon: FontAwesomeIcons.phone,
                        gradient: const LinearGradient(
                          colors: [Colors.greenAccent, Colors.lightGreen],
                        ),
                        url: phoneNumber,
                      ),
                    if (email != 'na') const SizedBox(width: 16),
                    if (email != 'na')
                      _socialButton(
                        icon: FontAwesomeIcons.envelope,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 240, 105, 105),
                            Color.fromARGB(255, 195, 74, 74),
                          ],
                        ),
                        url: email,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _socialButton({
  required IconData icon,
  required LinearGradient gradient,
  required String url,
}) {
  return GestureDetector(
    onTap: () async {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (url.startsWith(RegExp(r'^\+?[0-9]{7,15}$'))) {
        await launchUrl(Uri.parse("tel:$url"));
      } else {
        await launchUrl(Uri.parse("mailto:$url"));
      }
    },
    child: Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 22)),
    ),
  );
}

// Example formatName function
String formatName(String name) {
  return name.toUpperCase();
}

Widget mediaIcons(IconData icon, Color iconColor, double iconSize, String url) {
  return Container(
    alignment: Alignment.center,
    width: 40,
    height: 40,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: InkWell(
      onTap: () {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: Icon(icon, color: iconColor, size: iconSize),
    ),
  );
}

class TeamLogo extends StatelessWidget {
  final String teamName;
  final double size;
  final Color? ringColor;

  const TeamLogo({
    super.key,
    required this.teamName,
    this.size = 64,
    this.ringColor,
  });

  /// Predefined gradient palettes (vibrant + sporty)
  static final List<List<Color>> _palettes = [
    [Colors.blue.withAlpha(180), Colors.indigo.withAlpha(180)],
    [Colors.orange.withAlpha(180), Colors.deepOrangeAccent.withAlpha(180)],
    [Colors.green.withAlpha(180), Colors.teal.withAlpha(180)],
    [Colors.purple.withAlpha(180), Colors.deepPurpleAccent.withAlpha(180)],
    [Colors.red.withAlpha(180), Colors.pink.withAlpha(180)],
    [Colors.cyan.withAlpha(180), Colors.blueAccent.withAlpha(180)],
    [Colors.amber.withAlpha(180), Colors.deepOrange.withAlpha(180)],
  ];

  /// Deterministic gradient based on team name
  LinearGradient _generateGradient(String name) {
    final hash = name.codeUnits.fold(0, (prev, c) => prev + c);
    final index = hash % _palettes.length;
    final colors = _palettes[index];

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter = teamName.isNotEmpty ? teamName[0].toUpperCase() : "?";

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _generateGradient(teamName),
        border: Border.all(
          color: ringColor ?? Color.fromARGB(255, 22, 104, 255),
          width: size * 0.05,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft inner glow highlight
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.25), Colors.transparent],
                radius: 0.8,
                center: Alignment.topLeft,
              ),
            ),
          ),

          // Team letter
          Text(
            firstLetter,
            style: TextStyle(
              fontFamily: globalFontFamily,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
