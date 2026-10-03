import 'package:flutter/painting.dart';

/// One member of the core organising team.
class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    this.photo,
    this.phone,
    this.email,
    this.linkedin,
    this.instagram,
    this.hidden = false,
    this.alignment = Alignment.center,
    this.scale = 1,
  });

  final String name;
  final String role;
  final String? photo;
  final String? phone;
  final String? email;
  final String? linkedin;
  final String? instagram;

  /// Mirrors the `hidden` flag on the source roster. Hidden members are not
  /// rendered anywhere — see [CoreTeam.wings].
  final bool hidden;

  /// Crop focus and zoom for [photo], carried over from the website's
  /// `imageStyle` (`object-position` / `transform: scale(...)`). Headshots in
  /// the roster are framed inconsistently, so a few need nudging.
  final Alignment alignment;
  final double scale;

  bool get hasPhoto => (photo?.isNotEmpty ?? false);
  bool get hasPhone => (phone?.isNotEmpty ?? false);
  bool get hasEmail => (email?.isNotEmpty ?? false);
  bool get hasLinkedin => (linkedin?.isNotEmpty ?? false);
  bool get hasInstagram => (instagram?.isNotEmpty ?? false);

  bool get hasAnyContact => hasPhone || hasEmail || hasLinkedin || hasInstagram;

  /// First letter, for the fallback avatar when a photo is missing or fails.
  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// A wing of the organising team.
class TeamWing {
  const TeamWing({required this.id, required this.name, required this.members});

  final String id;
  final String name;
  final List<TeamMember> members;

  List<TeamMember> get visibleMembers =>
      members.where((m) => !m.hidden).toList();
}

/// The Udghosh '26 core organising team.
///
/// Transcribed verbatim from the fest's roster — names, photos, phone numbers,
/// emails and social links are all as supplied. Two rules are applied when
/// rendering:
///
/// * a member marked `hidden` in the roster is never shown, and
/// * a wing whose every member is hidden drops out of the list entirely.
///
/// [wings] already has both applied, so callers just render what they get.
class CoreTeam {
  CoreTeam._();

  /// Visible wings only — hidden members and emptied wings are filtered out.
  static List<TeamWing> get wings => _all
      .map((w) => TeamWing(id: w.id, name: w.name, members: w.visibleMembers))
      .where((w) => w.members.isNotEmpty)
      .toList();

  static int get memberCount =>
      wings.fold(0, (sum, wing) => sum + wing.members.length);

  static const List<TeamWing> _all = [
    TeamWing(
      id: 'teams-about-hospi',
      name: 'Hospitality',
      members: [
        TeamMember(
          name: 'Abhishek',
          role: 'Head',
          hidden: true,
          photo:
              'https://live.staticflickr.com/65535/55426699563_f4d0e1fee3_b.jpg',
          phone: '9927860926',
          email: 'sabhishekk23@iitk.ac.in',
        ),
        TeamMember(
          name: 'Suresh',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426555533_1db42ce5e9_b.jpg',
          phone: '7817940441',
          email: 'skmeena23@iitk.ac.in',
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-enc',
      name: 'Events & Competitions',
      members: [
        TeamMember(
          name: 'Amlan',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426825400_f88fb37810_b.jpg',
          phone: '7377093140',
          email: 'amlancd23@iitk.ac.in',
          // Full-body shot with the face near the top — bottomCenter + a 2x
          // zoom cropped the head out entirely. Framed on the top instead.
          alignment: Alignment.topCenter,
          scale: 1.3,
        ),
        TeamMember(
          name: 'Anshika',
          role: 'Head',
          hidden: true,
          photo:
              'https://live.staticflickr.com/65535/55426597179_27bfaa359d_b.jpg',
          phone: '6395485144',
          email: 'anshikam23@iitk.ac.in',
          alignment: Alignment.bottomCenter,
          scale: 2,
        ),
        TeamMember(
          name: 'Yuvraj',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426466966_faa2c383fe_z.jpg',
          phone: '8177001974',
          email: 'yuvraj23@iitk.ac.in',
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-mark',
      name: 'Marketing',
      members: [
        TeamMember(
          name: 'Aryan',
          role: 'Head',
          hidden: true,
          photo:
              'https://live.staticflickr.com/65535/55426597114_1d9a99ec13_b.jpg',
          phone: '8273695084',
          email: 'aryans23@iitk.ac.in',
        ),
        TeamMember(
          name: 'Amey',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426725814_14b2900efc_b.jpg',
          phone: '6387465054',
        ),
        TeamMember(
          name: 'Darshan',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426555643_4b55927d7d_b.jpg',
          phone: '9777751168',
          email: 'darshann23@iitk.ac.in',
          alignment: Alignment.bottomCenter,
          scale: 2,
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-pr',
      name: 'Public Relations',
      members: [
        TeamMember(
          name: 'Khush Maheshwari',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55465572983_c985c897cd_b.jpg',
          phone: '8949036446',
          // Transcribed as-is from the roster; note "itk" rather than "iitk".
          email: 'khushmahes23@itk.ac.in',
          linkedin: 'https://www.linkedin.com/in/khush-maheshwari-031187274/',
          instagram: 'https://www.instagram.com/_maheshwari_khush_/',
        ),
        TeamMember(
          name: 'Divyanshi',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426427051_70c289814a_b.jpg',
          phone: '9454030437',
          email: 'divyanshi23@iitk.ac.in',
          linkedin: 'https://www.linkedin.com/in/divyanshi-porwal-163b012b1',
          scale: 1.5,
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-wna',
      name: 'Web & App',
      members: [
        TeamMember(
          name: 'Yash',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426584153_83e73f789a_b.jpg',
          phone: '6262486147',
          email: 'yashd24@iitk.ac.in',
        ),
        TeamMember(
          name: 'Chirag Gupta',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426555633_6da4c9a6f7_b.jpg',
          phone: '8630969755',
          email: 'chiragg24@iitk.ac.in',
          alignment: Alignment(0, -0.6),
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-design',
      name: 'Design',
      members: [
        TeamMember(
          name: 'Om',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/54820124016_f82dd1a8f2_w.jpg',
          alignment: Alignment(0, -0.7),
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-mnp',
      name: 'Media & Publicity',
      members: [
        TeamMember(
          name: 'Suyash',
          role: 'Head',
          hidden: true,
          photo:
              'https://live.staticflickr.com/65535/55426597069_edaa1704c8_b.jpg',
          phone: '8989409477',
          email: 'psuyash23@iitk.ac.in',
        ),
        TeamMember(
          name: 'Muskan',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55425651397_345a5b2184_z.jpg',
          phone: '9024692887',
          email: 'kmuskan23@iitk.ac.in',
          linkedin: 'https://www.linkedin.com/in/muskan-gupta-284065261',
          alignment: Alignment(-0.8, -1),
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-sm',
      name: 'Show Management',
      members: [
        TeamMember(
          name: 'Lokesh',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426597004_c5084bfa8a_b.jpg',
          phone: '7673921276',
          email: 'glokesh23@iitk.ac.in',
          // Narrow full-body portrait — a centred square crop lands entirely
          // below the head. Framed on the top so the face is included.
          alignment: Alignment.topCenter,
        ),
        TeamMember(
          name: 'Mohith Varma',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55425457037_bd600d294d_b.jpg',
          phone: '8328520134',
          email: 'mohithv23@iitk.ac.in',
        ),
        TeamMember(
          name: 'Raghubir Kumar',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426596979_232220763b_b.jpg',
          phone: '6205929998',
          email: 'raghubirk23@iitk.ac.in',
          // Same narrow full-body framing as Lokesh's — top-align to keep
          // the face in the crop.
          alignment: Alignment.topCenter,
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-fin',
      name: 'Finance',
      members: [
        TeamMember(
          name: 'Ayush Rajput',
          role: 'Head',
          photo:
              'https://live.staticflickr.com/65535/55426555573_fec5851826_b.jpg',
          phone: '7024812198',
          email: 'arajput23@iitk.ac.in',
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-sec',
      name: 'Security',
      members: [
        TeamMember(
          name: 'Harshavardan',
          role: 'Head',
          hidden: true,
          photo:
              'https://live.staticflickr.com/65535/55425457052_23b1e0d599_b.jpg',
          phone: '9369567314',
          email: 'harshabs23@iitk.ac.in',
          linkedin: 'https://www.linkedin.com/in/harshavardan-yadav-037130282',
          scale: 2,
        ),
      ],
    ),
    TeamWing(
      id: 'teams-about-fc',
      name: 'Festival Coordinators',
      members: [
        TeamMember(
          name: 'Sparsh',
          role: 'Festival Coordinator',
          photo:
              'https://live.staticflickr.com/65535/55426427001_488fc2aaf4_b.jpg',
          phone: '9140599972',
          email: 'sparshg23@iitk.ac.in',
        ),
      ],
    ),
  ];
}
