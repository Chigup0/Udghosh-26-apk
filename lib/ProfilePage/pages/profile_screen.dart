import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/ProfilePage/pages/login_screen.dart';
import 'package:udghosh/services/auth_provider.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/utils.dart' show appVersion;
import 'package:udghosh/widgets/neo/neo_container.dart';

/// The user's profile.
///
/// Deliberately shows only what the backend actually returns from
/// `/auth/verifyotp` — id, email, name. The festival backend exposes no
/// sport/team/hall fields for a logged-in user, so nothing here is invented.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final auth = AuthController.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _ProfileHeader(auth: auth),
              const SizedBox(height: 20),
              if (!auth.isLoggedIn) ...[
                NeoCard(
                  child: Column(
                    children: [
                      Text(
                        'Sign in to see your athlete profile and get '
                        'personalised schedules.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: NeoColors.logoTeal,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      NeoPillButton(
                        label: 'LOGIN WITH EMAIL OTP',
                        icon: Icons.mail_outline_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                const _SectionLabel('Account'),
                _AccentTile(
                  icon: Icons.alternate_email_rounded,
                  tint: NeoColors.waveTeal,
                  ink: NeoColors.waveInk,
                  title: 'Email',
                  value: auth.email ?? '—',
                ),
                _AccentTile(
                  icon: Icons.badge_rounded,
                  tint: NeoColors.flameGold,
                  ink: NeoColors.goldInk,
                  title: 'Member ID',
                  value: auth.id != null ? '#${auth.id}' : '—',
                ),
                const SizedBox(height: 20),
              ],
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
              if (auth.isLoggedIn) ...[
                const SizedBox(height: 28),
                NeoPillButton(
                  label: 'LOGOUT',
                  icon: Icons.logout_rounded,
                  background: NeoColors.base,
                  foreground: NeoColors.alert,
                  onTap: () => auth.logout(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Gradient identity card — the one saturated surface in the app, so the
/// profile reads as "yours" rather than as another grey panel.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final name = (auth.name?.trim().isNotEmpty ?? false)
        ? auth.name!
        : (auth.isLoggedIn ? 'Athlete' : 'Guest');

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
              child: Text(
                auth.isLoggedIn ? auth.initials : '?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.logoTeal,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.isLoggedIn ? (auth.email ?? '') : 'Not signed in',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  if (auth.isLoggedIn) ...[
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
