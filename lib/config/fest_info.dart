import 'package:hugeicons/hugeicons.dart';

/// A campus helpline shown in the Home footer.
class EmergencyContact {
  const EmergencyContact(this.label, this.number, this.icon);

  final String label;
  final String number;
  final List<List<dynamic>> icon;

  /// `tel:` target. Numbers are stored exactly as dialled on campus.
  String get dialUri => 'tel:$number';
}

/// An official fest channel.
class FestChannel {
  const FestChannel(this.label, this.url, this.icon);

  final String label;
  final String url;
  final List<List<dynamic>> icon;
}

/// Contact details and official channels for the fest.
///
/// These values are carried over verbatim from the previous release's
/// `ContactUs` / `ConnectWithUs` widgets — they are the real campus helplines
/// and the real fest accounts, not placeholders. Verify them with the
/// organising team before each edition, since helpline numbers do change.
class FestInfo {
  FestInfo._();

  static const List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      'Campus Security',
      '5126797999',
      HugeIcons.strokeRoundedShield01,
    ),
    EmergencyContact(
      'Health Centre',
      '5126797769',
      HugeIcons.strokeRoundedHospital01,
    ),
    EmergencyContact(
      'Gender Cell (1)',
      '8247276839',
      HugeIcons.strokeRoundedCall02,
    ),
    EmergencyContact(
      'Gender Cell (2)',
      '9257009192',
      HugeIcons.strokeRoundedCall02,
    ),
  ];

  static const List<FestChannel> channels = [
    FestChannel(
      'Website',
      'https://udghosh.org.in/',
      HugeIcons.strokeRoundedGlobal,
    ),
    FestChannel(
      'Instagram',
      'https://www.instagram.com/udghosh_iitk/',
      HugeIcons.strokeRoundedInstagram,
    ),
    FestChannel(
      'YouTube',
      'https://www.youtube.com/@Udghoshiitk/featured',
      HugeIcons.strokeRoundedYoutube,
    ),
    FestChannel(
      'LinkedIn',
      'https://in.linkedin.com/company/udghosh-iit-kanpur-fest',
      HugeIcons.strokeRoundedLinkedin01,
    ),
    FestChannel(
      'Facebook',
      'https://www.facebook.com/udghosh.iitk/',
      HugeIcons.strokeRoundedFacebook01,
    ),
    FestChannel(
      'WhatsApp',
      'https://whatsapp.com/channel/0029Vb5lN5wHQbS9nLwj9A0d',
      HugeIcons.strokeRoundedWhatsapp,
    ),
  ];
}
