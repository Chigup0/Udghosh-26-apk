import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/utils.dart' show appVersion;
import 'package:udghosh/widgets/neo/neo_container.dart';
import 'package:url_launcher/url_launcher.dart';

/// App profile / about screen. There is no account system — every visitor
/// sees the same fest information.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.base,
      appBar: AppBar(
        backgroundColor: NeoColors.base,
        iconTheme: IconThemeData(color: NeoColors.logoTeal),
        title: Text(
          'Profile',
          style: TextStyle(
            color: NeoColors.logoTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 20),
          const _SectionLabel('Shortcuts'),
          _AccentTile(
            icon: Icons.campaign_rounded,
            tint: NeoColors.violet,
            ink: NeoColors.violetInk,
            title: 'Announcements',
            value: 'Latest notices from the organisers',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticesScreen()),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('About'),
          _AccentTile(
            icon: Icons.info_outline_rounded,
            tint: NeoColors.coral,
            ink: NeoColors.coralInk,
            title: 'App version',
            value: appVersion,
          ),
          _AccentTile(
            icon: Icons.privacy_tip_outlined,
            tint: NeoColors.waveTeal,
            ink: NeoColors.waveInk,
            title: 'Privacy Policy',
            value: 'How your data is handled',
            onTap: () => _open(AppConfig.privacyPolicyUrl),
          ),
          _AccentTile(
            icon: Icons.description_outlined,
            tint: NeoColors.flameGold,
            ink: NeoColors.goldInk,
            title: 'Terms & Conditions',
            value: 'Rules for using the app',
            onTap: () => _open(AppConfig.termsAndConditionsUrl),
          ),
        ],
      ),
    );
  }
}

/// Gradient identity card — the one saturated surface in the app, so the
/// profile reads as "yours" rather than as another grey panel.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeoTheme.raisedStyle(radius: NeoRadii.cardLarge),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NeoRadii.cardLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [NeoColors.headerStart, NeoColors.headerEnd],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text('🏆', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Udghosh Sports',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.flameGold,
                      borderRadius: BorderRadius.circular(NeoRadii.pill),
                    ),
                    child: Text(
                      'UDGHOSH \'26',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: NeoColors.onGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: NeoColors.flameGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: NeoColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row with a colour-tinted icon chip. [tint] is decorative; [ink] carries
/// the icon and clears 4.5:1 on the base.
class _AccentTile extends StatelessWidget {
  const _AccentTile({
    required this.icon,
    required this.tint,
    required this.ink,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color ink;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: ink, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NeoColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NeoColors.logoTeal,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: NeoColors.textMuted),
        ],
      ),
    );
  }
}
