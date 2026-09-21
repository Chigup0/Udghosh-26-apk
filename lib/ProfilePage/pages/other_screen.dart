import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'
    show Neumorphic;
import 'package:udghosh/config/core_team.dart';
import 'package:udghosh/widgets/team_photo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:udghosh/ProfilePage/pages/login_screen.dart';
import 'package:udghosh/ProfilePage/pages/profile_screen.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/services/auth_provider.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/theme/neo_palette.dart';
import 'package:udghosh/config/model_controller.dart';
import 'package:udghosh/config/feature_controller.dart';
import 'package:udghosh/config/nav_style_controller.dart';
import 'package:udghosh/widgets/neo/neo_selectors.dart';
import 'package:udghosh/theme/theme_controller.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: [
            if (auth.isLoggedIn)
              NeoCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.waveInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.name?.isNotEmpty == true
                                ? auth.name!
                                : 'Athlete',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: NeoColors.logoTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.email ?? '',
                            style: TextStyle(
                              color: NeoColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: NeoColors.textMuted,
                    ),
                  ],
                ),
              )
            else
              NeoCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_person_rounded,
                      size: 32,
                      color: NeoColors.waveTeal,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to access personalised schedules & games',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
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
            const _ModelCard(),
            const SizedBox(height: 20),
            const _ExtrasCard(),
            const SizedBox(height: 20),
            const _NavStyleCard(),
            const SizedBox(height: 20),
            const _AppearanceCard(),
            const SizedBox(height: 20),
            NeoCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticesScreen()),
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign_rounded, color: NeoColors.waveTeal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Announcements & Notices',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: NeoColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _CoreTeamSection(),
            // Logout lives on the profile screen — one place only.
            const NavSpacer(),
          ],
        );
      },
    );
  }
}

/// Theme picker.
///
/// Five options don't fit a segmented control, so each is a row with a live
/// swatch of its own canvas / card / accent colours. Listens to
/// [ThemeController] directly; the root widget does the palette swap.
class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final controller = ThemeController.instance;
        return NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: NeoColors.isDark
                        ? HugeIcons.strokeRoundedMoon02
                        : HugeIcons.strokeRoundedSun01,
                    color: NeoColors.violetInk,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Appearance',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                  Text(
                    controller.label,
                    style: TextStyle(fontSize: 12, color: NeoColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final theme in AppTheme.values)
                _ThemeOption(
                  theme: theme,
                  selected: theme == controller.theme,
                  onTap: () => controller.setTheme(theme),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // "System" has no palette of its own, so preview it with whatever the
    // device is currently set to.
    final palette = theme.paletteFor(MediaQuery.platformBrightnessOf(context));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _Swatch(palette: palette),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    theme.description,
                    style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: selected
                  ? HugeIcons.strokeRoundedCheckmarkCircle02
                  : HugeIcons.strokeRoundedCircle,
              color: selected ? NeoColors.waveInk : NeoColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Three-band chip previewing a palette's canvas, card and accent.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.palette});

  final NeoPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 30,
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: NeoColors.textMuted.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 14,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 3),
          Container(
            width: 8,
            height: 14,
            decoration: BoxDecoration(
              color: palette.flameGold,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Core organising committee, collapsed by default.
///
/// The roster is reference material, not something a user needs on every
/// visit — so it opens on demand and each wing expands independently into a
/// two-column grid of member cards.
class _CoreTeamSection extends StatefulWidget {
  const _CoreTeamSection();

  @override
  State<_CoreTeamSection> createState() => _CoreTeamSectionState();
}

class _CoreTeamSectionState extends State<_CoreTeamSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final wings = CoreTeam.wings;

    return NeoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    color: NeoColors.waveInk,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core organizing team',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: NeoColors.logoTeal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CoreTeam.memberCount} members across '
                          '${wings.length} wings',
                          style: TextStyle(
                            fontSize: 11,
                            color: NeoColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      color: NeoColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _open
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final wing in wings) _wingTile(wing),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One wing: a static heading followed by its member grid. There is only
  /// the single outer dropdown now — nothing to expand per wing.
  Widget _wingTile(TeamWing wing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: NeoColors.flameGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    wing.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                ),
                Text(
                  '${wing.members.length}',
                  style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Two columns, gutter removed before dividing so the cards fit
              // whatever width the sheet gives us.
              const gap = 12.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final member in wing.members)
                    SizedBox(
                      width: width,
                      child: _MemberCard(member: member),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

/// A portrait card: photo, name, role, and only the contact actions that
/// member actually published.
class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final TeamMember member;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _action(List<List<dynamic>> icon, Color tone, String target) {
    return GestureDetector(
      onTap: () => _open(target),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: HugeIcon(icon: icon, color: tone, size: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      small: true,
      radius: 18,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The photo sits in its own recess so it reads as inset into the
          // card rather than pasted on top of it.
          Neumorphic(
            style: NeoTheme.insetStyle(radius: 15, depth: -2),
            padding: const EdgeInsets.all(3),
            child: LayoutBuilder(
              builder: (context, constraints) => TeamPhoto(
                member: member,
                size: constraints.maxWidth,
                radius: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: NeoColors.logoTeal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            member.role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: NeoColors.textMuted),
          ),
          if (member.hasAnyContact) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (member.hasPhone)
                  _action(
                    HugeIcons.strokeRoundedCall02,
                    NeoColors.liveInk,
                    'tel:${member.phone}',
                  ),
                if (member.hasEmail)
                  _action(
                    HugeIcons.strokeRoundedMail01,
                    NeoColors.waveInk,
                    'mailto:${member.email}',
                  ),
                if (member.hasLinkedin)
                  _action(
                    HugeIcons.strokeRoundedLinkedin01,
                    NeoColors.violetInk,
                    member.linkedin!,
                  ),
                if (member.hasInstagram)
                  _action(
                    HugeIcons.strokeRoundedInstagram,
                    NeoColors.coralInk,
                    member.instagram!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Model 1 / Model 2 switch.
///
/// Model 2 is a separate shell over the same services and controllers, so
/// switching changes only the presentation.
class _ModelCard extends StatelessWidget {
  const _ModelCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ModelController.instance,
      builder: (context, _) {
        final controller = ModelController.instance;
        return NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedLayers01,
                    color: NeoColors.waveInk,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'App model',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                  Text(
                    controller.model.label,
                    style: TextStyle(fontSize: 12, color: NeoColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NeoSegmentedControl(
                labels: const ['Model 1', 'Model 2'],
                index: controller.isModelTwo ? 1 : 0,
                onChanged: (i) =>
                    controller.setModel(i == 0 ? AppModel.one : AppModel.two),
              ),
              const SizedBox(height: 10),
              Text(
                controller.model.description,
                style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom-bar style switch. The classic dock is the original widget, rendered
/// untouched; liquid glass is the alternative.
class _NavStyleCard extends StatelessWidget {
  const _NavStyleCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NavStyleController.instance,
      builder: (context, _) {
        final controller = NavStyleController.instance;
        return NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDashboardSquare02,
                    color: NeoColors.waveInk,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Navigation bar',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                  Text(
                    controller.style.label,
                    style: TextStyle(fontSize: 12, color: NeoColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NeoSegmentedControl(
                labels: const ['Classic', 'Liquid glass'],
                index: controller.isGlass ? 1 : 0,
                onChanged: (i) => controller.setStyle(
                  i == 0 ? NavStyle.classic : NavStyle.liquidGlass,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.style.description,
                style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Optional extras. Switching one off must leave the app exactly as it was
/// before the feature existed — never half-on.
class _ExtrasCard extends StatelessWidget {
  const _ExtrasCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FeatureController.instance,
      builder: (context, _) {
        final features = FeatureController.instance;
        return NeoCard(
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedMapsLocation01,
                color: NeoColors.waveInk,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus places on map',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Halls, messes, departments and shops from '
                      'OpenStreetMap. Off shows only the fest venues.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: NeoColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Switch.adaptive(
                value: features.campusPlaces,
                onChanged: features.setCampusPlaces,
                activeThumbColor: NeoColors.onGold,
                activeTrackColor: NeoColors.flameGold,
              ),
            ],
          ),
        );
      },
    );
  }
}
