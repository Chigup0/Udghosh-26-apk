import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

const String appVersion = "22.0.3";

bool expanded = true;
bool dark = false;
bool isStaff = false;
// bool isFirstLaunch = true;
Color whiteColor = const Color.fromRGBO(255, 255, 255, 1);
Color yellowColor = const Color.fromARGB(255, 45, 99, 235);
Color darkYellowColor = const Color.fromARGB(255, 45, 48, 200);
Color blueColor = const Color.fromRGBO(140, 223, 229, 1);
Color darkBlueColor = const Color.fromRGBO(31, 69, 107, 1);
String globalFontFamily = GoogleFonts.exo2().fontFamily!;
Color lightTextColor = const Color.fromARGB(255, 255, 255, 255);
BoxDecoration containerDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
    colors: [
      const Color.fromARGB(255, 3, 1, 6), // pure void black
      const Color.fromARGB(255, 4, 38, 102), // midnight blue core
      const Color.fromARGB(255, 3, 1, 6), // pure void black
    ],
    stops: [0.1, 0.5, 0.9], // Optional: control color distribution
  ),
);

String formatName(String name) {
  return name
      .split(' ')
      .map((word) {
        if (word.isNotEmpty) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }
        return word;
      })
      .join(' ');
}

List<Map<String, dynamic>> sportsList = [
  // {"name": "Athletics", "icon": Icons.directions_run},
  // {"name": "Aquatics", "icon": Icons.pool},
  // {"name": "Weight Lifting", "icon": Icons.fitness_center},
  // {"name": "PowerLifting", "icon": Icons.fitness_center},
  {"name": "Badminton", "icon": Icons.sports_tennis},
  {"name": "Basketball", "icon": Icons.sports_basketball},
  {"name": "Chess", "icon": FontAwesome.chess_board_solid}, // Use icons_plus
  {"name": "Cricket", "icon": Icons.sports_cricket},
  {"name": "Football", "icon": Icons.sports_soccer},
  {"name": "Hockey", "icon": Icons.sports_hockey},
  {"name": "Kabaddi", "icon": Icons.sports_handball}, // closest match
  {
    "name": "Kho-kho",
    "icon": FontAwesome.person_running_solid,
  }, // no direct icon
  {"name": "LawnTennis", "icon": Icons.sports_tennis},
  {"name": "Squash", "icon": Icons.sports_tennis}, // reuse tennis icon
  {"name": "TableTennis", "icon": Icons.sports_tennis},
  {"name": "Taekwondo", "icon": Icons.sports_martial_arts}, // use icons_plus
  {"name": "UltimateFrisbee", "icon": FontAwesome.circle}, // no direct icon
  {"name": "Volleyball", "icon": Icons.sports_volleyball},
];

final List<String> imageLinks = [
  "https://live.staticflickr.com/65535/54813588518_6232dc7e45_w.jpg",
  "https://live.staticflickr.com/65535/54813673185_37c07803be_w.jpg",
  "https://live.staticflickr.com/65535/54813589849_0455dd2082_w.jpg",
  "https://live.staticflickr.com/65535/54812486077_95de239d52_w.jpg",
  "https://live.staticflickr.com/65535/54813589904_64ff8a26e1_w.jpg",
  "https://live.staticflickr.com/65535/54813589969_4c37853550_w.jpg",
  "https://live.staticflickr.com/65535/54812486052_836b5dc6d4_w.jpg",
  "https://live.staticflickr.com/65535/54813673290_e1b6b59c51_w.jpg",
  "https://live.staticflickr.com/65535/54813606238_abe93e855a_w.jpg",
  "https://live.staticflickr.com/65535/54813349191_6f0e3cfb9b_w.jpg",
  "https://live.staticflickr.com/65535/54813606338_ef97dd4fd1_w.jpg",
  "https://live.staticflickr.com/65535/54813606038_83d438a1f7_w.jpg",
  "https://live.staticflickr.com/65535/54813348951_4033b79ba1_w.jpg",
  "https://live.staticflickr.com/65535/54812503872_3e178127d6_w.jpg",
  "https://live.staticflickr.com/65535/54813348836_ba83951875_w.jpg",
];

Map<String, String> locationVenueMap = {
  // Existing mappings
  'cricket': "https://maps.app.goo.gl/qWAPavBtsb7KCsYb9",
  'volleyball': "https://maps.app.goo.gl/N1Wifb1BHsvNWGR8A",
  'basketball': 'https://maps.app.goo.gl/6sn6m9muKxZHhYoN7',
  'lawntennis': "https://maps.app.goo.gl/YLZz5zWsPFpyZ6wR8",
  'hockey': "https://maps.app.goo.gl/uHzKub8eMjU5ELnKA",
  'tabletennis': "https://maps.app.goo.gl/mS963wEW1xnDaKxb8",
  'athletics': "https://maps.app.goo.gl/YOUR_ATHLETICS_URL",
  'aquatics': "https://maps.app.goo.gl/YOUR_AQUATICS_URL",
  'badminton': "https://maps.app.goo.gl/YOUR_BADMINTON_URL",
  'chess': "https://maps.app.goo.gl/YOUR_CHESS_URL",
  'football': "https://maps.app.goo.gl/YOUR_FOOTBALL_URL",
  'weight lifting': "https://maps.app.goo.gl/YOUR_WEIGHTLIFTING_URL",
  'kabaddi': "https://maps.app.goo.gl/YOUR_KABADDI_URL",
  'kho-kho': "https://maps.app.goo.gl/YOUR_KHOKHO_URL",
  'powerlifting': "https://maps.app.goo.gl/YOUR_POWERLIFTING_URL",
  'squash': "https://maps.app.goo.gl/YOUR_SQUASH_URL",
  'taekwondo': "https://maps.app.goo.gl/YOUR_TAEKWONDO_URL",
  'ultimatefrisbee': "https://maps.app.goo.gl/YOUR_FRISBEE_URL",
};

// Helper function to normalize sport names for map lookup
String normalizeSportName(String? sport) {
  if (sport == null) return '';
  return sport.toLowerCase().trim();
}
