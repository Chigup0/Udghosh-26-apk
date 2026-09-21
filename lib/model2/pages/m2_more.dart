import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/NoticePage/pages/notices_screen.dart';
import 'package:udghosh/ProfilePage/pages/login_screen.dart';
import 'package:udghosh/ProfilePage/pages/profile_screen.dart';
import 'package:udghosh/config/core_team.dart';
import 'package:udghosh/config/feature_controller.dart';
import 'package:udghosh/config/model_controller.dart';
import 'package:udghosh/config/nav_style_controller.dart';
import 'package:udghosh/model2/theme/m2_style.dart';
import 'package:udghosh/model2/widgets/m2_widgets.dart';
import 'package:udghosh/services/auth_provider.dart';
import 'package:udghosh/theme/neo_palette.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/theme/theme_controller.dart';
import 'package:udghosh/utils.dart' show appVersion;
import 'package:udghosh/widgets/team_photo.dart';
import 'package:url_launcher/url_launcher.dart';

/// Model 2 "More" — account, model switch, theme picker, team, about.
class M2More extends StatelessWidget {
  const M2More({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          children: [
            M2Plinth(
              onTap: auth.isLoggedIn
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    )
                  : null,
              child: Row(
                children: [
                  Neumorphic(
                    style: M2.knob(depth: M2.cardDepth),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: Center(
                        child: Text(
                          auth.isLoggedIn ? auth.initials : '?',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.waveInk,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isLoggedIn
                              ? (auth.name?.isNotEmpty == true
                                    ? auth.name!
                                    : 'Athlete')
                              : 'Guest',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: NeoColors.logoTeal,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          auth.isLoggedIn
                              ? (auth.email ?? '')
                              : 'Not signed in',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: NeoColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (auth.isLoggedIn)
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight02,
                      color: NeoColors.textMuted,
                      size: 17,
                    ),
                ],
              ),
            ),
            if (!auth.isLoggedIn) ...[
              const SizedBox(height: 12),
              NeumorphicButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: M2.pill(selected: false, color: NeoColors.charcoal),
                minDistance: M2.pressed,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Text(
                    'LOGIN WITH EMAIL OTP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: NeoColors.onCharcoal,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            const M2SectionTitle('App model'),
            const M2ModelCard(),
            const SizedBox(height: 22),
            const M2SectionTitle('Extras'),
            const _M2ExtrasCard(),
            const SizedBox(height: 22),
            const M2SectionTitle('Navigation bar'),
            const _M2NavStyleCard(),
            const SizedBox(height: 22),
            const M2SectionTitle('Appearance'),
            const _M2ThemeCard(),
            const SizedBox(height: 22),
            const M2SectionTitle('Fest'),
            M2Plinth(
              radius: M2.rCard,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticesScreen()),
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMegaphone01,
                    color: NeoColors.waveInk,
                    size: 19,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'Announcements & Notices',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight02,
                    color: NeoColors.textMuted,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _M2CoreTeam(),
            const SizedBox(height: 22),
            Center(
              child: Text(
                'Version $appVersion',
                style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
              ),
            ),
            const NavSpacer(),
          ],
        );
      },
    );
  }
}

/// Model 1 / Model 2 switch. Shared by both shells so either can hand back.
class M2ModelCard extends StatelessWidget {
  const M2ModelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ModelController.instance,
      builder: (context, _) {
        final controller = ModelController.instance;
        return M2Plinth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Two complete interfaces over the same data. Switching changes '
                'only how things look — never what the app does.',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: NeoColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              M2Switch(
                labels: const ['Model 1', 'Model 2'],
                index: controller.isModelTwo ? 1 : 0,
                onChanged: (i) =>
                    controller.setModel(i == 0 ? AppModel.one : AppModel.two),
              ),
              const SizedBox(height: 10),
              Text(
                controller.model.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _M2ThemeCard extends StatelessWidget {
  const _M2ThemeCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final controller = ThemeController.instance;
        return M2Plinth(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (final theme in AppTheme.values)
                GestureDetector(
                  onTap: () => controller.setTheme(theme),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        _Swatch(
                          palette: theme.paletteFor(
                            MediaQuery.platformBrightnessOf(context),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theme.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: NeoColors.logoTeal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                theme.description,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: NeoColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        HugeIcon(
                          icon: theme == controller.theme
                              ? HugeIcons.strokeRoundedCheckmarkCircle02
                              : HugeIcons.strokeRoundedCircle,
                          color: theme == controller.theme
                              ? NeoColors.waveInk
                              : NeoColors.textMuted,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

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

class _M2CoreTeam extends StatefulWidget {
  const _M2CoreTeam();

  @override
  State<_M2CoreTeam> createState() => _M2CoreTeamState();
}

class _M2CoreTeamState extends State<_M2CoreTeam> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final wings = CoreTeam.wings;

    return M2Plinth(
      radius: M2.rCard,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    color: NeoColors.waveInk,
                    size: 19,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core organizing team',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: NeoColors.logoTeal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CoreTeam.memberCount} members · '
                          '${wings.length} wings',
                          style: TextStyle(
                            fontSize: 10.5,
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
                      size: 17,
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

  /// One wing: a static heading followed by its member grid. Only the single
  /// outer dropdown remains — no per-wing toggles.
  Widget _wingTile(TeamWing wing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 3,
                  decoration: BoxDecoration(
                    color: NeoColors.flameGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    wing.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1,
                      color: NeoColors.logoTeal,
                    ),
                  ),
                ),
                Text(
                  '${wing.members.length}',
                  style: TextStyle(fontSize: 10.5, color: NeoColors.textMuted),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final member in wing.members)
                    SizedBox(
                      width: width,
                      child: _M2MemberCard(member: member),
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

/// Model 2 member card — the photo is sunk into a well, the name and role sit
/// on the plinth above it, and each published contact becomes a small knob.
class _M2MemberCard extends StatelessWidget {
  const _M2MemberCard({required this.member});

  final TeamMember member;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _action(List<List<dynamic>> icon, Color tone, String target) {
    return GestureDetector(
      onTap: () => _open(target),
      child: Neumorphic(
        style: M2.knob(depth: M2.chipKnobDepth),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: HugeIcon(icon: icon, color: tone, size: 13),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: M2.plinth(radius: 20, depth: M2.cardDepth),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          M2Well(
            radius: 16,
            padding: const EdgeInsets.all(4),
            child: LayoutBuilder(
              builder: (context, constraints) => TeamPhoto(
                member: member,
                size: constraints.maxWidth,
                radius: 13,
              ),
            ),
          ),
          const SizedBox(height: 11),
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
          const SizedBox(height: 3),
          Text(
            member.role.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: NeoColors.textMuted,
            ),
          ),
          if (member.hasAnyContact) ...[
            const SizedBox(height: 11),
            Wrap(
              spacing: 7,
              runSpacing: 7,
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

/// Bottom-bar style switch, in Model 2's own vocabulary.
class _M2NavStyleCard extends StatelessWidget {
  const _M2NavStyleCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NavStyleController.instance,
      builder: (context, _) {
        final controller = NavStyleController.instance;
        return M2Plinth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              M2Switch(
                labels: const ['Classic', 'Liquid glass'],
                index: controller.isGlass ? 1 : 0,
                onChanged: (i) => controller.setStyle(
                  i == 0 ? NavStyle.classic : NavStyle.liquidGlass,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.style.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: NeoColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Optional extras, in Model 2's vocabulary.
class _M2ExtrasCard extends StatelessWidget {
  const _M2ExtrasCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FeatureController.instance,
      builder: (context, _) {
        final features = FeatureController.instance;
        return M2Plinth(
          child: Row(
            children: [
              M2Well(
                radius: 13,
                padding: const EdgeInsets.all(10),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedMapsLocation01,
                  color: NeoColors.waveInk,
                  size: 19,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus places on map',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'OpenStreetMap halls, messes and departments. '
                      'Off shows only the fest venues.',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
                        color: NeoColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
