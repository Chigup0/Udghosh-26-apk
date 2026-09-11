import 'package:flutter/material.dart';
import 'package:udghosh/ProfilePage/pages/login_screen.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/services/auth_provider.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

class _TeamMember {
  const _TeamMember(this.name, this.role);
  final String name;
  final String role;
}

const _wings = <String, List<_TeamMember>>{
  'Festival Leads': [
    _TeamMember('Aarav Sharma', 'Overall Coordinator'),
    _TeamMember('Diya Mehta', 'Overall Coordinator'),
  ],
  'Events': [
    _TeamMember('Kabir Singh', 'Events Head'),
    _TeamMember('Ananya Rao', 'Events Head'),
  ],
  'Media & Web Operations': [
    _TeamMember('Rohan Gupta', 'Web & App Lead'),
    _TeamMember('Ishita Verma', 'Media Coordinator'),
  ],
};

/// "Other" tab: account/profile card, core team roster, notices link,
/// logout.
class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (auth.isLoggedIn)
              NeoCard(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceRecessed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        auth.initials,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: NeoColors.waveTeal),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.name?.isNotEmpty == true ? auth.name! : 'Athlete',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: NeoColors.logoTeal),
                          ),
                          const SizedBox(height: 2),
                          Text(auth.email ?? '', style: TextStyle(color: NeoColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              NeoCard(
                child: Column(
                  children: [
                    const Icon(Icons.lock_person_rounded, size: 32, color: NeoColors.waveTeal),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in to access personalised schedules & games',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, color: NeoColors.logoTeal),
                    ),
                    const SizedBox(height: 14),
                    NeoPillButton(
                      label: 'LOGIN WITH EMAIL OTP',
                      icon: Icons.mail_outline_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            NeoCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticesScreen()),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign_rounded, color: NeoColors.waveTeal),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Announcements & Notices', style: TextStyle(fontWeight: FontWeight.w700, color: NeoColors.logoTeal)),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: NeoColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CORE ORGANIZING COMMITTEE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: NeoColors.textMuted, letterSpacing: 0.6),
            ),
            const SizedBox(height: 12),
            for (final wing in _wings.entries) ...[
              Text(
                wing.key,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: NeoColors.logoTeal),
              ),
              const SizedBox(height: 8),
              for (final member in wing.value)
                NeoCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(color: NeoColors.surfaceRecessed, shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded, color: NeoColors.waveTeal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700, color: NeoColors.logoTeal)),
                            Text(member.role, style: TextStyle(fontSize: 12, color: NeoColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.link_rounded, color: NeoColors.textMuted, size: 18),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
            if (auth.isLoggedIn) ...[
              const SizedBox(height: 12),
              NeoPillButton(
                label: 'LOGOUT',
                icon: Icons.logout_rounded,
                background: NeoColors.alert.withValues(alpha: 0.12),
                foreground: NeoColors.alert,
                onTap: () => auth.logout(),
              ),
            ],
          ],
        );
      },
    );
  }
}
