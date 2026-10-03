import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'neo_container.dart';

/// Persistent top app bar shown on every main tab: circular logo mark +
/// stacked wordmark on the left, notification bell + profile avatar on the
/// right.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasUnread = false,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasUnread;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Neumorphic(
              style: NeoTheme.circleStyle(),
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 32,
                height: 32,
                child: ClipOval(
                  child: FractionallySizedBox(
                    widthFactor: 0.74,
                    heightFactor: 0.74,
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.emoji_events_outlined,
                        color: NeoColors.logoTeal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'UDGHOSH ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.logoTeal,
                            letterSpacing: 0.5,
                            height: 1.05,
                          ),
                        ),
                        TextSpan(
                          text: "'26",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.flameGold,
                            letterSpacing: 0.5,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ASCENSION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.waveInk,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            NeoCircleButton(
              onTap: onNotificationTap,
              badge: hasUnread,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedNotification01,
                size: 20,
                color: NeoColors.logoTeal,
              ),
            ),
            const SizedBox(width: 10),
            NeoCircleButton(
              onTap: onProfileTap,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUserCircle,
                size: 20,
                color: NeoColors.logoTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
